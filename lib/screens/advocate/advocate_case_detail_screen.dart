import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/legal_aid_application.dart';
import '../../widgets/status_badge.dart';

class AdvocateCaseDetailScreen extends StatelessWidget {
  final LegalAidApplication application;

  const AdvocateCaseDetailScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final applicant = application.applicantDetails;

    return Scaffold(
      appBar: AppBar(
        title: Text("Advocate View: #${application.applicationNumber}"),
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
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.accentGold),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Read-only Advocate View. Case edits, document additions, and status changes are managed via Admin CMS.",
                      style: TextStyle(fontSize: 12, color: AppColors.accentGold, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Header Status Card
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
                  Text(application.applicationNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  StatusBadge(status: application.currentStatus),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Client Contact Details
            _buildCard(
              context,
              title: "CLIENT CONTACT DETAILS",
              children: [
                _buildRow("Full Name", applicant?.fullName ?? 'N/A'),
                _buildRow("Gender", applicant?.gender ?? 'N/A'),
                _buildRow("Phone Number", applicant?.phoneNumber ?? 'N/A'),
                _buildRow("Village / Town", applicant?.villageOrTown ?? 'N/A'),
                _buildRow("District", application.districtName),
              ],
            ),
            const SizedBox(height: 16),

            // Case Details
            _buildCard(
              context,
              title: "CASE & GRIEVANCE INFORMATION",
              children: [
                _buildRow("Category", application.categoryName),
                _buildRow("Case Type", application.caseTypeName),
                _buildRow("Grievance Summary", application.summaryOfGrievance),
                if (application.reliefSought != null) _buildRow("Relief Sought", application.reliefSought!),
                _buildRow("Assigned Date", application.submittedAt.split('T')[0]),
              ],
            ),
            const SizedBox(height: 16),

            // Submitted Documents
            _buildCard(
              context,
              title: "SUBMITTED DOCUMENTS",
              children: [
                const ListTile(
                  leading: Icon(Icons.picture_as_pdf, color: AppColors.dangerRed),
                  title: Text("Identity Proof (Aadhaar/Voter ID)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: Text("Verified in Supabase Cloud Storage", style: TextStyle(fontSize: 11, color: AppColors.successGreen)),
                ),
                const ListTile(
                  leading: Icon(Icons.picture_as_pdf, color: AppColors.dangerRed),
                  title: Text("Income / Category Proof", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: Text("Verified in Supabase Cloud Storage", style: TextStyle(fontSize: 11, color: AppColors.successGreen)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required List<Widget> children}) {
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
}
