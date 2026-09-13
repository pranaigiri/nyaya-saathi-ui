# Fix: Text briefly swaps fonts on initial boot because fonts download late

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/google-fonts-glitch
- **Needs new dependency**: none

## Why

The `google_fonts` package fetches fonts on demand when first displayed. On fresh app launch, text flashes from the system default typeface to Outfit/Inter. Preloading pending fonts during the splash screen ensures immediate typographical fidelity.

## Where

```dart
// lib/screens/splash/splash_screen.dart:58 — current
  Future<void> _initApp() async {
    try {
      await Future.wait([
        _loadAppData(),
        _waitForIntroAnimation(),
      ]);
```

## The fix

Await `GoogleFonts.pendingFonts` with the exact weights used by Nyaya Saathi:
```dart
// target: in _initApp in splash_screen.dart
      await Future.wait([
        GoogleFonts.pendingFonts([
          GoogleFonts.inter(fontWeight: FontWeight.w400),
          GoogleFonts.inter(fontWeight: FontWeight.w500),
          GoogleFonts.inter(fontWeight: FontWeight.w600),
          GoogleFonts.outfit(fontWeight: FontWeight.w600),
          GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ]),
        _loadAppData(),
        _waitForIntroAnimation(),
      ]);
```

## Steps

1. In `lib/screens/splash/splash_screen.dart`, import `package:google_fonts/google_fonts.dart`.
2. Add `GoogleFonts.pendingFonts([...])` into the `Future.wait` call inside `_initApp()`.

## Check it

`dart analyze` exits clean.
`grep -c "pendingFonts" lib/screens/splash/splash_screen.dart` -> 1.

## Don't touch

- Theme text scales in `AppTheme`.

## STOP if

- Offline launch triggers unhandled network exception during font preload (pendingFonts gracefully caches or falls back).

## When you're done

All screens boot with Outfit and Inter rendered cleanly from frame one without font popping.
