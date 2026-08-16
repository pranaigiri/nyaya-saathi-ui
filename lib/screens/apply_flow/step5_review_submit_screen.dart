import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/draft_provider.dart';
import 'application_success_screen.dart';

class Step5ReviewSubmitScreen extends StatefulWidget {
  final VoidCallback onBack;

  const Step5ReviewSubmitScreen({super.key, required this.onBack});

  @override
  State<Step5ReviewSubmitScreen> createState() => _Step5ReviewSubmitScreenState();
}

class _Step5ReviewSubmitScreenState extends State<Step5ReviewSubmitScreen> {
  bool _declarationAccepted = false;
  bool _isSubmitting = false;
  final _otpController = TextEditingController();

  void _showOtpVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.mark_email_read_outlined, color: AppColors.primaryBlue),
            SizedBox(width: 8),
            Text("Verify OTP", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "An OTP has been sent to your registered phone & email address for digital authentication.",
              style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: "Enter 6-digit OTP *",
                hintText: "123456",
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Demo Mode: Enter '123456' to verify immediately.",
              style: TextStyle(fontSize: 11, color: AppColors.accentGold, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_otpController.text.trim().length >= 4) {
                Navigator.of(ctx).pop();
                _submitApplication();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid 6-digit OTP")),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            child: const Text("Verify & Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitApplication() async {
    setState(() => _isSubmitting = true);
    try {
      final appNum = await Provider.of<DraftProvider>(context, listen: false).submitFinalApplication();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => ApplicationSuccessScreen(applicationNumber: appNum)),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Submission failed: $e"), backgroundColor: AppColors.dangerRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draftProvider = Provider.of<DraftProvider>(context);
    final draft = draftProvider.draft;
    final docs = draftProvider.requiredDocuments;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (draft == null) {
      return const Center(child: Text("No draft application data found"));
    }

    final mq = MediaQuery.of(context);
    final bottomInset = mq.viewInsets.bottom > 0 ? mq.viewInsets.bottom : mq.padding.bottom;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      children: [
        const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text("Step 5: Review Application Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        const Text(
          "Please review all information filled in your legal aid application before final submission.",
          style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 20),

        // Section 1: Category Details
        _buildSectionCard(
          context: context,
          title: "Legal Aid Category",
          icon: Icons.category_outlined,
          children: [
            _buildDetailRow("Selected Category", draft.categoryName ?? 'General'),
          ],
        ),
        const SizedBox(height: 16),

        // Section 2: Applicant Personal Details
        _buildSectionCard(
          context: context,
          title: "Applicant Details",
          icon: Icons.person_outline,
          children: [
            _buildDetailRow("Full Name", draft.fullName),
            _buildDetailRow("Gender", draft.gender),
            if (draft.dob != null && draft.dob!.isNotEmpty) _buildDetailRow("Date of Birth", draft.dob!),
            _buildDetailRow("Phone Number", draft.phone),
            _buildDetailRow("Email Address", draft.email.isNotEmpty ? draft.email : "Not Provided"),
            _buildDetailRow("Village / Town", draft.villageTown),
            _buildDetailRow("District", draft.districtName),
          ],
        ),
        const SizedBox(height: 16),

        // Section 3: Case & Grievance Details
        _buildSectionCard(
          context: context,
          title: "Case & Grievance Details",
          icon: Icons.gavel_outlined,
          children: [
            _buildDetailRow("Case Type", draft.caseTypeName ?? 'N/A'),
            _buildDetailRow("Summary of Grievance", draft.summaryOfGrievance.isNotEmpty ? draft.summaryOfGrievance : "N/A", isFullWidth: true),
            _buildDetailRow("Relief Sought", draft.reliefSought.isNotEmpty ? draft.reliefSought : "N/A", isFullWidth: true),
          ],
        ),
        const SizedBox(height: 16),

        // Section 4: Uploaded Documents Summary
        _buildSectionCard(
          context: context,
          title: "Uploaded Documents (${draft.documentStoragePaths.length} Attached)",
          icon: Icons.folder_open_outlined,
          children: [
            if (docs.isEmpty && draft.documentStoragePaths.isEmpty)
              const Text("No documents attached", style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight))
            else if (docs.isNotEmpty)
              ...docs.map((doc) {
                final isUploaded = draft.documentStoragePaths.containsKey(doc.documentCode);
                return _buildDocumentTile(doc.documentName, isUploaded);
              })
            else
              ...draft.documentStoragePaths.keys.map((docCode) {
                return _buildDocumentTile(docCode, true);
              }),
          ],
        ),
        const SizedBox(height: 20),

        // Declaration Checkbox
        Material(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _declarationAccepted ? AppColors.primaryBlue : (isDark ? AppColors.borderDark : AppColors.borderLight)),
            ),
            child: CheckboxListTile(
              value: _declarationAccepted,
              onChanged: (val) => setState(() => _declarationAccepted = val ?? false),
              activeColor: AppColors.primaryBlue,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              title: const Text(
                "I hereby declare that all information provided is accurate to the best of my knowledge and I agree to the terms of Legal Aid Services.",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          height: 52,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (!_declarationAccepted || _isSubmitting)
                ? null
                : () => _showOtpVerificationDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isSubmitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("Verify OTP & Submit ✓", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryBlue),
              ),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isFullWidth = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: isFullWidth
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 130,
                  child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500)),
                ),
                Expanded(
                  child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
    );
  }

  Widget _buildDocumentTile(String name, bool isUploaded) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isUploaded ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isUploaded ? AppColors.successGreen : AppColors.textSecondaryLight,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isUploaded ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (isUploaded ? AppColors.successGreen : AppColors.accentGold).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isUploaded ? "Attached ✓" : "Pending",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isUploaded ? AppColors.successGreen : AppColors.accentGold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

