import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'dart:async';
import '../database/providers.dart';

class PersonalizationState {
  final double grade;
  final double weight;
  final double slant;
  final double width;
  final double roundness;
  final double fontRoundness;
  final double opticalSize;
  final bool fillIcons;
  final bool shouldRestartOnCurrencyChange;
  final String colorSchemeVariant;
  final bool isOnboardingComplete;
  final String? userName;
  final String? userPhoto;
  final String? defaultCurrency;
  final bool isBalanceVisible;
  final bool vibrateOnTransaction;
  final bool useGoogleSansFlex;
  final String iconStyle; // 'Outlined', 'Rounded', 'Sharp'

  final bool useDynamicColor;

  PersonalizationState({
    this.grade = 50,
    this.weight = 400,
    this.slant = 0,
    this.width = 100,
    this.roundness = 28,
    this.fontRoundness = 0,
    this.opticalSize = 12,
    this.fillIcons = false,
    this.shouldRestartOnCurrencyChange = true,
    this.colorSchemeVariant = 'tonalSpot',
    this.isOnboardingComplete = false,
    this.useDynamicColor = true,
    this.userName,
    this.userPhoto,
    this.defaultCurrency,
    this.isBalanceVisible = true,
    this.vibrateOnTransaction = true,
    this.useGoogleSansFlex = true,
    this.iconStyle = 'Rounded',
  });

  PersonalizationState copyWith({
    double? grade,
    double? weight,
    double? slant,
    double? width,
    double? roundness,
    double? fontRoundness,
    double? opticalSize,
    bool? fillIcons,
    bool? shouldRestartOnCurrencyChange,
    String? colorSchemeVariant,
    bool? isOnboardingComplete,
    bool? useDynamicColor,
    String? userName,
    String? userPhoto,
    String? defaultCurrency,
    bool? isBalanceVisible,
    bool? vibrateOnTransaction,
    bool? useGoogleSansFlex,
    String? iconStyle,
  }) {
    return PersonalizationState(
      grade: grade ?? this.grade,
      weight: weight ?? this.weight,
      slant: slant ?? this.slant,
      width: width ?? this.width,
      roundness: roundness ?? this.roundness,
      fontRoundness: fontRoundness ?? this.fontRoundness,
      opticalSize: opticalSize ?? this.opticalSize,
      fillIcons: fillIcons ?? this.fillIcons,
      shouldRestartOnCurrencyChange: shouldRestartOnCurrencyChange ?? this.shouldRestartOnCurrencyChange,
      colorSchemeVariant: colorSchemeVariant ?? this.colorSchemeVariant,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
      userName: userName ?? this.userName,
      userPhoto: userPhoto ?? this.userPhoto,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      isBalanceVisible: isBalanceVisible ?? this.isBalanceVisible,
      vibrateOnTransaction: vibrateOnTransaction ?? this.vibrateOnTransaction,
      useGoogleSansFlex: useGoogleSansFlex ?? this.useGoogleSansFlex,
      iconStyle: iconStyle ?? this.iconStyle,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'grade': grade,
      'weight': weight,
      'slant': slant,
      'width': width,
      'roundness': roundness,
      'fontRoundness': fontRoundness,
      'opticalSize': opticalSize,
      'fillIcons': fillIcons,
      'shouldRestartOnCurrencyChange': shouldRestartOnCurrencyChange,
      'colorSchemeVariant': colorSchemeVariant,
      'isOnboardingComplete': isOnboardingComplete,
      'useDynamicColor': useDynamicColor,
      'userName': userName,
      'userPhoto': userPhoto,
      'defaultCurrency': defaultCurrency,
      'isBalanceVisible': isBalanceVisible,
      'vibrateOnTransaction': vibrateOnTransaction,
      'useGoogleSansFlex': useGoogleSansFlex,
      'iconStyle': iconStyle,
    };
  }

