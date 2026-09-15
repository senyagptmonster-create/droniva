import 'package:flutter/material.dart';

class DronivaColors {
  DronivaColors._();

  static const Color background = Color(0xFF0C0D12);
  static const Color surface = Color(0xFF141721);
  static const Color surfaceElevated = Color(0xFF1C2230);
  static const Color border = Color(0xFF283144);

  static const Color neonLime = Color(0xFF00FFA3);
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonAmber = Color(0xFFFFB300);
  static const Color neonCoral = Color(0xFFFF5252);

  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData themeData() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      fontFamily: 'AppFont',
      colorScheme: const ColorScheme.dark(
        primary: neonLime,
        secondary: neonCyan,
        surface: surface,
        error: neonCoral,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'AppFont',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: neonLime.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: neonLime,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            );
          }
          return const TextStyle(
            color: textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: neonLime);
          }
          return const IconThemeData(color: textSecondary);
        }),
      ),
    );
  }
}
