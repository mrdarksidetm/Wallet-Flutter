import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:ota_update/ota_update.dart';
import '../../../core/services/update_service.dart';
import '../../../core/database/providers.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _currentVersion = '1.28';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final version = await ref.read(updateServiceProvider).getCurrentVersion();
    if (mounted) {
      setState(() {
        _currentVersion = version;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildSectionHeader(context, 'General'),
          _buildSettingsTile(
            context,
            icon: Symbols.settings_suggest_rounded,
            title: 'Preferences',
            subtitle: 'Theme, dynamic color, typography, and behavior',
            onTap: () {
              context.push('/personalization');
            },
          ),
          _buildSettingsTile(
            context,
            icon: Symbols.currency_exchange,
            title: 'Currency',
            subtitle: ref.watch(currencyProvider),
            onTap: () {
              context.push('/currency_selection');
            },
          ),
          const Divider(indent: 24, endIndent: 24, height: 32),
          _buildSectionHeader(context, 'Security'),
          _buildSettingsTile(
            context,
            icon:
                authState.isBiometricEnabled ? Symbols.lock_open : Symbols.lock,
            title: 'Biometric Lock',
            subtitle: authState.canCheckBiometrics
                ? 'Protect your data'
                : 'Not supported on device',
            trailing: Switch(
              value: authState.isBiometricEnabled,
              onChanged: authState.canCheckBiometrics
                  ? (val) async {
                      await ref
                          .read(authProvider.notifier)
                          .toggleBiometric(val);
                    }
                  : null,
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
              try {
                await ref.read(csvServiceProvider).exportTransactions();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Exported successfully! Check your selected folder.')),
                  );
                }
              } catch (e) {
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
              try {
                await ref.read(csvServiceProvider).importTransactions();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Imported successfully!')),
                  );
                }
              } catch (e) {
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
              try {
                final path =
                    await ref.read(backupServiceProvider).createBackup();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Backup created at: $path')),
                  );
                }
              } catch (e) {
                if (e.toString().contains('cancelled')) return;
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Backup failed: $e')),
                  );
                }
              }
            },
          ),
          _buildSettingsTile(
            context,
            icon: Symbols.restore,
            title: 'Restore Backup',
            subtitle: 'Restore from an .isar file',
            onTap: () async {
              try {
                final success =
                    await ref.read(backupServiceProvider).restoreBackup();
                if (success && context.mounted) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      title: const Text('Restore Successful'),
                      content: const Text(
                          'Database has been restored. Please restart the app to apply changes.'),
                      actions: [
                        FilledButton(
                          onPressed: () => exit(0),
                          child: const Text('Close App'),
                        ),
                      ],
                    ),
                  );
                }
              } catch (e) {
                if (e.toString().contains('cancelled')) return;
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Restore failed: $e')),
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
            onTap: () {
              context.push('/privacy_policy');
            },
          ),
          _buildSettingsTile(
            context,
            icon: Symbols.policy,
            title: 'Terms of Use',
            subtitle: 'Open source usage terms',
            onTap: () {
              context.push('/terms_of_use');
            },
          ),
          const Divider(indent: 24, endIndent: 24, height: 32),
          _buildSectionHeader(context, 'Feedback'),
          _buildSettingsTile(
            context,
            icon: Symbols.rate_review,
            title: 'Send Feedback',
            subtitle: 'Tell us what you think',
            onTap: () {
              context.push('/feedback');
            },
          ),
          _buildSettingsTile(
            context,
            icon: Symbols.bug_report,
            title: 'Logcat (Dev)',
            subtitle: 'View runtime logs and performance',
            onTap: () {
              context.push('/logcat');
            },
          ),
          const Divider(indent: 24, endIndent: 24, height: 32),
          _buildSectionHeader(context, 'Update & Contact'),
          _buildSettingsTile(
            context,
            icon: Symbols.info,
            title: 'About',
            subtitle: 'Version and developer info',
            onTap: () {
              context.push('/about');
            },
          ),
          _buildSettingsTile(
            context,
            icon: Symbols.update,
            title: 'Check for Updates',
            subtitle: 'v$_currentVersion "The Variable Atelier"',
            onTap: () {
              _checkForUpdates(context);
            },
          ),
          const SizedBox(height: 48),
          Center(
            child: Text(
              'Wallet v$_currentVersion (March 2026)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
            const Text('Connecting to GitHub...',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              borderRadius: BorderRadius.circular(4),
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
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

        if (update != null &&
            updateService.isNewerVersion(_currentVersion, update.version)) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
              title: Text('New Version v${update.version}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Changelog:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
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
                    Navigator.pop(context);
                    _startSelfUpdate(context, update.downloadUrl);
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
              title: const Text('Up to Date'),
              content: const Text(
                  'You are already using the most refined version of Wallet.'),
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

  void _startSelfUpdate(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StreamBuilder(
          stream: ref.read(updateServiceProvider).downloadAndInstall(url),
          builder: (context, snapshot) {
            double progress = 0;
            String status = 'Initializing...';

            if (snapshot.hasData) {
              final event = snapshot.data as OtaEvent;
              status = event.status.name.toUpperCase();
              if (event.value != null) {
                progress = double.tryParse(event.value!) ?? 0;
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
              title: const Text('Downloading Update'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(status),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress / 100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text('${progress.toInt()}%'),
                ],
              ),
              actions: [
                if (snapshot.hasError ||
                    (snapshot.hasData &&
                        (snapshot.data as OtaEvent).status ==
                            OtaStatus.INTERNAL_ERROR))
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
              ],
            );
          },
        );
      },
    );
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon,
            size: 28,
            fill: ref.watch(personalizationProvider).fillIcons ? 1.0 : 0.0),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
