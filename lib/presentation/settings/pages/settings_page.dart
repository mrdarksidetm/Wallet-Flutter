import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/database/providers.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _biometricEnabled = true;

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
          _buildSectionHeader(context, 'Appearance'),
          _buildSettingsTile(
            context,
            icon: Icons.palette_outlined,
            title: 'Theme Mode',
            subtitle: 'System',
            onTap: () async {
              await HapticService.selection();
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.color_lens_outlined,
            title: 'Dynamic Color',
            subtitle: 'Material You enabled',
            trailing: Switch(
              value: true,
              onChanged: (val) async {
                await HapticService.medium();
              },
            ),
          ),
          
          const Divider(indent: 24, endIndent: 24, height: 32),
          _buildSectionHeader(context, 'Localization'),
          _buildSettingsTile(
            context,
            icon: Icons.currency_exchange_rounded,
            title: 'Currency',
            subtitle: ref.watch(currencyProvider),
            onTap: () async {
              await HapticService.selection();
              if (context.mounted) context.push('/currency_selection');
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'English',
            onTap: () async {
              await HapticService.selection();
            },
          ),

          const Divider(indent: 24, endIndent: 24, height: 32),
          _buildSectionHeader(context, 'Security'),
          _buildSettingsTile(
            context,
            icon: Icons.fingerprint_rounded,
            title: 'Biometric Lock',
            subtitle: authState.canCheckBiometrics ? 'Protect your data' : 'Not supported on device',
            trailing: Switch(
              value: _biometricEnabled && authState.canCheckBiometrics,
              onChanged: authState.canCheckBiometrics ? (val) async {
                await HapticService.medium();
                setState(() => _biometricEnabled = val);
              } : null,
            ),
          ),

          const Divider(indent: 24, endIndent: 24, height: 32),
          _buildSectionHeader(context, 'Finances'),
          _buildSettingsTile(
            context,
            icon: Icons.repeat_rounded,
            title: 'Recurring Transactions',
            subtitle: 'Manage subscriptions & bills',
            onTap: () async {
              await HapticService.selection();
              if (context.mounted) context.push('/recurring');
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.category_rounded,
            title: 'Categories',
            subtitle: 'Manage income & expense types',
            onTap: () async {
              await HapticService.selection();
              if (context.mounted) context.push('/categories');
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.people_rounded,
            title: 'People',
            subtitle: 'Manage contacts for loans',
            onTap: () async {
              await HapticService.selection();
              if (context.mounted) context.push('/people');
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.flag_rounded,
            title: 'Financial Goals',
            subtitle: 'Track savings targets',
            onTap: () async {
              await HapticService.selection();
              if (context.mounted) context.push('/goals');
            },
          ),

          const Divider(indent: 24, endIndent: 24, height: 32),
          _buildSectionHeader(context, 'Data Management'),
          _buildSettingsTile(
            context,
            icon: Icons.file_upload_outlined,
            title: 'Export Data',
            subtitle: 'Export transactions to CSV',
            onTap: () async {
              await HapticService.medium();
              try {
                await ref.read(csvServiceProvider).exportTransactions();
                await HapticService.success();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exported successfully! Check downloads.')),
                  );
                }
              } catch (e) {
                await HapticService.error();
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
            icon: Icons.file_download_outlined,
            title: 'Import Data',
            subtitle: 'Import transactions from CSV',
            onTap: () async {
              await HapticService.medium();
              try {
                await ref.read(csvServiceProvider).importTransactions();
                await HapticService.success();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Imported successfully!')),
                  );
                }
              } catch (e) {
                await HapticService.error();
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
            icon: Icons.backup_outlined,
            title: 'Backup Database',
            subtitle: 'Create a local .isar backup',
            onTap: () async {
              await HapticService.medium();
              try {
                final path = await ref.read(backupServiceProvider).createBackup();
                await HapticService.success();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Backup created at: $path')),
                  );
                }
              } catch (e) {
                await HapticService.error();
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
            icon: Icons.restore_outlined,
            title: 'Restore Database',
            subtitle: 'Restore from a .isar file',
            onTap: () async {
              await HapticService.medium();
              try {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.any,
                );
                
                if (result != null && result.files.single.path != null) {
                  final path = result.files.single.path!;
                  if (context.mounted) {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Restore Backup?'),
                        content: const Text('This will close the app and replace current data. Are you sure?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () async {
                              await HapticService.medium();
                              if (context.mounted) Navigator.pop(context, true);
                            },
                            child: const Text('Restore'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await ref.read(backupServiceProvider).restoreBackup(path);
                      await HapticService.success();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Database replaced. Please restart the app.')),
                        );
                      }
                    }
                  }
                }
              } catch (e) {
                await HapticService.error();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Restore failed: $e')),
                  );
                }
              }
            },
          ),

          const SizedBox(height: 48),
          Center(
            child: Text(
              'Wallet v1.0.0 (2026 M3)',
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
        child: Icon(icon, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
