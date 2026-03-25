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
      // Roundness is not a standard variable axis for Google Sans Flex, 
      // but let's assume it might be a custom axis or we use it for border radius
    ];

    final baseTextStyle = TextStyle(
      fontFamily: 'GoogleSansFlex',
      fontVariations: variations,
      fontFamilyFallback: const ['AppleColorEmoji'],
    );

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: isDark ? AppColors.cardDark : AppColors.backgroundLight,
      onSurface: isDark ? AppColors.backgroundLight : AppColors.backgroundDark,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: 'GoogleSansFlex',
      fontFamilyFallback: const ['AppleColorEmoji'],
      textTheme: TextTheme(
        displayLarge: baseTextStyle.copyWith(fontSize: 57),
        displayMedium: baseTextStyle.copyWith(fontSize: 45),
        displaySmall: baseTextStyle.copyWith(fontSize: 36),
        headlineLarge: baseTextStyle.copyWith(fontSize: 32),
        headlineMedium: baseTextStyle.copyWith(fontSize: 28),
        headlineSmall: baseTextStyle.copyWith(fontSize: 24),
        titleLarge: baseTextStyle.copyWith(fontSize: 22),
        titleMedium: baseTextStyle.copyWith(fontSize: 16),
        titleSmall: baseTextStyle.copyWith(fontSize: 14),
        bodyLarge: baseTextStyle.copyWith(fontSize: 16),
        bodyMedium: baseTextStyle.copyWith(fontSize: 14),
        bodySmall: baseTextStyle.copyWith(fontSize: 12),
        labelLarge: baseTextStyle.copyWith(fontSize: 14),
        labelMedium: baseTextStyle.copyWith(fontSize: 12),
        labelSmall: baseTextStyle.copyWith(fontSize: 11),
      ),
      iconTheme: IconThemeData(
        fill: state.fillIcons ? 1.0 : 0.0,
        weight: state.weight,
        grade: state.grade,
      ),
      scaffoldBackgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(state.roundness)),
        elevation: 0,
        color: isDark ? AppColors.cardDark : Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: isDark ? AppColors.backgroundLight : AppColors.backgroundDark),
        titleTextStyle: baseTextStyle.copyWith(
          color: isDark ? AppColors.backgroundLight : AppColors.backgroundDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

final themeProvider = Provider.family<ThemeData, Brightness>((ref, brightness) {
  final personalization = ref.watch(personalizationProvider);
  return AppTheme.getTheme(personalization, brightness);
});
