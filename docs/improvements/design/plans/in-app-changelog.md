# Fix: Users have no idea what changed or improved after an app update

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/in-app-changelog
- **Needs new dependency**: package_info_plus: ^8.0.0, pub_semver: ^2.1.4

## Why

After an update, users open Nyaya Saathi and nothing tells them what has changed. Bug fixes, new legal aid categories, and improved document scanning go completely unnoticed. Presenting unseen release highlights on the first app launch after an update shows citizens that the service is actively improving.

## Where

Absence in startup and navigation flow:
```dart
// lib/screens/splash/splash_screen.dart:111 — current
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CitizenDashboardShell()),
      );
```

## The fix

Create `lib/widgets/in_app_changelog_dialog.dart` that checks `last_seen_version` in `SharedPreferences`, compares against current version using `pub_semver`, and presents a modal bottom sheet with changes since last version if updated.

```dart
// target: lib/widgets/in_app_changelog_dialog.dart
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Map<String, List<String>> _changelog = {
  '1.0.1': [
    'Camera crop editor: Smoother touch targets and aspect ratios.',
    'Enhanced dark mode contrast for form inputs.',
  ],
};

class InAppChangelogDialog {
  static Future<void> checkAndShow(BuildContext context) async {
    final info = await PackageInfo.fromPlatform();
    final current = info.version;
    final prefs = await SharedPreferences.getInstance();
    final lastSeen = prefs.getString('last_seen_version');

    if (lastSeen == null) {
      await prefs.setString('last_seen_version', current);
      return;
    }
    if (lastSeen == current) return;

    final lastSeenVer = Version.parse(lastSeen);
    final currentVer = Version.parse(current);
    final List<String> notes = [];
    for (final entry in _changelog.entries) {
      final v = Version.parse(entry.key);
      if (v > lastSeenVer && v <= currentVer) {
        notes.addAll(entry.value);
      }
    }
    await prefs.setString('last_seen_version', current);
    if (notes.isEmpty || !context.mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("What's New in v$current", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...notes.map((n) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [const Icon(Icons.check_circle, size: 16, color: Colors.green), const SizedBox(width: 8), Expanded(child: Text(n))]),
            )),
          ],
        ),
      ),
    );
  }
}
```

## Steps

1. Add `package_info_plus: ^8.0.0` and `pub_semver: ^2.1.4` to `pubspec.yaml`.
2. Create `lib/widgets/in_app_changelog_dialog.dart` with `InAppChangelogDialog`.
3. In `lib/screens/citizen/citizen_dashboard_shell.dart`, call `WidgetsBinding.instance.addPostFrameCallback((_) => InAppChangelogDialog.checkAndShow(context));` inside `initState`.

## Check it

`dart analyze` exits clean.
`grep -c "InAppChangelogDialog" lib/screens/citizen/citizen_dashboard_shell.dart` -> 1.

## Don't touch

- Do not modify existing API/Supabase calls in splash or dashboard.
- No refactors of navigation routes.

## STOP if

- Code at `citizen_dashboard_shell.dart` does not have `initState`.
- `dart analyze` reports dependency version incompatibility.

## When you're done

Users will see a friendly 'What's New' sheet whenever they update the app, highlighting recent enhancements and bug fixes.
