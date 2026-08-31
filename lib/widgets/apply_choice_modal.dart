import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/draft_provider.dart';
import '../providers/apply_data_provider.dart';
import '../screens/apply_flow/apply_wizard_screen.dart';

class ApplyChoiceModal extends StatelessWidget {
  /// Preselected eligibility category (from the One Tap Eligibility Check).
  final dynamic preselectedCategoryId;
  final String? preselectedCategoryCode;
  final String? preselectedCategoryName;

  /// Initial wizard step index (0-based). 1 skips Step 1 when the category
  /// was already selected via the eligibility check.
  final int initialStep;

  const ApplyChoiceModal({
    super.key,
    this.preselectedCategoryId,
    this.preselectedCategoryCode,
    this.preselectedCategoryName,
    this.initialStep = 0,
  });

  static Future<void> show(
    BuildContext context, {
    dynamic preselectedCategoryId,
    String? preselectedCategoryCode,
    String? preselectedCategoryName,
    int initialStep = 0,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ApplyChoiceModal(
        preselectedCategoryId: preselectedCategoryId,
        preselectedCategoryCode: preselectedCategoryCode,
        preselectedCategoryName: preselectedCategoryName,
        initialStep: initialStep,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final draftProvider = Provider.of<DraftProvider>(context, listen: false);
    final applyDataProvider = Provider.of<ApplyDataProvider>(context, listen: false);
    final profile = authProvider.profile;
    final userName = profile?.fullName.isNotEmpty == true
        ? profile!.fullName
        : (authProvider.userName.isNotEmpty ? authProvider.userName : 'You');

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_ind_rounded,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apply for Legal Aid',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Select who this application is for',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Option 1: Self
          _buildOptionCard(
            context,
            isDark: isDark,
            icon: Icons.person_rounded,
            iconBgColor: AppColors.primaryBlue.withValues(alpha: 0.15),
            iconColor: AppColors.primaryBlue,
            title: 'Apply for Self',
            subtitle: 'Auto-fill form using your profile ($userName)',
            badgeText: '1-Click Auto-Fill',
            badgeColor: AppColors.primaryBlue,
            onTap: () async {
              Navigator.pop(context);

              // Find district name if available
              String? districtName;
              if (profile?.districtId != null) {
                try {
                  final districts = await applyDataProvider.getDistricts();
                  final match = districts.where((d) => d.id == profile!.districtId).firstOrNull;
                  districtName = match?.districtName;
                } catch (_) {}
              }

              await draftProvider.startNewDraft(
                profile: profile,
                districtName: districtName,
              );
              await _applyPreselection(draftProvider);

              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ApplyWizardScreen(initialStep: initialStep),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 14),

          // Option 2: Others
          _buildOptionCard(
            context,
            isDark: isDark,
            icon: Icons.group_add_rounded,
            iconBgColor: const Color(0xFF0D9488).withValues(alpha: 0.15),
            iconColor: const Color(0xFF0D9488),
            title: 'Apply for Others',
            subtitle: 'Form will be empty to enter another person\'s details',
            badgeText: 'Blank Form',
            badgeColor: const Color(0xFF0D9488),
            onTap: () async {
              Navigator.pop(context);
              await draftProvider.startNewDraft(); // Starts fresh empty draft
              await _applyPreselection(draftProvider);

              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ApplyWizardScreen(initialStep: initialStep),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// Applies the category preselected via the eligibility check (if any) and
  /// persists the initial wizard step so the wizard opens on the right step.
  Future<void> _applyPreselection(DraftProvider draftProvider) async {
    if (preselectedCategoryId != null && preselectedCategoryCode != null) {
      await draftProvider.updateCategory(
        preselectedCategoryId,
        preselectedCategoryCode!,
        preselectedCategoryName ?? preselectedCategoryCode!,
      );
    }
    if (initialStep > 0) {
      await draftProvider.setStepIndex(initialStep);
    }
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }
}
