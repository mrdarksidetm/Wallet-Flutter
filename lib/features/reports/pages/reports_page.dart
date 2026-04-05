import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/database/models/category.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/database/providers.dart';
import '../../../core/services/currency_engine.dart';
import '../../../core/theme/color_extension.dart';
import '../../../core/widgets/icon_picker.dart';
import '../../../core/providers/fab_action_provider.dart';

/// ReportsPage: A dynamic, Material 3 reactive dashboard for financial analysis.
/// Implements date-range filtering, interactive charts, and quick spending insights.
class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  // [STATE]: Tracks the active date range for all reports on this screen.
  DateTimeRange _selectedRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
  );

  // [STATE]: Toggle between Line Chart and Donut Chart.
  bool _isLineChart = true;

  @override
  void initState() {
    super.initState();
    // Register the FAB action to trigger the date picker.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fabActionProvider.notifier).setAction(_selectDateRange);
    });
  }

  @override
  void dispose() {
    // Clear the FAB action when leaving the page.
    super.dispose();
  }

  /// Triggers the M3 DateRangePickerDialog and updates the global state.
  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCurrency = ref.watch(currencyProvider);

    // [REACTIVE]: Watch breakdown and insights based on the selected range.
    final breakdownAsync = ref.watch(categoryBreakdownProvider((_selectedRange, null, null, TransactionType.expense)));
    final insightsAsync = ref.watch(quickInsightsProvider(_selectedRange));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Reports', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Month Selection Row (Horizontal Pills)
          SliverToBoxAdapter(child: _MonthSelector(
            selectedRange: _selectedRange,
            onRangeSelected: (range) => setState(() => _selectedRange = range),
          )),

          // 2. Balance & Trend Section
          SliverToBoxAdapter(
            child: insightsAsync.when(
              data: (insights) => _BalanceSection(
                insights: insights,
                currency: selectedCurrency,
              ),
              loading: () => const _LoadingPlaceholder(height: 120),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),

          // 3. Quick Insights Grid
          SliverToBoxAdapter(
            child: insightsAsync.when(
              data: (insights) => _QuickInsightsGrid(insights: insights, currency: selectedCurrency),
              loading: () => const _LoadingPlaceholder(height: 200),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          // 4. Interactive Charts Section
          SliverToBoxAdapter(
            child: breakdownAsync.when(
              data: (breakdown) => _ChartSection(
                breakdown: breakdown,
                isLineChart: _isLineChart,
                onToggle: (val) => setState(() => _isLineChart = val),
                currency: selectedCurrency,
                range: _selectedRange,
              ),
              loading: () => const _LoadingPlaceholder(height: 300),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          // 5. Detailed Reports List
          const SliverToBoxAdapter(child: _DetailedReportsList()),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

/// A horizontally scrollable row of selectable month pills.
class _MonthSelector extends StatelessWidget {
  final DateTimeRange selectedRange;
  final Function(DateTimeRange) onRangeSelected;

  const _MonthSelector({required this.selectedRange, required this.onRangeSelected});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = List.generate(6, (i) => DateTime(now.year, now.month - i, 1));

    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: months.length,
        itemBuilder: (context, index) {
          final monthDate = months[index];
          final monthRange = DateTimeRange(
            start: monthDate,
            end: DateTime(monthDate.year, monthDate.month + 1, 0),
          );
          final isSelected = selectedRange.start.year == monthDate.year && 
                             selectedRange.start.month == monthDate.month &&
                             selectedRange.end.day == monthRange.end.day;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(DateFormat('MMM yy').format(monthDate)),
              selected: isSelected,
              onSelected: (val) {
                if (val) onRangeSelected(monthRange);
              },
            ),
          );
        },
      ),
    );
  }
}

/// Displays the net balance and Income/Expense comparison cards.
class _BalanceSection extends StatelessWidget {
  final Map<String, dynamic> insights;
  final String currency;

