import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/widgets/app_back_button.dart';

class PrivacyPolicyPage extends ConsumerWidget {
  const PrivacyPolicyPage({super.key});

  static const String privacyPolicyMarkdown = '''
*Last updated: August 2026*

---

### 1. Philosophy: Absolute Privacy by Design
Wallet is built from the ground up as a **strictly offline-first, local-only personal finance management system**. Our core architectural principle is simple: **Your financial data belongs exclusively to you and must never leave your physical device without your explicit command.**

---

### 2. Information Storage & Processing
* **Local Database Storage**: All transactions, accounts, account balances, categorization rules, budgets, savings goals, peer-to-peer loan ledgers, recurring subscriptions, and bill splitting calculations are stored exclusively on your device inside an embedded, high-performance **Isar database**.
* **Zero Remote Servers**: We do not operate cloud database backends, analytics collection servers, or intermediary sync relays for user financial data.
* **Zero Telemetry & Tracking**: The application contains no tracking pixels, ad networks, third-party analytics SDKs (e.g., Firebase Analytics, Google Analytics, Facebook SDK, Mixpanel), or behavioral profiling mechanisms.

---

### 3. Biometric & Device Security
* **Biometric Lock Mechanism**: When biometric authentication is enabled, Wallet utilizes your device's native hardware security layer (`local_auth` integration with Android BiometricPrompt and iOS LocalAuthentication).
* **Zero Biometric Access**: The app never accesses, reads, collects, or transmits your actual fingerprint, facial geometry, or passcode data. Authentication verification is handled entirely within your operating system's Trusted Execution Environment (TEE) / Secure Enclave.

---

### 4. Data Backup, Export & Destruction
* **User-Initiated Exports**: You may export your financial data at any time in structured JSON, comma-separated values (CSV), or binary database archives (`.isar`). These files are generated locally and stored only in the directory or destination you select.
* **Data Shredder**: Wallet provides an integrated Data Shredder utility designed for complete on-device data destruction. Triggering a data wipe permanently purges all Isar collections, secure preferences, and localized cache from disk storage.

---

### 5. Diagnostics & Error Collector (LogCat)
* **On-Demand Diagnostics**: The application includes an optional diagnostic log collector designed to capture runtime crash logs and framework events for debugging purposes.
* **Local Volatile Storage**: Diagnostic logs are stored only in temporary, volatile memory on your device. They are never transmitted automatically to any remote endpoint.
* **User Control**: The Error Collector is deactivated by default and can be viewed, copied, cleared, or disabled at your discretion.

---

### 6. External Links & Communications
* **Web Links**: The application contains links to developer resources, source code repositories, and email addresses (e.g., GitHub, support email). Tapping these links opens your device's default external browser or email application. Those third-party applications operate under their own independent privacy policies.

---

### 7. Open Source Transparency & Auditing
* Wallet is completely open-source. The entire application source code, database schemas, and cryptographic dependencies are publicly accessible and verifiable on GitHub.

---

### 8. Changes to this Policy
* If this Privacy Policy is amended in future application releases, the updated version will be included directly in the app bundle with a revised revision date.
''';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            leading: const AppBackButton(),
            title: Text(
              'Privacy Policy',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: (theme.textTheme.headlineLarge?.fontSize ?? 32) + 3,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: MarkdownBody(
                  data: privacyPolicyMarkdown,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                    h3: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary,
                      letterSpacing: -0.2,
                    ),
                    p: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                    listBullet: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    strong: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                    em: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    horizontalRuleDecoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
