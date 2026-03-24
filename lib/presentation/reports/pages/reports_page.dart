import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/database/providers.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'en_IN');

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final monthRange = DateTimeRange(start: startOfMonth, end: endOfMonth);

    final breakdownAsync = ref.watch(categoryBreakdownProvider(monthRange));
    final dailyStatsAsync = ref.watch(dailyStatsProvider(monthRange));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Donut Chart
            SizedBox(
              height: 200,
              child: breakdownAsync.when(
                data: (breakdown) {
                  if (breakdown.isEmpty) {
                    return const Center(child: Text('No expense data for this month'));
                  }
                  
                  final total = breakdown.values.fold<double>(0, (sum, val) => sum + val);
                  
                  return PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 60,
                      sections: breakdown.entries.map((entry) {
                        final category = entry.key;
                        final value = entry.value;
                        final percentage = (value / total * 100).toStringAsFixed(1);
                        
                        return PieChartSectionData(
                          color: Color(int.parse(category.color.replaceAll('0x', ''), radix: 16)),
                          value: value,
                          title: '$percentage%',
                          radius: 20,
                          showTitle: false,
                        );
                      }).toList(),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
            const SizedBox(height: 48),

            Text(
              'Daily Expenses (This Month)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Daily Stats Line Chart
            AspectRatio(
              aspectRatio: 1.7,
              child: dailyStatsAsync.when(
                data: (stats) {
                  if (stats.isEmpty) {
                    return const Center(child: Text('Not enough data for chart'));
                  }
                  
                  return LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: stats.map((e) => FlSpot(e.key.day.toDouble(), e.value)).toList(),
                          isCurved: true,
                          color: colorScheme.primary,
                          barWidth: 4,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: colorScheme.primary.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Summary List
            Text(
              'Categories',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            breakdownAsync.when(
              data: (breakdown) {
                final sortedEntries = breakdown.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
                return Column(
                  children: sortedEntries.map((entry) {
                    final category = entry.key;
                    final value = entry.value;
                    final color = Color(int.parse(category.color.replaceAll('0x', ''), radix: 16));
                    return _buildReportItem(context, category.name, currencyFormat.format(value), color);
                  }).toList(),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (err, stack) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(BuildContext context, String label, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          const Spacer(),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
