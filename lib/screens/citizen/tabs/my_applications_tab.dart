import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../providers/application_provider.dart';
import '../../../widgets/status_badge.dart';
import '../application_detail_screen.dart';
import '../../../core/utils/date_extensions.dart';

class MyApplicationsTab extends StatefulWidget {
  final ScrollController? scrollController;
  const MyApplicationsTab({super.key, this.scrollController});

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

    if (appProvider.isLoading && !appProvider.hasFetched) {
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
                child: Text(context.tr("retry")),
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
          children: [
            const SizedBox(height: 80),
            const Center(
              child: Icon(Icons.folder_open_outlined, size: 64, color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                context.tr("no_applications_yet"),
                style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                context.tr("no_applications_sub"),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => appProvider.refresh(),
      child: ListView.builder(
        controller: widget.scrollController,
        padding: EdgeInsets.fromLTRB(16, 16, 16, 36 + MediaQuery.of(context).padding.bottom),
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
                            app.trackingNumber.isNotEmpty ? app.trackingNumber : context.tr("pending_no"),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: app.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (app.isDetailsPending) ...[
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.accentGold),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              context.tr("details_pending_notice"),
                              style: const TextStyle(fontSize: 12.5, color: AppColors.accentGold, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        "${app.categoryName ?? 'Legal Aid'} • ${app.caseTypeName ?? 'Dispute'}",
                        style: const TextStyle(fontSize: 13, color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      (app.applicantFullName != null && app.applicantFullName!.trim().isNotEmpty)
                          ? "${context.tr('applicant_label')}: ${app.applicantFullName}"
                          : "${context.tr('applicant_label')}: ${context.tr('details_pending')}",
                      style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                    if (app.isQuickMode && app.callbackStatus != 'NOT_REQUIRED') ...[
                      const SizedBox(height: 6),
                      Text(
                        app.callbackStatus == 'CALLBACK_COMPLETED' || app.callbackStatus == 'DETAILS_COLLECTED'
                            ? "✓ ${context.tr("callback_details_collected")}"
                            : "📞 ${context.tr("callback_waiting")}",
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF0F9D78), fontWeight: FontWeight.w600),
                      ),
                    ],
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
                              children: [
                                const Icon(Icons.phone, size: 10, color: AppColors.successGreen),
                                const SizedBox(width: 3),
                                Text(
                                  context.tr("contact_available"),
                                  style: const TextStyle(fontSize: 10, color: AppColors.successGreen, fontWeight: FontWeight.w600),
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
                            context.tr("advocate_assignment_in_progress"),
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
                          context.tr("filed_on", args: {"date": DateTime.tryParse(app.createdAt).formattedDate()}),
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                        ),
                        Row(
                          children: [
                            Text(
                              context.tr("view_details"),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right, size: 16, color: AppColors.primaryBlue),
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
