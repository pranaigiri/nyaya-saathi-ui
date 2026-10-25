import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/advocate.dart';
import '../../models/legal_aid_application.dart';
import '../../models/draft_application_model.dart';
import '../../core/utils/tracking_number_formatter.dart';
import '../../core/utils/phone_utils.dart';
import '../../core/services/device_id_service.dart';

class ApplicationException implements Exception {
  final String code; // 'RATE_LIMITED' | 'INVALID_INPUT' | 'TRY_AGAIN'
  final String message;
  final int retryAfterMinutes;

  const ApplicationException({
    required this.code,
    required this.message,
    this.retryAfterMinutes = 10,
  });

  bool get isRateLimited => code == 'RATE_LIMITED';

  @override
  String toString() => message;
}

class ApplicationRepository {
  SupabaseClient get _client => Supabase.instance.client;

  static const String _applicationSelectFields =
      '*, legal_aid_category(category_name), case_type_master(case_type_name), advocate_master:assigned_advocate_id(*), applicant_district:applicant_district_id(district_name), current_district:current_district_id(district_name)';

  /// Submit a new legal aid application from a draft.
  ///
  /// For logged-in users, directly inserts to `legal_aid_application`.
  /// For guest (unauthenticated) users, invokes the `submit-application` Edge Function (mode FULL).
  Future<LegalAidApplication> submitApplication(
    DraftApplicationModel draft, {
    String? applicantId,
    String? deviceId,
    int? clientElapsedMs,
  }) async {
    final effectiveApplicantId = applicantId ?? _client.auth.currentUser?.id;

    final insertData = <String, dynamic>{
      if (effectiveApplicantId != null && effectiveApplicantId.isNotEmpty)
        'applicant_id': effectiveApplicantId,
      'category_id': draft.categoryId,
      'applicant_full_name': draft.fullName,
      'applicant_phone_number': draft.phone,
      'applicant_dob': draft.dob,
      'applicant_gender': draft.gender.toUpperCase(),
      'village_or_town': draft.villageTown.isNotEmpty ? draft.villageTown : null,
      'applicant_district_id': draft.districtId,
      'case_type_id': (draft.caseTypeId != null && draft.caseTypeId!.isNotEmpty) ? draft.caseTypeId : null,
      'current_district_id': draft.districtId,
      'current_taluka_id': draft.talukaId,
      'case_details': draft.caseDetails.trim().isNotEmpty ? draft.caseDetails.trim() : null,
      'preferred_advocate_id': (draft.preferredAdvocateId != null && draft.preferredAdvocateId!.isNotEmpty)
          ? draft.preferredAdvocateId
          : null,
      'tracking_number': '', // Trigger will generate
      'application_mode': 'FULL',
    };

    // ignore: avoid_print
    print('[ApplicationRepository] Submitting application (applicant: $effectiveApplicantId)');

    try {
      final LegalAidApplication application;

      if (effectiveApplicantId == null) {
        // Anonymous (not logged in) submission through Edge Function
        final persistentDeviceId = deviceId ?? await DeviceIdService.getDeviceId();
        final elapsed = clientElapsedMs ?? 20000;

        final res = await _client.functions.invoke(
          'submit-application',
          body: {
            'mode': 'FULL',
            'phone': PhoneUtils.normalize(draft.phone),
            'full_payload': insertData,
            'device_id': persistentDeviceId,
            'honeypot': '',
            'client_elapsed_ms': elapsed,
          },
        );

        final data = res.data;
        if (data is Map && data['tracking_number'] != null) {
          final trackingNo = data['tracking_number'].toString();
          // Fetch created application using tracking RPC to obtain row ID for document linking
          final tracked = await trackApplication(
            trackingNumber: trackingNo,
            phoneNumber: draft.phone,
          );
          application = tracked ??
              LegalAidApplication(
                id: trackingNo,
                trackingNumber: trackingNo,
                applicantPhoneNumber: draft.phone,
                applicantFullName: draft.fullName,
                categoryId: draft.categoryId,
                caseTypeId: draft.caseTypeId,
                applicantDistrictId: draft.districtId,
                status: 'SUBMITTED',
                createdAt: DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
              );
        } else if (data is Map && data['error'] != null) {
          throw ApplicationException(
            code: data['error'].toString(),
            message: _mapErrorCode(data['error'].toString()),
          );
        } else {
          throw const ApplicationException(
            code: 'TRY_AGAIN',
            message: 'Unable to submit application. Please try again.',
          );
        }
      } else {
        // Authenticated citizen: direct database insert
        final res = await _client
            .from('legal_aid_application')
            .insert(insertData)
            .select(_applicationSelectFields)
            .single();

        application = LegalAidApplication.fromJson(res);
      }

      // Upload and link documents if any
      final docCodes = draft.documentStoragePaths.keys.toList();
      if (docCodes.isNotEmpty && application.id.isNotEmpty) {
        try {
          final docRows = await _client
              .from('document_master')
              .select('id, document_code')
              .inFilter('document_code', docCodes);

          final idByCode = <String, dynamic>{
            for (final row in docRows) row['document_code'] as String: row['id'],
          };

          final links = <Map<String, dynamic>>[
            for (final entry in draft.documentStoragePaths.entries)
              if (idByCode[entry.key] != null)
                {
                  'application_id': application.id,
                  'document_id': idByCode[entry.key],
                  'file_url': entry.value,
                  'file_name': '${entry.key}.jpg',
                },
          ];

          if (links.isNotEmpty) {
            await _client.from('application_document').insert(links);
          }
        } catch (docErr) {
          // ignore: avoid_print
          print('[ApplicationRepository] Document linking failed: $docErr');
        }
      }

      return application;
    } on FunctionException catch (fe) {
      final code = _extractErrorCode(fe.details, fe.status);
      final retryMinutes = _extractRetryMinutes(fe.details);
      throw ApplicationException(
        code: code,
        message: _mapErrorCode(code, retryMinutes),
        retryAfterMinutes: retryMinutes,
      );
    } catch (e, stack) {
      // ignore: avoid_print
      print('========================================');
      // ignore: avoid_print
      print('[ApplicationRepository] SUBMIT FAILED ERROR: $e');
      // ignore: avoid_print
      print('[ApplicationRepository] STACK TRACE: $stack');
      // ignore: avoid_print
      print('========================================');
      if (e is ApplicationException) rethrow;
      throw const ApplicationException(
        code: 'TRY_AGAIN',
        message: 'Something went wrong. Please check your connection and try again.',
      );
    }
  }

