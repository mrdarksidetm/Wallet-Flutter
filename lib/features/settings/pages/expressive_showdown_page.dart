import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/app_back_button.dart';
import '../widgets/settings_segmented_card.dart';

/// Expressive Showdown Page
/// Showcases Material 3 Expressive design tokens, dynamic organic geometry,
/// blueprint grid overlays, variable font scaling, and expressive motion dynamics.
class ExpressiveShowdownPage extends ConsumerStatefulWidget {
  const ExpressiveShowdownPage({super.key});

  @override
  ConsumerState<ExpressiveShowdownPage> createState() =>
      _ExpressiveShowdownPageState();
}

class _ExpressiveShowdownPageState extends ConsumerState<ExpressiveShowdownPage>
    with TickerProviderStateMixin {
  late final AnimationController _motionController;
  late final AnimationController _shapeMorphController;
  late final AnimationController _springPadController;

  int _selectedShapeIndex = 0;
  double _springDragOffset = 0.0;

  static const List<_ShapeDescriptor> _expressiveShapes = [
    _ShapeDescriptor(
      name: 'Squircle',
      type: _ShapeType.squircle,
      subtitle: 'Smooth super-ellipse with continuous curvature',
      badge: 'Continuous C2',
      icon: Symbols.crop_square_rounded,
    ),
    _ShapeDescriptor(
      name: '4-Leaf Petal',
      type: _ShapeType.petal,
      subtitle: 'Intersecting organic clover quadrants',
      badge: 'Floral Emblem',
      icon: Symbols.local_florist_rounded,
    ),
    _ShapeDescriptor(
      name: '8-Point Starburst',
      type: _ShapeType.starburst,
      subtitle: 'Radial badge with smoothed vertices',
      badge: 'Accent Badge',
      icon: Symbols.auto_awesome_rounded,
    ),
    _ShapeDescriptor(
      name: 'Scallop Medallion',
      type: _ShapeType.scallop,
      subtitle: 'Circular container with 12-wave harmonic edge',
      badge: 'Harmonic',
      icon: Symbols.military_tech_rounded,
    ),
    _ShapeDescriptor(
      name: 'Pill Capsule',
      type: _ShapeType.pill,
      subtitle: 'Extended stadium container with maximal fillet',
      badge: 'Action Target',
      icon: Symbols.pill_rounded,
    ),
    _ShapeDescriptor(
      name: 'Asymmetric Arch',
      type: _ShapeType.asymmetric,
      subtitle: 'Contrasting diagonal corner radii for editorial layout',
      badge: 'Editorial',
      icon: Symbols.interests_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _shapeMorphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _springPadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _shapeMorphController.forward();
    _motionController.repeat();
  }

  @override
  void dispose() {
    _motionController.dispose();
    _shapeMorphController.dispose();
    _springPadController.dispose();
    super.dispose();
  }

  void _triggerSpringImpulse() {
    HapticFeedback.mediumImpact();
    _springPadController.reset();
    _springPadController.forward();
  }

  void _selectShape(int index) {
    if (_selectedShapeIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedShapeIndex = index;
    });
    _shapeMorphController.reset();
    _shapeMorphController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final personalization = ref.watch(personalizationProvider);
    final isExpressive = personalization.isExpressiveDiversificationEnabled;

    if (!isExpressive && _motionController.isAnimating) {
      _motionController.stop();
    } else if (isExpressive && !_motionController.isAnimating) {
      _motionController.repeat();
    }

    final double outerRadius =
        personalization.roundness > 0 ? personalization.roundness : 28.0;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Medium Flexible Top App Bar with back navigation & enlarged title
          SliverAppBar.medium(
            leading: const AppBackButton(),
            title: Text(
              'Expressive',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: (theme.textTheme.headlineLarge?.fontSize ?? 32) + 3,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),

          // Expressive Showcase Hero Banner (The ONLY backdrop banner on the page)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: AnimatedBuilder(
                animation: _motionController,
                builder: (context, child) {
                  final scale = isExpressive
                      ? 1.0 + (sin(_motionController.value * 2 * pi) * 0.012)
                      : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(outerRadius),
                        border: Border.all(
                          color: colorScheme.outlineVariant
                              .withValues(alpha: 0.25),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AspectRatio(
                        aspectRatio: 412 / 190,
                        child: SvgPicture.asset(
                          'assets/images/expressive_showdown_banner.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
            sliver: SliverList.list(
              children: [
                // Primary Setting: Expressive Diversification Switch Card (Matching skeleton)
                _buildExpressiveDiversificationCard(
                  context,
                  theme,
                  colorScheme,
                  personalization,
                  isExpressive,
                ),

                const SizedBox(height: 28),

                // Section 1: Expressive Shape Morphology Playground
                _buildSectionHeader(
                  theme,
                  colorScheme,
                  title: 'EXPRESSIVE SHAPE MORPHOLOGY',
                  badgeText: 'Interactive',
                  icon: Symbols.shapes_rounded,
                ),
                const SizedBox(height: 12),
                _buildShapePlaygroundCard(
                  theme,
                  colorScheme,
                  personalization,
                  outerRadius,
                  isExpressive,
                ),

                const SizedBox(height: 28),

                // Section 2: Spring Dynamics & Tactile Physics
                _buildSectionHeader(
                  theme,
                  colorScheme,
                  title: 'SPRING DYNAMICS & TACTILE PHYSICS',
                  badgeText: isExpressive ? 'Active' : 'M3 Linear',
                  icon: Symbols.motion_photos_on_rounded,
                ),
                const SizedBox(height: 12),
                _buildSpringDynamicsCard(
                  theme,
                  colorScheme,
                  personalization,
                  outerRadius,
                  isExpressive,
                ),

                const SizedBox(height: 28),

                // Section 3: Atelier Color Harmonies
                _buildSectionHeader(
                  theme,
                  colorScheme,
                  title: 'ATELIER COLOR HARMONIES',
                  badgeText: personalization.colorSchemeVariant.toUpperCase(),
                  icon: Symbols.palette_rounded,
                ),
                const SizedBox(height: 12),
                _buildAtelierColorSection(
                  theme,
                  colorScheme,
                  personalization,
                  outerRadius,
                ),

                const SizedBox(height: 28),

                // Section 4: Variable Typography Engine
                _buildSectionHeader(
                  theme,
                  colorScheme,
                  title: 'VARIABLE TYPOGRAPHY DYNAMICS',
                  badgeText: 'Google Sans Flex',
                  icon: Symbols.font_download_rounded,
                ),
                const SizedBox(height: 12),
                _buildVariableTypographyCard(
                  theme,
                  colorScheme,
                  personalization,
                  outerRadius,
                ),

                const SizedBox(height: 28),

                // Section 5: Design Token Metrics Inspector
                _buildSectionHeader(
                  theme,
                  colorScheme,
                  title: 'MATERIAL 3 EXPRESSIVE TOKENS',
                  icon: Symbols.token_rounded,
                ),
                const SizedBox(height: 12),
                _buildDesignTokensCard(
                  theme,
                  colorScheme,
                  personalization,
                  outerRadius,
                  isExpressive,
                ),

                const SizedBox(height: 24),

                // Quick Navigation Card to Full Personalization
                SettingsSegmentedGroup(
                  children: [
                    SettingsActionTile(
                      icon: Symbols.tune_rounded,
                      title: 'All Appearance & Sliders',
                      subtitle:
                          'Fine-tune variable optical size, grade, slant and corner fillets',
                      showDivider: false,
                      onTap: () => context.push('/personalization'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Section Header with optional badge ---
  Widget _buildSectionHeader(
    ThemeData theme,
    ColorScheme colorScheme, {
    required String title,
    String? badgeText,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                fontSize: 12,
              ),
            ),
          ),
          if (badgeText != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badgeText,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- Hero Switch Card (Matching exact wireframe/skeleton rx=36 pill) ---
  Widget _buildExpressiveDiversificationCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    PersonalizationState personalization,
    bool isExpressive,
  ) {
    return Material(
      color: colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(36), // Pill squircle matching SVG
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          ref
              .read(personalizationProvider.notifier)
              .toggleExpressiveDiversification();
        },
        borderRadius: BorderRadius.circular(36),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Icon Badge with subtle rotation when active
              AnimatedBuilder(
                animation: _motionController,
                builder: (context, child) {
                  final rotation = isExpressive
                      ? sin(_motionController.value * 2 * pi) * 0.15
                      : 0.0;
                  return Transform.rotate(
                    angle: rotation,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isExpressive
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isExpressive
                            ? [
                                BoxShadow(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        Symbols.auto_awesome_rounded,
                        size: 24,
                        color: isExpressive
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                        fill: personalization.fillIcons ? 1.0 : 0.0,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(width: 16),

              // Title and Description
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expressive Diversification',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'High-chroma organic shapes & motion',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Material 3 Switch with checkmark
              Switch(
                value: isExpressive,
                thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: colorScheme.onPrimary,
                    );
                  }
                  return null;
                }),
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  ref
                      .read(personalizationProvider.notifier)
                      .toggleExpressiveDiversification(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Section 1: Shape Morphing Playground Card ---
  Widget _buildShapePlaygroundCard(
    ThemeData theme,
    ColorScheme colorScheme,
    PersonalizationState personalization,
    double outerRadius,
    bool isExpressive,
  ) {
    final currentDescriptor = _expressiveShapes[_selectedShapeIndex];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(outerRadius),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Shape Canvas Preview
          Center(
            child: SizedBox(
              height: 150,
              width: 150,
              child: AnimatedBuilder(
                animation: Listenable.merge(
                    [_shapeMorphController, _motionController]),
                builder: (context, child) {
                  final morphProgress = CurvedAnimation(
                    parent: _shapeMorphController,
                    curve: Curves.easeOutBack,
                  ).value;

                  final breathScale = isExpressive
                      ? 1.0 + (sin(_motionController.value * 2 * pi) * 0.02)
                      : 1.0;

                  return Transform.scale(
                    scale: breathScale,
                    child: CustomPaint(
                      painter: _ExpressiveShapePainter(
                        shapeType: currentDescriptor.type,
                        progress: morphProgress,
                        primaryColor: colorScheme.primary,
                        containerColor: colorScheme.primaryContainer,
                        accentColor: colorScheme.tertiaryContainer,
                        outlineColor:
                            colorScheme.primary.withValues(alpha: 0.35),
                      ),
                      child: Center(
                        child: Icon(
                          currentDescriptor.icon,
                          size: 36,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Shape Title & Description Badge
          Center(
            child: Column(
              children: [
                Text(
                  currentDescriptor.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentDescriptor.subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Shape Selection Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_expressiveShapes.length, (index) {
              final shape = _expressiveShapes[index];
              final isSelected = index == _selectedShapeIndex;
              return ChoiceChip(
                label: Text(shape.name),
                selected: isSelected,
                avatar: Icon(
                  shape.icon,
                  size: 16,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
                selectedColor: colorScheme.primaryContainer,
                backgroundColor: colorScheme.surfaceContainerHighest,
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (_) => _selectShape(index),
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- Section 2: Spring Dynamics & Tactile Physics Card ---
  Widget _buildSpringDynamicsCard(
    ThemeData theme,
    ColorScheme colorScheme,
    PersonalizationState personalization,
    double outerRadius,
    bool isExpressive,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(outerRadius),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tactile Spring Simulator',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap or drag the interactive card to experience damped harmonic oscillation & haptic triggers.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),

          // Interactive Bouncy Drag / Tap Card
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _springDragOffset =
                    (_springDragOffset + details.delta.dy * 0.4)
                        .clamp(-25.0, 25.0);
              });
            },
            onPanEnd: (_) {
              setState(() {
                _springDragOffset = 0.0;
              });
              _triggerSpringImpulse();
            },
            onTap: _triggerSpringImpulse,
            child: AnimatedBuilder(
              animation: _springPadController,
              builder: (context, child) {
                // Harmonic damped oscillation formula
                final t = _springPadController.value * 6.0;
                final bounce = _springPadController.isAnimating
                    ? sin(t * 3.5) * exp(-t * 0.9) * 12.0
                    : 0.0;

                final currentOffset = _springDragOffset + bounce;

                return Transform.translate(
                  offset: Offset(0, currentOffset),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isExpressive
                          ? colorScheme.secondaryContainer
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Symbols.touch_app_rounded,
                            color: colorScheme.onPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tap to Feel Spring Physics',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isExpressive
                                    ? 'Stiffness: 300 N/m • Damping: 0.75'
                                    : 'Linear M3 Curve • Standard Easing',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isExpressive
                                      ? colorScheme.onSecondaryContainer
                                      : colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: _triggerSpringImpulse,
                          icon: const Icon(Symbols.play_arrow_rounded, size: 18),
                          label: const Text('Impulse'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Expressive Micro-Motion & Bottom Sheet Actions
          SettingsSegmentedGroup(
            children: [
              SettingsActionTile(
                icon: Symbols.water_drop_rounded,
                title: 'Fluid Organic Morphing',
                subtitle:
                    'Dynamic morphing on Floating Action Buttons and Bottom Sheets',
                showDivider: true,
                trailing: Switch(
                  value: isExpressive,
                  onChanged: (v) {
                    ref
                        .read(personalizationProvider.notifier)
                        .toggleExpressiveDiversification(v);
                  },
                ),
              ),
              SettingsActionTile(
                icon: Symbols.vibration_rounded,
                title: 'Tactile Haptic Feedback',
                subtitle: 'Calibrated micro-vibrations on transaction triggers',
                showDivider: false,
                trailing: Switch(
                  value: personalization.vibrateOnTransaction,
                  onChanged: (_) {
                    ref
                        .read(personalizationProvider.notifier)
                        .toggleVibration();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Section 3: Atelier Color Harmonies ---
  Widget _buildAtelierColorSection(
    ThemeData theme,
    ColorScheme colorScheme,
    PersonalizationState personalization,
    double outerRadius,
  ) {
    final variants = [
      {'name': 'expressive', 'label': 'Expressive'},
      {'name': 'vibrant', 'label': 'Vibrant'},
      {'name': 'fruitSalad', 'label': 'Fruit Salad'},
      {'name': 'rainbow', 'label': 'Rainbow'},
      {'name': 'tonalSpot', 'label': 'Tonal Spot'},
      {'name': 'monochrome', 'label': 'Monochrome'},
    ];

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(outerRadius),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dynamic Chroma Calibration',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select high-chroma scheme variants inspired by Material 3 Expressive Atelier palettes.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),

          // Horizontal Palette Cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: variants.map((v) {
                final name = v['name']!;
                final label = v['label']!;
                final isSelected = personalization.colorSchemeVariant == name;
                final colors = _getPaletteColors(name, isDark);

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref
                          .read(personalizationProvider.notifier)
                          .updateColorSchemeVariant(name);
                      final variantEnum = ColorSchemeVariant.values.firstWhere(
                        (e) => e.name == name,
                        orElse: () => ColorSchemeVariant.tonalSpot,
                      );
                      ref
                          .read(themeControllerProvider.notifier)
                          .setVariant(variantEnum);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 86,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primaryContainer
                                .withValues(alpha: 0.35)
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outlineVariant
                                  .withValues(alpha: 0.3),
                          width: isSelected ? 2.0 : 1.0,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _PalettePainter(
                                      topColor: colors['top']!,
                                      bottomLeftColor: colors['bottomLeft']!,
                                      bottomRightColor: colors['bottomRight']!,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check_rounded,
                                      color: colorScheme.onPrimary,
                                      size: 14,
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
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  static Map<String, Color> _getPaletteColors(String variant, bool isDark) {
    switch (variant) {
      case 'expressive':
        return {
          'top': isDark ? const Color(0xFFFFB596) : const Color(0xFFFFDBCA),
          'bottomLeft':
              isDark ? const Color(0xFFC7BFFF) : const Color(0xFFE5DEFF),
          'bottomRight':
              isDark ? const Color(0xFFB36700) : const Color(0xFFFF9800),
        };
      case 'vibrant':
        return {
          'top': isDark ? const Color(0xFFFFB0C8) : const Color(0xFFFFD8E4),
          'bottomLeft':
              isDark ? const Color(0xFFFFB787) : const Color(0xFFFFDCC1),
          'bottomRight':
              isDark ? const Color(0xFFB01D56) : const Color(0xFFE91E63),
        };
      case 'fruitSalad':
        return {
          'top': isDark ? const Color(0xFFA1DECA) : const Color(0xFFC3EEDD),
          'bottomLeft':
              isDark ? const Color(0xFFFFB1C1) : const Color(0xFFFFD8DF),
          'bottomRight':
              isDark ? const Color(0xFF007A50) : const Color(0xFF00B074),
        };
      case 'rainbow':
        return {
          'top': isDark ? const Color(0xFFFFB0D0) : const Color(0xFFFFD8E6),
          'bottomLeft':
              isDark ? const Color(0xFFA3DDB3) : const Color(0xFFC4EED0),
          'bottomRight':
              isDark ? const Color(0xFF7B1FA2) : const Color(0xFF9C27B0),
        };
      case 'tonalSpot':
        return {
          'top': isDark ? const Color(0xFF9BB1E8) : const Color(0xFFD3DFFF),
          'bottomLeft':
              isDark ? const Color(0xFFCBBCD6) : const Color(0xFFE8D5EC),
          'bottomRight':
              isDark ? const Color(0xFF42567D) : const Color(0xFF677799),
        };
      case 'monochrome':
      default:
        return {
          'top': isDark ? const Color(0xFFBDBDBD) : const Color(0xFFE0E0E0),
          'bottomLeft':
              isDark ? const Color(0xFF757575) : const Color(0xFFBDBDBD),
          'bottomRight':
              isDark ? const Color(0xFF212121) : const Color(0xFF424242),
        };
    }
  }

  // --- Section 4: Variable Typography Engine Card ---
  Widget _buildVariableTypographyCard(
    ThemeData theme,
    ColorScheme colorScheme,
    PersonalizationState personalization,
    double outerRadius,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(outerRadius),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Variable Font Preview Sample
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expressive Typography',
                  style: TextStyle(
                    fontFamily: 'GoogleSansFlex',
                    fontSize: 22,
                    fontWeight: FontWeight.values[
                        ((personalization.weight / 100).clamp(1, 9).toInt()) -
                            1],
                    letterSpacing: -0.5,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Weight: ${personalization.weight.toInt()} • Grade: ${personalization.grade.toInt()} • Width: ${personalization.width.toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Font Weight Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weight (wght)',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${personalization.weight.toInt()}',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: personalization.weight,
            min: 100,
            max: 900,
            divisions: 8,
            label: '${personalization.weight.toInt()}',
            onChanged: (v) {
              ref.read(personalizationProvider.notifier).updateWeight(v);
            },
          ),

          // Grade Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grade (GRAD)',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${personalization.grade.toInt()}',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: personalization.grade,
            min: -200,
            max: 200,
            divisions: 16,
            label: '${personalization.grade.toInt()}',
            onChanged: (v) {
              ref.read(personalizationProvider.notifier).updateGrade(v);
            },
          ),
        ],
      ),
    );
  }

  // --- Section 5: Design Token Metrics Inspector ---
  Widget _buildDesignTokensCard(
    ThemeData theme,
    ColorScheme colorScheme,
    PersonalizationState personalization,
    double outerRadius,
    bool isExpressive,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(outerRadius),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Symbols.token_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(
                'Active Expressive Parameters',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTokenChip(
                theme,
                colorScheme,
                'Fillet',
                '${personalization.roundness.toInt()}dp',
              ),
              const SizedBox(width: 8),
              _buildTokenChip(
                theme,
                colorScheme,
                'Weight',
                '${personalization.weight.toInt()}',
              ),
              const SizedBox(width: 8),
              _buildTokenChip(
                theme,
                colorScheme,
                'Grade',
                '${personalization.grade.toInt()}',
              ),
              const SizedBox(width: 8),
              _buildTokenChip(
                theme,
                colorScheme,
                'Motion',
                isExpressive ? 'Spring' : 'Linear',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTokenChip(
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    String value,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Supporting Shape Data Classes & Custom Painters ---

enum _ShapeType {
  squircle,
  petal,
  starburst,
  scallop,
  pill,
  asymmetric,
}

class _ShapeDescriptor {
  final String name;
  final _ShapeType type;
  final String subtitle;
  final String badge;
  final IconData icon;

  const _ShapeDescriptor({
    required this.name,
    required this.type,
    required this.subtitle,
    required this.badge,
    required this.icon,
  });
}

class _ExpressiveShapePainter extends CustomPainter {
  final _ShapeType shapeType;
  final double progress;
  final Color primaryColor;
  final Color containerColor;
  final Color accentColor;
  final Color outlineColor;

  _ExpressiveShapePainter({
    required this.shapeType,
    required this.progress,
    required this.primaryColor,
    required this.containerColor,
    required this.accentColor,
    required this.outlineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) * 0.9 * progress;

    final Path path = Path();

    switch (shapeType) {
      case _ShapeType.squircle:
        final r = radius * 0.95;
        final rect = Rect.fromCenter(
            center: center, width: r * 2, height: r * 2);
        path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(r * 0.45)));
        break;

      case _ShapeType.petal:
        // 4-leaf organic flower (matching left emblem on SVG backdrop)
        final lobeRadius = radius * 0.52;
        path.addOval(Rect.fromCircle(
            center: center + Offset(-lobeRadius * 0.6, 0), radius: lobeRadius));
        path.addOval(Rect.fromCircle(
            center: center + Offset(lobeRadius * 0.6, 0), radius: lobeRadius));
        path.addOval(Rect.fromCircle(
            center: center + Offset(0, -lobeRadius * 0.6), radius: lobeRadius));
        path.addOval(Rect.fromCircle(
            center: center + Offset(0, lobeRadius * 0.6), radius: lobeRadius));
        break;

      case _ShapeType.starburst:
        // 8-point smooth starburst (matching right emblem on SVG backdrop)
        const int points = 8;
        final outerR = radius;
        final innerR = radius * 0.62;
        for (int i = 0; i < points * 2; i++) {
          final r = i.isEven ? outerR : innerR;
          final angle = (i * pi) / points - (pi / 2);
          final x = center.dx + r * cos(angle);
          final y = center.dy + r * sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        break;

      case _ShapeType.scallop:
        // 12-wave circular medallion
        const int waves = 12;
        for (int i = 0; i <= 360; i += 2) {
          final rad = i * pi / 180;
          final waveR = radius * 0.85 + (sin(rad * waves) * radius * 0.12);
          final x = center.dx + waveR * cos(rad);
          final y = center.dy + waveR * sin(rad);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        break;

      case _ShapeType.pill:
        final w = radius * 2.0;
        final h = radius * 1.25;
        final rect = Rect.fromCenter(center: center, width: w, height: h);
        path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(h / 2)));
        break;

      case _ShapeType.asymmetric:
        final r = radius * 0.95;
        final rect = Rect.fromCenter(
            center: center, width: r * 2, height: r * 2);
        path.addRRect(RRect.fromRectAndCorners(
          rect,
          topLeft: Radius.circular(r * 0.65),
          bottomRight: Radius.circular(r * 0.65),
          topRight: Radius.circular(r * 0.15),
          bottomLeft: Radius.circular(r * 0.15),
        ));
        break;
    }

    // Fill with expressive gradient
    final paintFill = Paint()
      ..shader = LinearGradient(
        colors: [containerColor, accentColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paintFill);

    // Outline stroke
    final paintStroke = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(path, paintStroke);
  }

  @override
  bool shouldRepaint(covariant _ExpressiveShapePainter oldDelegate) {
    return oldDelegate.shapeType != shapeType ||
        oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.containerColor != containerColor;
  }
}

/// A custom painter that draws a circle split into three colored segments for palette previews
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
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = min(size.width / 2, size.height / 2);
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Top half
    paint.color = topColor;
    canvas.drawArc(rect, pi, pi, true, paint);

    // Bottom right quarter
    paint.color = bottomRightColor;
    canvas.drawArc(rect, 0, pi / 2, true, paint);

    // Bottom left quarter
    paint.color = bottomLeftColor;
    canvas.drawArc(rect, pi / 2, pi / 2, true, paint);
  }

  @override
  bool shouldRepaint(covariant _PalettePainter oldDelegate) {
    return oldDelegate.topColor != topColor ||
        oldDelegate.bottomLeftColor != bottomLeftColor ||
        oldDelegate.bottomRightColor != bottomRightColor;
  }
}
