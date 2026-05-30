import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/providers.dart';

enum ColorSchemeVariant {
  tonalSpot,
  vibrant,
  expressive,
  fruitSalad;

  String get name =>
      toString()
          .split('.')
          .last;
}

class ThemeState {
  final ThemeMode themeMode;
  final bool useMaterialYou;
  final Color? customColor;
  final bool isLiquid;
  final String fontFamily;
  final String currencySymbol;
  final String currencyCode;
  final ColorSchemeVariant variant;

  const ThemeState({
    required this.themeMode,
    required this.useMaterialYou,
    this.customColor,
    required this.isLiquid,
    required this.fontFamily,
    required this.currencySymbol,
    required this.currencyCode,
    required this.variant,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? useMaterialYou,
    Color? customColor,
    bool? isLiquid,
    String? fontFamily,
    String? currencySymbol,
    String? currencyCode,
    ColorSchemeVariant? variant,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      useMaterialYou: useMaterialYou ?? this.useMaterialYou,
      customColor: customColor ?? this.customColor,
      isLiquid: isLiquid ?? this.isLiquid,
      fontFamily: fontFamily ?? this.fontFamily,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyCode: currencyCode ?? this.currencyCode,
      variant: variant ?? this.variant,
    );
  }
}

class ThemeController extends Notifier<ThemeState> {
  static const _keyThemeMode = 'theme_mode';
  static const _keyUseMaterialYou = 'use_material_you';
  static const _keyCustomColor = 'custom_color';
  static const _keyIsLiquid = 'is_liquid';
  static const _keyFontFamily = 'font_family';
  static const _keyCurrencySymbol = 'currency_symbol';
  static const _keyCurrencyCode = 'currency_code';
  static const _keyVariant = 'color_scheme_variant';

  @override
  ThemeState build() {
    final prefs = ref.watch(sharedPreferencesProvider);

    final modeIndex = prefs.getInt(_keyThemeMode) ?? 0;
    final useMaterialYou = prefs.getBool(_keyUseMaterialYou) ?? true;
    final customColorVal = prefs.getInt(_keyCustomColor);
    final isLiquid = prefs.getBool(_keyIsLiquid) ?? true;
    final fontFamily = prefs.getString(_keyFontFamily) ?? 'GoogleSansFlex';
    final currencySymbol = prefs.getString(_keyCurrencySymbol) ?? '\$';
    final currencyCode = prefs.getString(_keyCurrencyCode) ?? 'USD';
    final variantStr = prefs.getString(_keyVariant) ?? 'tonalSpot';

    ThemeMode mode;
    switch (modeIndex) {
      case 1:
        mode = ThemeMode.light;
        break;
      case 2:
        mode = ThemeMode.dark;
        break;
      default:
        mode = ThemeMode.system;
    }

    final variant = ColorSchemeVariant.values.firstWhere(
          (e) => e.name == variantStr,
      orElse: () => ColorSchemeVariant.tonalSpot,
    );

    return ThemeState(
      themeMode: mode,
      useMaterialYou: useMaterialYou,
      customColor: customColorVal != null ? Color(customColorVal) : null,
      isLiquid: isLiquid,
      fontFamily: fontFamily,
      currencySymbol: currencySymbol,
      currencyCode: currencyCode,
      variant: variant,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = ref.read(sharedPreferencesProvider);
    int index = 0;
    if (mode == ThemeMode.light) index = 1;
    if (mode == ThemeMode.dark) index = 2;
    await prefs.setInt(_keyThemeMode, index);
  }

  Future<void> setUseMaterialYou(bool use) async {
    state = state.copyWith(useMaterialYou: use);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_keyUseMaterialYou, use);
  }

  Future<void> setCustomColor(Color? color) async {
    state = state.copyWith(customColor: color);
    final prefs = ref.read(sharedPreferencesProvider);
    if (color != null) {
      await prefs.setInt(_keyCustomColor, color.toARGB32());
    } else {
      await prefs.remove(_keyCustomColor);
    }
  }

  Future<void> setVariant(ColorSchemeVariant variant) async {
    state = state.copyWith(variant: variant);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_keyVariant, variant.name);
  }

  Future<void> setCurrency(String symbol, String code) async {
    state = state.copyWith(currencySymbol: symbol, currencyCode: code);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_keyCurrencySymbol, symbol);
    await prefs.setString(_keyCurrencyCode, code);
  }
}

final themeControllerProvider =
NotifierProvider<ThemeController, ThemeState>(() {
  return ThemeController();
});
