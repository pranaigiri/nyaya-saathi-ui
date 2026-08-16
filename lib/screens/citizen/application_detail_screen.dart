import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/application_repository.dart';
import '../../models/legal_aid_application.dart';
import '../../widgets/status_badge.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final LegalAidApplication? application;
  final String? applicationId;

  const ApplicationDetailScreen({
    super.key,
    this.application,
    this.applicationId,
  }) : assert(application != null || applicationId != null, 'Either application or applicationId must be provided');

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  final ApplicationRepository _repository = ApplicationRepository();
  LegalAidApplication? _application;
  List<Map<String, dynamic>> _statusHistory = [];
  bool _isLoading = true;
  bool _isLoadingHistory = false;
  String? _errorMessage;
  RealtimeChannel? _appRealtimeChannel;
  RealtimeChannel? _historyRealtimeChannel;

  @override
  void initState() {
    super.initState();
    if (widget.application != null) {
      _application = widget.application;
      _isLoading = false;
      _fetchStatusHistory(_application!.id);
      _setupRealtimeSubscription(_application!.id);
      if (_application!.assignedAdvocate == null) {
        _refreshApplicationSilently(_application!.id);
      }
    } else if (widget.applicationId != null) {
      _fetchApplicationDetails(widget.applicationId!);
    }
  }

  void _setupRealtimeSubscription(String appId) {
    _cleanupRealtime();
    try {
      _appRealtimeChannel = _repository.subscribeToApplicationDetail(
        applicationId: appId,
        onData: (payload) {
          // ignore: avoid_print
          print('[ApplicationDetailScreen] Realtime app update: ${payload.eventType}');
          _refreshApplicationSilently(appId);
        },
      );

      _historyRealtimeChannel = _repository.subscribeToStatusHistory(
        applicationId: appId,
        onData: (payload) {
          // ignore: avoid_print
          print('[ApplicationDetailScreen] Realtime history update: ${payload.eventType}');
          _fetchStatusHistorySilently(appId);
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[ApplicationDetailScreen] Realtime subscription error: $e');
    }
  }

  void _cleanupRealtime() {
    if (_appRealtimeChannel != null) {
      _repository.unsubscribe(_appRealtimeChannel!);
      _appRealtimeChannel = null;
    }
    if (_historyRealtimeChannel != null) {
      _repository.unsubscribe(_historyRealtimeChannel!);
      _historyRealtimeChannel = null;
    }
  }

  Future<void> _refreshApplicationSilently(String id) async {
    try {
      final app = await _repository.getApplicationDetail(id);
      if (app != null && mounted) {
        setState(() {
          _application = app;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchApplicationDetails(String id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final app = await _repository.getApplicationDetail(id);
      if (app != null) {
        if (mounted) {
          setState(() {
            _application = app;
            _isLoading = false;
          });
          _fetchStatusHistory(app.id);
          _setupRealtimeSubscription(app.id);
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Application details could not be found. Please check the tracking number or ID.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load application details. Please check your network connection.';
        });
      }
    }
  }

  Future<void> _fetchStatusHistorySilently(String appId) async {
    try {
      final history = await _repository.getStatusHistory(appId);
      if (mounted) {
        setState(() {
          _statusHistory = history;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchStatusHistory(String appId) async {
    setState(() => _isLoadingHistory = true);
    try {
      final history = await _repository.getStatusHistory(appId);
      if (mounted) {
        setState(() {
          _statusHistory = history;
          _isLoadingHistory = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  Future<void> _handleRefresh() async {
    final targetId = _application?.id ?? widget.applicationId;
    if (targetId != null) {
      await _fetchApplicationDetails(targetId);
    }
  }

  @override
  void dispose() {
    _cleanupRealtime();
    super.dispose();
  }


  String _formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final caseTitle = _application != null
        ? (_application!.trackingNumber.isNotEmpty
            ? 'Case #${_application!.trackingNumber}'
            : 'Case #${_application!.id.substring(0, 8)}')
        : 'Application Details';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          caseTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              "Loading application details...",
              style: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null || _application == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 54, color: AppColors.dangerRed),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? "Application not found",
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text("Go Back"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      final targetId = widget.applicationId ?? _application?.id;
                      if (targetId != null) {
                        _fetchApplicationDetails(targetId);
                      }
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text("Retry"),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }

    final application = _application!;
    final applicant = application.applicantDetails;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Tracking Number",
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          application.trackingNumber.isNotEmpty ? application.trackingNumber : "Application Submitted",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Filed on: ${application.createdAt.split('T')[0]}",
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  StatusBadge(status: application.status),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Assigned Advocate Section or Fallback
            _buildAdvocateSection(context, application, isDark),
            const SizedBox(height: 18),

            // Status Timeline History Section
            _buildTimelineCard(context, isDark),
            const SizedBox(height: 18),

            // Section 1: Applicant Info
            _buildDetailCard(
              context,
              title: "1. APPLICANT DETAILS",
              children: [
                _buildRow("Full Name", applicant.fullName.isNotEmpty ? applicant.fullName : application.applicantFullName),
                _buildRow("Gender", applicant.gender.isNotEmpty ? applicant.gender : application.applicantGender),
                _buildRow(
                  "Date of Birth",
                  applicant.dateOfBirth != null && applicant.dateOfBirth!.isNotEmpty
                      ? applicant.dateOfBirth!
                      : (application.applicantDob.isNotEmpty ? application.applicantDob : 'N/A'),
                ),
                _buildRow(
                  "Village / Town",
                  applicant.villageOrTown.isNotEmpty
                      ? applicant.villageOrTown
                      : (application.villageOrTown ?? 'N/A'),
                ),
                _buildRow("District", application.districtName ?? application.applicantDistrictId),
                _buildRow(
                  "Phone",
                  applicant.phoneNumber.isNotEmpty ? applicant.phoneNumber : application.applicantPhoneNumber,
                ),
                if (applicant.email != null && applicant.email!.isNotEmpty) _buildRow("Email", applicant.email!),
              ],
            ),
            const SizedBox(height: 18),

            // Section 2: Case Details
            _buildDetailCard(
              context,
              title: "2. CASE & CATEGORY INFORMATION",
              children: [
                _buildRow("Category", application.categoryName ?? 'Legal Aid Category'),
                _buildRow("Case Type", application.caseTypeName ?? 'General Dispute'),
                _buildRow(
                  "Case Details",
                  application.caseDetails.isNotEmpty
                      ? application.caseDetails
                      : (application.summaryOfGrievance.isNotEmpty ? application.summaryOfGrievance : 'N/A'),
                ),
                if (application.reliefSought != null && application.reliefSought!.isNotEmpty)
                  _buildRow("Relief Sought", application.reliefSought!),
                _buildRow("Filed Date", application.createdAt.split('T')[0]),
                if (application.withdrawalReason != null && application.withdrawalReason!.isNotEmpty)
                  _buildRow("Withdrawal Reason", application.withdrawalReason!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "STATUS TIMELINE",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryBlue),
              ),
              if (_isLoadingHistory)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                ),
            ],
          ),
          const Divider(height: 20),
          if (_statusHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Application Status: ${_application?.status.replaceAll('_', ' ') ?? 'Submitted'}",
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _statusHistory.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _statusHistory[index];
                final status = (item['new_status'] ?? '').toString().replaceAll('_', ' ');
                final createdAt = item['created_at']?.toString();
                final remarks = item['remarks']?.toString();
                final isLatest = index == 0;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isLatest ? AppColors.primaryBlue : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status.isNotEmpty ? status : 'Status Updated',
                            style: TextStyle(
                              fontWeight: isLatest ? FontWeight.bold : FontWeight.w600,
                              fontSize: 13,
                              color: isLatest ? AppColors.primaryBlue : null,
                            ),
                          ),
                          if (remarks != null && remarks.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                remarks,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                              ),
                            ),
                          if (createdAt != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                _formatDateTime(createdAt),
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAdvocateSection(BuildContext context, LegalAidApplication application, bool isDark) {
    final bool hasAdvocate = application.assignedAdvocate != null ||
        (application.assignedAdvocateName != null && application.assignedAdvocateName!.trim().isNotEmpty);
    final bool isAdvocateAssignedStatus = application.status.toUpperCase() == 'ADVOCATE_ASSIGNED';

    if (hasAdvocate) {
      return _buildAssignedAdvocateCard(context, application, isDark);
    } else if (isAdvocateAssignedStatus) {
      return _buildAdvocateFallbackCard(context, application, isDark);
    }

    return const SizedBox.shrink();
  }

  Widget _buildAssignedAdvocateCard(BuildContext context, LegalAidApplication application, bool isDark) {
    final advocate = application.assignedAdvocate;
    final String advocateName = advocate?.fullName ?? application.assignedAdvocateName ?? 'Assigned Panel Advocate';
    final String enrollmentNumber = advocate?.enrollmentNumber.isNotEmpty == true
        ? advocate!.enrollmentNumber
        : 'Sikkim State Bar Council Panel';
    final String? primaryPhone = advocate?.primaryPhoneNumber;
    final String? secondaryPhone = advocate?.secondaryPhoneNumber;
    final String? email = advocate?.primaryEmail;
    final String? officeAddress = advocate?.officeAddress;
    final int experience = advocate?.experienceYears ?? 0;

    // Generate initials for avatar
    final nameParts = advocateName.replaceAll(RegExp(r'^Adv\.?\s*', caseSensitive: false), '').trim().split(' ');
    final initials = nameParts.length > 1
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : (nameParts.isNotEmpty && nameParts[0].isNotEmpty ? nameParts[0][0].toUpperCase() : 'A');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.successGreen.withValues(alpha: isDark ? 0.4 : 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.successGreen.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, color: AppColors.successGreen, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "ASSIGNED LEGAL AID ADVOCATE",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.5,
                      color: AppColors.successGreen,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "Free Legal Aid",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile & Credentials
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.primaryBlue.withValues(alpha: isDark ? 0.3 : 0.15),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            advocateName.toLowerCase().startsWith('adv') ? advocateName : "Adv. $advocateName",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.badge_outlined, size: 14, color: AppColors.textSecondaryLight),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  "Bar Reg: $enrollmentNumber",
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (experience > 0) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.workspace_premium_outlined, size: 14, color: AppColors.textSecondaryLight),
                                const SizedBox(width: 4),
                                Text(
                                  "$experience Years Bar Experience",
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // Contact Section Title
                const Text(
                  "Connect with your Advocate",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 10),

                // Primary Phone
                if (primaryPhone != null && primaryPhone.isNotEmpty)
                  _buildAdvocateContactRow(
                    context: context,
                    icon: Icons.phone_rounded,
                    iconColor: AppColors.successGreen,
                    title: "Primary Phone",
                    value: primaryPhone,
                    copyValue: primaryPhone,
                    copyLabel: "Phone number",
                    isDark: isDark,
                  )
                else
                  _buildAdvocateContactRow(
                    context: context,
                    icon: Icons.phone_rounded,
                    iconColor: AppColors.textSecondaryLight,
                    title: "Advocate Phone",
                    value: "Available via SLSA Helpline (15100)",
                    copyValue: "15100",
                    copyLabel: "SLSA Helpline",
                    isDark: isDark,
                  ),

                // Secondary Phone
                if (secondaryPhone != null && secondaryPhone.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildAdvocateContactRow(
                    context: context,
                    icon: Icons.phone_android_rounded,
                    iconColor: AppColors.primaryBlue,
                    title: "Alternate Phone",
                    value: secondaryPhone,
                    copyValue: secondaryPhone,
                    copyLabel: "Alternate phone number",
                    isDark: isDark,
                  ),
                ],

                // Email
                if (email != null && email.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildAdvocateContactRow(
                    context: context,
                    icon: Icons.email_outlined,
                    iconColor: Colors.deepOrange,
                    title: "Email Address",
                    value: email,
                    copyValue: email,
                    copyLabel: "Email address",
                    isDark: isDark,
                  ),
                ],

                // Office Address
                if (officeAddress != null && officeAddress.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildAdvocateContactRow(
                    context: context,
                    icon: Icons.location_on_outlined,
                    iconColor: Colors.purple,
                    title: "Chamber / Office Address",
                    value: officeAddress,
                    copyValue: officeAddress,
                    copyLabel: "Office address",
                    isDark: isDark,
                  ),
                ],

                const SizedBox(height: 14),

                // Guidance Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.blue.withValues(alpha: 0.1) : const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Advocate consultation under Sikkim SLSA is 100% free of charge. Please quote your Tracking No. (#${application.trackingNumber.isNotEmpty ? application.trackingNumber : application.id.substring(0, 8)}) when calling.",
                          style: TextStyle(
                            fontSize: 11.5,
                            height: 1.4,
                            color: isDark ? Colors.blue.shade100 : const Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final details = "Advocate: $advocateName\n"
                              "Bar Reg: $enrollmentNumber\n"
                              "${primaryPhone != null ? 'Phone: $primaryPhone\n' : ''}"
                              "${email != null ? 'Email: $email\n' : ''}"
                              "Case Ref: #${application.trackingNumber}";
                          _copyToClipboard(context, details, "Advocate contact info");
                        },
                        icon: const Icon(Icons.copy_rounded, size: 15),
                        label: const Text("Copy Details", style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAdvocateChangeDialog(context),
                        icon: const Icon(Icons.swap_horiz, size: 16),
                        label: const Text("Change Request", style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          foregroundColor: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
                          side: BorderSide(
                            color: isDark ? Colors.amber.withValues(alpha: 0.4) : Colors.amber.shade300,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvocateFallbackCard(BuildContext context, LegalAidApplication application, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.shade600.withValues(alpha: isDark ? 0.4 : 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.hourglass_top_rounded, color: Colors.amber.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "ADVOCATE ASSIGNMENT IN PROGRESS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.5,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "Authority Processing",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: isDark ? 0.2 : 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.assignment_ind_outlined, color: Colors.amber.shade700, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Panel Advocate Allocation in Progress",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Your application has been approved for free legal aid. The Sikkim State Legal Services Authority (SLSA) is assigning a designated panel advocate to your case.",
                            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Reassuring bullets
                _buildFallbackBullet(
                  icon: Icons.check_circle_outline_rounded,
                  text: "The advocate's name, phone number, and contact info will appear here once finalized.",
                  isDark: isDark,
                ),
                const SizedBox(height: 6),
                _buildFallbackBullet(
                  icon: Icons.notifications_none_rounded,
                  text: "You will also receive an automatic update as soon as the lawyer is allocated.",
                  isDark: isDark,
                ),

                const SizedBox(height: 14),

                // Helpline Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.support_agent_rounded, size: 20, color: AppColors.primaryBlue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Need urgent legal assistance?",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Call Sikkim SLSA Helpline: 15100 (Toll-Free) / 03592-202695",
                              style: TextStyle(fontSize: 11.5, color: AppColors.textSecondaryLight),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Action row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _handleRefresh,
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text("Check for Updates", style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () => _copyToClipboard(context, "15100", "SLSA Helpline Number"),
                      icon: const Icon(Icons.phone_outlined, size: 15),
                      label: const Text("Helpline", style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvocateContactRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String copyValue,
    required String copyLabel,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.primaryBlue),
            tooltip: "Copy $copyLabel",
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            onPressed: () => _copyToClipboard(context, copyValue, copyLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackBullet({required IconData icon, required String text, required bool isDark}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.amber.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, height: 1.35),
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, {required String title, required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryBlue)),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  void _showAdvocateChangeDialog(BuildContext context) {
    final reasonController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text("Request Advocate Change", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Please state your reason for requesting a change of assigned panel advocate. Your request will be reviewed by the Member Secretary, Sikkim SLSA.",
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight, height: 1.4),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "State your reasons clearly (e.g. communication issue, conflict of interest)...",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final reason = reasonController.text.trim();
                      if (reason.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter a reason for advocate change")),
                        );
                        return;
                      }

                      setDialogState(() => isSubmitting = true);
                      final success = await _repository.requestAdvocateChange(
                        applicationId: _application!.id,
                        currentAdvocateId: _application!.assignedAdvocateId,
                        reason: reason,
                      );

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? "Advocate change request submitted successfully to SLSA."
                                : "Request submitted. SLSA admin will review your case."),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text("Submit Request"),
            ),
          ],
        ),
      ),
    );
  }
}

