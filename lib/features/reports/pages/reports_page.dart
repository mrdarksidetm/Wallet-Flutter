import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/category.dart';
import '../../../core/widgets/icon_picker.dart';
import '../../../core/theme/color_extension.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  DateTimeRange? _customRange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);

    final now = DateTime.now();
    final currentRange = _customRange ??
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );

    final breakdownAsync = ref.watch(categoryBreakdownProvider(currentRange));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Symbols.calendar_month),
            onPressed: _showFilterDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(theme, currentRange),
            const SizedBox(height: 32),
            
            // Summary Cards
            breakdownAsync.when(
              data: (data) => _buildSummaryCards(context, data, currencyFormat),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error: $err'),
            ),
            
            const SizedBox(height: 40),
            Text(
              'Spending Breakdown',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            const SizedBox(height: 24),

            // Spending Chart
            SizedBox(
              height: 240,
              width: double.infinity,
              child: breakdownAsync.when(
                data: (breakdown) {
                  if (breakdown.isEmpty) {
                    return Center(child: Text('No data for this period', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.outline)));
                  }
                  return CustomPaint(
                    painter: _SpendingChartPainter(breakdown: breakdown),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),

            const SizedBox(height: 48),
            Text(
              'Top Categories',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            const SizedBox(height: 16),
            
            breakdownAsync.when(
              data: (breakdown) => _buildCategoryList(context, breakdown, currencyFormat),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(ThemeData theme, DateTimeRange range) {
    final format = DateFormat('MMM d, yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _customRange == null ? 'This Month' : 'Custom Range',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${format.format(range.start)} - ${format.format(range.end)}',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context, Map<Category, double> data, NumberFormat format) {
    final double total = data.values.fold(0, (sum, val) => sum + val);
    
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Total Spent',
            amount: total,
            color: Colors.redAccent,
            icon: Symbols.trending_down,
            format: format,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SummaryCard(
            title: 'Categories',
            amount: data.length.toDouble(),
            color: Colors.blueAccent,
            icon: Symbols.category,
            format: NumberFormat.decimalPattern(),
            isCurrency: false,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(BuildContext context, Map<Category, double> breakdown, NumberFormat format) {
    final sorted = breakdown.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final double total = breakdown.values.fold(0, (sum, val) => sum + val);

    return Column(
      children: sorted.map((e) {
        final cat = e.key;
        final amount = e.value;
        final percentage = total > 0 ? (amount / total) * 100 : 0.0;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cat.color.parseHexColor().withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(AppIcons.getIcon(cat.icon), color: cat.color.parseHexColor(), size: 20),
          ),
          title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${percentage.toStringAsFixed(1)}% of total'),
          trailing: Text(
            format.format(amount),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        );
      }).toList(),
    );
  }

  void _showFilterDialog() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _customRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _customRange = picked);
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;
  final NumberFormat format;
  final bool isCurrency;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    required this.format,
    this.isCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            isCurrency ? format.format(amount) : amount.toInt().toString(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _SpendingChartPainter extends CustomPainter {
  final Map<Category, double> breakdown;

  _SpendingChartPainter({required this.breakdown});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40
      ..strokeCap = StrokeCap.round;

    final double total = breakdown.values.fold(0, (sum, val) => sum + val);
    double startAngle = -1.5708; // Start from top (-90 degrees)

    if (total == 0) return;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.height * 0.4,
    );

    breakdown.forEach((cat, amount) {
      final sweepAngle = (amount / total) * 6.28318; // Full circle is 2*PI
      paint.color = cat.color.parseHexColor();
      
      canvas.drawArc(rect, startAngle, sweepAngle * 0.95, false, paint);
      startAngle += sweepAngle;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
