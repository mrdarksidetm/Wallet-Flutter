import 'package:flutter/material.dart';

class AppColors {
  // --- Atelier Design Tokens (Editorial System - Light) ---
  static const Color primary = Color(0xFF5D5E61); // Muted slate
  static const Color primaryDim = Color(0xFF515255); // For gradients
  static const Color tertiary = Color(0xFF026595); // Subtle Accent
  
  // Surface Philosophy (Light)
  static const Color surface = Color(0xFFFBF9F9); // Warm off-white
  static const Color surfaceContainerLow = Color(0xFFF5F3F4);
  static const Color surfaceContainer = Color(0xFFEFEDEE);
  static const Color surfaceContainerHigh = Color(0xFFE9E8E9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF313234); // Atelier curated text
  static const Color backgroundLight = surface;

  // --- Dark Mode Specifics (Refined Sage/Teal Palette) ---
  static const Color backgroundDark = Color(0xFF1A1C1E);
  static const Color surfaceDark = Color(0xFF1A1C1E);
  static const Color onSurfaceDark = Color(0xFFE1E2E1);
  
  static const Color primaryDark = Color(0xFFB1CCBE); // Teal/Sage
  static const Color onPrimaryDark = Color(0xFF1B352E);
  static const Color primaryContainerDark = Color(0xFF334B46);
  static const Color onPrimaryContainerDark = Color(0xFFCCE8DB);
  
  static const Color secondaryDark = Color(0xFFB0CCC5);
  static const Color tertiaryDark = Color(0xFFB5CAD6);
  
  static const Color cardDark = Color(0xFF212523);
  static const Color surfaceContainerDark = Color(0xFF2C312E);
  static const Color surfaceContainerHighestDark = Color(0xFF363B39);
  static const Color outlineDark = Color(0xFF89938F);

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
