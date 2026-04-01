import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/personalization_provider.dart';
import 'app/router.dart';
import 'core/database/providers.dart';
import 'core/widgets/global_error_screen.dart';
import 'core/services/log_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Pre-load SharedPreferences for synchronous access
  final sharedPrefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPrefs),
    ],
  );

  // 2. Capture Flutter Framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    container.read(logServiceProvider.notifier).logError('Flutter Error', details.exception, details.stack);
  };

  // 3. Capture asynchronous errors outside of Flutter
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    container.read(logServiceProvider.notifier).logError('Async Error', error, stack);
    return true;
  };

  // 4. Custom Error Widget for UI crashes
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return GlobalErrorScreen(errorDetails: details);
  };

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const WalletApp(),
    ),
  );
}

class WalletApp extends ConsumerWidget {
  const WalletApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isarInit = ref.watch(isarProvider);
    final router = ref.watch(routerProvider);
    final themeState = ref.watch(themeControllerProvider);
    final personalization = ref.watch(personalizationProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme? lightScheme;
        ColorScheme? darkScheme;

        if (themeState.useMaterialYou &&
            lightDynamic != null &&
            darkDynamic != null) {
          lightScheme = lightDynamic.harmonized();
          darkScheme = darkDynamic.harmonized();
        }

        final lightTheme = AppTheme.getTheme(personalization, Brightness.light,
            dynamicColorScheme: lightScheme);
        final darkTheme = AppTheme.getTheme(personalization, Brightness.dark,
            dynamicColorScheme: darkScheme);

        return MaterialApp.router(
          title: 'Wallet',
          routerConfig: router,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeState.themeMode,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return isarInit.when(
              data: (_) => child!,
              loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Scaffold(
                body: Center(child: Text('Database Error: $err')),
              ),
            );
          },
        );
      },
    );
  }
}
