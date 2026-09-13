# Fix: Raw "null" string or blank spots appear on screen when data is empty

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/never-show-null
- **Needs new dependency**: none

## Why

When an API response returns `null` or serializes to the literal string `"null"`, scattered `?? '-'` operators fail to catch empty or `"null"` values. Users see technical `null` strings or awkward empty gaps.

## Where

```dart
// lib/screens/citizen/application_detail_screen.dart:246 — current
• Category: ${app.categoryName ?? 'Legal Aid'}
```
```dart
// lib/screens/citizen/application_detail_screen.dart:422 — current
                      : (application.villageOrTown ?? 'N/A'),
```
```dart
// lib/screens/citizen/application_detail_screen.dart:1250 — current
        advocate?.fullName ??
        application.assignedAdvocateName ??
        'Advocate Pending Assignment',
```

## The fix

Create `lib/core/utils/string_extensions.dart`:
```dart
// target: lib/core/utils/string_extensions.dart
extension StringX on String? {
  bool get isUsable {
    return this != null && this!.trim().isNotEmpty && this!.trim().toLowerCase() != 'null';
  }

  String orPlaceholder([String placeholder = '-']) {
    if (!isUsable) return placeholder;
    return this!;
  }
}
```

Use it in display widgets:
```dart
// target
Text(application.villageOrTown.orPlaceholder('N/A'))
```

## Steps

1. Create `lib/core/utils/string_extensions.dart`.
2. Import it in `lib/screens/citizen/application_detail_screen.dart`.
3. Replace raw fallbacks on `categoryName`, `villageOrTown`, and `assignedAdvocateName` with `.orPlaceholder()`.

## Check it

`dart analyze` exits clean.
`grep -c "orPlaceholder" lib/screens/citizen/application_detail_screen.dart` -> at least 2.

## Don't touch

- Business logic that validates required fields for form submission.

## STOP if

- String extension breaks existing null assertion operators.

## When you're done

Missing or null fields in case records now consistently display clean placeholders like '-' or 'N/A' instead of broken strings.
