import 'package:flutter/material.dart';

/// Industrial-light palette — not casino gold, not jelly hypercasual.
class AppColors {
  static const background = Color(0xFFF2F0EB);
  static const surface = Color(0xFFE8E4DC);
  static const surfaceDark = Color(0xFFD4CFC4);
  static const ink = Color(0xFF2C2A26);
  static const inkMuted = Color(0xFF6B6560);
  static const primary = Color(0xFF3D5A4C); // industrial green
  static const primaryLight = Color(0xFF5A7A6A);
  static const accent = Color(0xFFC4A35A); // muted brass
  static const plastic = Color(0xFF4A7AB5); // blue
  static const metal = Color(0xFF8A8E93); // grey
  static const paper = Color(0xFF9A6B3E); // brown
  static const money = Color(0xFF2E7D4F);
  static const dangerSoft = Color(0xFFB85C4A);
  static const yardDirty = Color(0xFF8B7355);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
    );
    return base.copyWith(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.surfaceDark, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
    );
  }
}
