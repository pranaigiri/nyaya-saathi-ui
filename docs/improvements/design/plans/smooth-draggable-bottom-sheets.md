# Fix: Modal bottom sheets open and close with rigid, mechanical animations

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/smooth-draggable-bottom-sheets
- **Needs new dependency**: none

## Why

Material's default `showModalBottomSheet` opens and dismisses with a mechanical slide. Small non-scrolling modals feel much more native and tactile when driven by spring physics that preserve the velocity of user drags.

## Where

```dart
// lib/screens/citizen/profile_screen.dart:259 — current
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
```
```dart
// lib/screens/apply_flow/step2_applicant_details_screen.dart:202 — current
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
```

## The fix

Create `lib/widgets/spring_bottom_sheet.dart` implementing `showSpringBottomSheet` and `SpringSheetRoute` with critically damped spring physics.

Use `showSpringBottomSheet` for non-scrolling sheets:
```dart
// target
showSpringBottomSheet<void>(
  context: context,
  builder: (ctx) => DateOfBirthPickerModal(...),
);
```

## Steps

1. Create `lib/widgets/spring_bottom_sheet.dart` implementing `SpringSheetRoute` and `showSpringBottomSheet`.
2. In `lib/screens/citizen/profile_screen.dart:259`, replace `showModalBottomSheet` with `showSpringBottomSheet`.
3. In `lib/screens/apply_flow/step2_applicant_details_screen.dart:202`, replace `showModalBottomSheet` with `showSpringBottomSheet`.

## Check it

`dart analyze` exits clean.
`grep -c "showSpringBottomSheet" lib/screens/citizen/profile_screen.dart` -> 1.

## Don't touch

- Full-screen wizards or multi-step modal dialogs.

## STOP if

- Nested scrollable inside sheet conflicts with drag physics.

## When you're done

The Date of Birth selector slides into view with a natural spring and can be effortlessly flicked down to dismiss.
