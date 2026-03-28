import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import '../theme/personalization_provider.dart';

class HapticService {
  final bool enabled;

  HapticService({required this.enabled});

  // Instance methods
  Future<void> light() async {
    if (!enabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  Future<void> medium() async {
    if (!enabled) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  Future<void> heavy() async {
    if (!enabled) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  Future<void> selection() async {
    if (!enabled) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  Future<void> success() async {
    if (!enabled) return;
    try {
      await HapticFeedback.mediumImpact();
      if (await Vibration.hasVibrator() == true) {
        await Vibration.vibrate(duration: 100, amplitude: 128);
      }
    } catch (_) {}
  }

  Future<void> error() async {
    if (!enabled) return;
    try {
      await HapticFeedback.heavyImpact();
      if (await Vibration.hasVibrator() == true) {
        await Vibration.vibrate(
            pattern: [0, 50, 100, 50, 100, 50], amplitude: 255);
      }
    } catch (_) {}
  }

  // Transaction specific haptic
  Future<void> transaction(bool transactionHapticsEnabled) async {
    if (!enabled || !transactionHapticsEnabled) return;
    await success();
  }

  // STATIC API (Always use these in UI)
  static late WidgetRef _ref;
  static void init(WidgetRef ref) => _ref = ref;

  static HapticService get _instance {
    try {
      return _ref.read(hapticServiceProvider);
    } catch (e) {
      return HapticService(enabled: true);
    }
  }

  // Static wrappers with 'Static' suffix to avoid conflicts
  static Future<void> lightStatic() async => _instance.light();
  static Future<void> mediumStatic() async => _instance.medium();
  static Future<void> heavyStatic() async => _instance.heavy();
  static Future<void> selectionStatic() async => _instance.selection();
  static Future<void> successStatic() async => _instance.success();
  static Future<void> errorStatic() async => _instance.error();

  // For compatibility with massive existing code base,
  // we can use a getter pattern or just rename the instance methods internally.
  // But safest is to keep Static suffix and update callers.
}

final hapticServiceProvider = Provider<HapticService>((ref) {
  final state = ref.watch(personalizationProvider);
  return HapticService(enabled: state.vibrationEnabled);
});
