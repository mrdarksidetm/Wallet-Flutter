import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/colors.dart';

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
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DynamicBlueprintBanner(),
                Padding(
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
              ],
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
          'App Craft',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w900,
            height: 1.0,
            fontSize: 45,
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
        _buildVariantSelector(context, state, notifier, themeState),
        const SizedBox(height: 12),
        _buildVariantInfo(context),
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
        if (state.useGoogleSansFlex) ...[
          const SizedBox(height: 24),
          _buildSliderSection(context, state, notifier),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () => notifier.resetTypography(),
              icon: const Icon(Symbols.restart_alt_rounded, size: 18),
              label: const Text('Reset Typography to Default'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
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

  Widget _buildVariantSelector(
    BuildContext context,
    PersonalizationState state,
    PersonalizationNotifier notifier,
    ThemeState themeState,
  ) {
    final bool variantsEnabled = themeState.useMaterialYou;
    final variants = [
      {'variant': 'monochrome', 'label': 'Monochrome'},
      {'variant': 'neutral', 'label': 'Neutral'},
      {'variant': 'tonalSpot', 'label': 'Tonal Spot'},
      {'variant': 'vibrant', 'label': 'Vibrant'},
      {'variant': 'expressive', 'label': 'Expressive'},
      {'variant': 'content', 'label': 'Content'},
      {'variant': 'fidelity', 'label': 'Fidelity'},
      {'variant': 'rainbow', 'label': 'Rainbow'},
      {'variant': 'fruitSalad', 'label': 'Fruit Salad'},
    ];

    return Opacity(
      opacity: variantsEnabled ? 1.0 : 0.5,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: variants.map((v) {
          final variant = v['variant'] as String;
          final isSelected = state.colorSchemeVariant == variant;
          return ChoiceChip(
            label: Text(v['label'] as String),
            selected: isSelected,
            onSelected: variantsEnabled
                ? (selected) {
                    if (selected) notifier.updateColorSchemeVariant(variant);
                  }
                : null,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVariantInfo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
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
              'Color scheme variants are used only when Dynamic Color is enabled.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
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

  Widget _buildSliderSection(BuildContext context, PersonalizationState state, PersonalizationNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AtelierSlider(
          label: 'Grade (GRAD)',
          value: state.grade,
          min: -200,
          max: 150,
          onChanged: (v) => notifier.updateGrade(v),
        ),
        _AtelierSlider(
          label: 'Weight (wght)',
          value: state.weight,
          min: 100,
          max: 1000,
          onChanged: (v) => notifier.updateWeight(v),
        ),
        _AtelierSlider(
          label: 'Width (wdth)',
          value: state.width,
          min: 50,
          max: 150,
          onChanged: (v) => notifier.updateWidth(v),
        ),
        _AtelierSlider(
          label: 'Roundness (ROND)',
          value: state.fontRoundness,
          min: 0,
          max: 100,
          onChanged: (v) {
            notifier.updateFontRoundness(v);
            notifier.updateRoundness(v * 0.32); // Scale 0-100% to 0-32dp
          },
        ),
        _AtelierSlider(
          label: 'Optical Size (opsz)',
          value: state.opticalSize,
          min: 8,
          max: 144,
          onChanged: (v) => notifier.updateOpticalSize(v),
        ),
      ],
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
              fontVariations: state.useGoogleSansFlex ? [
                FontVariation('GRAD', state.grade),
                FontVariation('wght', state.weight),
                FontVariation('wdth', state.width),
                FontVariation('ROND', state.fontRoundness),
                FontVariation('opsz', state.opticalSize),
              ] : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Variable font weight and width optimizations applied dynamically.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontFamily: state.useGoogleSansFlex ? 'GoogleSansFlex' : null,
              fontVariations: state.useGoogleSansFlex ? [
                FontVariation('GRAD', state.grade),
                FontVariation('wght', state.weight),
                FontVariation('wdth', state.width),
                FontVariation('ROND', state.fontRoundness),
                FontVariation('opsz', state.opticalSize),
              ] : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _AtelierSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _AtelierSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(
                value.toStringAsFixed(0),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: colorScheme.primary.withValues(alpha: 0.3),
              inactiveTrackColor: colorScheme.surfaceContainer,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8, elevation: 0),
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: (v) {
                onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A responsive, dynamic-color blueprint banner that adapts to the user's Material You theme.
class DynamicBlueprintBanner extends StatelessWidget {
  const DynamicBlueprintBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Extract the dynamic color scheme from the current context.
    // This automatically listens to light/dark mode switches and OS-level wallpaper changes.
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      // 2. Make the banner span the full width of the screen.
      width: double.infinity,
      height: 160, // Standard banner height, adjust as needed.

      // 3. Create the dynamic background gradient.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            // Top of gradient: A softer, slightly lighter version of the primary color.
            colorScheme.primaryContainer,
            // Bottom of gradient: The bold, deep primary color.
            // In dark mode, 'primary' is naturally lighter to stand out against dark surfaces,
            // and 'primaryContainer' is darker. This ensures a beautiful gradient either way.
            colorScheme.primary,
          ],
        ),
      ),

      // 4. Load your transparent SVG and dynamically tint it.
      child: SvgPicture.asset(
        'assets/images/blueprint.svg',
        // 'cover' ensures the grid lines stretch to fill the width,
        // while Figma's internal center constraints keep your logo perfect.
        fit: BoxFit.cover,

        // 5. The Magic Touch: Colorizing the SVG paths.
        // Instead of keeping the SVG lines stark white, we tint them using 'onPrimaryContainer'.
        // This guarantees the lines will be highly visible and perfectly themed against the gradient,
        // whether the user is in light or dark mode.
        colorFilter: ColorFilter.mode(
          colorScheme.onPrimaryContainer.withValues(alpha: 0.85),
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
