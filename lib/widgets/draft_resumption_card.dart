import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/app_localizations.dart';
import '../providers/draft_provider.dart';
import '../screens/apply_flow/apply_wizard_screen.dart';

class DraftResumptionCard extends StatelessWidget {
  final bool showDiscardButton;

  const DraftResumptionCard({
    super.key,
    this.showDiscardButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final draftProvider = Provider.of<DraftProvider>(context);
    final draft = draftProvider.draft;

    if (draft == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentStep = (draft.stepIndex) + 1;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.accentGold.withValues(alpha: 0.1)
            : AppColors.accentGold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentGold.withValues(alpha: 0.05),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_document,
                  color: AppColors.accentGold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr("draft_found_title"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Step $currentStep of 5 saved locally",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            context.tr("draft_found_body"),
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.85)
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 340;

              final resumeButton = ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ApplyWizardScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.play_arrow_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    context.tr("resume"),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              );

              final discardButton = showDiscardButton
                  ? TextButton.icon(
                      onPressed: () async {
                        await draftProvider.startNewDraft();
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ApplyWizardScreen(),
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: AppColors.dangerRed,
                      ),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          context.tr("discard"),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dangerRed,
                          ),
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        minimumSize: const Size(0, 44),
                      ),
                    )
                  : null;

              if (isNarrow || discardButton == null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: resumeButton,
                    ),
                    if (discardButton != null) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.center,
                        child: discardButton,
                      ),
                    ],
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: resumeButton,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: discardButton,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
