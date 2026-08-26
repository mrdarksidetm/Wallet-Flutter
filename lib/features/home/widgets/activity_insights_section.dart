import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/database/providers.dart';
import '../../../core/services/currency_engine.dart';

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

        final double totalIncome = incomeByDate.values.fold(0, (sum, val) => sum + val);
        final double totalExpense = expenseByDate.values.fold(0, (sum, val) => sum + val);
        final selectedCurrency = ref.watch(currencyProvider);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // --- CALENDAR HEATMAP ---
              _buildHeatmapCard(theme, colorScheme, heatmapData),
              const SizedBox(height: 16),
              // --- TRENDS LINE CHART ---
              _buildTrendsCard(
                theme, 
                colorScheme, 
                last30Days, 
                incomeByDate, 
                expenseByDate, 
                totalIncome, 
                totalExpense,
                selectedCurrency,
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildHeatmapCard(ThemeData theme, ColorScheme colorScheme, Map<DateTime, double> aggregatedData) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(28.0),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => context.push('/activity_heatmap'),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Icon(Symbols.calendar_today_rounded, color: colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Calendar heatmap',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Icon(Symbols.chevron_right_rounded, color: colorScheme.onSurface.withValues(alpha: 0.3), size: 16),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5), height: 1),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Symbols.chevron_left_rounded, size: 20),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(
                        _currentMonth.year, _currentMonth.month - 1);
                  });
                },
              ),
              Text(
                DateFormat('MMMM yyyy').format(_currentMonth),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Symbols.chevron_right_rounded, size: 20),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(
                        _currentMonth.year, _currentMonth.month + 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildCalendarGrid(theme, colorScheme, aggregatedData),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(ThemeData theme, ColorScheme colorScheme, Map<DateTime, double> aggregatedData) {
    final int daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final DateTime firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    int startOffset = firstDayOfMonth.weekday - 1; 
    if (startOffset < 0) startOffset = 6; 

    final int totalCells = startOffset + daysInMonth;
    final isDark = theme.brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
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
        final bool hasEntry = dayValue > 0;
        final Color cellColor = _getHeatColor(colorScheme, dayValue, isDark);

        final Color textColor = (hasEntry || isSelected)
            ? (isDark ? Colors.black : Colors.white)
            : colorScheme.onSurfaceVariant;

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
                  : Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3), width: 1.0), 
            ),
            alignment: Alignment.center,
            child: Text(
              day.toString(),
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: (isSelected || hasEntry) ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getHeatColor(ColorScheme colorScheme, double value, bool isDark) {
    if (value == 0) return Colors.transparent;
    
    // Intensity based on amount
    if (value < 500) return colorScheme.primary.withValues(alpha: isDark ? 0.45 : 0.55);
    if (value < 2000) return colorScheme.primary.withValues(alpha: isDark ? 0.70 : 0.75);
    if (value < 5000) return colorScheme.primary.withValues(alpha: isDark ? 0.85 : 0.90);
    return colorScheme.primary;
  }

  Widget _buildTrendsCard(
    ThemeData theme, 
    ColorScheme colorScheme, 
    List<DateTime> last30Days, 
    Map<DateTime, double> incomeByDate, 
    Map<DateTime, double> expenseByDate,
    double totalIncome,
    double totalExpense,
    String currency,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final incomeColor = Colors.green.shade600;
    final expenseColor = colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(28.0),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                'Last 30 days',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildTrendStat(theme, 'Income', totalIncome, incomeColor, currency),
              const SizedBox(width: 24),
              _buildTrendStat(theme, 'Expense', totalExpense, expenseColor, currency),
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
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => colorScheme.surfaceContainerHighest,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedSpotItems(touchedBarSpots, last30Days, currency);
                    },
                  ),
                ),
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

  List<LineTooltipItem> touchedSpotItems(List<LineBarSpot> touchedBarSpots, List<DateTime> last30Days, String currency) {
    return touchedBarSpots.map((barSpot) {
      final flSpot = barSpot;
      final date = last30Days[flSpot.x.toInt()];
      return LineTooltipItem(
        '${DateFormat('MMM d').format(date)}\n',
        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        children: [
          TextSpan(
            text: CurrencyEngine.formatCurrency(flSpot.y, currency),
            style: TextStyle(
              color: barSpot.bar.color,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildTrendStat(ThemeData theme, String label, double amount, Color color, String currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyEngine.formatCurrency(amount, currency),
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
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
