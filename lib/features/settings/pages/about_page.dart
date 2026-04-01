import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../../../core/theme/personalization_provider.dart';

class AboutPage extends ConsumerStatefulWidget {
  const AboutPage({super.key});

  @override
  ConsumerState<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPage> {
  String _architecture = 'Loading...';

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
  }

  Future<void> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    String arch = 'Unknown';
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        arch = androidInfo.supportedAbis.isNotEmpty 
            ? androidInfo.supportedAbis.first 
            : 'Unknown';
      } else if (Platform.isIOS) {
        arch = 'arm64';
      }
    } catch (_) {}
    
    if (mounted) {
      setState(() => _architecture = arch);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userName =
        ref.watch(personalizationProvider.select((p) => p.userName)) ?? 'Abhi';

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
            const SizedBox(height: 32),
            Text(
              'Rebuild from ground up to support Android Community using modern technologies and Material 3 design principles.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 48),
            _AboutTile(
              icon: Symbols.code,
              title: 'Developer',
              subtitle: 'Built with ❤️ by $userName',
            ),
            const SizedBox(height: 16),
            _AboutTile(
              icon: Symbols.source_notes,
              title: 'Open Source',
              subtitle: 'View source code on GitHub',
              onTap: () => _launchUrl('https://github.com/h4h13/paisa-app'),
            ),
            const SizedBox(height: 16),
            _AboutTile(
              icon: Symbols.policy,
              title: 'Privacy Policy',
              subtitle: 'How we handle your data',
              onTap: () => _launchUrl(
                  'https://github.com/h4h13/paisa-app/blob/main/PRIVACY_POLICY.md'),
            ),
            const SizedBox(height: 16),
            _AboutTile(
              icon: Symbols.gavel,
              title: 'Licenses',
              subtitle: 'Third-party software libraries',
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'Wallet',
              ),
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Architecture: $_architecture',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontFamily: 'monospace',
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '© 2026 Antigravity Ideas',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
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
        height: 64,
        width: 64,
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
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _AboutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.chevron_right_rounded) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
