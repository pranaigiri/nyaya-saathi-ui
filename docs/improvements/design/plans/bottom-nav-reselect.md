# Fix: Tapping the active bottom navigation tab again does not scroll the view back to the top

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/bottom-nav-reselect
- **Needs new dependency**: none

## Why

Users expect that tapping an already-selected navigation tab will scroll that screen back to the top. Without this, users have to manually swipe all the way back up.

## Where

```dart
// lib/screens/citizen/citizen_dashboard_shell.dart:103 — current
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
```

## The fix

Store ScrollControllers for tab views and animate to offset 0 on reselect:
```dart
// target: lib/screens/citizen/citizen_dashboard_shell.dart
class _CitizenDashboardShellState extends State<CitizenDashboardShell> {
  int _currentIndex = 0;
  final List<ScrollController> _tabControllers = [
    ScrollController(),
    ScrollController(),
    ScrollController(),
    ScrollController(),
  ];

  void _onTabTapped(int index) {
    if (index == _currentIndex) {
      final controller = _tabControllers[index];
      if (controller.hasClients && controller.offset > 0) {
        controller.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
      return;
    }
    setState(() => _currentIndex = index);
  }
```

And pass controllers to the respective tab widgets.

## Steps

1. In `lib/screens/citizen/citizen_dashboard_shell.dart`, initialize `_tabControllers` and update `onTap` to check for reselect.
2. Pass controllers to tab screens (`HomeTab`, `MyApplicationsTab`, `NotificationsTab`).
3. Dispose controllers in `dispose()`.

## Check it

`dart analyze` exits clean.
`grep -c "_onTabTapped" lib/screens/citizen/citizen_dashboard_shell.dart` -> 1.

## Don't touch

- Navigation bar styling or icons.

## STOP if

- A tab controller is attached to multiple scroll views simultaneously.

## When you're done

Tapping the active navigation tab smoothly scrolls the current dashboard or application list back to the top.
