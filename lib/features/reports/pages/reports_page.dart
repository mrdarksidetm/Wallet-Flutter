import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/providers/fab_action_provider.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/category.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/widgets/icon_picker.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fabActionProvider.notifier).setAction(_showFilterDialog);
    });
  }

  void _showFilterDialog() async {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Reports',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ListTile(
                // ------------------------------------------------------------------
                // FIX: Added the 'const' keyword to the Icon constructor below.
                // Since 'Symbols.calendar_month' is an immutable static constant,
                // making the Icon itself 'const' allows Dart to allocate it once at 
                // compile-time rather than recreating it on every single UI rebuild.
                // ------------------------------------------------------------------
                leading: const Icon(Symbols.calendar_month),
                title: const Text('Date Range'),
                subtitle: Text(_customRange == null ? 'This Month' : '${DateFormat.yMMMd().format(_customRange!.start)} - ${DateFormat.yMMMd().format(_customRange!.end)}'),
                onTap: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDateRange: _customRange,
                  );
                  if (range != null) {
                    setState(() {
                      _customRange = range;
                    });
                    if (mounted) Navigator.pop(context);
                  }
                },
              ),
              ListTile(
                // ------------------------------------------------------------------
                // FIX: Added the 'const' keyword to this Icon constructor as well.
                // This resolves the second 'prefer_const_constructors' warning 
                // and follows Flutter's best practices for memory optimization.
                // ------------------------------------------------------------------
                leading: const Icon(Symbols.restart_alt),
                title: const Text('Reset Filter'),
                onTap: () {
                  setState(() {
                    _customRange = null;
                  });
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final currentRange = _customRange ?? DateTimeRange(start: startOfMonth, end: endOfMonth);

    final breakdownAsync = ref.watch(categoryBreakdownProvider(currentRange));
    final dailyStatsAsync = ref.watch(dailyStatsProvider(currentRange));

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
                          color: theme.colorScheme.primary,
                          barWidth: 4,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
                    return _buildReportItem(context, category, currencyFormat.format(value), color);
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

  Widget _buildReportItem(BuildContext context, Category category, String amount, Color color) {
    return ListTile(
      onTap: () {
        HapticService.selectionStatic();
        context.push('/category_details', extra: category);
      },
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(AppIcons.getIcon(category.icon), size: 16, color: color),
      ),
      title: Text(category.name, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
