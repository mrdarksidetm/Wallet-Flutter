import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Phase 29: Privacy Masking & Security Gestures
///
/// Provides an app-wide reactive state to toggle privacy masking.
/// When true, monetary values are obfuscated with asterisks (***).
/// This is exposed as a Riverpod Provider so that any widget reading 
/// this state automatically rebuilds when privacy mode is toggled.
class PrivacyNotifier extends StateNotifier<bool> {
  PrivacyNotifier() : super(false);

  void togglePrivacy() {
    state = !state;
  }
}

final privacyProvider = StateNotifierProvider<PrivacyNotifier, bool>((ref) {
  return PrivacyNotifier();
});

extension PrivacyStringExtension on String {
  String maskIfRequired(bool isEnabled) {
    return isEnabled ? "***" : this;
  }
}
