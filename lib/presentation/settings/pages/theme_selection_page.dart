import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/services/haptic_service.dart';

class ThemeSelectionPage extends ConsumerWidget {
  const ThemeSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);
    final themeNotifier = ref.read(themeControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Mode'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildThemeTile(
            context,
            title: 'System Default',
            subtitle: 'Follow system settings',
            icon: Symbols.settings_suggest,
            mode: ThemeMode.system,
            currentMode: themeState.themeMode,
            onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
          ),
          _buildThemeTile(
            context,
            title: 'Light Mode',
            subtitle: 'Always light',
            icon: Symbols.light_mode,
            mode: ThemeMode.light,
            currentMode: themeState.themeMode,
            onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
          ),
          _buildThemeTile(
            context,
            title: 'Dark Mode',
            subtitle: 'Always dark',
            icon: Symbols.dark_mode,
            mode: ThemeMode.dark,
            currentMode: themeState.themeMode,
            onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required VoidCallback onTap,
  }) {
    final isSelected = mode == currentMode;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: () async {
        await HapticService.selection();
        onTap();
      },
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          fill: isSelected ? 1 : 0,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(Symbols.check_circle, color: colorScheme.primary, fill: 1)
          : null,
    );
  }
}
