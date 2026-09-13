# Fix: Vertical scrollable views lack scroll indicators on mobile

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/scrollbars
- **Needs new dependency**: none

## Why

Without a scrollbar, users reading long legal aid guidelines or extensive case histories cannot tell how much content remains or where they are in the document.

## Where

```dart
// lib/main.dart:93 — current
    return MaterialApp(
      navigatorKey: NotificationService.instance.navigatorKey,
      title: 'Nyaya Saathi',
```

## The fix

Create an app-wide scroll behavior that provides scrollbars automatically across all standard vertical scrollables:
```dart
// target: lib/core/theme/always_scrollbar_behavior.dart
import 'package:flutter/material.dart';

class AlwaysScrollbarBehavior extends MaterialScrollBehavior {
  const AlwaysScrollbarBehavior();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return Scrollbar(
      controller: details.controller,
      child: child,
    );
  }
}
```

And configure in `lib/main.dart`:
```dart
// target
return MaterialApp(
  scrollBehavior: const AlwaysScrollbarBehavior(),
  ...
);
```

## Steps

1. Create `lib/core/theme/always_scrollbar_behavior.dart`.
2. In `lib/main.dart`, add `scrollBehavior: const AlwaysScrollbarBehavior(),` to `MaterialApp`.

## Check it

`dart analyze` exits clean.
`grep -c "AlwaysScrollbarBehavior" lib/main.dart` -> 1.

## Don't touch

- Horizontal scrolling chips or carousels.

## STOP if

- Double scrollbars appear on desktop platforms.

## When you're done

Every scrollable screen across the application now features an indicator showing position and list length.
