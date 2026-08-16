import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Controller to trigger Captcha refresh and validate input
class CaptchaController {
  _CaptchaBoxState? _state;

  void _bindState(_CaptchaBoxState state) {
    _state = state;
  }

  void _unbindState() {
    _state = null;
  }

  /// Generate a new challenge code
  void refresh() {
    _state?.generateNewCode();
  }

  /// Current raw captcha code
  String? get code => _state?.currentCode;

  /// Validate user input against current code (case-insensitive)
  bool validate(String input) {
    if (_state == null || _state!.currentCode.isEmpty) return false;
    return _state!.currentCode.trim().toUpperCase() == input.trim().toUpperCase();
  }
}

class CaptchaBox extends StatefulWidget {
  final CaptchaController? controller;
  final ValueChanged<String>? onCodeChanged;
  final int length;

  const CaptchaBox({
    super.key,
    this.controller,
    this.onCodeChanged,
    this.length = 5,
  });

  @override
  State<CaptchaBox> createState() => _CaptchaBoxState();
}

class _CaptchaBoxState extends State<CaptchaBox> with SingleTickerProviderStateMixin {
  late String _currentCode;
  late AnimationController _animController;
  final Random _random = Random();

  String get currentCode => _currentCode;

  // Characters excluding ambiguous 0, O, 1, I, l
  static const String _charset = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';

  @override
  void initState() {
    super.initState();
    widget.controller?._bindState(this);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _currentCode = _generateRandomString(widget.length);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCodeChanged?.call(_currentCode);
    });
  }

  @override
  void didUpdateWidget(covariant CaptchaBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._unbindState();
      widget.controller?._bindState(this);
    }
  }

  @override
  void dispose() {
    widget.controller?._unbindState();
    _animController.dispose();
    super.dispose();
  }

  String _generateRandomString(int length) {
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.write(_charset[_random.nextInt(_charset.length)]);
    }
    return buffer.toString();
  }

  void generateNewCode() {
    _animController.forward(from: 0.0);
    setState(() {
      _currentCode = _generateRandomString(widget.length);
    });
    widget.onCodeChanged?.call(_currentCode);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Captcha visual canvas
          Container(
            width: 140,
            height: 48,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CustomPaint(
              painter: _CaptchaPainter(
                code: _currentCode,
                isDark: isDark,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Refresh Button
          IconButton(
            tooltip: "Get New CAPTCHA",
            icon: RotationTransition(
              turns: _animController,
              child: const Icon(
                Icons.refresh_rounded,
                color: AppColors.primaryBlue,
                size: 26,
              ),
            ),
            onPressed: generateNewCode,
          ),
        ],
      ),
    );
  }
}

class _CaptchaPainter extends CustomPainter {
  final String code;
  final bool isDark;

  _CaptchaPainter({
    required this.code,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(code.hashCode);

    // Draw background security lines
    final linePaint = Paint()
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 6; i++) {
      linePaint.color = (isDark ? Colors.blueGrey.shade700 : Colors.blueGrey.shade300)
          .withValues(alpha: 0.4 + random.nextDouble() * 0.4);
      final p1 = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      final p2 = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      canvas.drawLine(p1, p2, linePaint);
    }

    // Draw background noise dots
    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 25; i++) {
      dotPaint.color = (isDark ? Colors.cyan.shade300 : Colors.blueAccent)
          .withValues(alpha: 0.15 + random.nextDouble() * 0.3);
      final center = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      canvas.drawCircle(center, 1.2 + random.nextDouble() * 1.5, dotPaint);
    }

    // Draw characters with rotation and distinct colors
    final colors = isDark
        ? [
            const Color(0xFF60A5FA),
            const Color(0xFF34D399),
            const Color(0xFFFBBF24),
            const Color(0xFFF472B6),
            const Color(0xFFA78BFA),
          ]
        : [
            const Color(0xFF1E3A8A),
            const Color(0xFF047857),
            const Color(0xFFB45309),
            const Color(0xFF6D28D9),
            const Color(0xFFBE185D),
          ];

    final charSpacing = size.width / (code.length + 0.8);

    for (int i = 0; i < code.length; i++) {
      final char = code[i];
      final color = colors[i % colors.length];

      final textSpan = TextSpan(
        text: char,
        style: TextStyle(
          color: color,
          fontSize: 22 + (random.nextDouble() * 4 - 2),
          fontWeight: FontWeight.w900,
          fontFamily: 'monospace',
          letterSpacing: 2,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final angle = (random.nextDouble() * 0.5 - 0.25); // -15 to +15 deg
      final x = 8.0 + (i * charSpacing) + (random.nextDouble() * 4 - 2);
      final y = (size.height - textPainter.height) / 2 + (random.nextDouble() * 6 - 3);

      canvas.save();
      canvas.translate(x + textPainter.width / 2, y + textPainter.height / 2);
      canvas.rotate(angle);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    // Strike-through wavy line across the text
    final wavePaint = Paint()
      ..color = (isDark ? Colors.amber.shade400 : AppColors.accentGold).withValues(alpha: 0.5)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * (0.4 + random.nextDouble() * 0.2));
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * (random.nextDouble() * 0.8),
      size.width,
      size.height * (0.3 + random.nextDouble() * 0.4),
    );
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant _CaptchaPainter oldDelegate) {
    return oldDelegate.code != code || oldDelegate.isDark != isDark;
  }
}
