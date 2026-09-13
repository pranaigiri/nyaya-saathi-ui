# Fix: Tapping padding and gaps inside custom rows and overlays fails to register

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/gesture-detector-hit-area
- **Needs new dependency**: none

## Why

By default, Flutter's `GestureDetector` only detects hits on painted pixels of its children. Taps on unpainted padding, margins, or canvas cutouts fall through silently, causing frustrating missed taps.

## Where

```dart
// lib/widgets/image_crop_editor.dart:470 — current
    return GestureDetector(
      onPanStart: (details) {
```
```dart
// lib/screens/citizen/profile_screen.dart:609 — current
                    GestureDetector(
                      onTap: _openDobModal,
                      child: Container(
```
```dart
// lib/screens/apply_flow/step2_applicant_details_screen.dart:900 — current
    return GestureDetector(
      onTap: onTap,
      child: Container(
```
```dart
// lib/widgets/document_scanner_modal.dart:583 — current
                      GestureDetector(
                        onTap: _captureAndProceed,
                        child: Container(
```

## The fix

Add `behavior: HitTestBehavior.opaque` to each affected `GestureDetector`:
```dart
// target
GestureDetector(
  behavior: HitTestBehavior.opaque,
  onTap: ...,
  child: ...,
)
```

## Steps

1. In `lib/widgets/image_crop_editor.dart:470`, add `behavior: HitTestBehavior.opaque,`.
2. In `lib/screens/citizen/profile_screen.dart:609`, add `behavior: HitTestBehavior.opaque,`.
3. In `lib/screens/apply_flow/step2_applicant_details_screen.dart:900`, add `behavior: HitTestBehavior.opaque,`.
4. In `lib/widgets/document_scanner_modal.dart:583`, add `behavior: HitTestBehavior.opaque,`.

## Check it

`dart analyze` exits clean.
`grep -c "HitTestBehavior.opaque" lib/screens/citizen/profile_screen.dart` -> at least 1.

## Don't touch

- Drag handler coordinate logic.

## STOP if

- Adding opaque blocks interaction with an intentionally clickable underlying widget.

## When you're done

The entire bounding box of input selectors, crop handles, and capture buttons is now reliably responsive to touch.