  /// Submit a quick application requesting a call back from SLSA.
  ///
  /// Calls the `submit-application` Edge Function with mode `QUICK_CALLBACK`.
  Future<String> submitQuickApplication({
    required String phone,
    String? name,
    String? districtId,
    String? note,
    required String deviceId,
    required String honeypot,
    required int clientElapsedMs,
  }) async {
    final cleanPhone = PhoneUtils.normalize(phone);

    try {
      final res = await _client.functions.invoke(
        'submit-application',
        body: {
          'mode': 'QUICK_CALLBACK',
          'phone': cleanPhone,
          if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
          if (districtId != null && districtId.trim().isNotEmpty) 'district_id': districtId.trim(),
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
          'device_id': deviceId,
          'honeypot': honeypot,
          'client_elapsed_ms': clientElapsedMs,
        },
      );

      final data = res.data;
      if (data is Map && data['tracking_number'] != null) {
        return data['tracking_number'].toString();
      }

      if (data is Map && data['error'] != null) {
        final errCode = data['error'].toString();
        throw ApplicationException(
          code: errCode,
          message: _mapErrorCode(errCode),
        );
      }

      throw const ApplicationException(
        code: 'TRY_AGAIN',
        message: 'Something went wrong. Please check your connection and try again.',
      );
    } on FunctionException catch (fe) {
      final code = _extractErrorCode(fe.details, fe.status);
      final retryMinutes = _extractRetryMinutes(fe.details);
      throw ApplicationException(
        code: code,
        message: _mapErrorCode(code, retryMinutes),
        retryAfterMinutes: retryMinutes,
      );
    } catch (e) {
      if (e is ApplicationException) rethrow;
      throw const ApplicationException(
        code: 'TRY_AGAIN',
        message: 'Something went wrong. Please check your connection and try again.',
      );
    }
  }

