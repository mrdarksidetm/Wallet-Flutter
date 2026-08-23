import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/database/providers.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/transaction_segmented_group.dart';

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
              final sortedYears = grouped.keys.toList()
                ..sort((a, b) => b.compareTo(a));

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList.builder(
                  itemCount: sortedYears.length,
                  itemBuilder: (context, index) {
                    final year = sortedYears[index];
                    final months = grouped[year]!;
                    final sortedMonths = months.keys.toList()
                      ..sort((a, b) => b.compareTo(a));

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 8),
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

class _MonthHeatmapCard extends StatefulWidget {
  final int year;
  final int month;
  final List<TransactionModel> transactions;

  const _MonthHeatmapCard({
    required this.year,
    required this.month,
    required this.transactions,
  });

  @override
  State<_MonthHeatmapCard> createState() => _MonthHeatmapCardState();
}

class _MonthHeatmapCardState extends State<_MonthHeatmapCard> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Map<DateTime, double> heatmapData = {};
    final Map<DateTime, List<TransactionModel>> txsByDate = {};

    for (var tx in widget.transactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      heatmapData[date] = (heatmapData[date] ?? 0.0) + tx.amount;
      txsByDate.putIfAbsent(date, () => []).add(tx);
    }

    final selectedDayTxs = _selectedDate != null ? (txsByDate[_selectedDate] ?? []) : <TransactionModel>[];

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM').format(DateTime(widget.year, widget.month)),
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${widget.transactions.length} activities',
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _CalendarGrid(
            year: widget.year,
            month: widget.month,
            data: heatmapData,
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                if (_selectedDate == date) {
                  _selectedDate = null;
                } else {
                  _selectedDate = date;
                }
              });
            },
          ),
          if (_selectedDate != null && selectedDayTxs.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d').format(_selectedDate!),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
                Text(
                  '${selectedDayTxs.length} ${selectedDayTxs.length == 1 ? 'entry' : 'entries'}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TransactionSegmentedCard(transactions: selectedDayTxs),
          ],
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final int year;
  final int month;
  final Map<DateTime, double> data;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;

  const _CalendarGrid({
    required this.year,
    required this.month,
    required this.data,
    this.selectedDate,
    this.onDateSelected,
  });

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
        final bool hasEntry = value > 0;
        final bool isSelected = selectedDate == date;

        final color = _getHeatColor(colorScheme, value, isSelected);

        return GestureDetector(
          onTap: hasEntry
              ? () {
                  if (onDateSelected != null) {
                    onDateSelected!(date);
                  }
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant.withValues(alpha: hasEntry ? 0.3 : 0.1),
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              day.toString(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: (hasEntry || isSelected)
                    ? FontWeight.w900
                    : FontWeight.normal,
                // Make date white color when an entry is recorded or when selected
                color: (hasEntry || isSelected)
                    ? Colors.white
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getHeatColor(ColorScheme colorScheme, double value, bool isSelected) {
    if (isSelected) return colorScheme.primary;
    if (value == 0) return Colors.transparent;
    if (value < 500) return colorScheme.primary.withValues(alpha: 0.55);
    if (value < 2000) return colorScheme.primary.withValues(alpha: 0.75);
    if (value < 5000) return colorScheme.primary.withValues(alpha: 0.9);
    return colorScheme.primary;
  }
}
