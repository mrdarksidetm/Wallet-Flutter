import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/update_service.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildAppIcon(colorScheme),
            const SizedBox(height: 24),
            Text(
              'Wallet',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.3.0',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Rebuild from ground up to support Android Community using modern Flutter Support',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 48),
            _AboutTile(
              leading: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Image.asset(
                  'assets/images/developer.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              title: 'Developer',
              subtitle: 'Built with ❤️ by Abhijeet Yadav',
              onTap: () => _launchUrl('https://github.com/mrdarksidetm'),
            ),
            const SizedBox(height: 16),
            _AboutTile(
              leading: Icon(Symbols.source_notes, color: colorScheme.primary),
              title: 'Open Source',
              subtitle: 'View source code on GitHub',
              onTap: () =>
                  _launchUrl('https://github.com/mrdarksidetm/wallet-flutter'),
            ),
            const SizedBox(height: 16),
            _AboutTile(
              leading: Icon(Symbols.policy, color: colorScheme.primary),
              title: 'Privacy Policy',
              subtitle: 'How we handle your data',
              onTap: () async {
                
                if (context.mounted) context.push('/privacy_policy');
              },
            ),
            const SizedBox(height: 16),
            _AboutTile(
              leading: Icon(Symbols.gavel, color: colorScheme.primary),
              title: 'Licenses',
              subtitle: 'Third-party software libraries',
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'Wallet',
                applicationVersion: '1.3.0',
              ),
            ),
            const SizedBox(height: 64),
                        FutureBuilder<String>(
              future: ref.read(updateServiceProvider).getDeviceArchitecture(),
              builder: (context, snapshot) {
                final arch = snapshot.data ?? '...';
                return Opacity(
                  opacity: 0.5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Symbols.android, size: 14),
                      Text(
                        ' Android X ',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const FlutterLogo(size: 14),
                      Text(
                        ' Flutter | ',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Symbols.memory, size: 14),
                      Text(
                        ' Architecture: ',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        arch.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(32),
      ),
      child: SvgPicture.asset(
        'assets/images/logo.svg',
        height: 92,
        width: 92,
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _AboutTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _AboutTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: leading,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.chevron_right_rounded) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
