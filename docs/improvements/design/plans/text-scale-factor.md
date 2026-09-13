# Fix: Excessive device text scaling causes UI components to overflow and break

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/text-scale-factor
- **Needs new dependency**: none

## Why

When users have system font sizes set to extreme magnification (e.g. 1.8x - 2.0x), modal dialogs, buttons, and badges suffer yellow-and-black pixel overflow stripes. Clamping the maximum text scale factor to 1.15x retains accessibility while preserving visual layout integrity.

## Where

```dart
// lib/main.dart:93 — current
    return MaterialApp(
      navigatorKey: NotificationService.instance.navigatorKey,
      title: 'Nyaya Saathi',
```

## The fix

Add a clamp on `MediaQuery.textScaler` inside `MaterialApp.builder`:
```dart
// target: in lib/main.dart
    return MaterialApp(
      navigatorKey: NotificationService.instance.navigatorKey,
      title: 'Nyaya Saathi',
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(maxScaleFactor: 1.15),
          ),
          child: child!,
        );
      },
```

## Steps

1. In `lib/main.dart:93`, add the `builder` property with `textScaler.clamp(maxScaleFactor: 1.15)`.

## Check it

`dart analyze` exits clean.
`grep -c "maxScaleFactor: 1.15" lib/main.dart` -> 1.

## Don't touch

- App's internal font scaler toggle in `ThemeProvider`.

## STOP if

- Clamping removes user text scaling below 1.0x.

## When you're done

The app remains accessible on large text preferences while avoiding broken layouts and overflow warnings.
