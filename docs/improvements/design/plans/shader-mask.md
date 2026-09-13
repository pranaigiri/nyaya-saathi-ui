# Fix: Horizontal lists do not visually signal that they are scrollable

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/shader-mask
- **Needs new dependency**: none

## Why

Horizontal lists whose elements neatly fit within the view give no indication that more choices exist past the edge. Fading the end edge with a subtle gradient mask naturally cues the user to scroll.

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

Wrap horizontal scrollables in an `Edgy` shader mask widget:
```dart
// target: lib/widgets/edgy.dart
import 'package:flutter/material.dart';

class Edgy extends StatelessWidget {
  final Widget child;
  final Axis axis;
  final bool fadeStart;
  final bool fadeEnd;

  const Edgy({
    super.key,
    required this.child,
    this.axis = Axis.horizontal,
    this.fadeStart = false,
    this.fadeEnd = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isVertical = axis == Axis.vertical;

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: isVertical ? Alignment.topCenter : Alignment.centerLeft,
          end: isVertical ? Alignment.bottomCenter : Alignment.centerRight,
          colors: <Color>[
            fadeStart ? const Color(0x00FFFFFF) : const Color(0xFFFFFFFF),
            const Color(0xFFFFFFFF),
            const Color(0xFFFFFFFF),
            fadeEnd ? const Color(0x00FFFFFF) : const Color(0xFFFFFFFF),
          ],
          stops: const <double>[0.0, 0.08, 0.92, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}
```

And wrap the horizontal scrollable in `lib/widgets/image_crop_editor.dart`:
```dart
// target
Edgy(
  axis: Axis.horizontal,
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(...),
  ),
)
```

## Steps

1. Create `lib/widgets/edgy.dart`.
2. In `lib/widgets/image_crop_editor.dart:312`, wrap `SingleChildScrollView` with `Edgy(axis: Axis.horizontal, child: ...)`.

## Check it

`dart analyze` exits clean.
`grep -c "Edgy" lib/widgets/image_crop_editor.dart` -> 1.

## Don't touch

- Aspect ratio calculations in `_applyAspectRatio`.
- Other non-horizontal views.

## STOP if

- BlendMode fails to apply or causes color distortion.

## When you're done

The aspect ratio selector in the image cropping editor now smoothly fades at the screen edge, showing users there are more ratio options to explore.
