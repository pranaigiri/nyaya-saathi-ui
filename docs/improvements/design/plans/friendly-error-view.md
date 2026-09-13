# Fix: Broken widgets display a blank grey box in production and red screen in debug

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/friendly-error-view
- **Needs new dependency**: none

## Why

When an unexpected rendering error occurs in production, users see an empty grey box or jarring crash. Installing a custom `ErrorWidget.builder` shows a polite, themed recovery screen and allows long-pressing to copy debugging details to the clipboard.

## Where

```dart
// lib/main.dart:24 — current
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
```

## The fix

Create `lib/widgets/friendly_error_view.dart` containing the complete, responsive `FriendlyErrorView` widget with debug stack inspection and hidden long-press error copying.

And register it in `main.dart`:
```dart
// target: in lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (details) => FriendlyErrorView(details: details);
```

## Steps

1. Create `lib/widgets/friendly_error_view.dart` containing `FriendlyErrorView`.
2. In `lib/main.dart`, import `lib/widgets/friendly_error_view.dart` and set `ErrorWidget.builder`.

## Check it

`dart analyze` exits clean.
`grep -c "ErrorWidget.builder" lib/main.dart` -> 1.

## Don't touch

- Async error handling in `runZonedGuarded` or Firebase Crashlytics.

## STOP if

- The error widget causes recursive error throws when rendering.

## When you're done

Any broken widget renders as a calm, branded message with zero technical jargon, and long-pressing lets QA copy stack traces.
