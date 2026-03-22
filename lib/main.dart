import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'core/theme/app_theme.dart';
import 'app/router.dart';
import 'core/database/providers.dart';
import 'core/widgets/global_error_screen.dart';

void main() async {
  // 1. Capture Flutter Framework errors (White Screen of Death defense)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Log to console or crashlytics here
    debugPrint('Flutter Error: ${details.exception}');
  };

  // 2. Capture asynchronous errors outside of Flutter
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Async Error: $error');
    return true;
  };

  // 3. Custom Error Widget for UI crashes
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return GlobalErrorScreen(errorDetails: details);
  };

  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: WalletApp(),
    ),
  );
}

class WalletApp extends ConsumerWidget {
  const WalletApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isarInit = ref.watch(isarInitProvider);
    final router = ref.watch(routerProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp.router(
          title: 'Wallet',
          routerConfig: router,
          theme: AppTheme.lightTheme(lightDynamic),
          darkTheme: AppTheme.darkTheme(darkDynamic),
          themeMode: ThemeMode.system,
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