  /// Track all applications associated with a phone number.
  ///
  /// Calls the `track-by-phone` Edge Function and returns a list of applications.
  Future<List<LegalAidApplication>> trackApplicationsByPhone({
    required String phone,
    required String deviceId,
  }) async {
    final cleanPhone = PhoneUtils.normalize(phone);

    try {
      final res = await _client.functions.invoke(
        'track-by-phone',
        body: {
          'phone': cleanPhone,
          'device_id': deviceId,
        },
      );

      final data = res.data;
      if (data is Map && data['applications'] is List) {
        final list = data['applications'] as List;
        return list.map((item) {
          final m = Map<String, dynamic>.from(item as Map);
          return LegalAidApplication.fromJson(m);
        }).toList();
      }

      if (data is Map && data['error'] != null) {
        final errCode = data['error'].toString();
        throw ApplicationException(
          code: errCode,
          message: _mapErrorCode(errCode),
        );
      }

      return [];
    } on FunctionException catch (fe) {
      final code = _extractErrorCode(fe.details, fe.status);
      throw ApplicationException(
        code: code,
        message: _mapErrorCode(code),
      );
    } catch (e) {
      if (e is ApplicationException) rethrow;
      throw const ApplicationException(
        code: 'TRY_AGAIN',
        message: 'Something went wrong. Please check your connection and try again.',
      );
    }
  }

  static String _extractErrorCode(dynamic details, int? status) {
    if (details is Map && details['error'] != null) {
      return details['error'].toString();
    }
    if (details is String) {
      try {
        final decoded = jsonDecode(details);
        if (decoded is Map && decoded['error'] != null) {
          return decoded['error'].toString();
        }
      } catch (_) {}
      if (details.contains('RATE_LIMITED')) return 'RATE_LIMITED';
      if (details.contains('INVALID_INPUT')) return 'INVALID_INPUT';
    }
    if (status == 429) return 'RATE_LIMITED';
    if (status == 400) return 'INVALID_INPUT';
    return 'TRY_AGAIN';
  }

  static int _extractRetryMinutes(dynamic details) {
    if (details is Map && details['retry_after_minutes'] != null) {
      final val = details['retry_after_minutes'];
      if (val is int) return val;
      if (val is num) return val.toInt();
      final parsed = int.tryParse(val.toString());
      if (parsed != null) return parsed;
    }
    if (details is String) {
      try {
        final decoded = jsonDecode(details);
        if (decoded is Map && decoded['retry_after_minutes'] != null) {
          final parsed = int.tryParse(decoded['retry_after_minutes'].toString());
          if (parsed != null) return parsed;
        }
      } catch (_) {}
    }
    return 10;
  }

  static String _mapErrorCode(String code, [int retryMinutes = 10, String action = 'submission']) {
    switch (code) {
      case 'RATE_LIMITED':
        if (action == 'track') {
          return 'Tracking query limit reached. Please wait a few minutes before searching again.';
        }
        return 'Submission limit reached for this phone number. Please wait $retryMinutes minutes before submitting again.';
      case 'INVALID_INPUT':
        return 'Please enter a valid 10-digit mobile number or tracking number.';
      default:
        return 'Something went wrong. Please check your connection and try again.';
    }
  }

  /// Fetch citizen's own applications
  Future<List<LegalAidApplication>> getMyApplications() async {
    final res = await _client
        .from('legal_aid_application')
        .select(_applicationSelectFields)
        .order('created_at', ascending: false);

    return (res as List).map((x) => LegalAidApplication.fromJson(x)).toList();
  }

  /// Fetch advocate master details by ID
  Future<Advocate?> getAdvocateById(String advocateId) async {
    final cleanId = advocateId.trim();
    if (cleanId.isEmpty) return null;
    try {
      final res = await _client
          .from('advocate_master')
          .select('*')
          .eq('id', cleanId)
          .maybeSingle();
      if (res != null) {
        return Advocate.fromJson(res);
      }
    } catch (_) {}
    return null;
  }

