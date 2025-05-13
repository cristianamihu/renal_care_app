import 'package:flutter/material.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    // fundalul general
    scaffoldBackgroundColor: AppColors.backgroundColor,

    // culoarea "principala" a aplicației
    primaryColor: AppColors.gradient1,
    // folosită de unele widget-uri ca secundară
    secondaryHeaderColor: AppColors.gradient2,

    // definim întregul ColorScheme pe baza AppColors
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.gradient1,
      onPrimary: AppColors.whiteColor,
      secondary: AppColors.gradient2,
      onSecondary: AppColors.whiteColor,
      surface: AppColors.backgroundColor,
      onSurface: AppColors.whiteColor,
      error: Colors.red,
      onError: AppColors.whiteColor,
    ),

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.gradient1,
      foregroundColor: AppColors.whiteColor,
    ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gradient2,
        foregroundColor: AppColors.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),

    // TextButton (link‐uri, etc)
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.gradient1),
    ),

    // InputDecoration (TextField, Dropdown, etc)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.backgroundColor,
      labelStyle: TextStyle(color: AppColors.whiteColor),
      prefixIconColor: AppColors.whiteColor,
      suffixIconColor: AppColors.whiteColor,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.whiteColor),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // Stilul link‐urilor din Divider/text
    dividerColor: AppColors.whiteColor.withValues(alpha: 0.3),
  );

  //static final colorScheme = ColorScheme.fromSeed(
  //  seedColor: const Color.fromARGB(255, 116, 71, 194),
  //);

  //static final light = ThemeData(
  //  colorScheme: colorScheme,
  //  useMaterial3: true,
  //  appBarTheme: AppBarTheme(backgroundColor: colorScheme.primary),
  //  elevatedButtonTheme: ElevatedButtonThemeData(
  //    style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary),
  //  ),
  //);
}
