import 'package:flutter/material.dart';

/// Modern Editorial Theme for PrivatPDF
/// Sophisticated, magazine-inspired aesthetic with elegant typography
class AppTheme {
  // Color Palette - Editorial sophistication
  static const _cream = Color(0xFFFAF8F5); // Warm off-white background
  static const _charcoal = Color(0xFF2A2A2A); // Deep text color
  static const _graphite = Color(0xFF4A4A4A); // Secondary text
  static const _slate = Color(0xFF6B6B6B); // Muted text
  static const _sage = Color(0xFF8B9A8A); // Accent - sophisticated green
  static const _terracotta = Color(0xFFD4917B); // Warm accent
  static const _sand = Color(0xFFE5DDD5); // Subtle borders
  static const _paper = Color(0xFFFFFFFD); // Pure white for cards

  // Semantic Colors
  static const primary = _sage;
  static const secondary = _terracotta;
  static const background = _cream;
  static const surface = _paper;
  static const textPrimary = _charcoal;
  static const textSecondary = _graphite;
  static const textMuted = _slate;
  static const border = _sand;
  static const error = Color(0xFFC85A54);
  static const success = Color(0xFF6B8E7F);
  static const warning = Color(0xFFD9A441);
  static const info = Color(0xFF5B9BD5);

  // Typography Scale - Editorial hierarchy
  static const String _displayFont = 'Cormorant';
  static const String _bodyFont = 'Inter';

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: surface,
      background: background,
      error: error,
      onPrimary: _paper,
      onSecondary: _paper,
      onSurface: textPrimary,
      onBackground: textPrimary,
      onError: _paper,
    ),

    scaffoldBackgroundColor: background,

    // Typography - Magazine-quality text hierarchy
    textTheme: const TextTheme(
      // Display - Hero headlines
      displayLarge: TextStyle(
        fontFamily: _displayFont,
        fontSize: 72,
        height: 1.0,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.5,
        color: textPrimary,
      ),
      displayMedium: TextStyle(
        fontFamily: _displayFont,
        fontSize: 56,
        height: 1.1,
        fontWeight: FontWeight.w400,
        letterSpacing: -1.0,
        color: textPrimary,
      ),
      displaySmall: TextStyle(
        fontFamily: _displayFont,
        fontSize: 42,
        height: 1.15,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.5,
        color: textPrimary,
      ),

      // Headings - Section titles
      headlineLarge: TextStyle(
        fontFamily: _displayFont,
        fontSize: 36,
        height: 1.2,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.25,
        color: textPrimary,
      ),
      headlineMedium: TextStyle(
        fontFamily: _displayFont,
        fontSize: 28,
        height: 1.25,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: textPrimary,
      ),
      headlineSmall: TextStyle(
        fontFamily: _displayFont,
        fontSize: 24,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textPrimary,
      ),

      // Body - Readable content
      bodyLarge: TextStyle(
        fontFamily: _bodyFont,
        fontSize: 18,
        height: 1.6,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: _bodyFont,
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: textSecondary,
      ),
      bodySmall: TextStyle(
        fontFamily: _bodyFont,
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: textMuted,
      ),

      // Labels - UI elements
      labelLarge: TextStyle(
        fontFamily: _bodyFont,
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: textPrimary,
      ),
      labelMedium: TextStyle(
        fontFamily: _bodyFont,
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: textSecondary,
      ),
      labelSmall: TextStyle(
        fontFamily: _bodyFont,
        fontSize: 12,
        height: 1.35,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.75,
        color: textMuted,
      ),
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: _displayFont,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0,
      ),
    ),

    // Card Theme - Editorial cards with subtle shadows
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: BorderSide(color: border, width: 1),
      ),
      margin: const EdgeInsets.all(0),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: _paper,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        ),
        textStyle: const TextStyle(
          fontFamily: _bodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.75,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        side: BorderSide(color: border, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        ),
        textStyle: const TextStyle(
          fontFamily: _bodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontFamily: _bodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.25,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: BorderSide(color: border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: BorderSide(color: border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      labelStyle: const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textMuted,
      ),
      hintStyle: const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textMuted,
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: border,
      thickness: 1,
      space: 1,
    ),
  );
}

/// Spacing System - Editorial grid
class Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
  static const double huge = 96.0;
  static const double massive = 128.0;
}

/// Breakpoints for responsive design
class Breakpoints {
  static const double mobile = 320;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double wide = 1440;
  static const double ultrawide = 1920;
}
