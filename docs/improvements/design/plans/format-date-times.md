# Fix: Dates are shown with raw ISO strings like "2026-09-13" instead of humanized local dates

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/format-date-times
- **Needs new dependency**: none (intl is already installed)

## Why

Displaying raw technical strings like `2026-09-13T10:00:00` or `app.createdAt.split('T')[0]` degrades UX. Citizens should see clear, locale-friendly dates such as "13 Sep 2026".

## Where

```dart
// lib/screens/citizen/tabs/my_applications_tab.dart:201 — current
                          "Filed on: ${app.createdAt.split('T')[0]}",
```
```dart
// lib/screens/citizen/tracking_screen.dart:93 — current
          'date': DateTime.now().toIso8601String().split('T')[0],
```

## The fix

Create `lib/core/utils/date_extensions.dart`:
```dart
// target: lib/core/utils/date_extensions.dart
import 'package:intl/intl.dart';

extension DateTimeX on DateTime? {
  String formattedDateTime([String? locale]) {
    if (this == null) return 'N/A';
    return DateFormat('d MMM yyyy, hh:mm a', locale).format(this!);
  }

  String formattedDate([String? locale]) {
    if (this == null) return 'N/A';
    return DateFormat('d MMM yyyy', locale).format(this!);
  }

  String formattedDayOrDate([String? locale]) {
    if (this == null) return 'N/A';
    final now = DateTime.now();
    if (now.year == this!.year && now.month == this!.month && now.day == this!.day) {
      return 'Today';
    }
    return formattedDate(locale);
  }
}
```

And use in `my_applications_tab.dart`:
```dart
// target
"Filed on: ${DateTime.tryParse(app.createdAt).formattedDate()}",
```

## Steps

1. Create `lib/core/utils/date_extensions.dart`.
2. In `lib/screens/citizen/tabs/my_applications_tab.dart:201`, replace the raw split string with `DateTime.tryParse(app.createdAt).formattedDate()`.
3. In `lib/screens/citizen/tracking_screen.dart:93`, format timestamps with `.formattedDate()`.

## Check it

`dart analyze` exits clean.
`grep -c "formattedDate" lib/screens/citizen/tabs/my_applications_tab.dart` -> 1.

## Don't touch

- Supabase ISO timestamps sent to backend queries.

## STOP if

- `DateTime.tryParse` receives empty string (the extension safely returns 'N/A').

## When you're done

All application filing dates and timeline events appear formatted in localized readable text.
