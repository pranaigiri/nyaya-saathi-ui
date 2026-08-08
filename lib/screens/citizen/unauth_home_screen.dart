import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/draft_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/draft_resumption_card.dart';
import '../apply_flow/apply_wizard_screen.dart';
import 'tracking_screen.dart';
import '../auth/login_screen.dart';
import 'citizen_dashboard_shell.dart';
import '../advocate/advocate_dashboard_screen.dart';

class UnauthHomeScreen extends StatelessWidget {
  const UnauthHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final draftProvider = Provider.of<DraftProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Auto-redirect if already logged in
    if (authProvider.isAuthenticated) {
      if (authProvider.isAdvocate) {
        return const AdvocateDashboardScreen();
      }
      return const CitizenDashboardShell();
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
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

              // 2 Large Primary Buttons
              _buildBigActionButton(
                context,
                title: context.tr("apply_for_legal_aid"),
                subtitle: "Fast 5-step form • No initial account required",
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
                subtitle: "Check status using Application Number & DOB",
                icon: Icons.track_changes_rounded,
                gradientColors: [const Color(0xFF0F766E), const Color(0xFF0D9488)],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TrackingScreen()),
                  );
                },
              ),
              const SizedBox(height: 36),

              // Small Register / Login Links
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "Already filed or an Advocate? ",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      context.tr("register_login"),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
  }) {
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
