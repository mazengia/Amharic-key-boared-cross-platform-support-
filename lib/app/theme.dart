import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,

      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6D4C41),
        brightness: Brightness.light,
      ),

      fontFamily: 'Sans',

      scaffoldBackgroundColor: const Color(0xFFF7F5F3),

      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
    );
  }
}