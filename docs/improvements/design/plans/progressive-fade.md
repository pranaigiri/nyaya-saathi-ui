# Fix: Scrolling content without an AppBar collides with the system status bar icons

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/progressive-fade
- **Needs new dependency**: none

## Why

On screens without a top AppBar (such as the unauthenticated portal), content scrolling under the status bar clashes visually with the clock, signal, and battery indicators. A progressive top fade dissolves content smoothly as it passes underneath.

## Where

```dart
// lib/screens/citizen/unauth_home_screen.dart:29 — current
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
```

## The fix

Create `lib/widgets/progressive_fade.dart`:
```dart
// target: lib/widgets/progressive_fade.dart
import 'package:flutter/material.dart';

class ProgressiveFade extends StatelessWidget {
  final Widget child;
  final double height;

  const ProgressiveFade({
    super.key,
    required this.child,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    final double end = height / MediaQuery.of(context).size.height;

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0x00FFFFFF),
            Color(0x26FFFFFF),
            Color(0x66FFFFFF),
            Color(0xB3FFFFFF),
            Color(0xFFFFFFFF),
          ],
          stops: [
            0.0,
            end * 0.25,
            end * 0.5,
            end * 0.75,
            end,
          ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}
```

Wrap the body of `unauth_home_screen.dart`:
```dart
// target
body: ProgressiveFade(
  child: SafeArea(
    child: SingleChildScrollView(...),
  ),
)
```

## Steps

1. Create `lib/widgets/progressive_fade.dart`.
2. In `lib/screens/citizen/unauth_home_screen.dart:30`, wrap `SafeArea` with `ProgressiveFade`.

## Check it

`dart analyze` exits clean.
`grep -c "ProgressiveFade" lib/screens/citizen/unauth_home_screen.dart` -> 1.

## Don't touch

- Screens with an existing AppBar.

## STOP if

- Fade height covers non-scrollable sticky headers.

## When you're done

The welcome screen dissolves gracefully under the status bar when scrolled upward.
