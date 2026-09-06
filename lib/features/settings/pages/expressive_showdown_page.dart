import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/expressive_shape.dart';
import '../widgets/settings_segmented_card.dart';
import '../widgets/expressive_backdrop_banner.dart';

/// Expressive Showdown Page
/// Showcases Material 3 Expressive design tokens, multi-speed animated SVG backdrop,
/// dynamic organic shape morphology everywhere in the app, tactile spring dynamics,
/// Atelier palettes, and the Expressive Flex ("Wallet Flex") variable axis engine.
class ExpressiveShowdownPage extends ConsumerStatefulWidget {
  const ExpressiveShowdownPage({super.key});

  @override
  ConsumerState<ExpressiveShowdownPage> createState() =>
      _ExpressiveShowdownPageState();
}

class _ExpressiveShowdownPageState extends ConsumerState<ExpressiveShowdownPage>
    with TickerProviderStateMixin {
  late final AnimationController _shapeMorphController;
  late final AnimationController _springPadController;

  double _springDragOffset = 0.0;

  static const List<_ShapeDescriptor> _expressiveShapes = [
    _ShapeDescriptor(
      name: 'Squircle',
      type: ExpressiveShapeType.squircle,
      subtitle: 'Smooth super-ellipse with continuous curvature',
      badge: 'Continuous C2',
      icon: Symbols.crop_square_rounded,
    ),
    _ShapeDescriptor(
      name: '4-Leaf Petal',
      type: ExpressiveShapeType.petal,
      subtitle: 'Intersecting organic clover quadrants',
      badge: 'Floral Emblem',
      icon: Symbols.local_florist_rounded,
    ),
    _ShapeDescriptor(
      name: '8-Point Starburst',
      type: ExpressiveShapeType.starburst,
      subtitle: 'Radial badge with smoothed vertices',
      badge: 'Accent Badge',
      icon: Symbols.auto_awesome_rounded,
    ),
    _ShapeDescriptor(
      name: 'Scallop Medallion',
      type: ExpressiveShapeType.scallop,
      subtitle: 'Circular container with 12-wave harmonic edge',
      badge: 'Harmonic',
      icon: Symbols.military_tech_rounded,
    ),
    _ShapeDescriptor(
      name: 'Pill Capsule',
      type: ExpressiveShapeType.pill,
      subtitle: 'Extended stadium container with maximal fillet',
      badge: 'Action Target',
      icon: Symbols.pill_rounded,
    ),
    _ShapeDescriptor(
      name: 'Asymmetric Arch',
      type: ExpressiveShapeType.asymmetric,
      subtitle: 'Contrasting diagonal corner radii for editorial layout',
      badge: 'Editorial',
      icon: Symbols.interests_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _shapeMorphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _springPadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _shapeMorphController.forward();
  }

  @override
  void dispose() {
    _shapeMorphController.dispose();
    _springPadController.dispose();
    super.dispose();
  }

  void _triggerSpringImpulse() {
    HapticFeedback.mediumImpact();
    _springPadController.reset();
    _springPadController.forward();
  }

  void _selectShape(ExpressiveShapeType shapeType) {
    HapticFeedback.selectionClick();
    ref
        .read(personalizationProvider.notifier)
        .setExpressiveShape(shapeType.name);
    _shapeMorphController.reset();
    _shapeMorphController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final personalization = ref.watch(personalizationProvider);
    final isExpressive = personalization.isExpressiveDiversificationEnabled;
    final activeShapeType = ExpressiveShapeType.fromString(
        personalization.selectedExpressiveShape);

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

          // Expressive Showcase Hero Banner (Multi-speed, multi-direction animated SVG)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: ExpressiveBackdropBanner(
                isExpressive: isExpressive,
                borderRadius: outerRadius,
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
            sliver: SliverList.list(
              children: [
                // Primary Master Setting: Expressive Diversification Switch Card (Skeleton Wireframe)
                _buildExpressiveDiversificationCard(
                  context,
                  theme,
                  colorScheme,
                  personalization,
                  isExpressive,
                ),

                const SizedBox(height: 24),

                // Entire Page Body (Only interactive when Expressive Diversification is active)
                IgnorePointer(
                  ignoring: !isExpressive,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isExpressive ? 1.0 : 0.38,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isExpressive) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.outlineVariant
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Symbols.lock_rounded,
                                  size: 18,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Enable Expressive Diversification above to unlock custom morphology, tactile physics, atelier palettes & Wallet Flex.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Section 1: Expressive Shape Morphology Playground
                        _buildSectionHeader(
                          theme,
                          colorScheme,
                          title: 'EXPRESSIVE SHAPE MORPHOLOGY',
                          badgeText: 'Applied Everywhere',
                          icon: Symbols.shapes_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildShapePlaygroundCard(
                          theme,
                          colorScheme,
                          personalization,
                          outerRadius,
                          isExpressive,
                          activeShapeType,
                        ),

                        const SizedBox(height: 28),

                        // Section 2: Expressive Flex (Replacing Variable Typography Dynamic)
                        _buildSectionHeader(
                          theme,
                          colorScheme,
                          title: 'EXPRESSIVE FLEX',
                          badgeText: personalization.isWalletFlexEnabled
                              ? 'Active: 5 Axes'
                              : 'Standard',
                          icon: Symbols.font_download_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildExpressiveFlexCard(
                          theme,
                          colorScheme,
                          personalization,
                          outerRadius,
                          isExpressive,
                        ),

                        const SizedBox(height: 28),

                        // Section 3: Spring Dynamics & Tactile Physics
                        _buildSectionHeader(
                          theme,
                          colorScheme,
                          title: 'SPRING DYNAMICS & TACTILE PHYSICS',
                          badgeText: isExpressive ? 'Active' : 'Linear',
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

                        // Section 4: Atelier Color Harmonies
                        _buildSectionHeader(
                          theme,
                          colorScheme,
                          title: 'ATELIER COLOR HARMONIES',
                          badgeText:
                              personalization.colorSchemeVariant.toUpperCase(),
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
                          activeShapeType,
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
              // Icon Badge
              Container(
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
                            color:
                                colorScheme.primary.withValues(alpha: 0.25),
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
    ExpressiveShapeType activeShapeType,
  ) {
    final currentDescriptor = _expressiveShapes.firstWhere(
      (s) => s.type == activeShapeType,
      orElse: () => _expressiveShapes.first,
    );

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
          // Live Shape Canvas Preview with Spring Morph Animation
          Center(
            child: SizedBox(
              height: 140,
              width: 140,
              child: AnimatedBuilder(
                animation: _shapeMorphController,
                builder: (context, child) {
                  final morphProgress = CurvedAnimation(
                    parent: _shapeMorphController,
                    curve: Curves.easeOutBack,
                  ).value;

                  return Transform.scale(
                    scale: 0.92 + (morphProgress * 0.08),
                    child: ExpressiveShapeContainer(
                      size: 140,
                      shapeType: currentDescriptor.type,
                      isExpressive: true,
                      color: colorScheme.primaryContainer,
                      borderColor: colorScheme.primary.withValues(alpha: 0.4),
                      borderWidth: 2.0,
                      child: Icon(
                        currentDescriptor.icon,
                        size: 42,
                        color: colorScheme.onPrimaryContainer,
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentDescriptor.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Active Globally',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${currentDescriptor.subtitle} • Shown on transactions, heatmap, accounts, budgets & tiles',
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
              final isSelected = shape.type == activeShapeType;

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
                  width: isSelected ? 1.5 : 1.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (_) => _selectShape(shape.type),
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- Section 2: Expressive Flex Card (Replaces Variable Typography Dynamic) ---
  Widget _buildExpressiveFlexCard(
    ThemeData theme,
    ColorScheme colorScheme,
    PersonalizationState personalization,
    double outerRadius,
    bool isExpressive,
  ) {
    final isFlexOn = personalization.isWalletFlexEnabled;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(outerRadius),
        border: Border.all(
          color: isFlexOn
              ? colorScheme.primary.withValues(alpha: 0.4)
              : colorScheme.outlineVariant.withValues(alpha: 0.25),
          width: isFlexOn ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wallet Flex Switch Header Tile
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isFlexOn
                  ? colorScheme.primaryContainer.withValues(alpha: 0.35)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isFlexOn
                    ? colorScheme.primary.withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isFlexOn
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Symbols.fit_screen_rounded,
                    size: 22,
                    color: isFlexOn
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wallet Flex',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Grad=50 • wgth=585 • wdth=120% • rond=19% • opsz=68pt',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isFlexOn
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontWeight:
                              isFlexOn ? FontWeight.bold : FontWeight.normal,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isFlexOn,
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
                  onChanged: isExpressive
                      ? (value) {
                          HapticFeedback.mediumImpact();
                          ref
                              .read(personalizationProvider.notifier)
                              .toggleWalletFlex(value);
                        }
                      : null,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Live Variable Font Preview Box
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
                  'Wallet Flex Dynamic Axis',
                  style: TextStyle(
                    fontFamily: 'GoogleSansFlex',
                    fontSize: 22,
                    fontVariations: [
                      FontVariation('GRAD', personalization.grade),
                      FontVariation('wght', personalization.weight),
                      FontVariation('wdth', personalization.width),
                      FontVariation('ROND', personalization.fontRoundness),
                      FontVariation('opsz', personalization.opticalSize),
                    ],
                    letterSpacing: -0.5,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'When Wallet Flex is toggled, Google Sans Flex dynamically synchronizes across every screen, balance tile, transaction and menu in the app.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 5 Axis Metric Chips
          Row(
            children: [
              _buildFlexMetricChip(
                  theme, colorScheme, 'GRAD', '${personalization.grade.toInt()}'),
              const SizedBox(width: 6),
              _buildFlexMetricChip(
                  theme, colorScheme, 'wght', '${personalization.weight.toInt()}'),
              const SizedBox(width: 6),
              _buildFlexMetricChip(
                  theme, colorScheme, 'wdth', '${personalization.width.toInt()}%'),
              const SizedBox(width: 6),
              _buildFlexMetricChip(theme, colorScheme, 'rond',
                  '${personalization.fontRoundness.toInt()}%'),
              const SizedBox(width: 6),
              _buildFlexMetricChip(theme, colorScheme, 'opsz',
                  '${personalization.opticalSize.toInt()}pt'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlexMetricChip(
    ThemeData theme,
    ColorScheme colorScheme,
    String axis,
    String value,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              axis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.primary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Section 3: Spring Dynamics & Tactile Physics Card ---
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

  // --- Section 4: Atelier Color Harmonies ---
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

  // --- Section 5: Design Token Metrics Inspector ---
  Widget _buildDesignTokensCard(
    ThemeData theme,
    ColorScheme colorScheme,
    PersonalizationState personalization,
    double outerRadius,
    bool isExpressive,
    ExpressiveShapeType activeShapeType,
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
                'Shape',
                activeShapeType.name.toUpperCase(),
              ),
              const SizedBox(width: 6),
              _buildTokenChip(
                theme,
                colorScheme,
                'Flex',
                personalization.isWalletFlexEnabled ? 'ON' : 'OFF',
              ),
              const SizedBox(width: 6),
              _buildTokenChip(
                theme,
                colorScheme,
                'Fillet',
                '${personalization.roundness.toInt()}dp',
              ),
              const SizedBox(width: 6),
              _buildTokenChip(
                theme,
                colorScheme,
                'Weight',
                '${personalization.weight.toInt()}',
              ),
              const SizedBox(width: 6),
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShapeDescriptor {
  final String name;
  final ExpressiveShapeType type;
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
