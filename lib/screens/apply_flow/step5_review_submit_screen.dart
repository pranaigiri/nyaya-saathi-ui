import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/pdf_generator_service.dart';
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
    final draft = Provider.of<DraftProvider>(context).draft;
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
          child: Text("Step 5: Review & Auto-Generated Form", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        const Text("Review your details and preview the auto-composed official A4 Authority Form before submission.", style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
        const SizedBox(height: 20),

        // Live A4 PDF Preview Card
        Container(
          height: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryBlue, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: PdfPreview(
            build: (format) => PdfGeneratorService.generateA4FormPdf(draft),
            allowPrinting: false,
            allowSharing: false,
            canChangeOrientation: false,
            canChangePageFormat: false,
            initialPageFormat: PdfPageFormat.a4,
          ),
        ),
        const SizedBox(height: 20),

        // Summary details
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("APPLICATION SUMMARY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryBlue)),
              const Divider(height: 20),
              _buildRow("Category", draft.categoryName ?? 'General'),
              _buildRow("Applicant Name", draft.fullName),
              _buildRow("Case Type", draft.caseTypeName ?? 'N/A'),
              _buildRow("District", draft.districtName),
              _buildRow("Uploaded Docs", "${draft.documentStoragePaths.length} documents uploaded"),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Declaration Checkbox
        CheckboxListTile(
          value: _declarationAccepted,
          onChanged: (val) => setState(() => _declarationAccepted = val ?? false),
          activeColor: AppColors.primaryBlue,
          contentPadding: EdgeInsets.zero,
          title: const Text(
            "I hereby declare that all information provided is accurate to the best of my knowledge and I agree to the terms of Legal Aid Services.",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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

  Widget _buildRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight))),
          Expanded(child: Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
