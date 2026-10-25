import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/language_provider.dart';

class LanguageSelectionModal extends StatefulWidget {
  const LanguageSelectionModal({super.key});

  @override
  State<LanguageSelectionModal> createState() => _LanguageSelectionModalState();
}

class _LanguageSelectionModalState extends State<LanguageSelectionModal> {
  String _selectedLang = 'en';
  int _step = 0; // 0 = Language selection, 1 = SLSA info overview

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppColors.darkSurface : Colors.white;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: dialogBg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _step == 0 ? _buildLanguageStep(isDark) : _buildSlsaInfoStep(isDark),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // STEP 1: CHOOSE LANGUAGE
  // --------------------------------------------------------------------------
  Widget _buildLanguageStep(bool isDark) {
    return Padding(
      key: const ValueKey('lang_step'),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.language_rounded,
                color: AppColors.primaryBlue,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.tr("choose_language_title",
                      fallback: "Choose Language / भाषा छान्नुहोस् / भाषा चुनें"),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.tr("choose_language_sub",
                fallback:
                    "Select your preferred language for using Nyaya Saathi. You can change this anytime later in settings."),
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ...AppLocalizations.supportedLanguages.map((lang) {
            String subtitle = "Default language";
            if (lang.code == 'ne') {
              subtitle = "सिक्किम राज्य कानूनी सहायता";
            } else if (lang.code == 'hi') {
              subtitle = "सिक्किम राज्य विधिक सहायता";
            }
            final title = lang.code == 'en'
                ? lang.nativeName
                : "${lang.nativeName} (${lang.englishName})";

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildLangTile(
                code: lang.code,
                title: title,
                subtitle: subtitle,
                flag: lang.flag,
                isDark: isDark,
              ),
            );
          }),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                final langProvider = Provider.of<LanguageProvider>(context, listen: false);
                await langProvider.completeFirstLaunch(_selectedLang);
                if (mounted) {
                  setState(() => _step = 1);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                context.tr("continue_btn", fallback: "Continue / अगाडि बढ्नुहोस् / आगे बढ़ें"),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangTile({
    required String code,
    required String title,
    required String subtitle,
    required String flag,
    required bool isDark,
  }) {
    final isSelected = _selectedLang == code;
    return Material(
      color: isSelected
          ? AppColors.primaryBlue.withValues(alpha: isDark ? 0.2 : 0.08)
          : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05)),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _selectedLang = code),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryBlue
                  : (isDark ? AppColors.borderDark : Colors.grey.shade300),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.primaryBlue : (isDark ? Colors.white38 : Colors.grey.shade400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // STEP 2: SLSA WELCOME OVERVIEW
  // --------------------------------------------------------------------------
  Widget _buildSlsaInfoStep(bool isDark) {
    return Padding(
      key: const ValueKey('slsa_step'),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          ClipOval(
            child: Image.asset(
              'assets/images/sikkim_slsa_logo.png',
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              // 1MB source shown at 72px – decode small.
              cacheWidth: 216,
              errorBuilder: (_, _, _) => const Icon(
                Icons.account_balance_rounded,
                size: 60,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.tr("slsa_welcome_title"),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              context.tr("slsa_welcome_desc"),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.primaryBlue,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureBullet(
            icon: Icons.check_circle_outline,
            text: context.tr("slsa_feat_1"),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildFeatureBullet(
            icon: Icons.fact_check_outlined,
            text: context.tr("slsa_feat_2"),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildFeatureBullet(
            icon: Icons.edit_note_rounded,
            text: context.tr("slsa_feat_3"),
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                context.tr("get_started"),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBullet({required IconData icon, required String text, required bool isDark}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.accentGold),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }
}
