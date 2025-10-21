import 'package:flutter/material.dart';

class AppColors {
  // Light theme colors
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF6366F1);
  static const Color lightText = Color(0xFF1F2937);
  static const Color lightSubtext = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightToggleBg = Color(0xFFF3F4F6);
  static const Color lightGradientStart = Color(0xFFF9FAFB);
  static const Color lightSuccess = Color(0xFF10B981);
  static const Color lightShadow = Color(0x1F000000);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF111827);
  static const Color darkSurface = Color(0xFF1F2937);
  static const Color darkPrimary = Color(0xFF818CF8);
  static const Color darkText = Color(0xFFF9FAFB);
  static const Color darkSubtext = Color(0xFF9CA3AF);
  static const Color darkBorder = Color(0xFF374151);
  static const Color darkToggleBg = Color(0xFF374151);
  static const Color darkGradientStart = Color(0xFF1F2937);
  static const Color darkSuccess = Color(0xFF34D399);
  static const Color darkShadow = Color(0x1FFFFFFF);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightText,
      primary: AppColors.lightPrimary,
      onPrimary: Colors.white,
      secondary: AppColors.lightPrimary,
      onSecondary: Colors.white,
      outline: AppColors.lightBorder,
      shadow: AppColors.lightShadow,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      foregroundColor: AppColors.lightText,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.lightSurface,
      elevation: 2,
      shadowColor: AppColors.lightShadow,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.lightBackground,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightGradientStart,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightPrimary),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      primary: AppColors.darkPrimary,
      onPrimary: Colors.black,
      secondary: AppColors.darkPrimary,
      onSecondary: Colors.black,
      outline: AppColors.darkBorder,
      shadow: AppColors.darkShadow,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkText,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.darkSurface,
      elevation: 2,
      shadowColor: AppColors.darkShadow,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.darkBackground,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkPrimary),
      ),
    ),
  );
}
