import 'package:flutter/material.dart';

class ProgressiveFade extends StatelessWidget {
  final Widget child;
  final double height;

  const ProgressiveFade({
    super.key,
    required this.child,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    final double end = height / MediaQuery.of(context).size.height;

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0x00FFFFFF),
            Color(0x26FFFFFF),
            Color(0x66FFFFFF),
            Color(0xB3FFFFFF),
            Color(0xFFFFFFFF),
          ],
          stops: [
            0.0,
            end * 0.25,
            end * 0.5,
            end * 0.75,
            end,
          ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}
