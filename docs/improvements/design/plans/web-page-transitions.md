# Fix: Web and desktop builds use jarring mobile slide and zoom page transitions

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/web-page-transitions
- **Needs new dependency**: none

## Why

Mobile sliding and zooming transitions look out of place and slow on desktop browsers and desktop operating systems. The web should open pages instantly without slide animations.

## Where

```dart
// lib/core/theme/app_theme.dart:21 — current
  static ThemeData lightTheme(AppFontScale fontScale) {
```
```dart
// lib/core/theme/app_theme.dart:67 — current
  static ThemeData darkTheme(AppFontScale fontScale) {
```

## The fix

Define `appPageTransitionsTheme` in `lib/core/theme/app_theme.dart`:
```dart
// target: in lib/core/theme/app_theme.dart
import 'package:flutter/foundation.dart';

const PageTransitionsTheme appPageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: kIsWeb ? _NoPageTransitionsBuilder() : ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: kIsWeb ? _NoPageTransitionsBuilder() : CupertinoPageTransitionsBuilder(),
    TargetPlatform.macOS: _NoPageTransitionsBuilder(),
    TargetPlatform.windows: _NoPageTransitionsBuilder(),
    TargetPlatform.linux: _NoPageTransitionsBuilder(),
    TargetPlatform.fuchsia: _NoPageTransitionsBuilder(),
  },
);

class _NoPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoPageTransitionsBuilder();

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => Duration.zero;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
```

And set `pageTransitionsTheme: appPageTransitionsTheme` in both `lightTheme` and `darkTheme`.

## Steps

1. Add `appPageTransitionsTheme` and `_NoPageTransitionsBuilder` to `lib/core/theme/app_theme.dart`.
2. Add `pageTransitionsTheme: appPageTransitionsTheme` to `ThemeData` in `lightTheme` and `darkTheme`.

## Check it

`dart analyze` exits clean.
`grep -c "appPageTransitionsTheme" lib/core/theme/app_theme.dart` -> 3.

## Don't touch

- Native iOS/Android transitions on physical mobile devices.

## STOP if

- Web navigation throws a transition animation exception.

## When you're done

Pages on web and desktop switch instantly on click, while mobile keeps its natural native sliding transitions.
