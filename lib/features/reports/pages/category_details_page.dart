import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/category.dart';
import '../../../core/widgets/icon_picker.dart';
import 'package:wallet/core/theme/color_extension.dart';
import '../../settings/widgets/settings_segmented_card.dart';

class CategoryDetailsPage extends ConsumerWidget {
  final Category category;
  const CategoryDetailsPage({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);
    final categoryColor = category.color.parseHexColor();

    final statsAsync = ref.watch(categoryMonthlyStatsProvider(category.id));
    final allTransactionsAsync = ref.watch(transactionsStreamProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Symbols.arrow_back_rounded),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  AppIcons.getIcon(category.icon),
                  color: categoryColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.name,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MONTHLY SPENDING',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Chart Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.7,
                      child: statsAsync.when(
                        data: (stats) {
                          if (stats.isEmpty) {
                            return Center(
                              child: Text(
                                'No spending data available',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            );
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
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
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
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(8)),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, stack) =>
                            Center(child: Text('Error: $err')),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'TRANSACTION HISTORY',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'No transactions for this category yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
                sliver: SliverToBoxAdapter(
                  child: SettingsSegmentedGroup(
                    children: categoryTxs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final tx = entry.value;
                      final isLast = index == categoryTxs.length - 1;

                      return SettingsActionTile(
                        customLeading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Icon(
                              AppIcons.getIcon(tx.icon ?? category.icon),
                              color: categoryColor,
                              size: 22,
                            ),
                          ),
                        ),
                        title: tx.note?.isNotEmpty == true
                            ? tx.note!
                            : category.name,
                        subtitle: DateFormat('MMM d, yyyy').format(tx.date),
                        trailing: Text(
                          currencyFormat.format(tx.amount),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        showDivider: !isLast,
                      );
                    }).toList(),
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator())),
            error: (err, stack) =>
                SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
          ),
        ],
      ),
    );
  }
}
