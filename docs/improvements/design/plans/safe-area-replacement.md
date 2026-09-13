# Fix: System navigation bar covers the bottom of scrollable lists

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/safe-area-replacement
- **Needs new dependency**: none

## Why

On devices with gesture navigation or a hardware system bar, the last card or button of scrollable views is cut off or overlaps with the bar. Using a fixed padding fails because bar heights differ across devices, while wrapping with `SafeArea` truncates the scrolling viewport abruptly.

## Where

Multiple scrollables throughout the application:
```dart
// lib/screens/auth/login_screen.dart:76 — current
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
```
```dart
// lib/screens/auth/register_screen.dart:148 — current
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
```
```dart
// lib/screens/citizen/tabs/my_applications_tab.dart:91 — current
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
```
```dart
// lib/screens/citizen/tabs/notifications_tab.dart:335 — current
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
```
```dart
// lib/screens/citizen/tabs/home_tab.dart:38 — current
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
```
```dart
// lib/screens/apply_flow/step5_review_submit_screen.dart:217 — current
          child: ListView(
            padding: const EdgeInsets.all(16),
```

## The fix

Create `lib/widgets/bottom_padding.dart`:
```dart
// target: lib/widgets/bottom_padding.dart
import 'package:flutter/widgets.dart';

class BottomPadding extends StatelessWidget {
  const BottomPadding({super.key, this.minimum = 16});

  final double minimum;

  static double of(BuildContext context, {double minimum = 16}) {
    final double viewPadding = MediaQuery.viewPaddingOf(context).bottom;
    return viewPadding > minimum ? viewPadding : minimum;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: of(context, minimum: minimum));
  }
}
```

Update scrollable padding in lists and columns:
```dart
// target
padding: const EdgeInsets.all(16).copyWith(
  bottom: BottomPadding.of(context, minimum: 24),
)
```

## Steps

1. Create `lib/widgets/bottom_padding.dart`.
2. In `lib/screens/auth/login_screen.dart:76`, change padding to `EdgeInsets.fromLTRB(24, 24, 24, BottomPadding.of(context, minimum: 24))`.
3. In `lib/screens/auth/register_screen.dart:148`, update padding bottom with `BottomPadding.of(context, minimum: 24)`.
4. In `lib/screens/citizen/tabs/my_applications_tab.dart:91`, update `ListView.builder` padding bottom with `BottomPadding.of(context, minimum: 24)`.
5. In `lib/screens/citizen/tabs/notifications_tab.dart:335`, update padding bottom with `BottomPadding.of(context, minimum: 24)`.
6. In `lib/screens/citizen/tabs/home_tab.dart:38`, update padding bottom with `BottomPadding.of(context, minimum: 24)`.

## Check it

`dart analyze` exits clean.
`grep -c "BottomPadding" lib/widgets/bottom_padding.dart` -> 1.
`grep -c "BottomPadding.of" lib/screens/auth/login_screen.dart` -> 1.

## Don't touch

- Do not wrap the scrollables in `SafeArea`.
- Do not modify non-scrolling header bars.

## STOP if

- A screen does not have a BuildContext available for `MediaQuery.viewPaddingOf(context)`.

## When you're done

The bottom elements of forms, applications, and dashboards now float cleanly above the Android and iOS gesture bar with adequate breathing space.
