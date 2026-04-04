import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../home/widgets/home_header.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );

  String _chartType = 'line'; // 'line' or 'pie'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final personalization = ref.watch(personalizationProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Header (Conditional Icons Hidden)
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: HomeHeader(
                userName: personalization.userName ?? 'User',
                greeting: 'Financial Reports',
                hideIcons: true,
              ),
            ),
          ),

          // 2. Month Selector (Horizontal Pills)
          SliverToBoxAdapter(
            child: _buildMonthSelector(theme, colorScheme),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // 3. Dynamic Balance Section
          transactionsAsync.when(
            data: (txs) {
              final filteredTxs = txs.where((tx) =>
                  tx.createdAt.isAfter(_selectedDateRange.start) &&
                  tx.createdAt.isBefore(_selectedDateRange.end.add(const Duration(days: 1)))).toList();

              final totalIncome = filteredTxs
                  .where((tx) => tx.type == TransactionType.income)
                  .fold(0.0, (sum, tx) => sum + tx.amount);
              final totalExpense = filteredTxs
                  .where((tx) => tx.type == TransactionType.expense)
                  .fold(0.0, (sum, tx) => sum + tx.amount);
              final netBalance = totalIncome - totalExpense;

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildBalanceSummary(theme, colorScheme, netBalance, personalization.currencySymbol),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatCard(
                            theme,
                            'Income',
                            totalIncome,
                            Colors.green,
                            Symbols.trending_up,
                            personalization.currencySymbol,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            theme,
                            'Expense',
                            totalExpense,
                            Colors.red,
                            Symbols.trending_down,
                            personalization.currencySymbol,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildQuickInsights(theme, colorScheme, filteredTxs, personalization.currencySymbol),
                      const SizedBox(height: 24),
                      _buildChartsSection(theme, colorScheme, filteredTxs, personalization.currencySymbol),
                      const SizedBox(height: 24),
                      _buildReportsList(theme, colorScheme),
                    ],
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (err, _) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      // 6. Global Date Range Filter (FAB)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectDateRange,
        icon: const Icon(Symbols.calendar_month),
        label: Text(
          '${DateFormat('MMM d').format(_selectedDateRange.start)} - ${DateFormat('MMM d').format(_selectedDateRange.end)}',
        ),
      ),
    );
  }

  Widget _buildMonthSelector(ThemeData theme, ColorScheme colorScheme) {
    final now = DateTime.now();
    final months = List.generate(12, (i) => DateTime(now.year, now.month - i, 1));

    return SizedBox(
      height: 50,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: months.length,
        itemBuilder: (context, index) {
          final month = months[index];
          final isSelected = _selectedDateRange.start.year == month.year &&
              _selectedDateRange.start.month == month.month;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(DateFormat('MMM yy').format(month)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedDateRange = DateTimeRange(
                      start: month,
                      end: DateTime(month.year, month.month + 1, 0),
                    );
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceSummary(ThemeData theme, ColorScheme colorScheme, double balance, String symbol) {
    return Column(
      children: [
        Text('Net Balance', style: theme.textTheme.labelMedium),
        Text(
          '$symbol${balance.toStringAsFixed(2)}',
          style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, double amount, Color color, IconData icon, String symbol) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 8),
              Text(label, style: theme.textTheme.labelMedium?.copyWith(color: color)),
              Text(
                '$symbol${amount.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickInsights(ThemeData theme, ColorScheme colorScheme, List<TransactionModel> txs, String symbol) {
    final expenseTxs = txs.where((t) => t.type == TransactionType.expense).toList();
    final incomeTxs = txs.where((t) => t.type == TransactionType.income).toList();
    
    final totalExpense = expenseTxs.fold(0.0, (s, t) => s + t.amount);
    final totalIncome = incomeTxs.fold(0.0, (s, t) => s + t.amount);
    
    final savingsRate = totalIncome > 0 ? ((totalIncome - totalExpense) / totalIncome * 100) : 0.0;
    final avgDaily = txs.isEmpty ? 0.0 : totalExpense / 30; // Approximation

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Insights', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildInsightTile(theme, 'Savings Rate', '${savingsRate.toStringAsFixed(1)}%', Symbols.savings),
                _buildInsightTile(theme, 'Daily Avg', '$symbol${avgDaily.toStringAsFixed(0)}', Symbols.calendar_today),
                _buildInsightTile(theme, 'Transactions', '${txs.length}', Symbols.receipt_long),
                _buildInsightTile(theme, 'Top Cat', 'Food', Symbols.category),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightTile(ThemeData theme, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: theme.textTheme.labelSmall),
            Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildChartsSection(ThemeData theme, ColorScheme colorScheme, List<TransactionModel> txs, String symbol) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'line', icon: Icon(Symbols.show_chart)),
                    ButtonSegment(value: 'pie', icon: Icon(Symbols.pie_chart)),
                  ],
                  selected: {_chartType},
                  onSelectionChanged: (val) => setState(() => _chartType = val.first),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Symbols.more_vert)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: _chartType == 'line' ? _buildLineChart(txs) : _buildPieChart(txs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<TransactionModel> txs) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [const FlSpot(0, 3), const FlSpot(2, 5), const FlSpot(4, 4), const FlSpot(6, 8)],
            isCurved: true,
            color: Colors.blue,
            barWidth: 4,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(List<TransactionModel> txs) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(value: 40, color: Colors.blue, title: '40%'),
          PieChartSectionData(value: 30, color: Colors.red, title: '30%'),
          PieChartSectionData(value: 20, color: Colors.green, title: '20%'),
        ],
      ),
    );
  }

  Widget _buildReportsList(ThemeData theme, ColorScheme colorScheme) {
    final items = [
      {'title': 'Month Summary', 'icon': Symbols.summarize},
      {'title': 'Category Breakdown', 'icon': Symbols.pie_chart},
      {'title': 'Budget Performance', 'icon': Symbols.account_balance},
      {'title': 'Cash Flow Analysis', 'icon': Symbols.swap_horiz},
    ];

    return Column(
      children: items.map((item) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: colorScheme.surfaceContainerHighest,
            child: Icon(item['icon'] as IconData, size: 20),
          ),
          title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: const Icon(Symbols.chevron_right),
          onTap: () {},
        );
      }).toList(),
    );
  }

  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (range != null) {
      setState(() => _selectedDateRange = range);
    }
  }
}
