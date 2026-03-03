import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color backgroundBase = Color(0xFFFAF5F2); // Warm tinted off-white
  static const Color textPrimary = Color(0xFF1B1B1F);
  static const Color textSecondary = Color(0xFF757575);

  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme.apply(
      fontFamily: 'ProductSans',
      displayColor: textPrimary,
      bodyColor: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'ProductSans',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6750A4),
        surface: backgroundBase,
      ),
      scaffoldBackgroundColor: backgroundBase,
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.w900, // Very large, heavy weights
          color: textPrimary,
          fontSize: 56,
          letterSpacing: -1.5,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: textSecondary,
          fontWeight: FontWeight.w600, // High-contrast muted grays for subtitles
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: textSecondary,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 0,
        color: Colors.white.withOpacity(0.6), // Low-opacity pastel feel
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(const StadiumBorder()),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: StadiumBorder(),
        elevation: 2,
        backgroundColor: textPrimary,
        foregroundColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
      ),
    );
  }
}
