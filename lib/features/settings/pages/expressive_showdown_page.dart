import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/providers.dart';
import '../../../core/theme/personalization_provider.dart';
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _motionController;

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    // Perpetual subtle breathing micro-motion
    _motionController.repeat();
  }

  @override
  void dispose() {
    _motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final personalization = ref.watch(personalizationProvider);
    final currency = ref.watch(currencyProvider);
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
              'Expressive Showdown',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: (theme.textTheme.headlineLarge?.fontSize ?? 32) + 3,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            sliver: SliverList.list(
              children: [
                // Hero Expressive Graphic Showcase Banner
                _buildHeroBanner(
                  context,
                  colorScheme,
                  outerRadius,
                  currency,
                  isExpressive,
                ),

                const SizedBox(height: 20),

                // Primary Setting: Expressive Diversification Switch Card
                _buildExpressiveDiversificationCard(
                  context,
                  theme,
                  colorScheme,
                  personalization,
                  isExpressive,
                ),

                const SizedBox(height: 24),

                // Section Header
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    'EXPRESSIVE CAPABILITIES',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                // Expressive Motion & Dynamics Segmented Group
                SettingsSegmentedGroup(
                  children: [
                    SettingsActionTile(
                      icon: Symbols.motion_photos_on_rounded,
                      title: 'Dynamic Spring Physics',
                      subtitle:
                          'Perpetual micro-motion, organic squircle morphing & reactive sheets',
                      showDivider: true,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isExpressive
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isExpressive ? 'Active' : 'Paused',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isExpressive
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () {
                        ref
                            .read(personalizationProvider.notifier)
                            .toggleExpressiveDiversification();
                      },
                    ),
                    SettingsActionTile(
                      icon: Symbols.palette_rounded,
                      title: 'Atelier Color Harmonies',
                      subtitle:
                          'Variant: ${personalization.colorSchemeVariant.toUpperCase()} • Dynamic chroma calibration',
                      showDivider: true,
                      onTap: () => context.push('/personalization'),
                    ),
                    SettingsActionTile(
                      icon: Symbols.font_download_rounded,
                      title: 'Variable Typography',
                      subtitle:
                          'Google Sans Flex: weight ${personalization.weight.toInt()}, grade ${personalization.grade.toInt()}',
                      showDivider: false,
                      onTap: () => context.push('/personalization'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Design Token Metrics Card
                _buildDesignTokensCard(
                    theme, colorScheme, personalization, outerRadius),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(
    BuildContext context,
    ColorScheme colorScheme,
    double outerRadius,
    String currency,
    bool isExpressive,
  ) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A22), // Dark expressive canvas base
        borderRadius: BorderRadius.circular(outerRadius),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Animated Canvas with Organic Shapes, Blueprint Grid & Concentric Circles
          AnimatedBuilder(
            animation: _motionController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ExpressiveHeroPainter(
                  animationProgress:
                      isExpressive ? _motionController.value : 0.0,
                  primaryColor: colorScheme.primary,
                  primaryContainerColor: colorScheme.primaryContainer,
                  tertiaryColor: colorScheme.tertiary,
                  surfaceContainerColor: colorScheme.surfaceContainerHighest,
                  outlineColor: colorScheme.outlineVariant,
                  isExpressive: isExpressive,
                ),
              );
            },
          ),

          // Central Floating Squircle Card with Currency / Wallet Emblem
          Center(
            child: AnimatedBuilder(
              animation: _motionController,
              builder: (context, child) {
                final scale = isExpressive
                    ? 1.0 + 0.03 * math.sin(_motionController.value * 2 * math.pi)
                    : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.55),
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Wallet / Card squircle outline
                    Container(
                      width: 82,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE6E0E9).withValues(alpha: 0.85),
                          width: 3.5,
                        ),
                      ),
                    ),

                    // Central Scalloped Badge with Currency Emblem
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F378B).withValues(alpha: 0.75),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE6E0E9),
                          width: 2.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          currency.isNotEmpty ? currency : '₹',
                          style: const TextStyle(
                            color: Color(0xFFE6E0E9),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'GoogleSansFlex',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                onChanged: (value) {
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

  Widget _buildDesignTokensCard(
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
                'Material 3 Expressive Tokens',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
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
                'Radius',
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
                'Width',
                '${personalization.width.toInt()}%',
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Canvas Painter rendering the organic shapes, blueprint grid,
/// concentric circles, and geometry from the SVG reference.
class _ExpressiveHeroPainter extends CustomPainter {
  final double animationProgress;
  final Color primaryColor;
  final Color primaryContainerColor;
  final Color tertiaryColor;
  final Color surfaceContainerColor;
  final Color outlineColor;
  final bool isExpressive;

  _ExpressiveHeroPainter({
    required this.animationProgress,
    required this.primaryColor,
    required this.primaryContainerColor,
    required this.tertiaryColor,
    required this.surfaceContainerColor,
    required this.outlineColor,
    required this.isExpressive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final rotationAngle = animationProgress * 2 * math.pi;

    // 1. Left Organic Petal Blossom Shape (Tertiary Color)
    _drawLeftPetalBlossom(canvas, size, center, rotationAngle);

    // 2. Right Starburst Shape (Primary Color)
    _drawRightStarburst(canvas, size, center, rotationAngle);

    // 3. Center Scallop Flower Shape (Deep Primary / Container Color)
    _drawCenterScallop(canvas, size, center, rotationAngle);

    // 4. Blueprint Grid Lines (Horizontal & Vertical)
    _drawBlueprintGrid(canvas, size);

    // 5. Concentric Blueprint Circles
    _drawConcentricCircles(canvas, center);
  }

  void _drawLeftPetalBlossom(
      Canvas canvas, Size size, Offset center, double rotationAngle) {
    final paint = Paint()
      ..color = const Color(0xFF7D5260) // Material 3 baseline tertiary
      ..style = PaintingStyle.fill;

    final leftCenter = Offset(size.width * 0.18, size.height * 0.5);
    final angleOffset = isExpressive ? math.sin(rotationAngle) * 0.1 : 0.0;

    canvas.save();
    canvas.translate(leftCenter.dx, leftCenter.dy);
    canvas.rotate(angleOffset);

    final path = Path();
    const double radius = 70.0;
    const int lobes = 4;

    for (int i = 0; i <= 360; i += 2) {
      final rad = i * math.pi / 180;
      final r = radius * (0.65 + 0.35 * math.cos(lobes * rad));
      final x = r * math.cos(rad);
      final y = r * math.sin(rad);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawRightStarburst(
      Canvas canvas, Size size, Offset center, double rotationAngle) {
    final paint = Paint()
      ..color = const Color(0xFF6750A4) // Material 3 baseline primary
      ..style = PaintingStyle.fill;

    final rightCenter = Offset(size.width * 0.82, size.height * 0.5);
    final angle = isExpressive ? rotationAngle * 0.5 : 0.0;

    canvas.save();
    canvas.translate(rightCenter.dx, rightCenter.dy);
    canvas.rotate(angle);

    final path = Path();
    const int points = 12;
    const double outerR = 85.0;
    const double innerR = 48.0;

    for (int i = 0; i < points * 2; i++) {
      final isOuter = i.isEven;
      final r = isOuter ? outerR : innerR;
      final theta = i * math.pi / points;
      final x = r * math.cos(theta);
      final y = r * math.sin(theta);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawCenterScallop(
      Canvas canvas, Size size, Offset center, double rotationAngle) {
    final paint = Paint()
      ..color = const Color(0xFF4F378B) // Material 3 deep primary
      ..style = PaintingStyle.fill;

    final angle = isExpressive ? -rotationAngle * 0.3 : 0.0;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final path = Path();
    const double radius = 78.0;
    const int lobes = 8;

    for (int i = 0; i <= 360; i += 2) {
      final rad = i * math.pi / 180;
      final r = radius * (0.8 + 0.2 * math.cos(lobes * rad));
      final x = r * math.cos(rad);
      final y = r * math.sin(rad);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawBlueprintGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Horizontal grid lines
    const double lineSpacingY = 11.5;
    for (double y = 0; y <= size.height; y += lineSpacingY) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Vertical grid lines
    const double lineSpacingX = 11.0;
    for (double x = 0; x <= size.width; x += lineSpacingX) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
  }

  void _drawConcentricCircles(Canvas canvas, Offset center) {
    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const radii = [29.0, 46.0, 66.0, 86.0, 117.0, 143.0, 166.0];
    for (final r in radii) {
      canvas.drawCircle(center, r, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ExpressiveHeroPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.isExpressive != isExpressive ||
        oldDelegate.primaryColor != primaryColor;
  }
}
