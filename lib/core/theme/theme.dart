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

  static ThemeData getTheme(
    PersonalizationState state,
    Brightness brightness, {
    ColorScheme? dynamicColorScheme,
    bool useDynamicVariant = true,
  }) {
    final bool isDark = brightness == Brightness.dark;

    final List<FontVariation> variations = [
      FontVariation('GRAD', state.grade),
      FontVariation('wght', state.weight),
      FontVariation('slnt', state.slant),
      FontVariation('wdth', state.width),
      FontVariation('ROND', state.fontRoundness),
      FontVariation('opsz', state.opticalSize),
    ];

    final Color seedColor = isDark ? AppColors.primaryDark : AppColors.primary;
    final Color effectiveSeedColor = dynamicColorScheme?.primary ?? seedColor;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: effectiveSeedColor,
      brightness: brightness,
      dynamicSchemeVariant: useDynamicVariant
          ? _getVariant(state.colorSchemeVariant)
          : DynamicSchemeVariant.tonalSpot,
    );

    final baseTextStyle = TextStyle(
      fontFamily: 'GoogleSansFlex',
      fontVariations: variations,
      fontFamilyFallback: const ['AppleColorEmoji', 'Noto Color Emoji'],
      color: colorScheme.onSurface,
    );

    final borderRadius = BorderRadius.circular(state.roundness);
    final shape = RoundedRectangleBorder(borderRadius: borderRadius);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: 'GoogleSansFlex',
      fontFamilyFallback: const ['AppleColorEmoji', 'Noto Color Emoji'],
      textTheme: TextTheme(
        displayLarge:
            baseTextStyle.copyWith(fontSize: 57, fontWeight: FontWeight.normal),
        displayMedium:
            baseTextStyle.copyWith(fontSize: 45, fontWeight: FontWeight.normal),
        displaySmall:
            baseTextStyle.copyWith(fontSize: 36, fontWeight: FontWeight.normal),
        headlineLarge:
            baseTextStyle.copyWith(fontSize: 32, fontWeight: FontWeight.normal),
        headlineMedium:
            baseTextStyle.copyWith(fontSize: 28, fontWeight: FontWeight.normal),
        headlineSmall:
            baseTextStyle.copyWith(fontSize: 24, fontWeight: FontWeight.normal),
        titleLarge:
            baseTextStyle.copyWith(fontSize: 22, fontWeight: FontWeight.normal),
        titleMedium:
            baseTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.normal),
        titleSmall:
            baseTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.normal),
        bodyLarge:
            baseTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.normal),
        bodyMedium:
            baseTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.normal),
        bodySmall:
            baseTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.normal),
        labelLarge:
            baseTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.normal),
        labelMedium:
            baseTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.normal),
        labelSmall:
            baseTextStyle.copyWith(fontSize: 11, fontWeight: FontWeight.normal),
      ).apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      iconTheme: IconThemeData(
        fill: state.fillIcons ? 1.0 : 0.0,
        weight: 500,
        grade: 0.25,
        opticalSize: 24,
        color: colorScheme.onSurface,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          iconSize: 24,
          visualDensity: VisualDensity.standard,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
          weight: 600,
          opticalSize: 24,
        ),
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
        // [ACTION]: Assigning background color for the input fields.
        // [M3 UPDATE]: Using colorScheme.surfaceContainerHighest here instead of 
        // deprecated surfaceVariant or hardcoded translucent blacks/whites.
        // [WHY]: This ensures the input fields have a subtle, dynamic hue from the 
        // primary seed, providing visibility and depth without clashing with the main background.
        fillColor: colorScheme.surfaceContainerHighest,
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
        // [ACTION]: Ensuring label and hint text use appropriate contrast.
        // [M3 UPDATE]: Using onSurfaceVariant for secondary/utility text on top of containers.
        hintStyle: baseTextStyle.copyWith(color: colorScheme.onSurfaceVariant),
        labelStyle: baseTextStyle.copyWith(color: colorScheme.onSurfaceVariant),
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
          // [ACTION]: Refactoring outlined button background for a subtle separation.
          // [M3 UPDATE]: Using surfaceContainerHighest for a dynamic, non-white/non-grey neutral background.
          backgroundColor: colorScheme.surfaceContainerHighest,
          // [ACTION]: Ensuring icons and text on the button are clearly legible.
          // [M3 UPDATE]: Using onSurfaceVariant for secondary foreground elements.
          foregroundColor: colorScheme.onSurfaceVariant,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        // [ACTION]: Applying the unified surface hierarchy to the navigation bar.
        // [M3 UPDATE]: Replacing hardcoded surface or background with surfaceContainer.
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              weight: 700,
              opticalSize: 24,
              grade: 0.25,
              color: colorScheme.onPrimaryContainer,
            );
          }
          return IconThemeData(
            weight: 400,
            opticalSize: 24,
            grade: 0,
            color: colorScheme.onSurfaceVariant,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? colorScheme.onSurface
              : colorScheme.onSurfaceVariant;
          return baseTextStyle.copyWith(
              fontSize: 12, fontWeight: FontWeight.w500, color: color);
        }),
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      cardTheme: CardThemeData(
        shape: shape,
        elevation: 0,
        // [ACTION]: Assigning the background color for all cards globally.
        // [M3 UPDATE]: We use colorScheme.surfaceContainerHighest here instead of 
        // the deprecated surfaceVariant or a hardcoded grey/white. 
        // [WHY]: This provides a prominent, dynamic hue that visually separates 
        // cards from the base surface without relying on shadows, 
        // working perfectly across both light and dark dynamic themes.
        color: colorScheme.surfaceContainerHighest,
      ),
      switchTheme: SwitchThemeData(
        thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const Icon(Icons.check, size: 16);
          }
          return const Icon(Icons.close, size: 16);
        }),
        // [ACTION]: Refinement for the switch track to follow dynamic hues.
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colorScheme.primary;
          return colorScheme.surfaceContainerHighest;
        }),
      ),
    );
  }
}

final themeProvider = Provider.family<ThemeData, Brightness>((ref, brightness) {
  final personalization = ref.watch(personalizationProvider);
  return AppTheme.getTheme(personalization, brightness);
});
