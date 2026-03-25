import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PersonalizationState {
  final double grade;
  final double weight;
  final double slant;
  final double width;
  final double roundness;
  final bool fillIcons;

  PersonalizationState({
    this.grade = 50,
    this.weight = 400,
    this.slant = 0,
    this.width = 100,
    this.roundness = 40,
    this.fillIcons = false,
  });

  PersonalizationState copyWith({
    double? grade,
    double? weight,
    double? slant,
    double? width,
    double? roundness,
    bool? fillIcons,
  }) {
    return PersonalizationState(
      grade: grade ?? this.grade,
      weight: weight ?? this.weight,
      slant: slant ?? this.slant,
      width: width ?? this.width,
      roundness: roundness ?? this.roundness,
      fillIcons: fillIcons ?? this.fillIcons,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'grade': grade,
      'weight': weight,
      'slant': slant,
      'width': width,
      'roundness': roundness,
      'fillIcons': fillIcons,
    };
  }

  factory PersonalizationState.fromMap(Map<String, dynamic> map) {
    return PersonalizationState(
      grade: (map['grade'] as num?)?.toDouble() ?? 50,
      weight: (map['weight'] as num?)?.toDouble() ?? 400,
      slant: (map['slant'] as num?)?.toDouble() ?? 0,
      width: (map['width'] as num?)?.toDouble() ?? 100,
      roundness: (map['roundness'] as num?)?.toDouble() ?? 40,
      fillIcons: map['fillIcons'] as bool? ?? false,
    );
  }
}

class PersonalizationNotifier extends Notifier<PersonalizationState> {
  static const _key = 'personalization_settings';

  @override
  PersonalizationState build() {
    _load();
    return PersonalizationState();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data != null) {
      state = PersonalizationState.fromMap(jsonDecode(data));
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toMap()));
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

  void toggleFillIcons(bool value) {
    state = state.copyWith(fillIcons: value);
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
