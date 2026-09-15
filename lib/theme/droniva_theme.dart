import 'package:flutter/material.dart';

class DronivaTheme {
  static const bg = Color(0xFF0C0D12);
  static const surface = Color(0xFF141720);
  static const edge = Color(0xFF1F2332);
  static const accent = Color(0xFF10B981);
  static const accentLight = Color(0xFF6EE7B7);
  static const ink = Color(0xFFECFDF5);
  static const muted = Color(0xFF94A3B8);

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      fontFamily: 'AppFont',
      primaryColor: accent,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: ink,
      ),
    );
  }
}
