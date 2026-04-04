import 'package:flutter/material.dart';

class AppColors {
  // --- Atelier Design Tokens (Editorial System - Light) ---
  static const Color primary = Color(0xFF0061A4); // Material 3 Blue
  static const Color primaryDim = Color(0xFF004689); // For gradients
  static const Color tertiary = Color(0xFF535F7E); // Blue-grey Accent

  // Surface Philosophy (Light)
  static const Color surface = Color(0xFFFBF9F9); // Warm off-white
  static const Color surfaceContainerLow = Color(0xFFF5F3F4);
  static const Color surfaceContainer = Color(0xFFEFEDEE);
  static const Color surfaceContainerHigh = Color(0xFFE9E8E9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF313234); // Atelier curated text
  static const Color backgroundLight = surface;

  // --- Dark Mode Specifics (Refined Blue Palette) ---
  static const Color backgroundDark = Color(0xFF1A1C1E);
  static const Color surfaceDark = Color(0xFF1A1C1E);
  static const Color onSurfaceDark = Color(0xFFE2E2E6);

  static const Color primaryDark = Color(0xFFA9C7FF); // Primary Blue
  static const Color onPrimaryDark = Color(0xFF003062);
  static const Color primaryContainerDark = Color(0xFF004689);
  static const Color onPrimaryContainerDark = Color(0xFFD6E3FF);

  static const Color secondaryDark = Color(0xFFBEC6DC);
  static const Color tertiaryDark = Color(0xFFDDBCE0);

  static const Color cardDark = Color(0xFF1F1F23);
  static const Color surfaceContainerDark = Color(0xFF1F1F23);
  static const Color surfaceContainerHighestDark = Color(0xFF2A2A2E);
  static const Color outlineDark = Color(0xFF8E9099);

  // --- Utility Colors ---
  static const Color income = Color(0xFF10B981);
  static const Color expense = Color(0xFFEF4444);

  static const Color textMutedLight = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);
}

extension ColorUtils on Color {
  Color adaptive(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isDark) return this;

    // In dark mode, if the color is too dark, lighten it to follow the atelier curated vibe.
    final hsl = HSLColor.fromColor(this);
    if (hsl.lightness < 0.4) {
      return hsl.withLightness(0.65).withSaturation(0.4).toColor();
    }
    return this;
  }
}
