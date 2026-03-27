import 'package:flutter/material.dart';

class GlobalErrorScreen extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const GlobalErrorScreen({
    super.key,
    required this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.errorContainer,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bug_report_rounded,
                size: 80,
                color: colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Something went wrong',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'The app encountered an unexpected error. Don\'t worry, your data is safe.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.error.withValues(alpha: 0.2)),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      errorDetails.toString(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        // In a real app, we'd send this to a server or log it
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error copied to clipboard (Mock)')),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded),
                      label: const Text('Copy Error'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Implementation for restarting the app would go here
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Restart App'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