  factory PersonalizationState.fromMap(Map<String, dynamic> map) {
    return PersonalizationState(
      grade: (map['grade'] as num?)?.toDouble() ?? 50,
      weight: (map['weight'] as num?)?.toDouble() ?? 400,
      slant: (map['slant'] as num?)?.toDouble() ?? 0,
      width: (map['width'] as num?)?.toDouble() ?? 100,
      roundness: (map['roundness'] as num?)?.toDouble() ?? 28,
      fontRoundness: (map['fontRoundness'] as num?)?.toDouble() ?? 0,
      opticalSize: (map['opticalSize'] as num?)?.toDouble() ?? 12,
      fillIcons: map['fillIcons'] as bool? ?? false,
      shouldRestartOnCurrencyChange: map['shouldRestartOnCurrencyChange'] as bool? ?? true,
      colorSchemeVariant: map['colorSchemeVariant'] as String? ?? 'tonalSpot',
      isOnboardingComplete: map['isOnboardingComplete'] as bool? ?? false,
      useDynamicColor: map['useDynamicColor'] as bool? ?? true,
      userName: map['userName'] as String?,
      userPhoto: map['userPhoto'] as String?,
      defaultCurrency: map['defaultCurrency'] as String?,
      isBalanceVisible: map['isBalanceVisible'] as bool? ?? true,
      vibrateOnTransaction: map['vibrateOnTransaction'] as bool? ?? true,
      useGoogleSansFlex: map['useGoogleSansFlex'] as bool? ?? true,
      iconStyle: map['iconStyle'] as String? ?? 'Rounded',
    );
  }
}

class PersonalizationNotifier extends Notifier<PersonalizationState> {
  static const _key = 'personalization_v1';
  Timer? _debounceTimer;

  @override
  PersonalizationState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final jsonStr = prefs.getString(_key);
    if (jsonStr != null) {
      try {
        return PersonalizationState.fromMap(json.decode(jsonStr));
      } catch (e) {
        return PersonalizationState();
      }
    }
    return PersonalizationState();
  }

  void _save() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(_key, json.encode(state.toMap()));
    });
  }

  void toggleFillIcons() {
    state = state.copyWith(fillIcons: !state.fillIcons);
    _save();
  }

  void toggleVibration() {
    state = state.copyWith(vibrateOnTransaction: !state.vibrateOnTransaction);
    _save();
  }

  void toggleGoogleSans(bool value) {
    state = state.copyWith(useGoogleSansFlex: value);
    _save();
  }

  void toggleRestartOnCurrencyChange(bool value) {
    state = state.copyWith(shouldRestartOnCurrencyChange: value);
    _save();
  }

  void toggleBalanceVisibility() {
    state = state.copyWith(isBalanceVisible: !state.isBalanceVisible);
    _save();
  }

  void completeOnboarding({String? name, String? currency, String? photo}) {
    state = state.copyWith(
      isOnboardingComplete: true,
      userName: name,
      defaultCurrency: currency,
      userPhoto: photo,
    );
    _save();
  }

  void updateProfile({String? name, String? photo}) {
    state = state.copyWith(userName: name, userPhoto: photo);
    _save();
  }

  void updateCurrency(String currency) {
    state = state.copyWith(defaultCurrency: currency);
    _save();
  }

  void updateColorSchemeVariant(String variant) {
    state = state.copyWith(colorSchemeVariant: variant);
    _save();
  }

  void updateGrade(double v) { state = state.copyWith(grade: v); _save(); }
  void updateWeight(double v) { state = state.copyWith(weight: v); _save(); }
  void updateSlant(double v) { state = state.copyWith(slant: v); _save(); }
  void updateWidth(double v) { state = state.copyWith(width: v); _save(); }
  void updateRoundness(double v) { state = state.copyWith(roundness: v); _save(); }
  void updateFontRoundness(double v) { state = state.copyWith(fontRoundness: v); _save(); }
  void updateOpticalSize(double v) { state = state.copyWith(opticalSize: v); _save(); }
  
  void resetTypography() {
    state = state.copyWith(
      grade: 50,
      weight: 400,
      slant: 0,
      width: 100,
      roundness: 28,
      fontRoundness: 0,
      opticalSize: 12,
    );
    _save();
  }

  void reset() {
    state = PersonalizationState();
    _save();
  }
}

final personalizationProvider =
    NotifierProvider<PersonalizationNotifier, PersonalizationState>(() {
  return PersonalizationNotifier();
});
