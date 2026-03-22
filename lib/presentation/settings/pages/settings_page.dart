import 'package:flutter/material.dart';
import '../../../core/services/haptic_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              await HapticService.light();
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
            subtitle: 'Indian Rupee (₹)',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'English',
            onTap: () {},
          ),

          const Divider(indent: 24, endIndent: 24, height: 32),
          _buildSectionHeader(context, 'Security'),
          _buildSettingsTile(
            context,
            icon: Icons.fingerprint_rounded,
            title: 'Biometric Lock',
            subtitle: 'Protect your data',
            trailing: Switch(
              value: true,
              onChanged: (val) async {
                await HapticService.medium();
              },
            ),
          ),

          const Divider(indent: 24, endIndent: 24, height: 32),
          _buildSectionHeader(context, 'Data Management'),
          _buildSettingsTile(
            context,
            icon: Icons.file_upload_outlined,
            title: 'Export Data',
            subtitle: 'CSV, Excel, or JSON',
            onTap: () async {
              await HapticService.success();
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.backup_outlined,
            title: 'Backup & Restore',
            subtitle: 'Local backup file',
            onTap: () {},
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
