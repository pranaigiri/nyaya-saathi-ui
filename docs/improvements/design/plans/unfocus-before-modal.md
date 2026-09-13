# Fix: Opening a bottom sheet or modal while an input is focused brings back the keyboard afterwards

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/unfocus-before-modal
- **Needs new dependency**: none

## Why

If a user finishes editing an input and taps a button or date picker that opens a modal, the previous field retains focus. Closing the modal causes the keyboard to spring back up unexpectedly.

## Where

```dart
// lib/screens/citizen/profile_screen.dart:250 — current
  void _openDobModal() {
    int tempYear = _dobYear;
    int tempMonth = _dobMonth;
    int tempDay = _dobDay;
```
```dart
// lib/screens/apply_flow/step2_applicant_details_screen.dart:194 — current
  void _openDobModal() {
    int tempYear = _dobYear;
    int tempMonth = _dobMonth;
    int tempDay = _dobDay;
```

## The fix

Call `FocusManager.instance.primaryFocus?.unfocus();` before presenting the modal:
```dart
// target
void _openDobModal() {
  FocusManager.instance.primaryFocus?.unfocus();
  int tempYear = _dobYear;
  ...
}
```

## Steps

1. In `lib/screens/citizen/profile_screen.dart:250`, add `FocusManager.instance.primaryFocus?.unfocus();` as the first line of `_openDobModal()`.
2. In `lib/screens/apply_flow/step2_applicant_details_screen.dart:194`, add `FocusManager.instance.primaryFocus?.unfocus();` as the first line of `_openDobModal()`.

## Check it

`dart analyze` exits clean.
`grep -c "FocusManager.instance.primaryFocus?.unfocus()" lib/screens/citizen/profile_screen.dart` -> 1.
`grep -c "FocusManager.instance.primaryFocus?.unfocus()" lib/screens/apply_flow/step2_applicant_details_screen.dart` -> 1.

## Don't touch

- Do not use `FocusScope.of(context).unfocus()` (it searches the nearest scope rather than global primary focus).

## STOP if

- Calling unfocus causes unwanted validation triggers before modal open.

## When you're done

The software keyboard closes cleanly when opening the Date of Birth picker and stays away upon dismissal.
