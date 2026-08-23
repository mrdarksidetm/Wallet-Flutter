import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:restart_app/restart_app.dart';
import '../../../core/database/providers.dart';
import '../widgets/settings_segmented_card.dart';

class BackupRestoreSettingsPage extends ConsumerWidget {
  const BackupRestoreSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Medium Flexible Top App Bar with back navigation & enlarged title
          SliverAppBar.medium(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Symbols.arrow_back_rounded),
            ),
            title: Text(
              'Backup & Restore',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: (theme.textTheme.headlineLarge?.fontSize ?? 32) + 3,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Full Backup / Database Archive Section Header
                _buildSectionHeader(context, 'DATABASE ARCHIVES'),
                const SizedBox(height: 8),
                SettingsSegmentedGroup(
                  children: [
                    SettingsActionTile(
                      icon: Symbols.backup_rounded,
                      title: 'Backup Database',
                      subtitle:
                          'Complete archive of data, settings & attachments (.zip)',
                      showDivider: true,
                      onTap: () => _handleBackupDatabase(context, ref),
                    ),
                    SettingsActionTile(
                      icon: Symbols.restore_rounded,
                      title: 'Restore Backup',
                      subtitle: 'Restore all data from a .zip backup archive',
                      showDivider: false,
                      onTap: () => _handleRestoreBackup(context, ref),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // CSV Management Section Header
                _buildSectionHeader(context, 'CSV SPREADSHEETS'),
                const SizedBox(height: 8),
                SettingsSegmentedGroup(
                  children: [
                    SettingsActionTile(
                      icon: Symbols.upload_file_rounded,
                      title: 'Export to CSV',
                      subtitle: 'Export transactions to a CSV spreadsheet',
                      showDivider: true,
                      onTap: () => _handleExportCSV(context, ref),
                    ),
                    SettingsActionTile(
                      icon: Symbols.download_for_offline_rounded,
                      title: 'Import from CSV',
                      subtitle:
                          'Import transactions from an existing CSV file',
                      showDivider: false,
                      onTap: () => _handleImportCSV(context, ref),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // JSON Management Section Header
                _buildSectionHeader(context, 'JSON STRUCTURED DATA'),
                const SizedBox(height: 8),
                SettingsSegmentedGroup(
                  children: [
                    SettingsActionTile(
                      icon: Symbols.database_rounded,
                      title: 'Export to JSON',
                      subtitle:
                          'Backup your transactions in portable JSON format',
                      showDivider: true,
                      onTap: () => _handleExportJSON(context, ref),
                    ),
                    SettingsActionTile(
                      icon: Symbols.file_open_rounded,
                      title: 'Import from JSON',
                      subtitle:
                          'Restore transactions from a JSON data file',
                      showDivider: false,
                      onTap: () => _handleImportJSON(context, ref),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.w900,
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
      ),
    );
  }

  Future<void> _handleBackupDatabase(BuildContext context, WidgetRef ref) async {
    try {
      final path = await ref.read(backupServiceProvider).createBackup();
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
  }

  Future<void> _handleRestoreBackup(BuildContext context, WidgetRef ref) async {
    try {
      final success = await ref.read(backupServiceProvider).restoreBackup();
      if (success && context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            title: const Text('Restore Successful'),
            content: const Text(
              'Data has been restored. The app will now restart to apply changes.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Restart.restartApp(),
                child: const Text('Restart App'),
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
  }

  Future<void> _handleExportCSV(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(csvServiceProvider).exportTransactions();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exported CSV successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _handleImportCSV(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(csvServiceProvider).importTransactions();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imported CSV successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  Future<void> _handleExportJSON(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(jsonServiceProvider).exportTransactions();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exported JSON successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _handleImportJSON(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(jsonServiceProvider).importTransactions();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imported JSON successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }
}
