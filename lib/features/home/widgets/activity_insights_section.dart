import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/database/providers.dart';

class ActivityInsightsSection extends ConsumerStatefulWidget {
  const ActivityInsightsSection({super.key});

  @override
  ConsumerState<ActivityInsightsSection> createState() => _ActivityInsightsSectionState();
}

class _ActivityInsightsSectionState extends ConsumerState<ActivityInsightsSection> {
  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return transactionsAsync.when(
      data: (transactions) {
        // Filter transactions for the current month for the heatmap
        final monthTransactions = transactions.where((tx) => 
          tx.date.year == _currentMonth.year && tx.date.month == _currentMonth.month).toList();

        final Map<DateTime, double> heatmapData = {};
        for (var tx in monthTransactions) {
          final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
          heatmapData[date] = (heatmapData[date] ?? 0.0) + tx.amount;
        }

        // Process data for Line Chart (Last 30 days)
        final now = DateTime.now();
        final last30Days = List.generate(30, (index) {
          return DateTime(now.year, now.month, now.day).subtract(Duration(days: 29 - index));
        });

        final Map<DateTime, double> incomeByDate = {};
        final Map<DateTime, double> expenseByDate = {};

        for (var date in last30Days) {
          incomeByDate[date] = 0;
          expenseByDate[date] = 0;
        }

        for (var tx in transactions) {
          final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
          if (incomeByDate.containsKey(txDate)) {
            if (tx.type == TransactionType.income) {
              incomeByDate[txDate] = (incomeByDate[txDate] ?? 0.0) + tx.amount;
            } else if (tx.type == TransactionType.expense) {
              expenseByDate[txDate] = (expenseByDate[txDate] ?? 0.0) + tx.amount;
            }
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // --- CALENDAR HEATMAP ---
              _buildHeatmapCard(theme, colorScheme, heatmapData),
              const SizedBox(height: 16),
              // --- TRENDS LINE CHART ---
              _buildTrendsCard(theme, colorScheme, last30Days, incomeByDate, expenseByDate),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildHeatmapCard(ThemeData theme, ColorScheme colorScheme, Map<DateTime, double> aggregatedData) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Symbols.calendar_today_rounded, color: colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                'Calendar heatmap',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              Icon(Symbols.chevron_right_rounded, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5), height: 1),
          const SizedBox(height: 16),
          Text(
            DateFormat('MMMM yyyy').format(_currentMonth),
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildCalendarGrid(colorScheme, aggregatedData),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(ColorScheme colorScheme, Map<DateTime, double> aggregatedData) {
    final int daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final DateTime firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    int startOffset = firstDayOfMonth.weekday - 1; 
    if (startOffset < 0) startOffset = 6; 

    final int totalCells = startOffset + daysInMonth;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 1.0,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        if (index < startOffset) {
          return const SizedBox.shrink();
        }

        final int day = index - startOffset + 1;
        final DateTime cellDate = DateTime(_currentMonth.year, _currentMonth.month, day);
        
        final bool isSelected = cellDate.year == _selectedDate.year &&
                          cellDate.month == _selectedDate.month &&
                          cellDate.day == _selectedDate.day;

        final double dayValue = aggregatedData[cellDate] ?? 0.0;
        final Color cellColor = _getHeatColor(colorScheme, dayValue);

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = cellDate;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: cellColor,
              borderRadius: BorderRadius.circular(12.0),
              border: isSelected 
                  ? Border.all(color: colorScheme.primary, width: 2.0)
                  : null, 
            ),
            alignment: Alignment.center,
            child: Text(
              day.toString(),
              style: TextStyle(
                color: dayValue > 0 ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getHeatColor(ColorScheme colorScheme, double value) {
    if (value == 0) return colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    
    // Intensity based on amount
    if (value < 500) return colorScheme.primaryContainer.withValues(alpha: 0.4);
    if (value < 2000) return colorScheme.primaryContainer.withValues(alpha: 0.7);
    if (value < 5000) return colorScheme.primaryContainer;
    return colorScheme.primary;
  }

  Widget _buildTrendsCard(ThemeData theme, ColorScheme colorScheme, List<DateTime> last30Days, Map<DateTime, double> incomeByDate, Map<DateTime, double> expenseByDate) {
    // [M3 ADAPTIVE]: Using custom green for income that works in both modes
    final incomeColor = Colors.green.shade600;
    final expenseColor = colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Symbols.trending_up_rounded, color: colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                'Income vs Expense',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: last30Days.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), incomeByDate[e.value] ?? 0);
                    }).toList(),
                    isCurved: true,
                    color: incomeColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: incomeColor.withValues(alpha: 0.1),
                    ),
                  ),
                  LineChartBarData(
                    spots: last30Days.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), expenseByDate[e.value] ?? 0);
                    }).toList(),
                    isCurved: true,
                    color: expenseColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: expenseColor.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(theme, incomeColor, 'Income'),
              const SizedBox(width: 32),
              _buildLegendItem(theme, expenseColor, 'Expense'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(ThemeData theme, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color, 
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label, 
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
