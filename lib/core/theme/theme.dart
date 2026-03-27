import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'colors.dart';
import 'personalization_provider.dart';

class AppTheme {
  // ignore: unused_element
  static DynamicSchemeVariant _getVariant(String variant) {
    switch (variant) {
      case 'monochrome':
        return DynamicSchemeVariant.monochrome;
      case 'neutral':
        return DynamicSchemeVariant.neutral;
      case 'vibrant':
        return DynamicSchemeVariant.vibrant;
      case 'expressive':
        return DynamicSchemeVariant.expressive;
      case 'content':
        return DynamicSchemeVariant.content;
      case 'fidelity':
        return DynamicSchemeVariant.fidelity;
      case 'rainbow':
        return DynamicSchemeVariant.rainbow;
      case 'fruitSalad':
        return DynamicSchemeVariant.fruitSalad;
      case 'tonalSpot':
      default:
        return DynamicSchemeVariant.tonalSpot;
    }
  }

  static ThemeData getTheme(PersonalizationState state, Brightness brightness, {ColorScheme? dynamicColorScheme}) {
    final bool isDark = brightness == Brightness.dark;
    
    final List<FontVariation> variations = [
      FontVariation('GRAD', state.grade),
      FontVariation('wght', state.weight),
      FontVariation('slnt', state.slant),
      FontVariation('wdth', state.width),
      FontVariation('SOFT', state.fontRoundness),
      FontVariation('opsz', state.opticalSize),
    ];

    // Using DynamicColorScheme to support variants manually if needed, 
    // but ColorScheme.fromSeed is standard now in Flutter 3.22+
    // If 'variant' is not found, it might be a version mismatch.
    // In Flutter 3.22+, it is available.
    
    final Color seedColor = isDark ? AppColors.primaryDark : AppColors.primary;

    final colorScheme = dynamicColorScheme ?? ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      // variant: _getVariant(state.colorSchemeVariant), // Enable in modern Flutter 3.22+
      primary: isDark ? AppColors.primaryDark : AppColors.primary,
      surface: isDark ? AppColors.surfaceDark : AppColors.surface,
      onSurface: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
      surfaceContainerLowest: isDark ? AppColors.backgroundDark : AppColors.surfaceContainerLowest,
      surfaceContainerLow: isDark ? AppColors.surfaceDark : AppColors.surfaceContainerLow,
      surfaceContainer: isDark ? AppColors.cardDark : AppColors.surfaceContainer,
      surfaceContainerHigh: isDark ? AppColors.surfaceContainerDark : AppColors.surfaceContainerHigh,
    );

    final baseTextStyle = TextStyle(
      fontFamily: 'GoogleSansFlex',
      fontVariations: variations,
      fontFamilyFallback: const ['AppleColorEmoji'],
      color: colorScheme.onSurface,
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
      ).apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      iconTheme: IconThemeData(
        fill: state.fillIcons ? 1.0 : 0.0,
        weight: state.weight,
        grade: state.grade,
        color: colorScheme.onSurface,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          iconSize: 24,
          visualDensity: VisualDensity.compact,
        ),
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
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: baseTextStyle.copyWith(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: shape,
        elevation: 0,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceContainerDark.withValues(alpha: 0.5) : AppColors.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
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
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: shape,
          side: BorderSide.none,
          backgroundColor: isDark ? colorScheme.surfaceContainerHigh : colorScheme.surfaceContainerHigh,
          foregroundColor: colorScheme.onSurface,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(baseTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

final themeProvider = Provider.family<ThemeData, Brightness>((ref, brightness) {
  final personalization = ref.watch(personalizationProvider);
  return AppTheme.getTheme(personalization, brightness);
});
