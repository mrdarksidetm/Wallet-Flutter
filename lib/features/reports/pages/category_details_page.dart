import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/category.dart';
import '../../../core/widgets/icon_picker.dart';

import 'package:wallet/core/theme/color_extension.dart';

class CategoryDetailsPage extends ConsumerWidget {
  final Category category;
  const CategoryDetailsPage({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);
    final categoryColor = category.color.parseHexColor();

    final statsAsync = ref.watch(categoryMonthlyStatsProvider(category.id));
    final allTransactionsAsync = ref.watch(transactionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        backgroundColor: categoryColor.withValues(alpha: 0.1),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Spending',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Bar Chart
                  AspectRatio(
                    aspectRatio: 1.7,
                    child: statsAsync.when(
                      data: (stats) {
                        if (stats.isEmpty) {
                          return const Center(child: Text('No data available'));
                        }

                        final maxY = stats.isEmpty
                            ? 100.0
                            : stats
                                .map((e) => e.value)
                                .reduce((a, b) => a > b ? a : b);

                        return BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: maxY == 0 ? 100 : maxY * 1.2,
                            barTouchData: const BarTouchData(enabled: true),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < 0 || index >= stats.length) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        DateFormat('MMM')
                                            .format(stats[index].key),
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: stats.asMap().entries.map((entry) {
                              return BarChartGroupData(
                                x: entry.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value.value,
                                    color: categoryColor,
                                    width: 16,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Recent Transactions',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          allTransactionsAsync.when(
            data: (transactions) {
              final categoryTxs = transactions
                  .where((t) => t.category.value?.id == category.id)
                  .toList();

              if (categoryTxs.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                      child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No transactions for this category'),
                  )),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tx = categoryTxs[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: categoryColor.withValues(alpha: 0.1),
                          child: Icon(
                              AppIcons.getIcon(tx.icon ?? category.icon),
                              color: categoryColor,
                              size: 20),
                        ),
                        title: Text(tx.note ?? 'Transaction',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle:
                            Text(DateFormat('MMM d, yyyy').format(tx.date)),
                        trailing: Text(
                          currencyFormat.format(tx.amount),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                    childCount: categoryTxs.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator())),
            error: (err, stack) =>
                SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
