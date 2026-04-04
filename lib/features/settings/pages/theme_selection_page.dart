import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/personalization_provider.dart';

class ThemeSelectionPage extends ConsumerWidget {
  const ThemeSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);
    final themeNotifier = ref.read(themeControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme & Style'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildSectionHeader(context, 'Theme Mode'),
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
          const Divider(indent: 24, endIndent: 24, height: 32),
          _buildSectionHeader(context, 'Dynamic Color Style'),
          _buildVariantInfo(context, themeState.useMaterialYou),
          _buildVariantTile(context, ref, 'Tonal Spot', 'tonalSpot',
              enabled: themeState.useMaterialYou),
          _buildVariantTile(context, ref, 'Vibrant', 'vibrant',
              enabled: themeState.useMaterialYou),
          _buildVariantTile(context, ref, 'Expressive', 'expressive',
              enabled: themeState.useMaterialYou),
          _buildVariantTile(context, ref, 'Monochrome', 'monochrome',
              enabled: themeState.useMaterialYou),
          _buildVariantTile(context, ref, 'Neutral', 'neutral',
              enabled: themeState.useMaterialYou),
          _buildVariantTile(context, ref, 'Content', 'content',
              enabled: themeState.useMaterialYou),
          _buildVariantTile(context, ref, 'Fidelity', 'fidelity',
              enabled: themeState.useMaterialYou),
          _buildVariantTile(context, ref, 'Rainbow', 'rainbow',
              enabled: themeState.useMaterialYou),
          _buildVariantTile(context, ref, 'Fruit Salad', 'fruitSalad',
              enabled: themeState.useMaterialYou),
        ],
      ),
    );
  }

  Widget _buildVariantInfo(BuildContext context, bool enabled) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Symbols.info_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                enabled
                    ? 'Dynamic Color is on. Select a variant to tune your palette style.'
                    : 'These variants are available only when Dynamic Color is enabled.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
              ),
            ),
          ],
        ),
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

  Widget _buildVariantTile(
    BuildContext context,
    WidgetRef ref,
    String title,
    String variant, {
    required bool enabled,
  }) {
    final personalization = ref.watch(personalizationProvider);
    final isSelected = personalization.colorSchemeVariant == variant;
    final colorScheme = Theme.of(context).colorScheme;

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: ListTile(
        onTap: enabled
            ? () {
                ref
                    .read(personalizationProvider.notifier)
                    .updateColorSchemeVariant(variant);
              }
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? Icon(Symbols.check_circle, color: colorScheme.primary, fill: 1)
            : null,
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
        
        onTap();
      },
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color:
              isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
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
