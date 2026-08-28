import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/personalization_provider.dart';

enum ExpressiveShapeType {
  squircle,
  petal,
  starburst,
  scallop,
  pill,
  asymmetric;

  static ExpressiveShapeType fromString(String? name) {
    switch (name?.toLowerCase()) {
      case 'petal':
        return ExpressiveShapeType.petal;
      case 'starburst':
        return ExpressiveShapeType.starburst;
      case 'scallop':
        return ExpressiveShapeType.scallop;
      case 'pill':
        return ExpressiveShapeType.pill;
      case 'asymmetric':
        return ExpressiveShapeType.asymmetric;
      case 'squircle':
      default:
        return ExpressiveShapeType.squircle;
    }
  }
}

/// Computes the exact vector Path for any Material 3 Expressive shape
class ExpressiveShapePath {
  static Path buildPath(ExpressiveShapeType type, Size size) {
    final Path path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    switch (type) {
      case ExpressiveShapeType.squircle:
        final r = radius * 0.96;
        final rect = Rect.fromCenter(center: center, width: r * 2, height: r * 2);
        path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(r * 0.42)));
        break;

      case ExpressiveShapeType.petal:
        // 4-leaf organic clover/flower petals
        final lobeRadius = radius * 0.52;
        path.addOval(Rect.fromCircle(
            center: center + Offset(-lobeRadius * 0.58, 0), radius: lobeRadius));
        path.addOval(Rect.fromCircle(
            center: center + Offset(lobeRadius * 0.58, 0), radius: lobeRadius));
        path.addOval(Rect.fromCircle(
            center: center + Offset(0, -lobeRadius * 0.58), radius: lobeRadius));
        path.addOval(Rect.fromCircle(
            center: center + Offset(0, lobeRadius * 0.58), radius: lobeRadius));
        break;

      case ExpressiveShapeType.starburst:
        // 8-point smooth starburst with rounded radial points
        const int points = 8;
        final outerR = radius * 0.98;
        final innerR = radius * 0.60;
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

      case ExpressiveShapeType.scallop:
        // 12-wave harmonic circular medallion
        const int waves = 12;
        for (int i = 0; i <= 360; i += 2) {
          final rad = i * pi / 180;
          final waveR = radius * 0.86 + (sin(rad * waves) * radius * 0.12);
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

      case ExpressiveShapeType.pill:
        // Stadium capsule
        final w = size.width * 0.96;
        final h = size.height * 0.75;
        final rect = Rect.fromCenter(center: center, width: w, height: h);
        path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(h / 2)));
        break;

      case ExpressiveShapeType.asymmetric:
        // Editorial asymmetric corner arch
        final r = radius * 0.95;
        final rect = Rect.fromCenter(center: center, width: r * 2, height: r * 2);
        path.addRRect(RRect.fromRectAndCorners(
          rect,
          topLeft: Radius.circular(r * 0.65),
          bottomRight: Radius.circular(r * 0.65),
          topRight: Radius.circular(r * 0.16),
          bottomLeft: Radius.circular(r * 0.16),
        ));
        break;
    }
    return path;
  }
}

/// Custom Clipper for Material 3 Expressive shapes
class ExpressiveShapeClipper extends CustomClipper<Path> {
  final ExpressiveShapeType shapeType;

  const ExpressiveShapeClipper(this.shapeType);

  @override
  Path getClip(Size size) => ExpressiveShapePath.buildPath(shapeType, size);

  @override
  bool shouldReclip(covariant ExpressiveShapeClipper oldClipper) =>
      oldClipper.shapeType != shapeType;
}

/// Custom Painter for Material 3 Expressive shape fills & borders
class _ExpressiveShapePainter extends CustomPainter {
  final ExpressiveShapeType shapeType;
  final Color color;
  final Color? borderColor;
  final double borderWidth;

