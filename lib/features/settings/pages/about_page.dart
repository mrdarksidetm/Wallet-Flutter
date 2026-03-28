import 'dart:io';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '...';
  String _architecture = '...';

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    String arch = 'universal';
    
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final abis = androidInfo.supportedAbis;
      if (abis.contains('arm64-v8a')) {
        arch = 'arm64-v8a';
      } else if (abis.contains('armeabi-v7a')) {
        arch = 'armeabi-v7a';
      } else if (abis.isNotEmpty) {
        arch = abis.first;
      }
    }

    if (mounted) {
      setState(() {
        _version = packageInfo.version;
        _architecture = arch;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icon/Original-Colour.svg',
              height: 120,
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
              'v$_version "The Variable Atelier"',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'A premium, offline-first personal finance dashboard. Rebuilt from the ground up for Android 14 using modern Flutter standards.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 64),
            _buildAboutTile(
              context,
              leading: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/developer.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: 'Developer',
              subtitle: 'Built with ❤️ by Abhi',
            ),
            _buildAboutTile(
              context,
              icon: Symbols.code,
              title: 'Source Code',
              subtitle: 'View on GitHub',
              onTap: () => launchUrl(Uri.parse('https://github.com/mrdarksidetm/Wallet-Flutter')),
            ),
            _buildAboutTile(
              context,
              icon: Symbols.policy,
              title: 'Licenses',
              subtitle: 'Check third-party attributions',
              onTap: () => showLicensePage(context: context),
            ),
            const SizedBox(height: 64),
            
            // New dynamic footer
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.android, size: 18, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text('x', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      const FlutterLogo(size: 18),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Symbols.memory, size: 14, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              _architecture,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTile(BuildContext context, {IconData? icon, Widget? leading, required String title, required String subtitle, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: leading ?? Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.chevron_right_rounded) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
