import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/language_provider.dart';
import '../citizen/unauth_home_screen.dart';

class SlsaInfoModal extends StatelessWidget {
  final String selectedLanguage;

  const SlsaInfoModal({super.key, required this.selectedLanguage});

  @override
  Widget build(BuildContext context) {
    final isNepali = selectedLanguage == 'ne';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isNepali ? "सिक्किम राज्य कानूनी सहायता" : "Sikkim SLSA & Legal Aid",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => _dismiss(context),
                )
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isNepali
                    ? "सिक्किम राज्य कानूनी सेवा प्राधिकरण (SLSA) ले हरेक योग्य नागरिकलाई निःशुल्क र निष्पक्ष कानूनी सहायता प्रदान गर्दछ।"
                    : "Sikkim State Legal Services Authority (SLSA) provides free and competent legal services to eligible citizens across all 6 districts.",
                style: const TextStyle(fontSize: 13, color: AppColors.primaryBlue, height: 1.4),
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureBullet(
              icon: Icons.check_circle_outline,
              text: isNepali ? "निःशुल्क अधिवक्ता तथा कानूनी सल्लाह" : "100% Free advocate representation & consultation",
            ),
            const SizedBox(height: 8),
            _buildFeatureBullet(
              icon: Icons.fact_check_outlined,
              text: isNepali ? "आवेदन ट्र्याकिङ बिना लगइन" : "Instant application tracking without forced account creation",
            ),
            const SizedBox(height: 8),
            _buildFeatureBullet(
              icon: Icons.edit_note_rounded,
              text: isNepali ? "तपाईंको उपकरणमा ड्राफ्ट स्वतः बचत हुन्छ" : "Resume incomplete applications anytime on your device",
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _dismiss(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isNepali ? "सुरु गर्नुहोस्" : "Get Started",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBullet({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.accentGold),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimaryLight),
          ),
        )
      ],
    );
  }

  void _dismiss(BuildContext context) async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    await langProvider.completeFirstLaunch(selectedLanguage);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UnauthHomeScreen()),
      );
    }
  }
}
