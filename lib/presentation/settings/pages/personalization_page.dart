import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/services/haptic_service.dart';

class PersonalizationPage extends ConsumerWidget {
  const PersonalizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(personalizationProvider);
    final notifier = ref.read(personalizationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalization'),
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
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Preview Section
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LIVE PREVIEW',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'The quick brown fox jumps over the lazy dog',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.normal, // Controlled by variations
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(Icons.face_rounded, size: 40, fill: state.fillIcons ? 1 : 0),
                    Icon(Icons.eco_rounded, size: 40, fill: state.fillIcons ? 1 : 0),
                    Icon(Icons.star_rounded, size: 40, fill: state.fillIcons ? 1 : 0),
                    Icon(Icons.favorite_rounded, size: 40, fill: state.fillIcons ? 1 : 0),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          
          Text(
            'Typography Properties',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          _SliderTile(
            label: 'Grade',
            value: state.grade,
            min: 0,
            max: 100,
            onChanged: (v) => notifier.updateGrade(v),
          ),
          _SliderTile(
            label: 'Weight',
            value: state.weight,
            min: 100,
            max: 900,
            onChanged: (v) => notifier.updateWeight(v),
          ),
          _SliderTile(
            label: 'Slant',
            value: state.slant,
            min: -10,
            max: 0,
            onChanged: (v) => notifier.updateSlant(v),
          ),
          _SliderTile(
            label: 'Width',
            value: state.width,
            min: 75,
            max: 150,
            onChanged: (v) => notifier.updateWidth(v),
          ),
          _SliderTile(
            label: 'Roundness',
            value: state.roundness,
            min: 0,
            max: 100,
            onChanged: (v) => notifier.updateRoundness(v),
          ),

          const SizedBox(height: 32),
          
          SwitchListTile(
            title: const Text('Filled Icons'),
            subtitle: const Text('Enable solid fill for all interface iconography'),
            value: state.fillIcons,
            onChanged: (v) {
              notifier.toggleFillIcons(v);
              HapticService.light();
            },
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.brush_rounded,
                color: Theme.of(context).colorScheme.primary,
                fill: state.fillIcons ? 1 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text(
              value.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: (v) {
            onChanged(v);
            HapticService.light();
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
