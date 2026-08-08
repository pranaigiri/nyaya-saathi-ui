import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF1E3A8A); // Deep Slate Blue
  static const Color primaryDark = Color(0xFF0F172A); // Dark Slate background
  static const Color accentGold = Color(0xFFD97706);  // Emblematical Gold
  static const Color successGreen = Color(0xFF059669); // Emerald Status
  static const Color warningOrange = Color(0xFFEA580C);
  static const Color dangerRed = Color(0xFFDC2626);
  static const Color infoCyan = Color(0xFF0891B2);

  // Backgrounds
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);

  // Text
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Card & Glass
  static Color glassLight = Colors.white.withValues(alpha: 0.85);
  static Color glassDark = const Color(0xFF1E293B).withValues(alpha: 0.85);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);
}
