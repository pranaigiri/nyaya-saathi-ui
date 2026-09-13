import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Light Mode)
  static const Color primaryBlue = Color(0xFF1E3A8A); // Deep Slate / Sapphire Blue
  static const Color primaryDark = Color(0xFF0F172A); // Dark Slate
  static const Color accentGold = Color(0xFFD97706);  // Emblematical Gold
  static const Color successGreen = Color(0xFF059669); // Emerald Status
  static const Color warningOrange = Color(0xFFEA580C);
  static const Color dangerRed = Color(0xFFDC2626);
  static const Color infoCyan = Color(0xFF0891B2);

  // Calibrated Semantic Dark Colors (High-Contrast & Non-muddy on dark surfaces)
  static const Color darkPrimary = Color(0xFF3B82F6);    // Vibrant Cobalt
  static const Color mintGreen = Color(0xFF10B981);      // Radiant Mint (Success / Resolved)
  static const Color amberGold = Color(0xFFF59E0B);      // Luminous Amber (In Progress / Scrutiny)
  static const Color coralOrange = Color(0xFFFB923C);    // Warm Coral (Warning / Action needed)
  static const Color roseRed = Color(0xFFF87171);        // Pastel Rose (Danger / Rejected)
  static const Color skyBlue = Color(0xFF38BDF8);        // Sky Blue (Info / Tracking mono)

  // Backgrounds & Surface Elevation Scale
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightSurface2 = Color(0xFFF1F5F9);

  // Dark Neutral Charcoal Elevation Scale (replaces flat navy #0F172A)
  static const Color darkBg = Color(0xFF111215);        // Surface 0: Base Canvas
  static const Color darkSurface = Color(0xFF191B20);   // Surface 1: Base Cards / Containers
  static const Color darkSurface1 = Color(0xFF191B20);  // Alias for Surface 1
  static const Color darkSurface2 = Color(0xFF23262E);  // Surface 2: Elevated Cards / Action Tiles / Inputs
  static const Color darkSurface3 = Color(0xFF2D323C);  // Surface 3: Dialogs / Overlays / Active States

  // Text
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Card & Glass
  static Color glassLight = Colors.white.withValues(alpha: 0.85);
  static Color glassDark = const Color(0xFF191B20).withValues(alpha: 0.85);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF282C34);     // Neutral dark border
  static const Color borderDarkSubtle = Color(0x1FFFFFFF); // 12% white subtle border
  static const Color borderDarkAccent = Color(0x33FFFFFF); // 20% white accent border
}
