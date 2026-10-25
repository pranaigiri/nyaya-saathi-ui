import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  static const int _faqCount = 8;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Authority Contact & Helpline Section
          Text(
            context.tr("authority_support_helplines"),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        'assets/images/sikkim_slsa_logo.png',
                        width: 28,
                        height: 28,
                        fit: BoxFit.cover,
                        // 1MB source shown at 28px – decode small.
                        cacheWidth: 112,
                        errorBuilder: (context, error, stackTrace) => Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.gavel_rounded,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.tr("slsa_full_title"),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Toll-free / Helpline
                _buildContactRow(
                  icon: Icons.phone_in_talk_rounded,
                  title: context.tr("toll_free_helpline"),
                  value: context.tr("toll_free_value", fallback: "15100 / 03592-205377"),
                  isDark: isDark,
                ),
                const SizedBox(height: 12),

                // Email
                _buildContactRow(
                  icon: Icons.email_rounded,
                  title: context.tr("email_support"),
                  value: context.tr("email_support_value", fallback: "sikkim_slsa@live.com"),
                  isDark: isDark,
                ),
                const SizedBox(height: 12),

                // Working Hours
                _buildContactRow(
                  icon: Icons.access_time_filled_rounded,
                  title: context.tr("office_hours"),
                  value: context.tr("office_hours_value", fallback: "Mon - Sat: 10AM - 5PM (2nd & 4th Sat Closed)"),
                  isDark: isDark,
                ),
                const SizedBox(height: 12),

                // Office Address
                _buildContactRow(
                  icon: Icons.location_on_rounded,
                  title: context.tr("office_address"),
                  value: context.tr("office_address_value", fallback: "Development Area, Gangtok, Sikkim - 737101"),
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section Title: FAQ
          Text(
            context.tr("faq"),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 12),

          // FAQ Accordion Cards
          ...List.generate(_faqCount, (index) {
            final idx = index + 1;
            final question = context.tr("faq_q$idx");
            final answer = context.tr("faq_a$idx");

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: isDark ? AppColors.darkSurface : Colors.white,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
                child: ExpansionTile(
                  leading: const Icon(
                    Icons.help_outline,
                    color: AppColors.primaryBlue,
                  ),
                  title: Text(
                    question,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        answer,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primaryBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
