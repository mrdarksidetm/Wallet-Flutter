import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:material_symbols_icons/symbols.dart';

class PrivacyPolicyPage extends ConsumerWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    const markdown = '''
# Privacy Policy & Terms

## 1. Data Privacy
Wallet is an **offline-first** application. Your financial data is stored locally on your device using a secure Isar database. We do not collect, upload, or sell your personal or financial information.

## 2. Security
The biometric lock feature uses your device's native security systems. We do not have access to your fingerprint or facial recognition data.

## 3. Licenses
This project is built using open-source libraries:
- **Flutter Framework**: BSD 3-Clause
- **Isar Database**: Apache 2.0
- **Riverpod**: MIT
- **Material Symbols**: Apache 2.0
- **Google Sans Flex**: Google Fonts License

## 4. Open Source Terms
By using this app, you agree that it is provided "as is" without warranty of any kind. This project is a tribute to premium financial management software.
''';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Symbols.arrow_back_rounded),
        ),
        title: Text(
          'Privacy Policy',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
          ),
          child: MarkdownBody(
            data: markdown,
            selectable: true,
            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
              h1: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
              h2: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              p: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
