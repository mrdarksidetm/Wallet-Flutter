import 'dart:async';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/core/database/providers.dart';
import 'package:wallet/core/theme/theme.dart';
import 'package:wallet/features/home/presentation/home_screen.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Set custom white screen of death for Flutter runtime errors
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'An Error Occurred',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      details.exceptionAsString(),
                      style: const TextStyle(color: Colors.black87, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    if (details.stack != null)
                      Text(
                        details.stack.toString(),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    };

    // Initialize error UI early
    runApp(const InitializationApp());
    
    try {
      final container = ProviderContainer();
      // Wait for Isar to initialize
      await container.read(isarProvider.future);
      // Run seed defaults
      await container.read(seedServiceProvider).seedDefaults();
      // Check recurring transactions
      await container.read(recurringServiceProvider).checkRecurringTransactions();

      runApp(
        UncontrolledProviderScope(
          container: container,
          child: const WalletApp(),
        ),
      );
    } catch (e, stack) {
      runApp(ErrorApp(error: e, stack: stack));
    }
  }, (error, stack) {
    runApp(ErrorApp(error: error, stack: stack));
  });
}

class InitializationApp extends StatelessWidget {
  const InitializationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final Object error;
  final StackTrace stack;
  const ErrorApp({super.key, required this.error, required this.stack});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red.shade900,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Initialization Error',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    error.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    stack.toString(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WalletApp extends ConsumerWidget {
  const WalletApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        // Use dynamic color if enabled and available, otherwise fall back to seeds/custom
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Wallet',
          theme: AppTheme.lightTheme,
          // darkTheme: AppTheme.darkTheme(darkScheme), // Skipping dark mode for now
          // themeMode: themeState.themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
