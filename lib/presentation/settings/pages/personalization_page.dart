import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              icon: const Icon(Icons.arrow_back_rounded),
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
                  HapticService.medium();
                },
                icon: const Icon(Icons.refresh_rounded),
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
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
        
        // Icons Toggle
        _buildIconsToggle(context, state, notifier),
        
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
          label: 'Slant',
          value: state.slant,
          min: -10,
          max: 0,
          onChanged: (v) => notifier.updateSlant(v),
        ),
        _AtelierSlider(
          label: 'Width',
          value: state.width,
          min: 50,
          max: 150,
          onChanged: (v) => notifier.updateWidth(v),
        ),
        _AtelierSlider(
          label: 'Roundness',
          value: state.roundness,
          min: 0,
          max: 32,
          onChanged: (v) => notifier.updateRoundness(v),
        ),
      ],
    );
  }

  Widget _buildIconsToggle(BuildContext context, PersonalizationState state, PersonalizationNotifier notifier) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        notifier.toggleFillIcons(!state.fillIcons);
        HapticService.light();
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
                color: state.fillIcons ? colorScheme.primary : colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.brush_rounded,
                color: state.fillIcons ? Colors.white : colorScheme.primary,
                fill: state.fillIcons ? 1 : 0,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filled Icons',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Enable solid fill for all interface iconography',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: state.fillIcons,
              onChanged: (v) {
                notifier.toggleFillIcons(v);
                HapticService.light();
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
                  color: colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
              Row(
                children: [
                   Icon(Icons.palette_outlined, size: 18, color: colorScheme.primary),
                   const SizedBox(width: 12),
                   Icon(Icons.text_fields_rounded, size: 18, color: colorScheme.primary),
                   const SizedBox(width: 12),
                   Icon(Icons.auto_awesome_rounded, size: 18, color: colorScheme.primary),
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
              ],
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _PreviewIcon(icon: Icons.face_rounded, state: state),
              const SizedBox(width: 32),
              _PreviewIcon(icon: Icons.eco_rounded, state: state),
              const SizedBox(width: 32),
              _PreviewIcon(icon: Icons.star_rounded, state: state),
              const SizedBox(width: 32),
              _PreviewIcon(icon: Icons.favorite_rounded, state: state),
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
                  color: colorScheme.onSurface.withOpacity(0.5),
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
              activeTrackColor: colorScheme.primary.withOpacity(0.3),
              inactiveTrackColor: colorScheme.surfaceContainer,
              thumbColor: AppColors.tertiary,
              overlayColor: AppColors.tertiary.withOpacity(0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8, elevation: 0),
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: (v) {
                onChanged(v);
                HapticService.light();
              },
            ),
          ),
        ],
      ),
    );
  }
}
