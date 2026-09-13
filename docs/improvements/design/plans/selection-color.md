# Fix: Text selection color does not match the app's brand theme

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/selection-color
- **Needs new dependency**: none

## Why

Material 3 defaults apply generic tinted purple/grey colors to text selection handles and highlight rectangles in input fields. Customizing `textSelectionTheme` ensures input selection harmonizes with Nyaya Saathi's primary blue brand identity.

## Where

```dart
// lib/core/theme/app_theme.dart:21 — current
  static ThemeData lightTheme(AppFontScale fontScale) {
    final scale = getScaleFactor(fontScale);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryBlue,
```
```dart
// lib/core/theme/app_theme.dart:67 — current
  static ThemeData darkTheme(AppFontScale fontScale) {
    final scale = getScaleFactor(fontScale);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryBlue,
```

## The fix

Add `textSelectionTheme` in both `lightTheme` and `darkTheme` in `lib/core/theme/app_theme.dart`:
```dart
// target
textSelectionTheme: TextSelectionThemeData(
  selectionColor: AppColors.primaryBlue.withValues(alpha: 0.3),
  selectionHandleColor: AppColors.primaryBlue,
  cursorColor: AppColors.primaryBlue,
),
```

## Steps

1. Open `lib/core/theme/app_theme.dart`.
2. In `lightTheme`, add the `textSelectionTheme` property.
3. In `darkTheme`, add the `textSelectionTheme` property.

## Check it

`dart analyze` exits clean.
`grep -c "textSelectionTheme" lib/core/theme/app_theme.dart` -> 2.

## Don't touch

- `textTheme` font configurations.
- `colorScheme` definitions.

## STOP if

- Text selection colors obscure text contrast.

## When you're done

Highlighting and selecting text inside search bars, login fields, and application forms now uses the app's signature Nyaya Saathi blue.
