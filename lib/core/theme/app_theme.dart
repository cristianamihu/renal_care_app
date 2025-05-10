import 'package:flutter/material.dart';

class AppTheme {
  static final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 116, 71, 194),
  );

  static final light = ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    appBarTheme: AppBarTheme(backgroundColor: colorScheme.primary),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary),
    ),
  );
}
