# Fix: Numbers and counts are rendered as raw unformatted digits

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/format-numbers-for-humans
- **Needs new dependency**: none (intl is already installed)

## Why

Raw unformatted numbers like `12345` are difficult to read and do not follow the user's regional conventions. Big counts and statistics should be humanized according to locale.

## Where

```dart
// lib/screens/citizen/application_detail_screen.dart:1412 — current
                                Text(
                                  "$experience Years Bar Experience",
                                  style: const TextStyle(
```
```dart
// lib/screens/apply_flow/step5_review_submit_screen.dart:276 — current
                title: "Uploaded Documents (${draft.documentStoragePaths.length} Attached)",
```

## The fix

Create `lib/core/utils/number_extensions.dart`:
```dart
// target: lib/core/utils/number_extensions.dart
import 'package:intl/intl.dart';

extension NumX on num {
  String humanizedCount({int? decimalDigits, String? locale}) {
    return NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: decimalDigits,
    ).format(this);
  }

  String humanizedCurrency(String code, {String? locale}) {
    return NumberFormat.simpleCurrency(name: code, locale: locale).format(this);
  }

  String humanizedCompact({String? locale}) {
    return NumberFormat.compact(locale: locale).format(this);
  }
}
```

Use it in UI files:
```dart
// target
Text("${experience.humanizedCount()} Years Bar Experience")
```

## Steps

1. Create `lib/core/utils/number_extensions.dart`.
2. In `lib/screens/citizen/application_detail_screen.dart:1412`, replace `"$experience Years Bar Experience"` with `"${experience.humanizedCount()} Years Bar Experience"`.
3. In `lib/screens/apply_flow/step5_review_submit_screen.dart:276`, format `draft.documentStoragePaths.length.humanizedCount()`.

## Check it

`dart analyze` exits clean.
`grep -c "humanizedCount" lib/screens/citizen/application_detail_screen.dart` -> 1.

## Don't touch

- Tracking application number formatter (which formats alphanumeric codes).

## STOP if

- NumberFormat produces syntax error with integer primitives.

## When you're done

Numeric metrics and counts throughout case reviews now format with regional digit grouping.
