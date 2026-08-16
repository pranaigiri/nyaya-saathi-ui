import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/repositories/application_repository.dart';
import '../../models/legal_aid_application.dart';
import '../../widgets/status_badge.dart';
import 'application_detail_screen.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _appRepo = ApplicationRepository();
  bool _isLoading = false;
  LegalAidApplication? _foundApplication;
  String? _errorMessage;

  Future<void> _performTrack() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _foundApplication = null;
    });

    try {
      final result = await _appRepo.trackApplication(
        trackingNumber: _appNumberController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      setState(() {
        _isLoading = false;
        if (result != null) {
          _foundApplication = result;
        } else {
          _errorMessage = "No matching application found. Please check your Tracking ID and Phone Number.";
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Unable to reach server. Please check your network connection.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr("track_application")),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Track Your Application",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "No account required. Enter your Tracking ID along with the registered applicant phone number.",
                style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _appNumberController,
                decoration: const InputDecoration(
                  labelText: "Tracking ID / Application Number *",
                  hintText: "e.g. LA-20260816-001",
                  prefixIcon: Icon(Icons.confirmation_number_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? "Please enter Tracking ID" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Registered Phone Number *",
                  hintText: "e.g. 9876543210",
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? "Please enter phone number" : null,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _performTrack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(context.tr("track_now"), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),

              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.dangerRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.dangerRed),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.dangerRed, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_foundApplication != null) ...[
                const Text(
                  "Tracking Result",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ApplicationDetailScreen(application: _foundApplication!),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.successGreen, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.successGreen.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _foundApplication!.trackingNumber,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            StatusBadge(status: _foundApplication!.status),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondaryLight),
                            const SizedBox(width: 6),
                            Text(
                              _foundApplication!.applicantFullName,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.category_outlined, size: 16, color: AppColors.textSecondaryLight),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "${_foundApplication!.categoryName ?? 'Legal Aid'} • ${_foundApplication!.caseTypeName ?? 'Dispute'}",
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                              ),
                            ),
                          ],
                        ),
                        if (_foundApplication!.assignedAdvocateName != null && _foundApplication!.assignedAdvocateName!.trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.shield_outlined, size: 16, color: AppColors.successGreen),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Advocate: ${_foundApplication!.assignedAdvocateName!.toLowerCase().startsWith('adv') ? _foundApplication!.assignedAdvocateName! : 'Adv. ${_foundApplication!.assignedAdvocateName!}'}",
                                  style: const TextStyle(fontSize: 12, color: AppColors.successGreen, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ] else if (_foundApplication!.status.toUpperCase() == 'ADVOCATE_ASSIGNED') ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.hourglass_top_rounded, size: 16, color: Colors.amber.shade700),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Advocate Assignment in Progress",
                                  style: TextStyle(fontSize: 12, color: Colors.amber.shade800, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Text(
                              "View Full Details & Status History",
                              style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 16, color: AppColors.primaryBlue),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
