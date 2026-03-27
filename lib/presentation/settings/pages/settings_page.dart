import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/update_service.dart';
import '../../../core/database/providers.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  static const String _currentVersion = '1.25';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(authProvider);
    final themeState = ref.watch(themeControllerProvider);
    final themeNotifier = ref.read(themeControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildSectionHeader(context, 'Appearance'),
          _buildSettingsTile(
            context,
            icon: Symbols.palette,
            title: 'Personalization',
            subtitle: 'Fine-tune typography and geometry',
            onTap: () async {
              await HapticService.selectionStatic();
              if (context.mounted) context.push('/personalization');
            },
          ),
          _buildSettingsTile(
            context,
            icon: Symbols.color_lens,
            title: 'Theme Mode',
            subtitle: themeState.themeMode.name.toUpperCase(),
            onTap: () async {
              await HapticService.selectionStatic();
              if (context.mounted) context.push('/theme_selection');
            },
          ),
          _buildSettingsTile(
            context,
            icon: Symbols.draw,
            title: 'Dynamic Color',
            subtitle: 'Material You dynamic palettes',
            trailing: Switch(
              value: themeState.useMaterialYou,
              onChanged: (val) async {
                await HapticService.mediumStatic();
                await themeNotifier.setUseMaterialYou(val);
              },
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Symbols.currency_exchange,
            title: 'Currency',
            subtitle: ref.watch(currencyProvider),
            onTap: () async {
              await HapticService.selectionStatic();
              if (context.mounted) context.push('/currency_selection');
            },
          ),

          const Divider(indent: 24, endIndent: 24, height: 32),
          _buildSectionHeader(context, 'Security'),
          _buildSettingsTile(
            context,
            icon: authState.isBiometricEnabled ? Symbols.lock_open : Symbols.lock,
            title: 'Biometric Lock',
            subtitle: authState.canCheckBiometrics ? 'Protect your data' : 'Not supported on device',
            trailing: Switch(
              value: authState.isBiometricEnabled,
              onChanged: authState.canCheckBiometrics ? (val) async {
                await HapticService.mediumStatic();
                await ref.read(authProvider.notifier).toggleBiometric(val);
              } : null,
            ),
          ),

          const Divider(indent: 24, endIndent: 24, height: 32),
          _buildSectionHeader(context, 'Data Management'),
          _buildSettingsTile(
            context,
            icon: Symbols.upload_file,
            title: 'Export Data',
            subtitle: 'Export transactions to CSV',
            onTap: () async {
              await HapticService.mediumStatic();
              try {
                await ref.read(csvServiceProvider).exportTransactions();
                await HapticService.successStatic();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exported successfully! Check your selected folder.')),
                  );
                }
              } catch (e) {
                await HapticService.errorStatic();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              }
            },
          ),
          _buildSettingsTile(
            context,
            icon: Symbols.download_for_offline,
            title: 'Import Data',
            subtitle: 'Import transactions from CSV',
            onTap: () async {
              await HapticService.mediumStatic();
              try {
                await ref.read(csvServiceProvider).importTransactions();
                await HapticService.successStatic();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Imported successfully!')),
                  );
                }
              } catch (e) {
                await HapticService.errorStatic();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Import failed: $e')),
                  );
                }
              }
            },
          ),
          _buildSettingsTile(
            context,
            icon: Symbols.backup,
            title: 'Backup Database',
            subtitle: 'Create a local .isar backup',
            onTap: () async {
              await HapticService.mediumStatic();
              try {
                final path = await ref.read(backupServiceProvider).createBackup();
                await HapticService.successStatic();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Backup created at: $path')),
                  );
                }
              } catch (e) {
                if (e.toString().contains('cancelled')) return;
                await HapticService.errorStatic();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Backup failed: $e')),
                  );
                }
              }
            },
          ),
          
          const Divider(indent: 24, endIndent: 24, height: 32),
          _buildSectionHeader(context, 'Privacy & Policy'),
          _buildSettingsTile(
            context,
            icon: Symbols.shield_lock,
            title: 'Privacy Policy',
            subtitle: 'Offline-first data philosophy',
            onTap: () async {
              await HapticService.selectionStatic();
              if (context.mounted) context.push('/privacy_policy');
            },
          ),
          _buildSettingsTile(
            context,
            icon: Symbols.policy,
            title: 'Terms of Use',
            subtitle: 'Open source usage terms',
            onTap: () async {
              await HapticService.selectionStatic();
              if (context.mounted) context.push('/privacy_policy'); // Reuse for now
            },
          ),

          const Divider(indent: 24, endIndent: 24, height: 32),
          _buildSectionHeader(context, 'Feedback'),
          _buildSettingsTile(
            context,
            icon: Symbols.rate_review,
            title: 'Send Feedback',
            subtitle: 'Tell us what you think',
            onTap: () async {
              await HapticService.selectionStatic();
              if (context.mounted) context.push('/feedback');
            },
          ),

          const Divider(indent: 24, endIndent: 24, height: 32),
          _buildSectionHeader(context, 'Update & Contact'),
          _buildSettingsTile(
            context,
            icon: Symbols.info,
            title: 'About',
            subtitle: 'Version and developer info',
            onTap: () async {
              await HapticService.selectionStatic();
              if (context.mounted) context.push('/about');
            },
          ),
          _buildSettingsTile(
            context,
            icon: Symbols.update,
            title: 'Check for Updates',
            subtitle: 'v$_currentVersion "The Variable Atelier"',
            onTap: () async {
              await HapticService.mediumStatic();
              _checkForUpdates(context);
            },
          ),

          const SizedBox(height: 48),
          Center(
            child: Text(
              'Wallet v$_currentVersion (March 2026)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _checkForUpdates(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Row(
          children: [
            Icon(Symbols.auto_awesome, color: Colors.teal),
            SizedBox(width: 12),
            Text('System Update'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Connecting to GitHub...', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              borderRadius: BorderRadius.circular(4),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ],
        ),
      ),
    );
    
    try {
      final updateService = ref.read(updateServiceProvider);
      final update = await updateService.checkForUpdates();
      
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        if (update != null && updateService.isNewerVersion(_currentVersion, update.version)) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              title: Text('New Version v${update.version}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Changelog:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(update.changelog),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Later'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    launchUrl(Uri.parse(update.downloadUrl), mode: LaunchMode.externalApplication);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Symbols.download, size: 18),
                  label: const Text('Update Now'),
                ),
              ],
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              title: const Text('Up to Date'),
              content: const Text('You are already using the most refined version of Wallet.'),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Excellent'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update check failed: $e')),
        );
      }
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 22, fill: ref.watch(personalizationProvider).fillIcons ? 1.0 : 0.0),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
