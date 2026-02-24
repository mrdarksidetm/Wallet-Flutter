import 'package:flutter/material.dart';
import 'package:wallet/core/theme/colors.dart';
import 'package:wallet/core/theme/typography.dart';

class AppTheme {
  static ThemeData lightTheme(ColorScheme? dynamicColorScheme) {
    final ColorScheme scheme = dynamicColorScheme ?? ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: AppTypography.textTheme,
      fontFamily: AppTypography.fontFamily,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }
      ),
      // Add other component themes here (Card, AppBar, etc.)
    );
  }

  static ThemeData darkTheme(ColorScheme? dynamicColorScheme) {
    final ColorScheme baseScheme = dynamicColorScheme ?? ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    );
    
    // Paisa strongly uses pure black backgrounds for dark mode OLED efficiency and contrast
    final ColorScheme scheme = baseScheme.copyWith(
      surface: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: scheme,
      textTheme: AppTypography.textTheme, // Apply typography to dark mode too
      fontFamily: AppTypography.fontFamily,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }
      ),
    );
  }
}
