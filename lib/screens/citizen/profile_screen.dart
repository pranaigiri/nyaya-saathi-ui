import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile & Settings"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Login ID Read-Only Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_circle, color: AppColors.primaryBlue, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Account Login ID (Read-only)",
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          authProvider.userPhoneOrEmail.isNotEmpty ? authProvider.userPhoneOrEmail : "9876543210 (Citizen)",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text("APP PREFERENCES", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accentGold)),
            const SizedBox(height: 10),

            // Language Selector
            _buildPreferenceTile(
              context,
              icon: Icons.language,
              title: "App Language",
              trailing: DropdownButton<String>(
                value: langProvider.locale.languageCode,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text("English")),
                  DropdownMenuItem(value: 'ne', child: Text("नेपाली")),
                ],
                onChanged: (val) {
                  if (val != null) langProvider.setLanguage(val);
                },
              ),
            ),
            const SizedBox(height: 10),

            // Theme Selector
            _buildPreferenceTile(
              context,
              icon: Icons.brightness_6,
              title: "App Theme",
              trailing: DropdownButton<ThemeMode>(
                value: themeProvider.themeMode,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: ThemeMode.light, child: Text("Light")),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark")),
                  DropdownMenuItem(value: ThemeMode.system, child: Text("System")),
                ],
                onChanged: (mode) {
                  if (mode != null) themeProvider.setThemeMode(mode);
                },
              ),
            ),
            const SizedBox(height: 10),

            // Font Scale Selector
            _buildPreferenceTile(
              context,
              icon: Icons.format_size,
              title: "Text Font Size",
              trailing: DropdownButton<AppFontScale>(
                value: themeProvider.fontScale,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: AppFontScale.small, child: Text("Small")),
                  DropdownMenuItem(value: AppFontScale.medium, child: Text("Medium")),
                  DropdownMenuItem(value: AppFontScale.large, child: Text("Large")),
                ],
                onChanged: (scale) {
                  if (scale != null) themeProvider.setFontScale(scale);
                },
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  authProvider.logout();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.logout, color: AppColors.dangerRed),
                label: const Text("Logout", style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.dangerRed),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceTile(BuildContext context, {required IconData icon, required String title, required Widget trailing}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
          trailing,
        ],
      ),
    );
  }
}
