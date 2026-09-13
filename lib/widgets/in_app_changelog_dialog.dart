import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';

const Map<String, List<String>> _changelog = {
  '1.0.0': [
    'Initial release of Nyaya Saathi legal aid portal.',
    'Bilingual case registration and legal representation requests.',
    'Real-time application status tracking.',
  ],
  '1.0.1': [
    'Camera crop editor: Smoother touch targets and aspect ratios.',
    'Enhanced dark mode contrast for legal form inputs.',
    'Instant offline syncing for drafted applications.',
  ],
};

Version? _tryParseVersion(String v) {
  try {
    final cleaned = v.split('+').first.trim();
    return Version.parse(cleaned);
  } catch (_) {
    return null;
  }
}

class InAppChangelogDialog {
  static const String _prefKey = 'last_seen_version';

  static Future<void> checkAndShow(BuildContext context) async {
    try {
      final info = await PackageInfo.fromPlatform();
      final current = info.version;
      final prefs = await SharedPreferences.getInstance();
      final lastSeen = prefs.getString(_prefKey);

      if (lastSeen == null) {
        // First run on fresh install: record current version without interrupting
        await prefs.setString(_prefKey, current);
        return;
      }
      if (lastSeen == current) return;

      final lastSeenVer = _tryParseVersion(lastSeen);
      final currentVer = _tryParseVersion(current);

      if (lastSeenVer == null || currentVer == null) {
        await prefs.setString(_prefKey, current);
        return;
      }

      final List<String> notes = [];
      for (final entry in _changelog.entries) {
        final v = _tryParseVersion(entry.key);
        if (v != null && v > lastSeenVer && v <= currentVer) {
          notes.addAll(entry.value);
        }
      }

      await prefs.setString(_prefKey, current);
      if (notes.isEmpty || !context.mounted) return;

      _showChangelogSheet(context, current, notes);
    } catch (e) {
      debugPrint('Error checking in-app changelog: $e');
    }
  }

  static void _showChangelogSheet(
    BuildContext context,
    String currentVersion,
    List<String> notes,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "What's New",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          "Version $currentVersion updates & improvements",
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: notes
                        .map(
                          (note) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.check_circle_rounded,
                                    size: 18,
                                    color: AppColors.successGreen,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    note,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Got It',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
