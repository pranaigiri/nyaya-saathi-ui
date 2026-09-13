# Fix: Selecting a partially visible chip or tab does not scroll it into view

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/tab-visibility
- **Needs new dependency**: none

## Why

When tapping an aspect ratio chip or filter that is cut off by the edge of the viewport, the chip stays half-hidden unless the view scrolls to center it.

## Where

```dart
// lib/widgets/image_crop_editor.dart:312 — current
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _aspectChip(
```

## The fix

Assign GlobalKeys to the aspect chips and call `Scrollable.ensureVisible` with `alignment: 0.5` upon selection:
```dart
// target
void _scrollToChip(GlobalKey key) {
  final ctx = key.currentContext;
  if (ctx == null) return;
  Scrollable.ensureVisible(
    ctx,
    alignment: 0.5,
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeInOut,
  );
}
```

## Steps

1. In `lib/widgets/image_crop_editor.dart`, map a `GlobalKey` to each aspect chip option.
2. In `_aspectChip`, wrap the chip in a keyed container and trigger `_scrollToChip(key)` inside `onSelected`.

## Check it

`dart analyze` exits clean.
`grep -c "Scrollable.ensureVisible" lib/widgets/image_crop_editor.dart` -> 1.

## Don't touch

- Crop rectangle transformation logic.

## STOP if

- Calling ensureVisible on disposed context.

## When you're done

Tapping any aspect ratio option in the image crop editor smoothly centers that chip on screen.
