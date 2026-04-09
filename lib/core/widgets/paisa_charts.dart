import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/currency_engine.dart';
import '../widgets/icon_picker.dart';
import '../database/models/category.dart';
import '../theme/color_extension.dart';

/// PaisaDonutChart: A high-performance, interactive Donut Chart for spending analysis.
/// Features smooth animations, tap-to-expand segments, and a central balance display.
class PaisaDonutChart extends StatefulWidget {
  final Map<Category, double> breakdown;
  final String currency;
  final Function(Category) onCategorySelected;

  const PaisaDonutChart({
    super.key,
    required this.breakdown,
    required this.currency,
    required this.onCategorySelected,
  });

  @override
  State<PaisaDonutChart> createState() => _PaisaDonutChartState();
}

class _PaisaDonutChartState extends State<PaisaDonutChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = widget.breakdown.values.fold(0.0, (sum, v) => sum + v);
    final entries = widget.breakdown.entries.toList();

    return GestureDetector(
      onTapUp: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final Offset localOffset = box.globalToLocal(details.globalPosition);
        final center = Offset(box.size.width / 2, box.size.height / 2);
        final double distance = (localOffset - center).distance;
        
        // Only trigger if tapping within the donut ring area.
        if (distance > 60 && distance < 110) {
          final double angle = math.atan2(localOffset.dy - center.dy, localOffset.dx - center.dx) + math.pi / 2;
          final normalizedAngle = angle < 0 ? angle + 2 * math.pi : angle;
          
          double currentStartAngle = 0;
          for (int i = 0; i < entries.length; i++) {
            final sweepAngle = (entries[i].value / total) * 2 * math.pi;
            if (normalizedAngle >= currentStartAngle && normalizedAngle < currentStartAngle + sweepAngle) {
              setState(() => _touchedIndex = i);
              widget.onCategorySelected(entries[i].key);
              break;
            }
            currentStartAngle += sweepAngle;
          }
        } else {
          setState(() => _touchedIndex = -1);
        }
      },
      child: SizedBox(
        width: 260,
        height: 260,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(260, 260),
                  painter: _PaisaDonutPainter(
                    breakdown: widget.breakdown,
                    progress: _animation.value,
                    total: total,
                    touchedIndex: _touchedIndex,
                  ),
                );
              },
            ),
            // Central Label
            Container(
              padding: const EdgeInsets.all(40),
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _touchedIndex == -1 ? 'Total Spent' : entries[_touchedIndex].key.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      CurrencyEngine.formatCurrency(
                        _touchedIndex == -1 ? total : entries[_touchedIndex].value, 
                        widget.currency
                      ),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaisaDonutPainter extends CustomPainter {
  final Map<Category, double> breakdown;
  final double progress;
  final double total;
  final int touchedIndex;

  _PaisaDonutPainter({
    required this.breakdown, 
    required this.progress, 
    required this.total,
    required this.touchedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double baseStrokeWidth = 32.0;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width - 60) / 2;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (total == 0) {
      canvas.drawCircle(center, radius, paint..color = Colors.grey.withValues(alpha: 0.1)..strokeWidth = baseStrokeWidth);
      return;
    }

    double currentAngle = -math.pi / 2;
    final entries = breakdown.entries.toList();

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final sweepAngle = (entry.value / total) * 2 * math.pi * progress;
      final bool isTouched = i == touchedIndex;
      
      paint.color = entry.key.color.parseHexColor();
      paint.strokeWidth = isTouched ? baseStrokeWidth + 8 : baseStrokeWidth;
      
      // Add a slight pop effect for the touched segment
      final double effectiveRadius = isTouched ? radius + 4 : radius;
      final Rect rect = Rect.fromCircle(center: center, radius: effectiveRadius);

      canvas.drawArc(rect, currentAngle, sweepAngle, false, paint);
      currentAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PaisaDonutPainter oldDelegate) => 
      oldDelegate.progress != progress || oldDelegate.touchedIndex != touchedIndex;
}

/// PaisaSpendingBreakdown: A premium list of spending categories with progress bars.
class PaisaSpendingBreakdown extends StatelessWidget {
  final Map<Category, double> breakdown;
  final String currency;
  final Function(Category) onCategorySelected;

  const PaisaSpendingBreakdown({
    super.key,
    required this.breakdown,
    required this.currency,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = breakdown.values.fold(0.0, (sum, v) => sum + v);
    final sorted = breakdown.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sorted.map((e) {
        final category = e.key;
        final amount = e.value;
        final Color color = category.color.parseHexColor();
        final percentage = total > 0 ? (amount / total) : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onCategorySelected(category),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1), 
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 1),
                        ]
                      ),
                      child: Icon(AppIcons.getIcon(category.icon), color: color, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(category.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                              Text(
                                CurrencyEngine.formatCurrency(amount, currency), 
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            children: [
                              Container(
                                height: 8,
                                width: double.infinity,
                                decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(4)),
                              ),
                              FractionallySizedBox(
                                widthFactor: percentage,
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [color, color.withValues(alpha: 0.7)],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${(percentage * 100).toStringAsFixed(0)}%', 
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900, 
                        color: theme.colorScheme.primary,
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
}
