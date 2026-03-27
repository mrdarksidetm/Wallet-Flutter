import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PrivacyPolicyPage extends ConsumerWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      appBar: AppBar(
        title: const Text('Privacy & Policy'),
      ),
      body: const Markdown(
        data: markdown,
        selectable: true,
      ),
    );
  }
}
