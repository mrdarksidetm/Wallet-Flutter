import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class HapticService {
  static Future<void> light() async {
    HapticFeedback.lightImpact();
  }

  static Future<void> medium() async {
    HapticFeedback.mediumImpact();
  }

  static Future<void> heavy() async {
    HapticFeedback.heavyImpact();
  }

  static Future<void> selection() async {
    HapticFeedback.selectionClick();
  }

  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 100, amplitude: 128);
    }
  }

  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(pattern: [0, 50, 100, 50, 100, 50], amplitude: 255);
    }
  }
}
