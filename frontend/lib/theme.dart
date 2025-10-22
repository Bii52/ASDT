import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1EBEB6)),
        scaffoldBackgroundColor: const Color(0xFFF7FAF9),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF1A7D78)),
        ),
      );

  static ThemeData get dark => ThemeData.dark(useMaterial3: true);
}
