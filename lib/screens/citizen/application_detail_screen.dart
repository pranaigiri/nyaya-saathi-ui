import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/legal_aid_application.dart';
import '../../widgets/status_badge.dart';

class ApplicationDetailScreen extends StatelessWidget {
  final LegalAidApplication application;

  const ApplicationDetailScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final applicant = application.applicantDetails;

    return Scaffold(
      appBar: AppBar(
        title: Text("Case #${application.applicationNumber}"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Current Status", style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                      const SizedBox(height: 4),
                      Text(application.applicationNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  StatusBadge(status: application.currentStatus),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Assigned Advocate Section
            if (application.assignedAdvocateName != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.shield, color: AppColors.successGreen),
                        SizedBox(width: 8),
                        Text("Assigned Advocate", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.successGreen)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(application.assignedAdvocateName!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        _showAdvocateChangeDialog(context);
                      },
                      icon: const Icon(Icons.swap_horiz, size: 16),
                      label: const Text("Request Advocate Change"),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Section 1: Applicant Info
            _buildDetailCard(
              context,
              title: "1. APPLICANT DETAILS",
              children: [
                _buildRow("Applied For", applicant?.appliedFor == 'self' ? 'Self' : 'Other (${applicant?.relationRemark ?? ''})'),
                _buildRow("Full Name", applicant?.fullName ?? 'N/A'),
                _buildRow("Gender", applicant?.gender ?? 'N/A'),
                _buildRow("Date of Birth", applicant?.dateOfBirth ?? 'N/A'),
                _buildRow("Village / Town", applicant?.villageOrTown ?? 'N/A'),
                _buildRow("District", application.districtName),
                _buildRow("Phone", applicant?.phoneNumber ?? 'N/A'),
                if (applicant?.email != null) _buildRow("Email", applicant!.email!),
              ],
            ),
            const SizedBox(height: 16),

            // Section 2: Case Details
            _buildDetailCard(
              context,
              title: "2. CASE & CATEGORY INFORMATION",
              children: [
                _buildRow("Category", application.categoryName),
                _buildRow("Case Type", application.caseTypeName),
                _buildRow("Grievance Summary", application.summaryOfGrievance),
                if (application.reliefSought != null) _buildRow("Relief Sought", application.reliefSought!),
                _buildRow("Filed Date", application.submittedAt.split('T')[0]),
              ],
            ),
          ],
        ),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Request Advocate Change"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Please state the reason for requesting a change of assigned advocate. This will be reviewed by SLSA."),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: "Enter reason..."),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Advocate change request submitted to SLSA.")),
              );
            },
            child: const Text("Submit Request"),
          )
        ],
      ),
    );
  }
}
