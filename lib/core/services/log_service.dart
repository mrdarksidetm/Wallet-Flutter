import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum LogLevel { info, warning, error, performance }

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? stackTrace;

  LogEntry({
    required this.level,
    required this.message,
    this.stackTrace,
  }) : timestamp = DateTime.now();

  String get formattedTime => DateFormat('HH:mm:ss.SSS').format(timestamp);
}

class LogService extends Notifier<List<LogEntry>> {
  @override
  List<LogEntry> build() {
    return [];
  }

  void log(String message, {LogLevel level = LogLevel.info}) {
    final entry = LogEntry(level: level, message: message);
    state = [...state, entry];
    debugPrint('[${level.name.toUpperCase()}] $message');
  }

  void logError(String message, dynamic error, [StackTrace? stack]) {
    final entry = LogEntry(
      level: LogLevel.error,
      message: '$message\n$error',
      stackTrace: stack?.toString(),
    );
    state = [...state, entry];
    debugPrint('[ERROR] $message\n$error\n$stack');
  }

  void logPerformance(String operation, Duration duration) {
    final entry = LogEntry(
      level: LogLevel.performance,
      message: '$operation took ${duration.inMilliseconds}ms',
    );
    state = [...state, entry];
  }

  void clear() {
    state = [];
  }
}

final logServiceProvider = NotifierProvider<LogService, List<LogEntry>>(() {
  return LogService();
});

// A handy utility to wrap risky operations
T safeRun<T>(T Function() action, T fallback, String contextName, WidgetRef ref) {
  final stopwatch = Stopwatch()..start();
  try {
    final result = action();
    stopwatch.stop();
    ref.read(logServiceProvider.notifier).logPerformance(contextName, stopwatch.elapsed);
    return result;
  } catch (e, stack) {
    stopwatch.stop();
    ref.read(logServiceProvider.notifier).logError(
      'SafeRun Fallback Triggered in $contextName', 
      e, 
      stack
    );
    return fallback;
  }
}
