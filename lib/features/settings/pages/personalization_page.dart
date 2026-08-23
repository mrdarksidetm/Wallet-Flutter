import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/app_back_button.dart';

class PersonalizationPage extends ConsumerWidget {
  const PersonalizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(personalizationProvider);
    final notifier = ref.read(personalizationProvider.notifier);
    final themeState = ref.watch(themeControllerProvider);
    final themeNotifier = ref.read(themeControllerProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            leading: const AppBackButton(),
            title: Text(
              'Preferences',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: (theme.textTheme.headlineLarge?.fontSize ?? 32) + 3,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
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
                      _buildConfigCanvas(
                          context, state, notifier, themeState, themeNotifier),
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
        const SizedBox(height: 48),

        // 2. Dynamic Color & Properties (Renamed from COLOR SCHEME VARIANT)
        _buildSectionTitle(context, 'DYNAMIC COLOR AND PROPERTIES'),
        const SizedBox(height: 16),
        _buildToggleItem(
          context,
          title: 'Dynamic Color',
          subtitle: 'Use Material You dynamic palettes from your wallpaper',
          icon: Symbols.palette_rounded,
          value: themeState.useMaterialYou,
          onChanged: (v) => themeNotifier.setUseMaterialYou(v),
        ),
        const SizedBox(height: 16),
        _buildHorizontalVariantSelector(context, state, notifier, themeState),
        const SizedBox(height: 12),
        _buildVariantInfo(context),
        const SizedBox(height: 48),

        // 3. Typography Section
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
        const SizedBox(height: 16),
        _TypeTester(state: state),
        if (state.useGoogleSansFlex) ...[
          const SizedBox(height: 20),
          _buildSliderSection(context, state, notifier),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.tonalIcon(
              onPressed: () => notifier.resetTypography(),
              icon: const Icon(Symbols.restart_alt_rounded, size: 18),
              label: const Text(
                'Reset Typography',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 48),

        // 4. Feedback Section
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

        const SizedBox(height: 100), // Bottom breathing room
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

  Widget _buildThemeModeSelector(
      BuildContext context, ThemeState state, ThemeController notifier) {
    final colorScheme = Theme.of(context).colorScheme;
    final modes = [
      {
        'mode': ThemeMode.system,
        'label': 'System',
        'icon': Symbols.settings_brightness_rounded
      },
      {
        'mode': ThemeMode.light,
        'label': 'Light',
        'icon': Symbols.light_mode_rounded
      },
      {
        'mode': ThemeMode.dark,
        'label': 'Dark',
        'icon': Symbols.dark_mode_rounded
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(modes.length, (index) {
          final m = modes[index];
          final isSelected = state.themeMode == m['mode'];

          BorderRadius itemBorderRadius;
          if (index == 0) {
            itemBorderRadius =
                const BorderRadius.horizontal(left: Radius.circular(20));
          } else if (index == modes.length - 1) {
            itemBorderRadius =
                const BorderRadius.horizontal(right: Radius.circular(20));
          } else {
            itemBorderRadius = BorderRadius.circular(6);
          }

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Material(
                color: isSelected ? colorScheme.primary : Colors.transparent,
                borderRadius: isSelected
                    ? BorderRadius.circular(18)
                    : itemBorderRadius,
                clipBehavior: Clip.antiAlias,
                elevation: isSelected ? 1.5 : 0,
                shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
                child: InkWell(
                  onTap: () => notifier.setThemeMode(m['mode'] as ThemeMode),
                  borderRadius: isSelected
                      ? BorderRadius.circular(18)
                      : itemBorderRadius,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          m['icon'] as IconData,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                          size: 22,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          m['label'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHorizontalVariantSelector(
    BuildContext context,
    PersonalizationState state,
    PersonalizationNotifier notifier,
    ThemeState themeState,
  ) {
    final bool variantsEnabled = themeState.useMaterialYou;
    final colorScheme = Theme.of(context).colorScheme;
    final variants = [
      {
        'variant': 'tonalSpot',
        'label': 'Tonal Spot',
        'icon': Symbols.palette_rounded
      },
      {'variant': 'vibrant', 'label': 'Vibrant', 'icon': Symbols.flare_rounded},
      {
        'variant': 'expressive',
        'label': 'Expressive',
        'icon': Symbols.auto_awesome_rounded
      },
      {'variant': 'rainbow', 'label': 'Rainbow', 'icon': Symbols.looks_rounded},
      {
        'variant': 'fruitSalad',
        'label': 'Fruit Salad',
        'icon': Symbols.nutrition_rounded
      },
      {
        'variant': 'fidelity',
        'label': 'Fidelity',
        'icon': Symbols.verified_rounded
      },
      {
        'variant': 'content',
        'label': 'Content',
        'icon': Symbols.article_rounded
      },
      {
        'variant': 'neutral',
        'label': 'Neutral',
        'icon': Symbols.contrast_rounded
      },
      {
        'variant': 'monochrome',
        'label': 'Monochrome',
        'icon': Symbols.monochrome_photos_rounded
      },
    ];

    return Opacity(
      opacity: variantsEnabled ? 1.0 : 0.45,
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          itemCount: variants.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final v = variants[index];
            final variant = v['variant'] as String;
            final isSelected = state.colorSchemeVariant == variant;

            return Material(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(100),
              clipBehavior: Clip.antiAlias,
              elevation: isSelected ? 1 : 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: variantsEnabled
                    ? () => notifier.updateColorSchemeVariant(variant)
                    : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant
                              .withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        v['icon'] as IconData,
                        size: 16,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        v['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildSliderSection(BuildContext context, PersonalizationState state,
      PersonalizationNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSliderTile(
          context,
          label: 'Grade',
          code: 'GRAD',
          value: state.grade,
          min: -200,
          max: 150,
          displayValue: state.grade.toStringAsFixed(0),
          onChanged: (v) => notifier.updateGrade(v),
        ),
        const SizedBox(height: 10),
        _buildSliderTile(
          context,
          label: 'Weight',
          code: 'wght',
          value: state.weight,
          min: 100,
          max: 1000,
          displayValue: state.weight.toStringAsFixed(0),
          onChanged: (v) => notifier.updateWeight(v),
        ),
        const SizedBox(height: 10),
        _buildSliderTile(
          context,
          label: 'Width',
          code: 'wdth',
          value: state.width,
          min: 50,
          max: 150,
          displayValue: '${state.width.toStringAsFixed(0)}%',
          onChanged: (v) => notifier.updateWidth(v),
        ),
        const SizedBox(height: 10),
        _buildSliderTile(
          context,
          label: 'Roundness',
          code: 'ROND',
          value: state.fontRoundness,
          min: 0,
          max: 100,
          displayValue: '${state.fontRoundness.toStringAsFixed(0)}%',
          onChanged: (v) {
            notifier.updateFontRoundness(v);
            notifier.updateRoundness(v * 0.32);
          },
        ),
        const SizedBox(height: 10),
        _buildSliderTile(
          context,
          label: 'Optical Size',
          code: 'opsz',
          value: state.opticalSize,
          min: 8,
          max: 144,
          displayValue: '${state.opticalSize.toStringAsFixed(0)}pt',
          onChanged: (v) => notifier.updateOpticalSize(v),
        ),
      ],
    );
  }

  Widget _buildSliderTile(
    BuildContext context, {
    required String label,
    required String code,
    required double value,
    required double min,
    required double max,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      code,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: colorScheme.surfaceContainerHighest,
              thumbColor: colorScheme.primary,
              overlayColor: colorScheme.primary.withValues(alpha: 0.12),
              thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 7, elevation: 1),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
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
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
            color: colorScheme.primaryContainer.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: colorScheme.primary, shape: BoxShape.circle),
                child: Icon(Symbols.account_balance_wallet,
                    color: colorScheme.onPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Wallet Sample',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'The quick brown fox jumps over the lazy dog.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontFamily: state.useGoogleSansFlex ? 'GoogleSansFlex' : null,
                  fontWeight: FontWeight.w900,
                  fontVariations: state.useGoogleSansFlex
                      ? [
                          FontVariation('GRAD', state.grade),
                          FontVariation('wght', state.weight),
                          FontVariation('wdth', state.width),
                          FontVariation('ROND', state.fontRoundness),
                          FontVariation('opsz', state.opticalSize),
                        ]
                      : null,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Variable font weight and width optimizations applied dynamically.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontFamily: state.useGoogleSansFlex ? 'GoogleSansFlex' : null,
                  fontVariations: state.useGoogleSansFlex
                      ? [
                          FontVariation('GRAD', state.grade),
                          FontVariation('wght', state.weight),
                          FontVariation('wdth', state.width),
                          FontVariation('ROND', state.fontRoundness),
                          FontVariation('opsz', state.opticalSize),
                        ]
                      : null,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primary,
          ],
        ),
      ),
      child: SvgPicture.asset(
        'assets/images/blueprint.svg',
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          colorScheme.onPrimaryContainer.withValues(alpha: 0.85),
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
