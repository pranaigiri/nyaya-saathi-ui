import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../providers/draft_provider.dart';
import '../../../providers/application_provider.dart';
import '../../../widgets/draft_resumption_card.dart';
import '../../../widgets/stat_card.dart';
import '../tracking_screen.dart';
import '../quick_apply_screen.dart';
import '../../../core/utils/phone_utils.dart';
import '../../../widgets/apply_choice_modal.dart';
import '../../../widgets/eligibility_check_modal.dart';

class HomeTab extends StatefulWidget {
  final ScrollController? scrollController;
  const HomeTab({super.key, this.scrollController});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApplicationProvider>(context, listen: false).fetchApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final draftProvider = Provider.of<DraftProvider>(context);
    final appProvider = Provider.of<ApplicationProvider>(context);
    final apps = appProvider.applications;

    final activeCount = apps.where((a) => a.status != 'RESOLVED' && a.status != 'REJECTED' && a.status != 'WITHDRAWN').length;
    final resolvedCount = apps.where((a) => a.status == 'RESOLVED').length;

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: EdgeInsets.fromLTRB(20, 16, 20, 36 + MediaQuery.of(context).padding.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat Strip
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: context.tr("active"),
                  value: "$activeCount ${activeCount == 1 ? context.tr('case_singular') : context.tr('case_plural')}",
                  icon: Icons.pending_actions,
                  color: AppColors.infoCyan,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  title: context.tr("resolved"),
                  value: "$resolvedCount ${context.tr('resolved')}",
                  icon: Icons.check_circle_outline,
                  color: AppColors.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Resume Draft Banner if present (only for drafts with actual data)
          if (draftProvider.draft?.hasMeaningfulData == true) ...[
            const DraftResumptionCard(showDiscardButton: true),
            const SizedBox(height: 24),
          ],

          // One Tap Eligibility Check (outlined, compact)
          _buildActionCard(
            context,
            title: context.tr("one_tap_eligibility_check"),
            subtitle: context.tr("one_tap_check_subtitle"),
            icon: Icons.fact_check_rounded,
            gradientColors: [const Color(0xFF0F9D78), const Color(0xFF34D399)],
            outlinedColor: const Color(0xFF0F9D78),
            onTap: () {
              EligibilityCheckModal.show(context);
            },
          ),
          const SizedBox(height: 16),
          _buildQuickApplySection(context),
          const SizedBox(height: 16),
          _buildActionCard(
            context,
            title: context.tr("apply_for_legal_aid"),
            subtitle: context.tr("apply_fresh_subtitle"),
            icon: Icons.post_add_rounded,
            gradientColors: [AppColors.primaryBlue, const Color(0xFF1E40AF)],
            onTap: () {
              ApplyChoiceModal.show(context);
            },
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            context,
            title: context.tr("track_application"),
            subtitle: context.tr("track_status_subtitle"),
            icon: Icons.location_searching_rounded,
            gradientColors: [const Color(0xFF6750C8), const Color(0xFF8B7CE0)],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TrackingScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickApplySection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.6) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.accentGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr("quick_apply_section_title"),
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.primaryDark,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      context.tr("quick_apply_section_subtitle"),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildCallNalsaCard(context),
          const SizedBox(height: 10),
          _buildRequestCallbackCard(context),
        ],
      ),
    );
  }

  Widget _buildCallNalsaCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF047857).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final success = await PhoneUtils.dialNalsaHelpline();
            if (!success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.tr('quick_apply_dial_error')),
                  backgroundColor: AppColors.dangerRed,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.call_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr("call_nalsa_title"),
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr("call_nalsa_subtitle"),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone, size: 13, color: Color(0xFF047857)),
                      SizedBox(width: 4),
                      Text(
                        "15100",
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCallbackCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const QuickApplyScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_callback_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr("request_callback_title"),
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr("request_callback_subtitle"),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    Color? outlinedColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (outlinedColor != null) {
      // Compact outlined variant for secondary actions
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: outlinedColor, width: 1.5),
            color: outlinedColor.withValues(alpha: isDark ? 0.12 : 0.06),
          ),
          child: Row(
            children: [
              Icon(icon, color: outlinedColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: outlinedColor,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: outlinedColor, size: 13),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}
