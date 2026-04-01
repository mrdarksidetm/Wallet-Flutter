import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

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
    final errorText = 'EXCEPTION:\n${errorDetails.exception}\n\nSTACK TRACE:\n${errorDetails.stack}';

    return Scaffold(
      backgroundColor: colorScheme.errorContainer,
      appBar: AppBar(
        title: const Text('Render Error'),
        backgroundColor: colorScheme.errorContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: errorText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error details copied to clipboard')),
              );
            },
            tooltip: 'Copy Error',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.bug_report_rounded, color: colorScheme.error, size: 48),
              const SizedBox(height: 16),
              Text(
                'Something went wrong while rendering this part of the UI.',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.error.withValues(alpha: 0.2)),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      errorText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: colorScheme.error,
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
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('Back to Home'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Attempt to pop or go back
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          context.go('/');
                        }
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
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
