import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/database/providers.dart';
import '../../../core/widgets/app_back_button.dart';

class ActivityHeatmapPage extends ConsumerWidget {
  const ActivityHeatmapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            leading: const AppBackButton(),
            title: Text(
              'Activity History',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: (theme.textTheme.headlineLarge?.fontSize ?? 32) + 3,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          transactionsAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('No transactions found')),
                );
              }

              // Group transactions by year and month
              final Map<int, Map<int, List<TransactionModel>>> grouped = {};
              for (var tx in transactions) {
                final year = tx.date.year;
                final month = tx.date.month;
                grouped.putIfAbsent(year, () => {});
                grouped[year]!.putIfAbsent(month, () => []);
                grouped[year]![month]!.add(tx);
              }

              // Sort years and months in descending order
              final sortedYears = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList.builder(
                  itemCount: sortedYears.length,
                  itemBuilder: (context, index) {
                    final year = sortedYears[index];
                    final months = grouped[year]!;
                    final sortedMonths = months.keys.toList()..sort((a, b) => b.compareTo(a));

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          child: Text(
                            year.toString(),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        ...sortedMonths.map((month) {
                          return _MonthHeatmapCard(
                            year: year,
                            month: month,
                            transactions: months[month]!,
                          );
                        }),
                      ],
                    );
                  },
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthHeatmapCard extends StatelessWidget {
  final int year;
  final int month;
  final List<TransactionModel> transactions;

  const _MonthHeatmapCard({
    required this.year,
    required this.month,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Map<DateTime, double> heatmapData = {};
    for (var tx in transactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      heatmapData[date] = (heatmapData[date] ?? 0.0) + tx.amount;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM').format(DateTime(year, month)),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${transactions.length} activities',
                style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _CalendarGrid(year: year, month: month, data: heatmapData),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final int year;
  final int month;
  final Map<DateTime, double> data;

  const _CalendarGrid({required this.year, required this.month, required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final int daysInMonth = DateUtils.getDaysInMonth(year, month);
    final DateTime firstDayOfMonth = DateTime(year, month, 1);
    int startOffset = firstDayOfMonth.weekday - 1;
    if (startOffset < 0) startOffset = 6;

    final int totalCells = startOffset + daysInMonth;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        if (index < startOffset) return const SizedBox.shrink();

        final day = index - startOffset + 1;
        final date = DateTime(year, month, day);
        final value = data[date] ?? 0.0;
        final color = _getHeatColor(colorScheme, value);

        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.1),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            day.toString(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: value > 0 ? FontWeight.bold : FontWeight.normal,
              color: value > 0 ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        );
      },
    );
  }

  Color _getHeatColor(ColorScheme colorScheme, double value) {
    if (value == 0) return Colors.transparent;
    if (value < 500) return colorScheme.primaryContainer.withValues(alpha: 0.3);
    if (value < 2000) return colorScheme.primaryContainer.withValues(alpha: 0.6);
    if (value < 5000) return colorScheme.primaryContainer;
    return colorScheme.primary;
  }
}