  /// Fetch a single application with details
  Future<LegalAidApplication?> getApplicationDetail(String applicationId) async {
    final cleanId = applicationId.trim();
    if (cleanId.isEmpty) return null;

    try {
      final res = await _client
          .from('legal_aid_application')
          .select(_applicationSelectFields)
          .eq('id', cleanId)
          .maybeSingle();

      if (res != null) {
        var app = LegalAidApplication.fromJson(res);
        if (app.assignedAdvocateId != null && app.assignedAdvocate == null) {
          final adv = await getAdvocateById(app.assignedAdvocateId!);
          if (adv != null) {
            app = app.copyWith(assignedAdvocate: adv, assignedAdvocateName: adv.fullName);
          }
        }
        return app;
      }
    } catch (_) {}

    try {
      final res = await _client
          .from('legal_aid_application')
          .select(_applicationSelectFields)
          .eq('tracking_number', cleanId)
          .maybeSingle();

      if (res != null) {
        var app = LegalAidApplication.fromJson(res);
        if (app.assignedAdvocateId != null && app.assignedAdvocate == null) {
          final adv = await getAdvocateById(app.assignedAdvocateId!);
          if (adv != null) {
            app = app.copyWith(assignedAdvocate: adv, assignedAdvocateName: adv.fullName);
          }
        }
        return app;
      }
    } catch (_) {}

    return null;
  }

  /// Track application using Edge Function (with IP/device rate limiting spam check)
  /// or RPC function with automatic district alias fallback. Phone number is optional for Direct ID tracking.
  Future<LegalAidApplication?> trackApplication({
    required String trackingNumber,
    String? phoneNumber,
    String? deviceId,
  }) async {
    final cleanTracking = trackingNumber.trim();
    final cleanPhone = phoneNumber?.trim();
    final effectivePhone = (cleanPhone != null && cleanPhone.isNotEmpty) ? cleanPhone : null;
    final candidateNumbers = TrackingNumberHelper.getAlternativeTrackingNumbers(cleanTracking);

    // Try track-by-id edge function for background rate-limiting & anti-spam checks
    try {
      final effectiveDeviceId = deviceId ?? await DeviceIdService.getDeviceId();
      final res = await _client.functions.invoke(
        'track-by-id',
        body: {
          'tracking_number': cleanTracking,
          if (effectivePhone != null) 'phone': effectivePhone,
          'device_id': effectiveDeviceId,
        },
      );

      final data = res.data;
      if (data is Map && data['application'] != null) {
        final rawApp = LegalAidApplication.fromJson(Map<String, dynamic>.from(data['application'] as Map));
        if (rawApp.id.isNotEmpty) {
          final fullApp = await getApplicationDetail(rawApp.id);
          if (fullApp != null) return fullApp;
        }

        var app = rawApp;
        if (app.assignedAdvocateId != null && app.assignedAdvocate == null) {
          final adv = await getAdvocateById(app.assignedAdvocateId!);
          if (adv != null) {
            app = app.copyWith(
              assignedAdvocate: adv,
              assignedAdvocateName: adv.fullName,
            );
          }
        }
        return app;
      }

      if (data is Map && data['error'] != null) {
        final errCode = data['error'].toString();
        if (errCode == 'RATE_LIMITED') {
          throw ApplicationException(
            code: 'RATE_LIMITED',
            message: _mapErrorCode(errCode, 10, 'track'),
          );
        }
      }
    } on FunctionException catch (fe) {
      final code = _extractErrorCode(fe.details, fe.status);
      if (code == 'RATE_LIMITED') {
        throw ApplicationException(
          code: 'RATE_LIMITED',
          message: _mapErrorCode(code, 10, 'track'),
        );
      }
    } catch (e) {
      if (e is ApplicationException) rethrow;
    }

    // Direct fallback to track_application RPC
    for (final num in candidateNumbers) {
      try {
        final res = await _client.rpc('track_application', params: {
          'p_tracking_number': num,
          'p_phone_number': effectivePhone,
        });

        if (res != null && (res is! List || res.isNotEmpty)) {
          final data = res is List ? res.first : res;
          if (data != null && data is Map) {
            final rawApp = LegalAidApplication.fromJson(Map<String, dynamic>.from(data));

            // Attempt to load fully-joined application (with category, case type, district names)
            if (rawApp.id.isNotEmpty) {
              final fullApp = await getApplicationDetail(rawApp.id);
              if (fullApp != null) {
                return fullApp;
              }
            }

            var app = rawApp;
            // If advocate is assigned by ID but advocate details were not joined in the flat RPC return
            if (app.assignedAdvocateId != null && app.assignedAdvocate == null) {
              final adv = await getAdvocateById(app.assignedAdvocateId!);
              if (adv != null) {
                app = app.copyWith(
                  assignedAdvocate: adv,
                  assignedAdvocateName: adv.fullName,
                );
              }
            }

            return app;
          }
        }
      } catch (_) {}
    }

    return null;
  }

