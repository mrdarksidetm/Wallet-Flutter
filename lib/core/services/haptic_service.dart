import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HapticService {
  /// Triggers a vibration only when a new transaction is added.
  /// This is the ONLY place in the app where haptic feedback is allowed,
  /// and it must be explicitly enabled in the user's Preferences.
  Future<void> transaction(bool enabled) async {
    if (enabled) {
      await HapticFeedback.mediumImpact();
    }
  }
}

final hapticServiceProvider = Provider<HapticService>((ref) => HapticService());
