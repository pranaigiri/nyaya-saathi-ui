import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final List<Map<String, String>> _faqs = [
    {
      'q': 'Who is eligible for free Legal Aid in Sikkim?',
      'a':
          'Under Section 12 of the Legal Services Authorities Act, 1987, women, children, SC/ST members, victims of disasters, mentally ill/disabled persons, and citizens with annual income < ₹3,00,000 are eligible.',
    },
    {
      'q': 'How long does application processing take?',
      'a':
          'Initial scrutiny by DLSA is completed within 3-5 working days. Upon approval, an advocate is assigned immediately.',
    },
    {
      'q': 'Can I apply on behalf of someone else?',
      'a':
          'Yes! Select "Other" under "Applying For" in Step 2 and mention your relation to the applicant.',
    },
    {
      'q': 'Are legal aid services 100% free?',
      'a':
          'Yes, all services including advocate representation, court fees, and paper filing provided by SLSA are completely free.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Authority Contact & Helpline Section
          const Text(
            "Authority Support & Helplines",
            style: TextStyle(
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
                    const Expanded(
                      child: Text(
                        "Sikkim State Legal Services Authority (SLSA)",
                        style: TextStyle(
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
                  title: "Toll-Free Legal Helpline",
                  value: "15100 / 03592-205377",
                  isDark: isDark,
                ),
                const SizedBox(height: 12),

                // Email
                _buildContactRow(
                  icon: Icons.email_rounded,
                  title: "Email Support",
                  value: "sikkim_slsa@live.com",
                  isDark: isDark,
                ),
                const SizedBox(height: 12),

                // Working Hours
                _buildContactRow(
                  icon: Icons.access_time_filled_rounded,
                  title: "Office Hours",
                  value: "Mon - Sat: 10AM - 5PM (2nd & 4th Sat Closed)",
                  isDark: isDark,
                ),
                const SizedBox(height: 12),

                // Office Address
                _buildContactRow(
                  icon: Icons.location_on_rounded,
                  title: "Office Address",
                  value: "Development Area, Gangtok, Sikkim - 737101",
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section Title: FAQ
          const Text(
            "Frequently Asked Questions",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 12),

          // FAQ Accordion Cards
          ..._faqs.map((item) {
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
                    item['q']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        item['a']!,
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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryBlue),
        ),
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
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
