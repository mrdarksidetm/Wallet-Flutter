import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState {
  final ThemeMode themeMode;
  final bool useMaterialYou;
  final Color? customColor;
  final bool isLiquid;
  final String fontFamily;
  final String currencySymbol;
  final String currencyCode;

  const ThemeState({
    required this.themeMode,
    required this.useMaterialYou,
    this.customColor,
    required this.isLiquid,
    required this.fontFamily,
    required this.currencySymbol,
    required this.currencyCode,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? useMaterialYou,
    Color? customColor,
    bool? isLiquid,
    String? fontFamily,
    String? currencySymbol,
    String? currencyCode,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      useMaterialYou: useMaterialYou ?? this.useMaterialYou,
      customColor: customColor ?? this.customColor,
      isLiquid: isLiquid ?? this.isLiquid,
      fontFamily: fontFamily ?? this.fontFamily,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyCode: currencyCode ?? this.currencyCode,
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

  @override
  ThemeState build() {
    // Return initial state immediately, load prefs async
    _loadSettings();
    return const ThemeState(
      themeMode: ThemeMode.system,
      useMaterialYou: true,
      customColor: null,
      isLiquid: false,
      fontFamily: 'ProductSans',
      currencySymbol: '\$',
      currencyCode: 'USD',
    );
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final modeIndex = prefs.getInt(_keyThemeMode) ?? 0;
    final useMaterialYou = prefs.getBool(_keyUseMaterialYou) ?? true;
    final customColorVal = prefs.getInt(_keyCustomColor);
    final isLiquid = prefs.getBool(_keyIsLiquid) ?? false;
    final fontFamily = prefs.getString(_keyFontFamily) ?? 'ProductSans';
    final currencySymbol = prefs.getString(_keyCurrencySymbol) ?? '\$';
    final currencyCode = prefs.getString(_keyCurrencyCode) ?? 'USD';

    ThemeMode mode;
    switch (modeIndex) {
      case 1: mode = ThemeMode.light; break;
      case 2: mode = ThemeMode.dark; break;
      default: mode = ThemeMode.system;
    }

    state = state.copyWith(
      themeMode: mode,
      useMaterialYou: useMaterialYou,
      customColor: customColorVal != null ? Color(customColorVal) : null,
      isLiquid: isLiquid,
      fontFamily: fontFamily,
      currencySymbol: currencySymbol,
      currencyCode: currencyCode,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    int index = 0; 
    if (mode == ThemeMode.light) index = 1;
    if (mode == ThemeMode.dark) index = 2;
    await prefs.setInt(_keyThemeMode, index);
  }

  Future<void> setUseMaterialYou(bool use) async {
    state = state.copyWith(useMaterialYou: use);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUseMaterialYou, use);
  }
  
  Future<void> setCustomColor(Color? color) async {
    state = state.copyWith(customColor: color);
    final prefs = await SharedPreferences.getInstance();
    if (color != null) {
      await prefs.setInt(_keyCustomColor, color.value);
    } else {
      await prefs.remove(_keyCustomColor);
    }
  }

  Future<void> toggleLiquid(bool enabled) async {
    state = state.copyWith(isLiquid: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLiquid, enabled);
  }

  Future<void> setFontFamily(String family) async {
    state = state.copyWith(fontFamily: family);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFontFamily, family);
  }

  Future<void> setCurrency(String symbol, String code) async {
    state = state.copyWith(currencySymbol: symbol, currencyCode: code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrencySymbol, symbol);
    await prefs.setString(_keyCurrencyCode, code);
  }
}

final themeControllerProvider = NotifierProvider<ThemeController, ThemeState>(() {
  return ThemeController();
});