  /// Withdraw an application
  Future<bool> withdrawApplication(String applicationId, String reason) async {
    try {
      await _client
          .from('legal_aid_application')
          .update({
            'status': 'WITHDRAWN',
            'is_withdrawn_by_citizen': true,
            'withdrawal_reason': reason,
            'withdrawn_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', applicationId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Fetch status history for an application
  Future<List<Map<String, dynamic>>> getStatusHistory(String applicationId) async {
    final res = await _client
        .from('application_status_history')
        .select('id, previous_status, new_status, remarks, created_at')
        .eq('application_id', applicationId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Upload a document to Supabase storage
  Future<String> uploadDocument({
    required String draftUuid,
    required String docCode,
    required String fileName,
    required List<int> bytes,
  }) async {
    final path = 'draft-uploads/$draftUuid/$docCode.jpg';
    await _client.storage.from('legal-documents').uploadBinary(
      path,
      Uint8List.fromList(bytes),
      fileOptions: const FileOptions(upsert: true),
    );
    return path;
  }

  /// Request a change of assigned advocate
  Future<bool> requestAdvocateChange({
    required String applicationId,
    String? currentAdvocateId,
    String? preferredNewAdvocateId,
    required String reason,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null || userId.isEmpty) {
        // ignore: avoid_print
        print('[ApplicationRepository] Cannot request advocate change: user is not authenticated');
        return false;
      }
      await _client.from('advocate_change_request').insert({
        'application_id': applicationId,
        'requested_by_citizen_id': userId,
        'current_advocate_id': currentAdvocateId,
        'preferred_new_advocate_id': preferredNewAdvocateId,
        'reason': reason.trim(),
        'request_status': 'PENDING',
      });
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('[ApplicationRepository] requestAdvocateChange error: $e');
      return false;
    }
  }

  /// Subscribe to realtime updates for legal_aid_application.
  RealtimeChannel subscribeToApplications({
    required void Function(PostgresChangePayload payload) onData,
  }) {
    final channelName = 'public:legal_aid_application_${DateTime.now().millisecondsSinceEpoch}';
    final userId = _client.auth.currentUser?.id;

    final channel = _client.channel(channelName).onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'legal_aid_application',
      filter: (userId != null && userId.isNotEmpty)
          ? PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'applicant_id',
              value: userId,
            )
          : null,
      callback: onData,
    );
    channel.subscribe();
    return channel;
  }

  /// Subscribe to realtime updates for a single application by ID
  RealtimeChannel subscribeToApplicationDetail({
    required String applicationId,
    required void Function(PostgresChangePayload payload) onData,
  }) {
    final cleanId = applicationId.trim();
    final channelName = 'app_detail_${cleanId}_${DateTime.now().millisecondsSinceEpoch}';
    final channel = _client.channel(channelName).onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'legal_aid_application',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: cleanId,
      ),
      callback: onData,
    );
    channel.subscribe();
    return channel;
  }

  /// Subscribe to realtime updates for status history of an application
  RealtimeChannel subscribeToStatusHistory({
    required String applicationId,
    required void Function(PostgresChangePayload payload) onData,
  }) {
    final cleanId = applicationId.trim();
    final channelName = 'app_history_${cleanId}_${DateTime.now().millisecondsSinceEpoch}';
    final channel = _client.channel(channelName).onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'application_status_history',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'application_id',
        value: cleanId,
      ),
      callback: onData,
    );
    channel.subscribe();
    return channel;
  }

  /// Unsubscribe a realtime channel
  Future<String> unsubscribe(RealtimeChannel channel) async {
    return await _client.removeChannel(channel);
  }
}
