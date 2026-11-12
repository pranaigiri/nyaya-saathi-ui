import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/app_localizations.dart';
import '../core/utils/phone_utils.dart';
import '../screens/citizen/quick_apply_screen.dart';

/// Modal bottom sheet allowing citizens to choose between the two Quick Apply methods:
/// 1. Instant direct dial of the NALSA 24x7 toll-free helpline (15100).
/// 2. Request a callback via the quick online application form.
class QuickApplyChoiceModal extends StatelessWidget {
  const QuickApplyChoiceModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const QuickApplyChoiceModal(),
    );
  }

  Future<void> _handleDial(BuildContext context) async {
    final success = await PhoneUtils.dialNalsaHelpline();
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('quick_apply_dial_error'),
          ),
          backgroundColor: AppColors.dangerRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'Copy 15100',
            textColor: Colors.white,
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: PhoneUtils.nalsaHelplineNumber));
            },
          ),
        ),
      );
    }
  }

  void _handleOpenForm(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuickApplyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;

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
                  color: const Color(0xFF0F9D78).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flash_on_rounded,
                  color: Color(0xFF0F9D78),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('quick_apply_choice_title'),
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('quick_apply_choice_subtitle'),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Button 1: Method 1 - Dial NALSA Helpline (15100)
          _buildMethodCard(
            context,
            isDark: isDark,
            icon: Icons.phone_forwarded_rounded,
            iconBgColor: const Color(0xFF0F9D78).withValues(alpha: 0.15),
            iconColor: const Color(0xFF0F9D78),
            badgeText: context.tr('quick_apply_dial_badge'),
            badgeColor: const Color(0xFF0F9D78),
            title: context.tr('quick_apply_dial_title'),
            subtitle: context.tr('quick_apply_dial_subtitle'),
            actionLabel: context.tr('quick_apply_dial_btn'),
            actionIcon: Icons.call_rounded,
            actionColor: const Color(0xFF0F9D78),
            onTap: () => _handleDial(context),
          ),
          const SizedBox(height: 14),

          // Button 2: Method 2 - Request a Callback (Existing Quick Apply)
          _buildMethodCard(
            context,
            isDark: isDark,
            icon: Icons.phone_callback_rounded,
            iconBgColor: AppColors.primaryBlue.withValues(alpha: 0.15),
            iconColor: AppColors.primaryBlue,
            badgeText: context.tr('quick_apply_form_badge'),
            badgeColor: AppColors.primaryBlue,
            title: context.tr('quick_apply_form_title'),
            subtitle: context.tr('quick_apply_form_subtitle'),
            actionLabel: context.tr('quick_apply_form_btn'),
            actionIcon: Icons.assignment_outlined,
            actionColor: AppColors.primaryBlue,
            onTap: () => _handleOpenForm(context),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildMethodCard(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String badgeText,
    required Color badgeColor,
    required String title,
    required String subtitle,
    required String actionLabel,
    required IconData actionIcon,
    required Color actionColor,
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
        child: Column(
          children: [
            Row(
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
                              style: TextStyle(
                                fontSize: 15.5,
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
                          height: 1.3,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: onTap,
                icon: Icon(actionIcon, size: 17),
                label: Text(
                  actionLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