  _ExpressiveShapePainter({
    required this.shapeType,
    required this.color,
    this.borderColor,
    this.borderWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = ExpressiveShapePath.buildPath(shapeType, size);

    // Fill
    final paintFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(path, paintFill);

    // Border
    if (borderColor != null && borderWidth > 0) {
      final paintStroke = Paint()
        ..color = borderColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..isAntiAlias = true;
      canvas.drawPath(path, paintStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _ExpressiveShapePainter oldDelegate) {
    return oldDelegate.shapeType != shapeType ||
        oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}

/// Universal Material 3 Expressive Shape Container for icon backdrops and tile badges
class ExpressiveShapeContainer extends ConsumerWidget {
  final Widget child;
  final double? size;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final ExpressiveShapeType? shapeType;
  final bool? isExpressive;

  const ExpressiveShapeContainer({
    super.key,
    required this.child,
    this.size,
    this.width,
    this.height,
    this.padding,
    this.color,
    this.borderColor,
    this.borderWidth = 0.0,
    this.shapeType,
    this.isExpressive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personalization = ref.watch(personalizationProvider);
    final bool effectiveExpressive =
        isExpressive ?? personalization.isExpressiveDiversificationEnabled;
    final ExpressiveShapeType effectiveShape = shapeType ??
        ExpressiveShapeType.fromString(personalization.selectedExpressiveShape);

    final double effectiveWidth = width ?? size ?? 44.0;
    final double effectiveHeight = height ?? size ?? 44.0;
    final Color effectiveColor =
        color ?? Theme.of(context).colorScheme.primaryContainer;

    if (!effectiveExpressive) {
      // Standard Material 3 Rounded Rectangle fallback
      return Container(
        width: effectiveWidth,
        height: effectiveHeight,
        padding: padding,
        decoration: BoxDecoration(
          color: effectiveColor,
          borderRadius: BorderRadius.circular(14),
          border: (borderColor != null && borderWidth > 0)
              ? Border.all(color: borderColor!, width: borderWidth)
              : null,
        ),
        child: Center(child: child),
      );
    }

    // Expressive dynamic morphing shape container
    return SizedBox(
      width: effectiveWidth,
      height: effectiveHeight,
      child: CustomPaint(
        painter: _ExpressiveShapePainter(
          shapeType: effectiveShape,
          color: effectiveColor,
          borderColor: borderColor,
          borderWidth: borderWidth,
        ),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// Animated / Styled Expressive Obscured Balance Indicator (replaces static dots)
class ExpressiveObscuredBalance extends ConsumerStatefulWidget {
  final double dotSize;
  final Color? color;
  final int count;

  const ExpressiveObscuredBalance({
    super.key,
    this.dotSize = 18.0,
    this.color,
    this.count = 5,
  });

  @override
  ConsumerState<ExpressiveObscuredBalance> createState() =>
      _ExpressiveObscuredBalanceState();
}

class _ExpressiveObscuredBalanceState extends ConsumerState<ExpressiveObscuredBalance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<ExpressiveShapeType> _shapesSequence = [
    ExpressiveShapeType.squircle,
    ExpressiveShapeType.petal,
    ExpressiveShapeType.starburst,
    ExpressiveShapeType.scallop,
    ExpressiveShapeType.pill,
    ExpressiveShapeType.asymmetric,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final personalization = ref.watch(personalizationProvider);
    final isExpressive = personalization.isExpressiveDiversificationEnabled;
    final Color effectiveColor = widget.color ?? theme.colorScheme.onSurface;

    if (!isExpressive) {
      return Text(
        '••••••',
        style: theme.textTheme.displayMedium?.copyWith(
          color: effectiveColor,
          letterSpacing: 4,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(widget.count, (index) {
            final shape = _shapesSequence[index % _shapesSequence.length];
            final wave = sin((_controller.value * 2 * pi) + (index * 0.8));
            final scale = 0.88 + (wave * 0.12);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Transform.scale(
                scale: scale,
                child: SizedBox(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  child: CustomPaint(
                    painter: _ExpressiveShapePainter(
                      shapeType: shape,
                      color: effectiveColor.withValues(
                          alpha: 0.75 + (wave * 0.25).clamp(0.0, 0.25)),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
