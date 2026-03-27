import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/services/haptic_service.dart';

class PersonalizationPage extends ConsumerWidget {
  const PersonalizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(personalizationProvider);
    final notifier = ref.read(personalizationProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Symbols.arrow_back_rounded),
            ),
            title: Text(
              'Personalization',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  notifier.reset();
                  HapticService.mediumStatic();
                },
                icon: const Icon(Symbols.refresh_rounded),
                tooltip: 'Reset',
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 4, child: _buildEditorialHeader(context)),
                            const SizedBox(width: 48),
                            Expanded(flex: 8, child: _buildConfigCanvas(context, state, notifier)),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEditorialHeader(context),
                            const SizedBox(height: 48),
                            _buildConfigCanvas(context, state, notifier),
                          ],
                        ),
                );
              },
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
          'Visual\nGrade',
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
          'Curate your interface. Adjust the weight, width, and optical properties of the typography to match your creative intent.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildConfigCanvas(BuildContext context, PersonalizationState state, PersonalizationNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preview Card (Type-Tester)
        _TypeTester(state: state),
        const SizedBox(height: 48),
        
        // Sliders
        _buildSliderSection(context, state, notifier),
        
        const SizedBox(height: 48),

        // Color Schemes
        _buildColorSchemeSection(context, state, notifier),

        const SizedBox(height: 48),
        
        // Toggles
        _buildTogglesSection(context, state, notifier),
        
        const SizedBox(height: 100), // Bottom padding for breathing room
      ],
    );
  }

  Widget _buildSliderSection(BuildContext context, PersonalizationState state, PersonalizationNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AtelierSlider(
          label: 'Grade',
          value: state.grade,
          min: -200,
          max: 150,
          onChanged: (v) => notifier.updateGrade(v),
        ),
        _AtelierSlider(
          label: 'Weight',
          value: state.weight,
          min: 100,
          max: 1000,
          onChanged: (v) => notifier.updateWeight(v),
        ),
        _AtelierSlider(
          label: 'Width',
          value: state.width,
          min: 50,
          max: 150,
          onChanged: (v) => notifier.updateWidth(v),
        ),
        _AtelierSlider(
          label: 'Font Roundness (SOFT)',
          value: state.fontRoundness,
          min: 0,
          max: 100,
          onChanged: (v) => notifier.updateFontRoundness(v),
        ),
        _AtelierSlider(
          label: 'Optical Size (opsz)',
          value: state.opticalSize,
          min: 8,
          max: 144,
          onChanged: (v) => notifier.updateOpticalSize(v),
        ),
        _AtelierSlider(
          label: 'Corner Roundness',
          value: state.roundness,
          min: 0,
          max: 32,
          onChanged: (v) => notifier.updateRoundness(v),
        ),
      ],
    );
  }

  Widget _buildColorSchemeSection(BuildContext context, PersonalizationState state, PersonalizationNotifier notifier) {
    final colorScheme = Theme.of(context).colorScheme;
    final variants = {
      'tonalSpot': 'Tonal Spot',
      'monochrome': 'Monochrome',
      'neutral': 'Neutral',
      'vibrant': 'Vibrant',
      'expressive': 'Expressive',
      'content': 'Content',
      'fidelity': 'Fidelity',
      'rainbow': 'Rainbow',
      'fruitSalad': 'Fruit Salad',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COLOR SCHEME VARIANT',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: variants.entries.map((e) {
            final isSelected = state.colorSchemeVariant == e.key;
            return ChoiceChip(
              label: Text(e.value),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  notifier.updateColorSchemeVariant(e.key);
                  HapticService.mediumStatic();
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTogglesSection(BuildContext context, PersonalizationState state, PersonalizationNotifier notifier) {
    return Column(
      children: [
        _buildToggleItem(
          context,
          title: 'Filled Icons',
          subtitle: 'Enable solid fill for all interface iconography',
          icon: Symbols.brush_rounded,
          value: state.fillIcons,
          onChanged: (v) => notifier.toggleFillIcons(v),
        ),
        const SizedBox(height: 16),
        _buildToggleItem(
          context,
          title: 'Haptic Feedback',
          subtitle: 'System-wide vibrations and clicks',
          icon: Symbols.vibration_rounded,
          value: state.vibrationEnabled,
          onChanged: (v) => notifier.toggleVibration(v),
        ),
        const SizedBox(height: 16),
        _buildToggleItem(
          context,
          title: 'Transaction Haptics',
          subtitle: 'Vibrate specifically when adding transactions',
          icon: Symbols.add_task_rounded,
          value: state.vibrateOnTransaction,
          onChanged: (v) => notifier.toggleVibrateOnTransaction(v),
        ),
      ],
    );
  }

  Widget _buildToggleItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        onChanged(!value);
        HapticService.lightStatic();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: value ? colorScheme.primary : colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: value ? Colors.white : colorScheme.primary,
                fill: value ? 1.0 : 0.0, // Specific local control
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: (v) {
                onChanged(v);
                HapticService.lightStatic();
              },
            ),
          ],
        ),
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
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LIVE PREVIEW',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
              Row(
                children: [
                   Icon(Symbols.palette, size: 18, color: colorScheme.primary),
                   const SizedBox(width: 12),
                   Icon(Symbols.text_fields_rounded, size: 18, color: colorScheme.primary),
                   const SizedBox(width: 12),
                   Icon(Symbols.auto_awesome_rounded, size: 18, color: colorScheme.primary),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            'The quick brown fox jumps over the lazy dog',
            style: TextStyle(
              fontFamily: 'GoogleSansFlex',
              fontSize: 48,
              height: 1.1,
              fontVariations: [
                FontVariation('GRAD', state.grade),
                FontVariation('wght', state.weight),
                FontVariation('slnt', state.slant),
                FontVariation('wdth', state.width),
                FontVariation('SOFT', state.fontRoundness),
                FontVariation('opsz', state.opticalSize),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _PreviewIcon(icon: Symbols.face_rounded, state: state),
              const SizedBox(width: 32),
              _PreviewIcon(icon: Symbols.eco_rounded, state: state),
              const SizedBox(width: 32),
              _PreviewIcon(icon: Symbols.star_rounded, state: state),
              const SizedBox(width: 32),
              _PreviewIcon(icon: Symbols.favorite_rounded, state: state),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewIcon extends StatelessWidget {
  final IconData icon;
  final PersonalizationState state;
  const _PreviewIcon({required this.icon, required this.state});

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: 40,
      fill: state.fillIcons ? 1.0 : 0.0,
      weight: state.weight,
      grade: state.grade,
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
      padding: const EdgeInsets.only(bottom: 32),
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
          const SizedBox(height: 8),
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
                HapticService.lightStatic();
              },
            ),
          ),
        ],
      ),
    );
  }
}
