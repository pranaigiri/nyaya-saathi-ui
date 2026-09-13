# Fix: The software keyboard stays open and covers the screen when the user scrolls a form

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/dismiss-keyboard-on-scroll
- **Needs new dependency**: none

## Why

When finishing an input field, users naturally drag down to see subsequent fields or the submit button. Leaving the keyboard pinned obscures half the view. Setting `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag` automatically closes the keyboard on gesture.

## Where

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
// lib/screens/citizen/profile_screen.dart:453 — current
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
```
```dart
// lib/screens/citizen/tracking_screen.dart:396 — current
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
```

## The fix

Add `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag` to form scrollables:
```dart
// target
body: SingleChildScrollView(
  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
  padding: const EdgeInsets.all(24),
  child: Column(...),
)
```

## Steps

1. In `lib/screens/auth/login_screen.dart:76`, add `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag`.
2. In `lib/screens/auth/register_screen.dart:148`, add `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag`.
3. In `lib/screens/citizen/profile_screen.dart:453`, add `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag`.
4. In `lib/screens/citizen/tracking_screen.dart:396`, add `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag`.

## Check it

`dart analyze` exits clean.
`grep -c "ScrollViewKeyboardDismissBehavior.onDrag" lib/screens/auth/login_screen.dart` -> 1.
`grep -c "ScrollViewKeyboardDismissBehavior.onDrag" lib/screens/auth/register_screen.dart` -> 1.

## Don't touch

- Do not set `keyboardDismissBehavior: onDrag` in `lib/screens/citizen/tabs/chat_tab.dart` (chat streams must allow scrolling while typing).

## STOP if

- A scrollable is not a ScrollView subclass.

## When you're done

Scrolling down on any login, register, profile, or tracking form immediately dismisses the on-screen keyboard.
