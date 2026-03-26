import 'package:flutter/material.dart';

class AppTypography {
  static const String fontFamily = 'GoogleSansFlex';

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontFamily: fontFamily, fontSize: 57, height: 64 / 57, letterSpacing: -0.25),
    displayMedium: TextStyle(fontFamily: fontFamily, fontSize: 45, height: 52 / 45, letterSpacing: 0),
    displaySmall: TextStyle(fontFamily: fontFamily, fontSize: 36, height: 44 / 36, letterSpacing: 0),
    headlineLarge: TextStyle(fontFamily: fontFamily, fontSize: 32, height: 40 / 32, letterSpacing: 0),
    headlineMedium: TextStyle(fontFamily: fontFamily, fontSize: 28, height: 36 / 28, letterSpacing: 0),
    headlineSmall: TextStyle(fontFamily: fontFamily, fontSize: 24, height: 32 / 24, letterSpacing: 0),
    titleLarge: TextStyle(fontFamily: fontFamily, fontSize: 22, height: 28 / 22, letterSpacing: 0),
    titleMedium: TextStyle(fontFamily: fontFamily, fontSize: 16, height: 24 / 16, letterSpacing: 0.15),
    titleSmall: TextStyle(fontFamily: fontFamily, fontSize: 14, height: 20 / 14, letterSpacing: 0.1),
    bodyLarge: TextStyle(fontFamily: fontFamily, fontSize: 16, height: 24 / 16, letterSpacing: 0.5),
    bodyMedium: TextStyle(fontFamily: fontFamily, fontSize: 14, height: 20 / 14, letterSpacing: 0.25),
    bodySmall: TextStyle(fontFamily: fontFamily, fontSize: 12, height: 16 / 12, letterSpacing: 0.4),
    labelLarge: TextStyle(fontFamily: fontFamily, fontSize: 14, height: 20 / 14, letterSpacing: 0.1),
    labelMedium: TextStyle(fontFamily: fontFamily, fontSize: 12, height: 16 / 12, letterSpacing: 0.5),
    labelSmall: TextStyle(fontFamily: fontFamily, fontSize: 11, height: 16 / 11, letterSpacing: 0.5),
  );
}
