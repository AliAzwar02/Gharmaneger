import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const _navy = Color(0xFF102A43);
  static const _teal = Color(0xFF138A83);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: _navy,
      primary: _navy,
      secondary: _teal,
      surface: const Color(0xFFF8FAFC),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _navy,
      brightness: Brightness.dark,
      secondary: const Color(0xFF55C6BC),
    ),
  );
}
