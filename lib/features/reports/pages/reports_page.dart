import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/models/category.dart';
import '../../../core/database/providers.dart';
import '../../../core/services/currency_engine.dart';
import '../../../core/theme/color_extension.dart';
import '../../../core/widgets/icon_picker.dart';
import '../../../core/theme/personalization_provider.dart';

/// ReportsPage: A dynamic, reactive dashboard for spending analysis.
class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  // [LOGIC]: Persistent custom range if selected, otherwise defaults to "This Month".
  DateTimeRange? _customRange;
  // [LOGIC]: Filter transactions by a specific account.
  int? _selectedAccountId;
  // [LOGIC]: Filter transactions by tags.
  final List<String> _selectedTags = [];

  Widget _buildDynamicShadowLogo() {
    const double logoSize = 32.0;
    const String logoPath = 'assets/images/logo.svg';

    return Stack(
      children: [
        Transform.translate(
          offset: const Offset(0, 3),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Opacity(
              opacity: 0.3,
              child: SvgPicture.asset(
                logoPath,
                width: logoSize,
                height: logoSize,
              ),
            ),
          ),
        ),
        SvgPicture.asset(
          logoPath,
          width: logoSize,
          height: logoSize,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedCurrency = ref.watch(currencyProvider);
    final personalization = ref.watch(personalizationProvider);

    final now = DateTime.now();
    final effectiveRange = _customRange ??
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );

    final breakdownAsync = ref.watch(categoryBreakdownProvider(
      (effectiveRange, _selectedAccountId, _selectedTags.isEmpty ? null : _selectedTags),
    ));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: breakdownAsync.when(
        data: (breakdown) => _buildReportContent(
          theme,
          colorScheme,
          breakdown,
          selectedCurrency,
          effectiveRange,
          personalization,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading reports: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFilterSheet(context, colorScheme),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Symbols.filter_list),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final accountsAsync = ref.watch(accountsStreamProvider);
            final txsAsync = ref.watch(transactionsStreamProvider);

            return accountsAsync.when(
              data: (accounts) {
                final allTags = txsAsync.value
                        ?.expand((tx) => tx.tags ?? <String>[])
                        .toSet()
                        .toList() ??
                    [];

                return DraggableScrollableSheet(
                  initialChildSize: 0.6,
                  maxChildSize: 0.9,
                  minChildSize: 0.4,
                  expand: false,
                  builder: (context, scrollController) {
                    return SafeArea(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          const SizedBox(height: 12),
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Filter Reports',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'ACCOUNTS',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                  letterSpacing: 1.2,
                                ),
                          ),
                          const SizedBox(height: 8),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Symbols.account_balance_wallet),
                            title: const Text('All Accounts', style: TextStyle(fontWeight: FontWeight.w600)),
                            trailing: _selectedAccountId == null 
                                ? Icon(Symbols.check_circle, color: colorScheme.primary) 
                                : null,
                            onTap: () {
                              setState(() => _selectedAccountId = null);
                              Navigator.pop(context);
                            },
                          ),
                          ...accounts.map((acc) {
                            final color = acc.color.parseHexColor();
                            final isSelected = _selectedAccountId == acc.id;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(AppIcons.getIcon(acc.icon), color: color, size: 20),
                              ),
                              title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              trailing: isSelected 
                                  ? Icon(Symbols.check_circle, color: colorScheme.primary) 
                                  : null,
                              onTap: () {
                                setState(() => _selectedAccountId = acc.id);
                                Navigator.pop(context);
                              },
                            );
                          }),
                          const SizedBox(height: 24),
                          if (allTags.isNotEmpty) ...[
                            Text(
                              'TAGS',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: allTags.map((tag) {
                                final isSelected = _selectedTags.contains(tag);
                                return FilterChip(
                                  label: Text(tag),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedTags.add(tag);
                                      } else {
                                        _selectedTags.remove(tag);
                                      }
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 32),
                          ],
                          FilledButton(
                            onPressed: () => Navigator.pop(context),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Apply Filters'),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Error loading accounts')),
            );
          },
        );
      },
    );
  }

  Widget _buildReportContent(
    ThemeData theme,
    ColorScheme colorScheme,
    Map<Category, double> breakdown,
    String currency,
    DateTimeRange range,
    PersonalizationState personalization,
  ) {
    final totalSpent = breakdown.values.fold(0.0, (sum, val) => sum + val);
    final categoryCount = breakdown.keys.length;
    final sortedEntries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final dateLabel = _customRange == null ? 'This Month' : 'Custom Period';
    final dateString =
        '${DateFormat('MMM d').format(range.start)} - ${DateFormat('MMM d, y').format(range.end)}';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // FIXED HEADER
        SliverAppBar(
          pinned: true,
          floating: true,
          backgroundColor: theme.scaffoldBackgroundColor,
          surfaceTintColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          leadingWidth: 72,
          leading: Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Center(child: _buildDynamicShadowLogo()),
          ),
          title: Text(
            'Reports',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: _selectDateRange,
              icon: const Icon(Symbols.calendar_month),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Symbols.settings),
              onPressed: () => context.push('/settings'),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.push('/edit_profile'),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: colorScheme.surfaceContainerHighest,
                backgroundImage: personalization.userPhoto != null 
                    ? FileImage(File(personalization.userPhoto!)) 
                    : null,
                child: personalization.userPhoto == null
                    ? Icon(
                        Symbols.person,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 24),
          ],
        ),

        // [SECTION]: Date Display Header (SCROLLABLE)
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
