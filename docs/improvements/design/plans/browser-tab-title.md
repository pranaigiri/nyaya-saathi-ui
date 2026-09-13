# Fix: Browser tabs display a single static title across all distinct screens on web

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/browser-tab-title
- **Needs new dependency**: none

## Why

When multiple browser tabs or history items are open, every page says the same static app name. Users cannot distinguish between their Application Form, Case Detail, and Dashboard tabs.

## Where

```dart
// lib/screens/citizen/citizen_dashboard_shell.dart:29 — current
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr("app_title")),
```
```dart
// lib/screens/citizen/application_detail_screen.dart:266 — current
    return Scaffold(
      appBar: AppBar(
        title: Text(
          application != null
              ? "Application #${application.applicationNumber}"
              : "Application Details",
        ),
```

## The fix

Wrap primary screens in Flutter's built-in `Title` widget:
```dart
// target: in citizen_dashboard_shell.dart
return Title(
  title: 'Dashboard · Nyaya Saathi',
  color: AppColors.primaryBlue,
  child: Scaffold(...),
);
```
```dart
// target: in application_detail_screen.dart
return Title(
  title: 'Application Details · Nyaya Saathi',
  color: AppColors.primaryBlue,
  child: Scaffold(...),
);
```

## Steps

1. In `lib/screens/citizen/citizen_dashboard_shell.dart:29`, wrap `Scaffold` in `Title(title: 'Dashboard · Nyaya Saathi', color: AppColors.primaryBlue, child: ...)`.
2. In `lib/screens/citizen/application_detail_screen.dart:266`, wrap `Scaffold` in `Title(title: 'Application Details · Nyaya Saathi', color: AppColors.primaryBlue, child: ...)`.

## Check it

`dart analyze` exits clean.
`grep -c "Title(" lib/screens/citizen/citizen_dashboard_shell.dart` -> 1.
`grep -c "Title(" lib/screens/citizen/application_detail_screen.dart` -> 1.

## Don't touch

- Modal dialogs or bottom sheets.

## STOP if

- Title.color is not fully opaque (alpha 0xFF required).

## When you're done

Switching between browser tabs clearly identifies the open screen name in the browser header.
