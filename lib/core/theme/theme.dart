import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'colors.dart';
import 'personalization_provider.dart';

class AppTheme {
  static ThemeData getTheme(PersonalizationState state, Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    
    final List<FontVariation> variations = [
      FontVariation('GRAD', state.grade),
      FontVariation('wght', state.weight),
      FontVariation('slnt', state.slant),
      FontVariation('wdth', state.width),
    ];

    final baseTextStyle = TextStyle(
      fontFamily: 'GoogleSansFlex',
      fontVariations: variations,
      fontFamilyFallback: const ['AppleColorEmoji'],
      color: isDark ? Colors.white : AppColors.onSurface,
    );

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.tertiary,
      tertiary: AppColors.tertiary,
      surface: isDark ? AppColors.cardDark : AppColors.surface,
      onSurface: isDark ? Colors.white : AppColors.onSurface,
      surfaceContainerLow: isDark ? const Color(0xFF1E1E1E) : AppColors.surfaceContainerLow,
      surfaceContainer: isDark ? const Color(0xFF252525) : AppColors.surfaceContainer,
      surfaceContainerHigh: isDark ? const Color(0xFF2C2C2C) : AppColors.surfaceContainerHigh,
      brightness: brightness,
    );

    final borderRadius = BorderRadius.circular(state.roundness);
    final shape = RoundedRectangleBorder(borderRadius: borderRadius);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: 'GoogleSansFlex',
      fontFamilyFallback: const ['AppleColorEmoji'],
      textTheme: TextTheme(
        displayLarge: baseTextStyle.copyWith(fontSize: 57, fontWeight: FontWeight.normal),
        displayMedium: baseTextStyle.copyWith(fontSize: 45, fontWeight: FontWeight.normal),
        displaySmall: baseTextStyle.copyWith(fontSize: 36, fontWeight: FontWeight.normal),
        headlineLarge: baseTextStyle.copyWith(fontSize: 32, fontWeight: FontWeight.normal),
        headlineMedium: baseTextStyle.copyWith(fontSize: 28, fontWeight: FontWeight.normal),
        headlineSmall: baseTextStyle.copyWith(fontSize: 24, fontWeight: FontWeight.normal),
        titleLarge: baseTextStyle.copyWith(fontSize: 22, fontWeight: FontWeight.normal),
        titleMedium: baseTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.normal),
        titleSmall: baseTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.normal),
        bodyLarge: baseTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.normal),
        bodyMedium: baseTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.normal),
        bodySmall: baseTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.normal),
        labelLarge: baseTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.normal),
        labelMedium: baseTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.normal),
        labelSmall: baseTextStyle.copyWith(fontSize: 11, fontWeight: FontWeight.normal),
      ),
      iconTheme: IconThemeData(
        fill: state.fillIcons ? 1.0 : 0.0,
        weight: state.weight,
        grade: state.grade,
      ),
      scaffoldBackgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      cardTheme: CardThemeData(
        shape: shape,
        elevation: 0,
        color: isDark ? AppColors.cardDark : AppColors.surfaceContainerLowest,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.onSurface),
        titleTextStyle: baseTextStyle.copyWith(
          color: isDark ? Colors.white : AppColors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: shape,
        elevation: 0, // Following the "No-Line" / Flat feel where possible, or low elevation
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceContainerHigh.withOpacity(0.2) : AppColors.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none, // Prohibited borders for sectioning
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: shape,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: shape,
          side: BorderSide.none,
          backgroundColor: isDark ? AppColors.surfaceContainerHigh : AppColors.surfaceContainerHigh,
          foregroundColor: isDark ? Colors.white : AppColors.onSurface,
        ),
      ),
    );
  }
}

final themeProvider = Provider.family<ThemeData, Brightness>((ref, brightness) {
  final personalization = ref.watch(personalizationProvider);
  return AppTheme.getTheme(personalization, brightness);
});
