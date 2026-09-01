import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

enum AppFontScale { small, medium, large }

class AppTheme {
  static double getScaleFactor(AppFontScale scale) {
    switch (scale) {
      case AppFontScale.small:
        return 0.9;
      case AppFontScale.medium:
        return 1.0;
      case AppFontScale.large:
        return 1.15;
    }
  }

  static ThemeData lightTheme(AppFontScale fontScale) {
    final scale = getScaleFactor(fontScale);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.accentGold,
        surface: AppColors.lightSurface,
        error: AppColors.dangerRed,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.outfit(
              fontSize: 32 * scale,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
            titleLarge: GoogleFonts.outfit(
              fontSize: 22 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
            bodyLarge: GoogleFonts.inter(
              fontSize: 16 * scale,
              color: AppColors.textPrimaryLight,
            ),
            bodyMedium: GoogleFonts.inter(
              fontSize: 14 * scale,
              color: AppColors.textSecondaryLight,
            ),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
      listTileTheme: const ListTileThemeData(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static ThemeData darkTheme(AppFontScale fontScale) {
    final scale = getScaleFactor(fontScale);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlue,
        secondary: AppColors.accentGold,
        surface: AppColors.darkSurface,
        error: AppColors.dangerRed,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.outfit(
              fontSize: 32 * scale,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryDark,
            ),
            titleLarge: GoogleFonts.outfit(
              fontSize: 22 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryDark,
            ),
            bodyLarge: GoogleFonts.inter(
              fontSize: 16 * scale,
              color: AppColors.textPrimaryDark,
            ),
            bodyMedium: GoogleFonts.inter(
              fontSize: 14 * scale,
              color: AppColors.textSecondaryDark,
            ),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentGold, width: 2),
        ),
      ),
      listTileTheme: const ListTileThemeData(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Immersive dark theme used by the camera scanner & crop editor so the
  /// capture UI stays consistent (and readable) regardless of whether the app
  /// is running in light or dark mode.
  static ThemeData cameraTheme() {
    final base = darkTheme(AppFontScale.medium);
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0D0E15),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF161925),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      // High-contrast chips for the crop aspect-ratio selector: solid dark
      // unselected background with white labels, deep-blue selected state.
      chipTheme: const ChipThemeData(
        backgroundColor: Color(0xFF252A40),
        selectedColor: AppColors.primaryBlue,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(color: Colors.white, fontSize: 12),
        secondaryLabelStyle: TextStyle(color: Colors.white, fontSize: 12),
        side: BorderSide(color: Colors.white24),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurface,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
