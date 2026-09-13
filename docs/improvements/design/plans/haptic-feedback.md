# Fix: Key actions like tab switches, card submits, and errors lack tactile haptic feedback

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/haptic-feedback
- **Needs new dependency**: none (uses Flutter's built-in services.dart HapticFeedback)

## Why

Actions performed in silence make an app feel flat and unresponsive. Subtle tactile vibrations on tab switches, successful submissions, or validation alerts give users tactile confidence in their interactions.

## Where

```dart
// lib/screens/citizen/citizen_dashboard_shell.dart:104 — current
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
```
```dart
// lib/screens/auth/login_screen.dart:154 — current
                onPressed: _isLoading ? null : _handleLogin,
```

## The fix

Create `lib/core/utils/haptics.dart`:
```dart
// target: lib/core/utils/haptics.dart
import 'package:flutter/services.dart';

class Haptics {
  static void selection() => HapticFeedback.selectionClick();
  static void light() => HapticFeedback.lightImpact();
  static void medium() => HapticFeedback.mediumImpact();
  static void heavy() => HapticFeedback.heavyImpact();
  static void error() => HapticFeedback.vibrate();
}
```

Trigger tactile cues at key moments:
```dart
// target: in citizen_dashboard_shell.dart
onTap: (index) {
  Haptics.selection();
  setState(() => _currentIndex = index);
},
```

## Steps

1. Create `lib/core/utils/haptics.dart`.
2. In `lib/screens/citizen/citizen_dashboard_shell.dart:104`, add `Haptics.selection();` when switching tabs.
3. In `lib/screens/auth/login_screen.dart:154`, invoke `Haptics.medium();` on submit.

## Check it

`dart analyze` exits clean.
`grep -c "Haptics.selection" lib/screens/citizen/citizen_dashboard_shell.dart` -> 1.

## Don't touch

- Audio or notification sound triggers.

## STOP if

- Platform channels for HapticFeedback fail compilation.

## When you're done

Navigating bottom tabs and triggering forms provides satisfying, native haptic feedback.
