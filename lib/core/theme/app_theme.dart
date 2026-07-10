import 'package:flutter/material.dart';

/// Dusk-adventure identity for Mythora.
///
/// Intentionally distinct from Dot Clash neon (no cyan/magenta glow theme).
abstract final class MythoraColors {
  static const ink = Color(0xFF0B1C24);
  static const deepTeal = Color(0xFF123A44);
  static const mist = Color(0xFF1E4D57);
  static const parchment = Color(0xFFE8DFC8);
  static const amber = Color(0xFFD4A24C);
  static const softGold = Color(0xFFE6C87A);
  static const ember = Color(0xFFC45C3A);
  static const muted = Color(0xFF8FA6AD);

  static const tileRed = Color(0xFFC94B4B);
  static const tileBlue = Color(0xFF3D7CC9);
  static const tileGreen = Color(0xFF3FA86A);
  static const tileYellow = Color(0xFFD4B03C);
  static const tilePurple = Color(0xFF8B5CB8);
}

abstract final class AppTheme {
  static ThemeData get dusk {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: MythoraColors.amber,
      onPrimary: MythoraColors.ink,
      secondary: MythoraColors.softGold,
      onSecondary: MythoraColors.ink,
      error: MythoraColors.ember,
      onError: MythoraColors.parchment,
      surface: MythoraColors.deepTeal,
      onSurface: MythoraColors.parchment,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: MythoraColors.ink,
      appBarTheme: const AppBarTheme(
        backgroundColor: MythoraColors.ink,
        foregroundColor: MythoraColors.parchment,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: MythoraColors.parchment,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: MythoraColors.parchment,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: MythoraColors.parchment,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.4,
          color: MythoraColors.muted,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: MythoraColors.ink,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: MythoraColors.amber,
          foregroundColor: MythoraColors.ink,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
