import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/theme/theme_provider.dart';

class PersonalizationPage extends ConsumerWidget {
  const PersonalizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(personalizationProvider);
    final notifier = ref.read(personalizationProvider.notifier);
    final themeState = ref.watch(themeControllerProvider);
    final themeNotifier = ref.read(themeControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Symbols.arrow_back_rounded),
            ),
            title: Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  notifier.reset();
                  themeNotifier.setThemeMode(ThemeMode.system);
                  themeNotifier.setUseMaterialYou(true);
                },
                icon: const Icon(Symbols.restart_alt_rounded),
                tooltip: 'Reset to Default',
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEditorialHeader(context),
                  const SizedBox(height: 48),
                  _buildConfigCanvas(context, state, notifier, themeState, themeNotifier),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorialHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'App\nCraft',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w900,
            height: 1.0,
            fontSize: 64,
            fontVariations: const [FontVariation('wdth', 120)],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Tailor every detail of your experience. From the depth of the typography to the behavior of the hardware.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
        ),
      ],
    );
  }

  Widget _buildConfigCanvas(
    BuildContext context, 
    PersonalizationState state,
    PersonalizationNotifier notifier,
    ThemeState themeState,
    ThemeController themeNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Appearance Section (THEME & STYLE)
        _buildSectionTitle(context, 'THEME & STYLE'),
        const SizedBox(height: 16),
        _buildThemeModeSelector(context, themeState, themeNotifier),
        const SizedBox(height: 24),
        _buildToggleItem(
          context,
          title: 'Dynamic Color',
          subtitle: 'Use Material You dynamic palettes from your wallpaper',
          icon: Symbols.draw_rounded,
          value: themeState.useMaterialYou,
          onChanged: (v) => themeNotifier.setUseMaterialYou(v),
        ),
        const SizedBox(height: 48),

        // 2. Color Scheme Variant
        _buildSectionTitle(context, 'COLOR SCHEME VARIANT'),
        const SizedBox(height: 16),
        _buildVariantSelector(context, themeState, themeNotifier),
        const SizedBox(height: 48),

        // 3. Live Preview (Card Sample)
        _buildSectionTitle(context, 'LIVE PREVIEW'),
        const SizedBox(height: 16),
        _TypeTester(state: state),
        const SizedBox(height: 48),

        // 4. Typography Section
        _buildSectionTitle(context, 'TYPOGRAPHY'),
        const SizedBox(height: 16),
        _buildToggleItem(
          context,
          title: 'Google Sans Flex',
          subtitle: 'Enable variable weight and width optimizations',
          icon: Symbols.font_download_rounded,
          value: state.useGoogleSansFlex,
          onChanged: (v) => notifier.toggleGoogleSans(v),
        ),
        const SizedBox(height: 48),

        // 5. Feedback Section
        _buildSectionTitle(context, 'FEEDBACK & BEHAVIOR'),
        const SizedBox(height: 16),
        _buildToggleItem(
          context,
          title: 'Vibrate on Transaction',
          subtitle: 'Only vibrates when a new transaction is successfully saved',
          icon: Symbols.vibration_rounded,
          value: state.vibrateOnTransaction,
          onChanged: (v) => notifier.toggleVibration(),
        ),
        const SizedBox(height: 16),
        _buildToggleItem(
          context,
          title: 'Restart on Currency Change',
          subtitle: 'Automatically restart app to apply new currency settings',
          icon: Symbols.restart_alt_rounded,
          value: state.shouldRestartOnCurrencyChange,
          onChanged: (v) => notifier.toggleRestartOnCurrencyChange(v),
        ),

        const SizedBox(height: 100), // Bottom padding for breathing room
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
    );
  }

  Widget _buildThemeModeSelector(BuildContext context, ThemeState state, ThemeController notifier) {
    final modes = [
      {'mode': ThemeMode.system, 'label': 'System', 'icon': Symbols.settings_brightness},
      {'mode': ThemeMode.light, 'label': 'Light', 'icon': Symbols.light_mode},
      {'mode': ThemeMode.dark, 'label': 'Dark', 'icon': Symbols.dark_mode},
    ];

    return Row(
      children: modes.map((m) {
        final isSelected = state.themeMode == m['mode'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => notifier.setThemeMode(m['mode'] as ThemeMode),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(m['icon'] as IconData, color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface, size: 20),
                    const SizedBox(height: 8),
                    Text(
                      m['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVariantSelector(BuildContext context, ThemeState state, ThemeController notifier) {
    final variants = [
      {'variant': ColorSchemeVariant.tonalSpot, 'label': 'Tonal Spot'},
      {'variant': ColorSchemeVariant.vibrant, 'label': 'Vibrant'},
      {'variant': ColorSchemeVariant.expressive, 'label': 'Expressive'},
      {'variant': ColorSchemeVariant.fruitSalad, 'label': 'Fruit Salad'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: variants.map((v) {
        final isSelected = state.variant == v['variant'];
        return ChoiceChip(
          label: Text(v['label'] as String),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) notifier.setVariant(v['variant'] as ColorSchemeVariant);
          },
        );
      }).toList(),
    );
  }

  Widget _buildToggleItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _TypeTester extends StatelessWidget {
  final PersonalizationState state;
  const _TypeTester({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colorScheme.primaryContainer.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                child: Icon(Symbols.account_balance_wallet, color: colorScheme.onPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Wallet Sample', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'The quick brown fox jumps over the lazy dog.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontFamily: state.useGoogleSansFlex ? 'GoogleSansFlex' : null,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Variable font weight and width optimizations applied dynamically.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontFamily: state.useGoogleSansFlex ? 'GoogleSansFlex' : null,
            ),
          ),
        ],
      ),
    );
  }
}
