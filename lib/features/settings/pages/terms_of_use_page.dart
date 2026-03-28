import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Use'),
      ),
      body: const Markdown(
        data: '''
# Terms of Use

## 1. Acceptance of Terms
By using Wallet, you agree to these terms. If you do not agree, please do not use the application.

## 2. Open Source
Wallet is an open-source project. You are free to modify and distribute it under the terms of the MIT License.

## 3. Disclaimer
The application is provided "as is", without warranty of any kind. The developers are not responsible for any financial loss or data loss.

## 4. Privacy
Wallet is offline-first. Your data never leaves your device unless you explicitly export or back it up.

## 5. Updates
We may update these terms from time to time. Continued use of the app constitutes acceptance of the new terms.
''',
      ),
    );
  }
}