  const _BalanceSection({required this.insights, required this.currency});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalIncome = insights['totalIncome'] as double? ?? 0;
    final totalExpense = insights['totalExpense'] as double? ?? 0;
    final netBalance = totalIncome - totalExpense;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total balance', style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            CurrencyEngine.formatCurrency(netBalance, currency),
            style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _TrendCard(
                title: 'Income',
                amount: totalIncome,
                color: Colors.green,
                currency: currency,
                icon: Symbols.trending_up,
              )),
              const SizedBox(width: 12),
              Expanded(child: _TrendCard(
                title: 'Expense',
                amount: totalExpense,
                color: Colors.red,
                currency: currency,
                icon: Symbols.trending_down,
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final String currency;
  final IconData icon;

  const _TrendCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.currency,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyEngine.formatCurrency(amount, currency),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// A grid of key financial metrics (Savings Rate, Avg Spend, etc.)
class _QuickInsightsGrid extends StatelessWidget {
  final Map<String, dynamic> insights;
  final String currency;

  const _QuickInsightsGrid({required this.insights, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quick Insights', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _InsightTile(label: 'Savings Rate', value: '${(insights['savingsRate'] as double).toStringAsFixed(1)}%'),
                  _InsightTile(label: 'Avg. Daily Spend', value: CurrencyEngine.formatCurrency(insights['avgDailySpend'] as double, currency)),
                  _InsightTile(label: 'Transactions', value: insights['transactionCount'].toString()),
                  _InsightTile(label: 'Top Category', value: insights['topCategory'].toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final String label;
  final String value;
  const _InsightTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

/// Interactive chart section with toggle between Line and Donut charts.
class _ChartSection extends ConsumerWidget {
  final Map<Category, double> breakdown;
  final bool isLineChart;
  final Function(bool) onToggle;
  final String currency;
  final DateTimeRange range;

  const _ChartSection({
    required this.breakdown,
    required this.isLineChart,
    required this.onToggle,
    required this.currency,
    required this.range,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dailyStatsAsync = ref.watch(dailyStatsProvider(range));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Visual Breakdown', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, icon: Icon(Symbols.show_chart)),
                  ButtonSegment(value: false, icon: Icon(Symbols.pie_chart)),
                ],
                selected: {isLineChart},
                onSelectionChanged: (s) => onToggle(s.first),
                showSelectedIcon: false,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 240,
            child: isLineChart 
              ? dailyStatsAsync.when(
                  data: (data) => _LineChartWidget(data: data),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('No trend data')),
                )
              : _DonutChartWidget(breakdown: breakdown),
          ),
          if (!isLineChart) ...[
            const SizedBox(height: 24),
            _DonutLegend(breakdown: breakdown, currency: currency),
          ]
        ],
      ),
    );
  }
}

class _LineChartWidget extends StatelessWidget {
  final List<MapEntry<DateTime, double>> data;
  const _LineChartWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('No data for this period'));
    
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChartWidget extends StatelessWidget {
  final Map<Category, double> breakdown;
  const _DonutChartWidget({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    if (breakdown.isEmpty) return const Center(child: Text('No spending data'));

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 60,
        sections: breakdown.entries.map((e) {
          final color = e.key.color.parseHexColor();
          return PieChartSectionData(
            color: color,
            value: e.value,
            title: '',
            radius: 30,
          );
        }).toList(),
      ),
    );
  }
}

class _DonutLegend extends StatelessWidget {
  final Map<Category, double> breakdown;
  final String currency;

  const _DonutLegend({required this.breakdown, required this.currency});

  @override
  Widget build(BuildContext context) {
    final total = breakdown.values.fold(0.0, (sum, v) => sum + v);
    final sorted = breakdown.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sorted.take(5).map((e) {
        final category = e.key;
        final amount = e.value;
        final color = category.color.parseHexColor();
        final percentage = total > 0 ? (amount / total) : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(AppIcons.getIcon(category.icon), color: color, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(CurrencyEngine.formatCurrency(amount, currency), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: color.withValues(alpha: 0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text('${(percentage * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// A vertical list of navigation items for specialized reports.
class _DetailedReportsList extends ConsumerWidget {
  const _DetailedReportsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              'DETAILED REPORTS', 
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const _ReportNavItem(title: 'Month Summary', subtitle: 'A complete overview of your monthly flow', icon: Symbols.event_note, color: Colors.blue),
          const _ReportNavItem(title: 'Category Breakdown', subtitle: 'Where your money actually goes', icon: Symbols.category, color: Colors.orange),
          const _ReportNavItem(title: 'Budget Performance', subtitle: 'How well you stick to your limits', icon: Symbols.pie_chart, color: Colors.purple),
          const _ReportNavItem(title: 'Cash Flow Analysis', subtitle: 'Inflow vs Outflow over time', icon: Symbols.swap_vert, color: Colors.teal),
          _ReportNavItem(
            title: 'Export to CSV', 
            subtitle: 'Download your transaction history', 
            icon: Symbols.download, 
            color: Colors.indigo,
            onTap: () async {
              try {
                await ref.read(csvServiceProvider).exportTransactions();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transactions exported successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              }
            },
          ),
          _ReportNavItem(
            title: 'Export to JSON', 
            subtitle: 'Backup your data in JSON format', 
            icon: Symbols.database, 
            color: Colors.amber,
            onTap: () async {
              try {
                await ref.read(jsonServiceProvider).exportTransactions();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transactions exported successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              }
            },
          ),
          _ReportNavItem(
            title: 'Import from JSON', 
            subtitle: 'Restore your data from a JSON file', 
            icon: Symbols.upload_file, 
            color: Colors.teal,
            onTap: () async {
              try {
                await ref.read(jsonServiceProvider).importTransactions();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data imported successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Import failed: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ReportNavItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ReportNavItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      onTap: onTap ?? () {},
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
      trailing: Icon(Symbols.chevron_right, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  final double height;
  const _LoadingPlaceholder({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
