import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../providers/draft_provider.dart';
import '../../../widgets/stat_card.dart';
import '../../apply_flow/apply_wizard_screen.dart';
import '../tracking_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final draftProvider = Provider.of<DraftProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat Strip
          Row(
            children: const [
              Expanded(
                child: StatCard(
                  title: "Active",
                  value: "2 Cases",
                  icon: Icons.pending_actions,
                  color: AppColors.infoCyan,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  title: "Approved",
                  value: "1 Approved",
                  icon: Icons.check_circle_outline,
                  color: AppColors.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Resume Draft Banner if present
          if (draftProvider.draft != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_document, color: AppColors.accentGold, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr("draft_found_title"),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          "Step ${(draftProvider.draft?.stepIndex ?? 0) + 1} of 5 saved locally",
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ApplyWizardScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    child: const Text("Resume", style: TextStyle(fontSize: 13, color: Colors.white)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 2 Primary Action Cards
          _buildActionCard(
            context,
            title: context.tr("apply_for_legal_aid"),
            subtitle: "File a fresh application for free legal representation",
            icon: Icons.post_add_rounded,
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
          _buildActionCard(
            context,
            title: context.tr("track_application"),
            subtitle: "Instant status check using Application Number & DOB",
            icon: Icons.location_searching_rounded,
            gradientColors: [const Color(0xFF0F766E), const Color(0xFF0D9488)],
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

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
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
