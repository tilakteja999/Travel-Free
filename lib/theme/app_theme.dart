import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF2053D5);
  static const Color darkHeaderBlue = Color(0xFF163C9B);
  static const Color lightBg = Color(0xFFF4F7FC);
  static const Color accentCyan = Color(0xFF38C5CD);
  static const Color accentGreen = Color(0xFF32C690);
  static const Color vanRed = Color(0xFFD3524B);
  static const Color vanTeal = Color(0xFF2EA5B0);
  static const Color vanOrange = Color(0xFFE56A32);
  static const Color suitcaseYellow = Color(0xFFF5B638);
  static const Color luggageCyan = Color(0xFF20B2AA);
  static const Color darkButton = Color(0xFF282F3F);
  static const Color lightCardBg = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF666666);
  static const Color starGold = Color(0xFFFFB300);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.accentCyan,
        surface: AppColors.lightBg,
      ),
      scaffoldBackgroundColor: AppColors.lightBg,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColors.lightCardBg,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkButton,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
