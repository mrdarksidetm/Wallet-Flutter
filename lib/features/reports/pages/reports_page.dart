import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/models/category.dart';
import '../../../core/database/providers.dart';
import '../../../core/services/currency_engine.dart';
import '../../../core/theme/color_extension.dart';
import '../../../core/widgets/icon_picker.dart';

/// ReportsPage: A dynamic, reactive dashboard for spending analysis.
/// It uses Riverpod to watch the database and automatically update metrics.
class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  // [LOGIC]: Persistent custom range if selected, otherwise defaults to "This Month".
  DateTimeRange? _customRange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedCurrency = ref.watch(currencyProvider);

    // [LOGIC]: Calculate the effective range (either custom or current month).
    final now = DateTime.now();
    final effectiveRange = _customRange ??
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );

    // [REACTIVE DATA]: Watch the breakdown provider for the effective range.
    // Because we added ref.watch(transactionsStreamProvider) in providers.dart,
    // this will rebuild the UI whenever ANY transaction is added, edited, or deleted.
    final breakdownAsync = ref.watch(categoryBreakdownProvider(effectiveRange));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Reports', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: _selectDateRange,
            icon: const Icon(Symbols.calendar_month),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: breakdownAsync.when(
        data: (breakdown) => _buildReportContent(
          theme,
          colorScheme,
          breakdown,
          selectedCurrency,
          effectiveRange,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading reports: $err')),
      ),
      // [FEATURE]: Filter FAB positioned above navigation.
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Placeholder for future advanced filters (by Account, Tags, etc.)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Advanced filtering by account coming soon!')),
          );
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Symbols.filter_list),
      ),
    );
  }

  /// [UI BLOCK]: Main scrollable content using Sliver architecture for fluid motion.
  Widget _buildReportContent(
    ThemeData theme,
    ColorScheme colorScheme,
    Map<Category, double> breakdown,
    String currency,
    DateTimeRange range,
  ) {
    // [CALCULATION]: Iterating through filtered transactions (via provider) to sum metrics.
    final totalSpent = breakdown.values.fold(0.0, (sum, val) => sum + val);
    final categoryCount = breakdown.keys.length;

    // [CALCULATION]: Grouping and sorting expenses by category amount (highest to lowest).
    final sortedEntries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final dateLabel = _customRange == null ? 'This Month' : 'Custom Period';
    final dateString =
        '${DateFormat('MMM d').format(range.start)} - ${DateFormat('MMM d, y').format(range.end)}';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // [SECTION]: Date Display Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabel.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateString,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),

        // [SECTION]: Dynamic Metric Cards
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // [CARD]: Total Spent with dynamic currency formatting.
                Expanded(
                  child: _MetricCard(
                    title: 'Total Spent',
                    value: CurrencyEngine.formatCurrency(totalSpent, currency),
                    icon: Symbols.trending_down,
                    iconColor: Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 12),
                // [CARD]: Category usage metric.
                Expanded(
                  child: _MetricCard(
                    title: 'Categories',
                    value: '$categoryCount used',
                    icon: Symbols.category,
                    iconColor: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // [SECTION]: Spending Breakdown Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              'SPENDING BREAKDOWN',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),

        // [SECTION]: Spending Breakdown List (Handles Empty State)
        if (sortedEntries.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Symbols.analytics, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No data for this period', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = sortedEntries[index];
                  final category = entry.key;
                  final amount = entry.value;
                  final percentage = totalSpent > 0 ? (amount / totalSpent) * 100 : 0.0;

                  return _CategoryBreakdownTile(
                    category: category,
                    amount: amount,
                    currency: currency,
                    percentage: percentage,
                  );
                },
                childCount: sortedEntries.length,
              ),
            ),
          ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  /// [HELPER]: Logic to connect calendar icon to Flutter showDateRangePicker.
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _customRange ?? DateTimeRange(
        start: DateTime(DateTime.now().year, DateTime.now().month, 1),
        end: DateTime.now(),
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _customRange = picked);
    }
  }
}

/// [_MetricCard]: Modern M3 metric card with tonal elevation.
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900, 
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// [_CategoryBreakdownTile]: List item for category spending.
class _CategoryBreakdownTile extends StatelessWidget {
  final Category category;
  final double amount;
  final String currency;
  final double percentage;

  const _CategoryBreakdownTile({
    required this.category,
    required this.amount,
    required this.currency,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = category.color.parseHexColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(AppIcons.getIcon(category.icon), color: color, size: 24),
        ),
        title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${percentage.toStringAsFixed(1)}% of total period spending'),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: color.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        trailing: Text(
          CurrencyEngine.formatCurrency(amount, currency),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5),
        ),
      ),
    );
  }
}
