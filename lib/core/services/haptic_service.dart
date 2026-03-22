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

  static Future<void> success() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 50, amplitude: 128);
    }
  }

  static Future<void> error() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(pattern: [0, 50, 50, 50], amplitude: 255);
    }
  }
}
