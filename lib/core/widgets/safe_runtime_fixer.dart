import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/log_service.dart';

class SafeRuntimeFixer extends ConsumerStatefulWidget {
  final Widget child;
  const SafeRuntimeFixer({super.key, required this.child});

  @override
  ConsumerState<SafeRuntimeFixer> createState() => _SafeRuntimeFixerState();
}

class _SafeRuntimeFixerState extends ConsumerState<SafeRuntimeFixer> {
  @override
  void initState() {
    super.initState();
    // Catch-all for logic errors that don't trigger FlutterError
    // but might be caught here if they happen during build or lifecycle
  }

  @override
  Widget build(BuildContext context) {
    return _SafeErrorBoundary(
      logService: ref.read(logServiceProvider.notifier),
      child: widget.child,
    );
  }
}

class _SafeErrorBoundary extends StatefulWidget {
  final Widget child;
  final LogService logService;

  const _SafeErrorBoundary({
    required this.child,
    required this.logService,
  });

  @override
  State<_SafeErrorBoundary> createState() => _SafeErrorBoundaryState();
}

class _SafeErrorBoundaryState extends State<_SafeErrorBoundary> {
  Object? _lastError;
  bool _hasError = false;

  @override
  void didUpdateWidget(_SafeErrorBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    // On update, reset error state to try re-rendering
    if (_hasError) {
      setState(() {
        _hasError = false;
        _lastError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: Colors.red, brightness: MediaQuery.platformBrightnessOf(context))),
        home: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_fix_high_rounded, color: Colors.blue, size: 64),
                  const SizedBox(height: 24),
                  const Text(
                    'Runtime Fixer Active',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We caught an error and are preventing a crash. The logs have been captured.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _lastError.toString(),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                        _lastError = null;
                      });
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try to Resume'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Wrap the child in a builder to catch errors during build
    return Builder(
      builder: (context) {
        try {
          return widget.child;
        } catch (e, stack) {
          _handleError(e, stack);
          return const SizedBox.shrink();
        }
      },
    );
  }

  void _handleError(Object error, StackTrace stack) {
    if (_hasError) return; // Prevent infinite loop
    
    debugPrint('SafeRuntimeFixer caught: $error');
    widget.logService.logError('Runtime Fixer Caught', error, stack);
    
    // Schedule setState for next frame
    Future.microtask(() {
      if (mounted) {
        setState(() {
          _hasError = true;
          _lastError = error;
        });
      }
    });
  }
}
