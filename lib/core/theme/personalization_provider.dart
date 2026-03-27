import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
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
    );
  }
}

class PersonalizationNotifier extends Notifier<PersonalizationState> {
  static const _key = 'personalization_v1';

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

  Future<void> _save() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, json.encode(state.toMap()));
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
    state = state.copyWith(fontRoundness: value);
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

final personalizationProvider = NotifierProvider<PersonalizationNotifier, PersonalizationState>(() {
  return PersonalizationNotifier();
});
