import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/transaction_model.dart';

class HomeInsightsSection extends ConsumerWidget {
  const HomeInsightsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return transactionsAsync.when(
      data: (transactions) {
        // Prepare Heatmap Data
        final Map<DateTime, int> dataset = {};
        for (var tx in transactions) {
          final date = DateTime(tx.createdAt.year, tx.createdAt.month, tx.createdAt.day);
          dataset[date] = (dataset[date] ?? 0) + 1;
        }

        // Prepare Line Chart Data (Last 30 days)
        final now = DateTime.now();
        final last30Days = List.generate(30, (index) => now.subtract(Duration(days: 29 - index)));
        
        final Map<DateTime, double> incomeData = {};
        final Map<DateTime, double> expenseData = {};

        for (var date in last30Days) {
          final normalizedDate = DateTime(date.year, date.month, date.day);
          incomeData[normalizedDate] = 0;
          expenseData[normalizedDate] = 0;
        }

        for (var tx in transactions) {
          final txDate = DateTime(tx.createdAt.year, tx.createdAt.month, tx.createdAt.day);
          if (incomeData.containsKey(txDate)) {
            if (tx.type == TransactionType.income) {
              incomeData[txDate] = (incomeData[txDate] ?? 0) + tx.amount;
            } else {
              expenseData[txDate] = (expenseData[txDate] ?? 0) + tx.amount;
            }
          }
        }

        final incomeSpots = last30Days.asMap().entries.map((e) {
          final date = DateTime(e.value.year, e.value.month, e.value.day);
          return FlSpot(e.key.toDouble(), incomeData[date] ?? 0);
        }).toList();

        final expenseSpots = last30Days.asMap().entries.map((e) {
          final date = DateTime(e.value.year, e.value.month, e.value.day);
          return FlSpot(e.key.toDouble(), expenseData[date] ?? 0);
        }).toList();

        return Column(
          children: [
            // Heatmap
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activity Heatmap',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      HeatMap(
                        datasets: dataset,
                        colorMode: ColorMode.opacity,
                        showText: false,
                        scrollable: true,
                        colorsets: {
                          1: colorScheme.primary.withValues(alpha: 0.2),
                          3: colorScheme.primary.withValues(alpha: 0.5),
                          5: colorScheme.primary,
                        },
                        onClick: (value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Transactions on $value: ${dataset[value] ?? 0}')));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Line Chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trends (Last 30 Days)',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: incomeSpots,
                                isCurved: true,
                                color: Colors.green,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.green.withValues(alpha: 0.1),
                                ),
                              ),
                              LineChartBarData(
                                spots: expenseSpots,
                                isCurved: true,
                                color: Colors.red,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.red.withValues(alpha: 0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
