import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/draft_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/draft_resumption_card.dart';
import '../../widgets/eligibility_check_modal.dart';
import '../apply_flow/apply_wizard_screen.dart';
import 'tracking_screen.dart';
import 'quick_apply_screen.dart';
import '../../core/utils/phone_utils.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import 'citizen_dashboard_shell.dart';
import '../../widgets/progressive_fade.dart';
import '../../widgets/language_switcher_button.dart';

class UnauthHomeScreen extends StatelessWidget {
  const UnauthHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final draftProvider = Provider.of<DraftProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Auto-redirect if already logged in
    if (authProvider.isAuthenticated) {
      return const CitizenDashboardShell();
    }

    return Scaffold(
      body: ProgressiveFade(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 12, 24, 48 + MediaQuery.of(context).padding.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: const LanguageSwitcherButton(),
              ),
              const SizedBox(height: 8),
              // Top Header Emblem
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    cacheWidth: 288,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.gavel_rounded,
                      size: 56,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                context.tr("app_title"),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr("app_subtitle"),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accentGold,
                ),
              ),
              const SizedBox(height: 36),

              // Draft Resumption Banner (if draft exists on device)
              if (draftProvider.draft != null) ...[
                const DraftResumptionCard(showDiscardButton: true),
                const SizedBox(height: 24),
              ],

              // 3 Large Primary Buttons
              // One Tap Eligibility Check (outlined, compact)
              _buildBigActionButton(
                context,
                title: context.tr("one_tap_eligibility_check"),
                subtitle: context.tr("one_tap_eligibility_subtitle"),
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
              _buildBigActionButton(
                context,
                title: context.tr("apply_for_legal_aid"),
                subtitle: context.tr("apply_for_legal_aid_subtitle"),
                icon: Icons.assignment_add,
                gradientColors: [AppColors.primaryBlue, const Color(0xFF1E40AF)],
                onTap: () {
                  if (draftProvider.draft == null) {
                    draftProvider.startNewDraft();
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ApplyWizardScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildBigActionButton(
                context,
                title: context.tr("track_application"),
                subtitle: context.tr("track_application_subtitle"),
                icon: Icons.track_changes_rounded,
                gradientColors: [const Color(0xFF6750C8), const Color(0xFF8B7CE0)],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TrackingScreen()),
                  );
                },
              ),
              const SizedBox(height: 36),

              // Register / Sign In Links
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                            label: Text(context.tr("register"), style: const TextStyle(fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryBlue,
                              side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.login_rounded, size: 18),
                            label: Text(context.tr("sign_in"), style: const TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr("register_login_banner_text"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
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

  Widget _buildBigActionButton(
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
              Icon(Icons.arrow_forward_ios_rounded, color: outlinedColor, size: 13),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
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
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
