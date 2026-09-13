# Fix: No app version or build number is displayed for users or support in settings

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/show-app-version
- **Needs new dependency**: package_info_plus: ^8.0.0

## Why

When citizens contact legal aid support or report technical difficulties, verifying which app version and build they are running is impossible without an accessible version label.

## Where

```dart
// lib/screens/citizen/profile_screen.dart:453 — current
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
```

## The fix

Create `lib/widgets/version_indicator.dart`:
```dart
// target: lib/widgets/version_indicator.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionIndicator extends StatefulWidget {
  const VersionIndicator({super.key});

  @override
  State<VersionIndicator> createState() => _VersionIndicatorState();
}

class _VersionIndicatorState extends State<VersionIndicator> {
  String? _label;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _label = '${info.appName} v${info.version} (${info.buildNumber})';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _label = 'Nyaya Saathi v1.0.0 (1)');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_label == null) return const SizedBox.shrink();
    return Center(
      child: Text(
        _label!,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFeatures: const [FontFeature.tabularFigures()],
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}
```

Place at the bottom of the profile scroll view in `lib/screens/citizen/profile_screen.dart`.

## Steps

1. Create `lib/widgets/version_indicator.dart`.
2. Add `const SizedBox(height: 24),` and `const VersionIndicator(),` at the end of `lib/screens/citizen/profile_screen.dart` Column.

## Check it

`dart analyze` exits clean.
`grep -c "VersionIndicator" lib/screens/citizen/profile_screen.dart` -> 1.

## Don't touch

- Profile avatar or edit profile fields.

## STOP if

- PackageInfo crashes on desktop/web (fallback string handles failure).

## When you're done

The bottom of the citizen profile tab cleanly displays the app's version and build number.
