import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/app_back_button.dart';

/// A custom painter that draws a circle split into three colored segments:
/// A top half, a bottom-left quarter, and a bottom-right quarter.
class _PalettePainter extends CustomPainter {
  final Color topColor;
  final Color bottomLeftColor;
  final Color bottomRightColor;

  _PalettePainter({
    required this.topColor,
    required this.bottomLeftColor,
    required this.bottomRightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Calculate the center point of our drawing area
    final Offset center = Offset(size.width / 2, size.height / 2);

    // 2. Determine the radius based on the smallest side to ensure it remains a perfect circle
    final double radius = min(size.width / 2, size.height / 2);

    // 3. Create a bounding rectangle where the circle will be drawn
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    // 4. Initialize the Paint object, which dictates how the shapes are filled
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // --- DRAWING THE TOP HALF ---
    // In Flutter, pi (180 degrees) is the 9 o'clock position (left side).
    // A sweep angle of pi (180 degrees) drawn clockwise brings us to the 3 o'clock position (right side).
    paint.color = topColor;
    canvas.drawArc(
      rect,
      pi, // Start angle: Left side
      pi, // Sweep angle: Half a circle
      true, // useCenter: true means it draws a pie slice connected to the center
      paint,
    );

    // --- DRAWING THE BOTTOM RIGHT QUARTER ---
    // 0 is the 3 o'clock position (right side).
    // A sweep angle of pi/2 (90 degrees) clockwise brings us to 6 o'clock (bottom center).
    paint.color = bottomRightColor;
    canvas.drawArc(
      rect,
      0, // Start angle: Right side
      pi / 2, // Sweep angle: Quarter of a circle
      true,
      paint,
    );

    // --- DRAWING THE BOTTOM LEFT QUARTER ---
    // pi/2 is the 6 o'clock position (bottom center).
    // A sweep angle of pi/2 (90 degrees) clockwise brings us back to 9 o'clock (left side).
    paint.color = bottomLeftColor;
    canvas.drawArc(
      rect,
      pi / 2, // Start angle: Bottom center
      pi / 2, // Sweep angle: Quarter of a circle
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PalettePainter oldDelegate) {
    return oldDelegate.topColor != topColor ||
        oldDelegate.bottomLeftColor != bottomLeftColor ||
        oldDelegate.bottomRightColor != bottomRightColor;
  }
}

/// A widget that displays a circular color palette and handles its selected state.
class DynamicColorVariant extends StatelessWidget {
  final String label;
  final Color topColor;
  final Color bottomLeftColor;
  final Color bottomRightColor;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  const DynamicColorVariant({
    super.key,
    required this.label,
    required this.topColor,
    required this.bottomLeftColor,
    required this.bottomRightColor,
    required this.isSelected,
    this.isEnabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.45,
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: Container(
          width: 84,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.35),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. Draw the actual three-color pie chart
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _PalettePainter(
                          topColor: topColor,
                          bottomLeftColor: bottomLeftColor,
                          bottomRightColor: bottomRightColor,
                        ),
                      ),
                    ),

                    // 2. If this item is selected, overlay the checkmark indicator
                    if (isSelected)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: colorScheme.onPrimary,
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

  static Map<String, Color> _getVariantColors(
    String variant,
    bool isDark,
  ) {
    switch (variant) {
      case 'tonalSpot':
        return {
          'top': isDark ? const Color(0xFF9BB1E8) : const Color(0xFFD3DFFF),
          'bottomLeft': isDark ? const Color(0xFFCBBCD6) : const Color(0xFFE8D5EC),
          'bottomRight': isDark ? const Color(0xFF42567D) : const Color(0xFF677799),
        };
      case 'vibrant':
        return {
          'top': isDark ? const Color(0xFFFFB0C8) : const Color(0xFFFFD8E4),
          'bottomLeft': isDark ? const Color(0xFFFFB787) : const Color(0xFFFFDCC1),
          'bottomRight': isDark ? const Color(0xFFB01D56) : const Color(0xFFE91E63),
        };
      case 'expressive':
        return {
          'top': isDark ? const Color(0xFFFFB596) : const Color(0xFFFFDBCA),
          'bottomLeft': isDark ? const Color(0xFFC7BFFF) : const Color(0xFFE5DEFF),
          'bottomRight': isDark ? const Color(0xFFB36700) : const Color(0xFFFF9800),
        };
      case 'rainbow':
        return {
          'top': isDark ? const Color(0xFFFFB0D0) : const Color(0xFFFFD8E6),
          'bottomLeft': isDark ? const Color(0xFFA3DDB3) : const Color(0xFFC4EED0),
          'bottomRight': isDark ? const Color(0xFF7B1FA2) : const Color(0xFF9C27B0),
        };
      case 'fruitSalad':
        return {
          'top': isDark ? const Color(0xFFA1DECA) : const Color(0xFFC3EEDD),
          'bottomLeft': isDark ? const Color(0xFFFFB1C1) : const Color(0xFFFFD8DF),
          'bottomRight': isDark ? const Color(0xFF007A50) : const Color(0xFF00B074),
        };
      case 'fidelity':
        return {
          'top': isDark ? const Color(0xFFB8C4F6) : const Color(0xFFDFE2F9),
          'bottomLeft': isDark ? const Color(0xFFC4B2EE) : const Color(0xFFE1D3F8),
          'bottomRight': isDark ? const Color(0xFF303F9F) : const Color(0xFF3F51B5),
        };
      case 'content':
        return {
          'top': isDark ? const Color(0xFFA8C8FF) : const Color(0xFFD7E2FF),
          'bottomLeft': isDark ? const Color(0xFFB9C9DF) : const Color(0xFFD9E2F1),
          'bottomRight': isDark ? const Color(0xFF1976D2) : const Color(0xFF2196F3),
        };
      case 'neutral':
        return {
          'top': isDark ? const Color(0xFFC7C6CA) : const Color(0xFFE3E2E6),
          'bottomLeft': isDark ? const Color(0xFFC6C6CD) : const Color(0xFFE2E2E9),
          'bottomRight': isDark ? const Color(0xFF5A5C63) : const Color(0xFF75787F),
        };
      case 'monochrome':
      default:
        return {
          'top': isDark ? const Color(0xFFBDBDBD) : const Color(0xFFE0E0E0),
          'bottomLeft': isDark ? const Color(0xFF757575) : const Color(0xFFBDBDBD),
          'bottomRight': isDark ? const Color(0xFF212121) : const Color(0xFF424242),
        };
    }
  }

  Widget _buildHorizontalVariantSelector(
    BuildContext context,
    PersonalizationState state,
    PersonalizationNotifier notifier,
    ThemeState themeState,
  ) {
    final bool variantsEnabled = themeState.useMaterialYou;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final variants = [
      {'variant': 'tonalSpot', 'label': 'Tonal Spot'},
      {'variant': 'vibrant', 'label': 'Vibrant'},
      {'variant': 'expressive', 'label': 'Expressive'},
      {'variant': 'rainbow', 'label': 'Rainbow'},
      {'variant': 'fruitSalad', 'label': 'Fruit Salad'},
      {'variant': 'fidelity', 'label': 'Fidelity'},
      {'variant': 'content', 'label': 'Content'},
      {'variant': 'neutral', 'label': 'Neutral'},
      {'variant': 'monochrome', 'label': 'Monochrome'},
    ];

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: variants.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final v = variants[index];
          final variant = v['variant'] as String;
          final isSelected = state.colorSchemeVariant == variant;
          final colors = _getVariantColors(variant, isDark);

          return DynamicColorVariant(
            label: v['label'] as String,
            topColor: colors['top']!,
            bottomLeftColor: colors['bottomLeft']!,
            bottomRightColor: colors['bottomRight']!,
            isSelected: isSelected,
            isEnabled: variantsEnabled,
            onTap: () => notifier.updateColorSchemeVariant(variant),
          );
        },
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
