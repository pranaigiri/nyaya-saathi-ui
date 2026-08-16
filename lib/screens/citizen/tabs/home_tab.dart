import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../providers/draft_provider.dart';
import '../../../providers/application_provider.dart';
import '../../../widgets/draft_resumption_card.dart';
import '../../../widgets/stat_card.dart';
import '../tracking_screen.dart';
import '../../../widgets/apply_choice_modal.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat Strip
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: "Active",
                  value: "$activeCount ${activeCount == 1 ? 'Case' : 'Cases'}",
                  icon: Icons.pending_actions,
                  color: AppColors.infoCyan,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  title: "Resolved",
                  value: "$resolvedCount Resolved",
                  icon: Icons.check_circle_outline,
                  color: AppColors.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Resume Draft Banner if present
          if (draftProvider.draft != null) ...[
            const DraftResumptionCard(showDiscardButton: true),
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
              ApplyChoiceModal.show(context);
            },
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            context,
            title: context.tr("track_application"),
            subtitle: "Instant status check using Application Number & Phone",
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
