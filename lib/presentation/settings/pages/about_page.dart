import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.account_balance_wallet,
                size: 80,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Wallet',
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              'v1.25 "The Variable Atelier"',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'A premium, offline-first personal finance dashboard. Rebuilt from the ground up for Android 14 using Jetpack Compose principles in Flutter.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 64),
            _buildAboutTile(
              context,
              icon: Symbols.developer_board,
              title: 'Developer',
              subtitle: 'Built with ❤️ by Abhi',
            ),
            _buildAboutTile(
              context,
              icon: Symbols.code,
              title: 'Source Code',
              subtitle: 'View on GitHub',
              onTap: () => launchUrl(Uri.parse('https://github.com/mrdarksidetm/Wallet')),
            ),
            _buildAboutTile(
              context,
              icon: Symbols.policy,
              title: 'Licenses',
              subtitle: 'Check third-party attributions',
              onTap: () => showLicensePage(context: context),
            ),
            const SizedBox(height: 48),
            Text(
              '© 2026 Antigravity Ideas',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTile(BuildContext context, {required IconData icon, required String title, required String subtitle, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.chevron_right_rounded) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
