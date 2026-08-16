import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/advocate.dart';
import '../../models/legal_aid_application.dart';
import '../../models/draft_application_model.dart';

class ApplicationRepository {
  SupabaseClient get _client => Supabase.instance.client;

  /// Submit a new legal aid application from a draft
  Future<LegalAidApplication> submitApplication(DraftApplicationModel draft, {String? applicantId}) async {
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
      'case_type_id': draft.caseTypeId,
      'current_district_id': draft.districtId,
      'current_taluka_id': draft.talukaId,
      'case_details': draft.caseDetails,
      'preferred_advocate_id': (draft.preferredAdvocateId != null && draft.preferredAdvocateId!.isNotEmpty)
          ? draft.preferredAdvocateId
          : null,
      'tracking_number': '', // Trigger will generate
    };

    // ignore: avoid_print
    print('========================================');
    // ignore: avoid_print
    print('[ApplicationRepository] SUBMITTING APPLICATION PAYLOAD:');
    // ignore: avoid_print
    print('[ApplicationRepository] Auth Current User ID: ${_client.auth.currentUser?.id}');
    // ignore: avoid_print
    print('[ApplicationRepository] Effective Applicant ID: $effectiveApplicantId');
    // ignore: avoid_print
    print('[ApplicationRepository] Data map: $insertData');
    // ignore: avoid_print
    print('========================================');

    try {
      final res = await _client
          .from('legal_aid_application')
          .insert(insertData)
          .select('*, legal_aid_category(category_name), case_type_master(case_type_name), advocate_master:assigned_advocate_id(*)')
          .single();

      // ignore: avoid_print
      print('[ApplicationRepository] Insert success response: $res');
      final application = LegalAidApplication.fromJson(res);

      // Upload documents if any
      for (final entry in draft.documentStoragePaths.entries) {
        try {
          // ignore: avoid_print
          print('[ApplicationRepository] Linking doc code: ${entry.key}, storage path: ${entry.value}');
          final docResult = await _client
              .from('document_master')
              .select('id')
              .eq('document_code', entry.key)
              .maybeSingle();

          if (docResult != null) {
            await _client.from('application_document').insert({
              'application_id': application.id,
              'document_id': docResult['id'],
              'file_url': entry.value,
              'file_name': '${entry.key}.jpg',
            });
            // ignore: avoid_print
            print('[ApplicationRepository] Successfully linked doc ${entry.key}');
          } else {
            // ignore: avoid_print
            print('[ApplicationRepository] Warning: docResult was null for code: ${entry.key}');
          }
        } catch (docErr) {
          // ignore: avoid_print
          print('[ApplicationRepository] Document linking failed for ${entry.key}: $docErr');
        }
      }

      return application;
    } catch (e, stack) {
      // ignore: avoid_print
      print('========================================');
      // ignore: avoid_print
      print('[ApplicationRepository] SUBMIT FAILED ERROR: $e');
      // ignore: avoid_print
      print('[ApplicationRepository] STACK TRACE: $stack');
      // ignore: avoid_print
      print('========================================');
      rethrow;
    }
  }

  /// Fetch citizen's own applications
  Future<List<LegalAidApplication>> getMyApplications() async {
    final res = await _client
        .from('legal_aid_application')
        .select('*, legal_aid_category(category_name), case_type_master(case_type_name), advocate_master:assigned_advocate_id(*)')
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
          .select('*, legal_aid_category(category_name), case_type_master(case_type_name), advocate_master:assigned_advocate_id(*)')
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
          .select('*, legal_aid_category(category_name), case_type_master(case_type_name), advocate_master:assigned_advocate_id(*)')
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

  /// Track application using the RPC function
  Future<LegalAidApplication?> trackApplication({
    required String trackingNumber,
    required String phoneNumber,
  }) async {
    final res = await _client.rpc('track_application', params: {
      'p_tracking_number': trackingNumber.trim(),
      'p_phone_number': phoneNumber.trim(),
    });

    if (res == null || (res is List && res.isEmpty)) return null;

    final data = res is List ? res.first : res;
    if (data == null || data is! Map<String, dynamic>) return null;

    var app = LegalAidApplication.fromJson(data);

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
    required String reason,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      await _client.from('advocate_change_request').insert({
        'application_id': applicationId,
        'requested_by_citizen_id': ?userId,
        'current_advocate_id': ?currentAdvocateId,
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

  /// Subscribe to realtime updates for legal_aid_application table
  RealtimeChannel subscribeToApplications({
    required void Function(PostgresChangePayload payload) onData,
  }) {
    final channelName = 'public:legal_aid_application_${DateTime.now().millisecondsSinceEpoch}';
    final channel = _client.channel(channelName).onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'legal_aid_application',
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

