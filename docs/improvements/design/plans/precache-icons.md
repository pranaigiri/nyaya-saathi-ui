# Fix: Asset images and emblems pop in late after startup

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/precache-icons
- **Needs new dependency**: none

## Why

Asset images like `app_logo.png` and `sikkim_emblem.png` must be decoded into GPU memory when first rendered. Without precaching during splash, they flash or pop in a few frames after the UI appears.

## Where

```dart
// lib/screens/splash/splash_screen.dart:45 — current
  @override
  void initState() {
    super.initState();
    _splashStartTime = DateTime.now();
    _initApp();
  }
```

## The fix

Precache primary assets in `didChangeDependencies` or during `_initApp` in `SplashScreen`:
```dart
// target
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/app_logo.png'), context);
    precacheImage(const AssetImage('assets/images/sikkim_emblem.png'), context);
  }
```

## Steps

1. In `lib/screens/splash/splash_screen.dart`, implement `didChangeDependencies` to call `precacheImage` for `assets/images/app_logo.png` and `assets/images/sikkim_emblem.png`.

## Check it

`dart analyze` exits clean.
`grep -c "precacheImage" lib/screens/splash/splash_screen.dart` -> 2.

## Don't touch

- Do not alter splash screen animations or delay timers.

## STOP if

- Assets fail to resolve at the given path.

## When you're done

The state emblem and app logo render instantly on frame zero without pop-in when transitioning between screens.
