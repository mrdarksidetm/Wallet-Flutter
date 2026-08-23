import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/core/database/providers.dart';
import 'package:wallet/core/theme/personalization_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PersonalizationNotifier Error Collector tests', () {
    test('isErrorCollectorEnabled defaults to false and can be enabled', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      // Initially false
      expect(container.read(personalizationProvider).isErrorCollectorEnabled, isFalse);

      // Enable error collector
      container.read(personalizationProvider.notifier).enableErrorCollector();

      // Now true
      expect(container.read(personalizationProvider).isErrorCollectorEnabled, isTrue);
    });

    test('isErrorCollectorEnabled persists across reloads', () async {
      SharedPreferences.setMockInitialValues({
        'personalization_v1': '{"isErrorCollectorEnabled": true}',
      });
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(personalizationProvider).isErrorCollectorEnabled, isTrue);
    });
  });
}
