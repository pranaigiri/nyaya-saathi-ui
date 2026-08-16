import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/application_provider.dart';
import '../../../widgets/status_badge.dart';
import '../application_detail_screen.dart';

class MyApplicationsTab extends StatefulWidget {
  const MyApplicationsTab({super.key});

  @override
  State<MyApplicationsTab> createState() => _MyApplicationsTabState();
}

class _MyApplicationsTabState extends State<MyApplicationsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApplicationProvider>(context, listen: false).fetchApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appProvider = Provider.of<ApplicationProvider>(context);

    if (appProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (appProvider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.dangerRed, size: 40),
              const SizedBox(height: 12),
              Text(
                appProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.dangerRed),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => appProvider.fetchApplications(),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final list = appProvider.applications;
    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => appProvider.refresh(),
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: const [
            SizedBox(height: 80),
            Center(
              child: Icon(Icons.folder_open_outlined, size: 64, color: AppColors.textSecondaryLight),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                "No applications filed yet.",
                style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 16),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                "When you submit a legal aid application, it will appear here.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => appProvider.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final app = list[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ApplicationDetailScreen(application: app)),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            app.trackingNumber.isNotEmpty ? app.trackingNumber : 'Pending No.',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: app.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${app.categoryName ?? 'Legal Aid'} • ${app.caseTypeName ?? 'Dispute'}",
                      style: const TextStyle(fontSize: 13, color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Applicant: ${app.applicantFullName}",
                      style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                    if (app.assignedAdvocateName != null && app.assignedAdvocateName!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.shield_outlined, size: 14, color: AppColors.successGreen),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              app.assignedAdvocateName!.toLowerCase().startsWith('adv')
                                  ? app.assignedAdvocateName!
                                  : "Adv. ${app.assignedAdvocateName!}",
                              style: const TextStyle(fontSize: 12, color: AppColors.successGreen, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.successGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.phone, size: 10, color: AppColors.successGreen),
                                SizedBox(width: 3),
                                Text(
                                  "Contact Available",
                                  style: TextStyle(fontSize: 10, color: AppColors.successGreen, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ] else if (app.status.toUpperCase() == 'ADVOCATE_ASSIGNED') ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.hourglass_top_rounded, size: 14, color: Colors.amber.shade700),
                          const SizedBox(width: 4),
                          Text(
                            "Advocate Assignment in Progress",
                            style: TextStyle(fontSize: 12, color: Colors.amber.shade800, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Filed on: ${app.createdAt.split('T')[0]}",
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                        ),
                        Row(
                          children: const [
                            Text(
                              "View Details",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.chevron_right, size: 16, color: AppColors.primaryBlue),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
