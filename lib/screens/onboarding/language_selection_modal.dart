import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
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
          const Row(
            children: [
              Icon(
                Icons.language_rounded,
                color: AppColors.primaryBlue,
                size: 28,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Choose Language / भाषा छान्नुहोस्",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Select your preferred language for using Nyaya Saathi. You can change this anytime later in settings.",
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          _buildLangTile(
            code: 'en',
            title: "English",
            subtitle: "Default language",
            flag: "🇮🇳",
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildLangTile(
            code: 'ne',
            title: "नेपाली (Nepali)",
            subtitle: "सिक्किम राज्य कानूनी सहायता",
            flag: "🇮🇳",
            isDark: isDark,
          ),
          const SizedBox(height: 24),
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
              child: const Text(
                "Continue / अगाडि बढ्नुहोस्",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
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
    final isNepali = _selectedLang == 'ne';

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
              errorBuilder: (_, _, _) => const Icon(
                Icons.account_balance_rounded,
                size: 60,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isNepali
                ? "सिक्किम राज्य कानूनी सेवा प्राधिकरण"
                : "Sikkim State Legal Services Authority",
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
              isNepali
                  ? "सिक्किम राज्य कानूनी सेवा प्राधिकरण (SLSA) ले हरेक योग्य नागरिकलाई निःशुल्क र निष्पक्ष कानूनी सहायता प्रदान गर्दछ।"
                  : "Sikkim State Legal Services Authority (SLSA) provides free and competent legal services to eligible citizens across all 6 districts.",
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
            text: isNepali
                ? "निःशुल्क अधिवक्ता तथा कानूनी सल्लाह"
                : "100% Free advocate representation & consultation",
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildFeatureBullet(
            icon: Icons.fact_check_outlined,
            text: isNepali
                ? "आवेदन ट्र्याकिङ बिना लगइन"
                : "Instant application tracking without forced account creation",
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildFeatureBullet(
            icon: Icons.edit_note_rounded,
            text: isNepali
                ? "तपाईंको उपकरणमा ड्राफ्ट स्वतः बचत हुन्छ"
                : "Resume incomplete applications anytime on your device",
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
                isNepali ? "सुरु गर्नुहोस्" : "Get Started",
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
