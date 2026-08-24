import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/widgets/app_back_button.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  static const String termsMarkdown = '''
*Last updated: August 2026*

---

### 1. Acceptance of Terms
By downloading, installing, accessing, or using the **Wallet** application ("the Application", "the Software"), you agree to be bound by these Terms of Use ("Terms"). If you do not agree to these Terms, do not install or use the Software.

---

### 2. Nature of the Software
* **Personal Finance Tool**: Wallet is a locally executed financial record-keeping, budgeting, and transaction calculation tool.
* **No Banking or Financial Services**: Wallet is **not a bank, financial institution, licensed broker, credit provider, or financial advisor**. The Software does not hold funds, process monetary transfers between bank accounts, issue credit, or provide professional investment, tax, or legal advice.
* **Offline Execution**: The Software performs all computational operations entirely on your device. You are solely responsible for entering accurate financial data and maintaining your device's security.

---

### 3. Open Source & Licensing
* **Open Source Software**: Wallet is developed and maintained as open-source software under permissive licensing terms.
* **Third-Party Dependencies**: The Software is constructed using high-quality open-source components and frameworks, including:
  * **Flutter Framework**: BSD 3-Clause License (Google LLC)
  * **Isar Database**: Apache License 2.0
  * **Flutter Riverpod**: MIT License
  * **Material Symbols**: Apache License 2.0
  * **Google Sans Flex Variable Font**: Google Fonts Open Font License (OFL)
* You may inspect, modify, fork, and distribute the source code in accordance with the applicable open-source license agreements.

---

### 4. User Responsibilities & Data Backups
* **Device Security**: You are solely responsible for maintaining the physical and digital security of your device, including screen lock passcodes, biometric permissions, and operating system updates.
* **Backup Responsibility**: Because Wallet does not maintain cloud synchronization, **you are solely responsible for regularly exporting and backing up your database archives (JSON, CSV, or .isar files)**. If your device is lost, stolen, damaged, or factory-reset without an external backup, your local data cannot be recovered by the developers.

---

### 5. Disclaimer of Warranties
* THE SOFTWARE IS PROVIDED ON AN **"AS IS"** AND **"AS AVAILABLE"** BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, ACCURACY, TIMELINESS, OR NON-INFRINGEMENT.
* THE DEVELOPERS DO NOT WARRANT THAT THE SOFTWARE WILL BE UNINTERRUPTED, ERROR-FREE, FREE OF BUGS, OR THAT CALCULATIONS (SUCH AS MULTI-CURRENCY CONVERSIONS, LOAN INTEREST ESTIMATES, OR BUDGET PROJECTIONS) WILL BE FULLY SUITABLE FOR STATUTORY TAX OR LEGAL REPORTING.

---

### 6. Limitation of Liability
* TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL THE DEVELOPERS, CONTRIBUTORS, OR AFFILIATES BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR EXEMPLARY DAMAGES, INCLUDING BUT NOT LIMITED TO LOSS OF PROFITS, DATA LOSS, FINANCIAL REVENUE DISCREPANCIES, BUSINESS INTERRUPTION, OR DEVICE MALFUNCTION ARISING OUT OF OR IN CONNECTION WITH THE USE OR INABILITY TO USE THE APPLICATION.

---

### 7. Intellectual Property & Brand
* "Wallet", "The Variable Atelier", and associated logo artwork are original designs and open assets of the project. All other trademarks, service marks, and brand names mentioned within the app or documentation belong to their respective owners.

---

### 8. Amendments & Termination
* We reserve the right to revise or modify these Terms at any time. Continued use of the Application following any updates constitutes acceptance of the modified Terms.
''';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            leading: const AppBackButton(),
            title: Text(
              'Terms of Use',
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
                  data: termsMarkdown,
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
