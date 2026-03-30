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
  final bool vibrationEnabled;
  final bool vibrateOnTransaction;
  final String colorSchemeVariant;
  final bool isOnboardingComplete;
  final String? userName;
  final String? userPhoto;
  final String? defaultCurrency;

  PersonalizationState({
    this.grade = 50,
    this.weight = 400,
    this.slant = 0,
    this.width = 100,
    this.roundness = 28,
    this.fontRoundness = 0,
    this.opticalSize = 12,
    this.fillIcons = false,
    this.vibrationEnabled = true,
    this.vibrateOnTransaction = true,
    this.colorSchemeVariant = 'tonalSpot',
    this.isOnboardingComplete = false,
    this.userName,
    this.userPhoto,
    this.defaultCurrency,
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
    bool? vibrationEnabled,
    bool? vibrateOnTransaction,
    String? colorSchemeVariant,
    bool? isOnboardingComplete,
    String? userName,
    String? userPhoto,
    String? defaultCurrency,
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
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      vibrateOnTransaction: vibrateOnTransaction ?? this.vibrateOnTransaction,
      colorSchemeVariant: colorSchemeVariant ?? this.colorSchemeVariant,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      userName: userName ?? this.userName,
      userPhoto: userPhoto ?? this.userPhoto,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
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
      'vibrationEnabled': vibrationEnabled,
      'vibrateOnTransaction': vibrateOnTransaction,
      'colorSchemeVariant': colorSchemeVariant,
      'isOnboardingComplete': isOnboardingComplete,
      'userName': userName,
      'userPhoto': userPhoto,
      'defaultCurrency': defaultCurrency,
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
      vibrationEnabled: map['vibrationEnabled'] as bool? ?? true,
      vibrateOnTransaction: map['vibrateOnTransaction'] as bool? ?? true,
      colorSchemeVariant: map['colorSchemeVariant'] as String? ?? 'tonalSpot',
      isOnboardingComplete: map['isOnboardingComplete'] as bool? ?? false,
      userName: map['userName'] as String?,
      userPhoto: map['userPhoto'] as String?,
      defaultCurrency: map['defaultCurrency'] as String?,
    );
  }
}

class PersonalizationNotifier extends Notifier<PersonalizationState> {
  static const _key = 'personalization_v1';
  Timer? _debounceTimer;

  @override
  PersonalizationState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final data = prefs.getString(_key);
    if (data != null) {
      try {
        return PersonalizationState.fromMap(json.decode(data));
      } catch (_) {
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

  void completeOnboarding(
      {required String name, required String currency, String? photo}) {
    state = state.copyWith(
      isOnboardingComplete: true,
      userName: name,
      userPhoto: photo,
      defaultCurrency: currency,
    );
    _save();
  }

  void updateCurrency(String currency) {
    state = state.copyWith(defaultCurrency: currency);
    _save();
  }

  void updateGrade(double value) {
    state = state.copyWith(grade: value);
    _save();
  }

  void updateWeight(double value) {
    state = state.copyWith(weight: value);
    _save();
  }

  void updateSlant(double value) {
    state = state.copyWith(slant: value);
    _save();
  }

  void updateWidth(double value) {
    state = state.copyWith(width: value);
    _save();
  }

  void updateRoundness(double value) {
    state = state.copyWith(roundness: value);
    _save();
  }

  void updateFontRoundness(double value) {
    // Combine with general roundness to prevent double state updates
    state = state.copyWith(
        fontRoundness: value.clamp(0, 100),
        roundness: (value * 0.32).clamp(0, 32));
    _save();
  }

  void updateOpticalSize(double value) {
    state = state.copyWith(opticalSize: value);
    _save();
  }

  void toggleFillIcons(bool value) {
    state = state.copyWith(fillIcons: value);
    _save();
  }

  void toggleVibration(bool value) {
    state = state.copyWith(vibrationEnabled: value);
    _save();
  }

  void toggleVibrateOnTransaction(bool value) {
    state = state.copyWith(vibrateOnTransaction: value);
    _save();
  }

  void updateColorSchemeVariant(String variant) {
    state = state.copyWith(colorSchemeVariant: variant);
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
