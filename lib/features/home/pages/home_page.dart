import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/database/providers.dart';
import '../../../core/widgets/transaction_list_tile.dart';
import '../../../core/services/currency_engine.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/database/models/transaction_model.dart';
import '../widgets/animated_balance_hero.dart';
import '../widgets/overview_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    final personalization = ref.watch(personalizationProvider);
    final userName = personalization.userName ?? 'User';
    
    final backgroundColor = isDark ? colorScheme.surface : const Color(0xFFF7F7F9);

    return Container(
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SCROLLABLE CONTENT
          Expanded(
            child: AnimationLimiter(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // FIXED HEADER
                  SliverAppBar(
                    pinned: true,
                    floating: true,
                    backgroundColor: backgroundColor,
                    surfaceTintColor: backgroundColor,
                    elevation: 0,
                    leadingWidth: 72,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Center(child: _buildDynamicShadowLogo()),
                    ),
                    actions: [
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

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  
                  // SCROLLABLE GREETING
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Text(
                        '${_getGreeting()}, $userName',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: _HomeBalanceSection()),
                  const _SectionHeader(title: 'Overview'),
                  const _HomeFinanceGrid(),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  const _SectionHeader(title: 'Activity Insights'),
                  const SliverToBoxAdapter(child: _HomeChartsSection()),
                  const _SectionHeader(title: 'Recent Transactions'),
                  const _HomeRecentTransactions(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      child: FilledButton.tonal(
                        onPressed: () => context.push('/all_transactions'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.4),
                          foregroundColor: colorScheme.primary,
                        ),
                        child: const Text(
                          'View All Transactions',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

class _HomeBalanceSection extends ConsumerWidget {
  const _HomeBalanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalBalanceAsync = ref.watch(totalBalanceProvider);
    final monthlyStatsAsync = ref.watch(monthlyStatsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: totalBalanceAsync.when(
        data: (total) => monthlyStatsAsync.when(
          data: (stats) => AnimatedBalanceHero(
            totalBalance: total,
            monthlyIncome: stats['income'] ?? 0.0,
            monthlyExpense: stats['expense'] ?? 0.0,
          ),
          loading: () => const _LoadingBalance(),
          error: (_, __) => const _LoadingBalance(),
        ),
        loading: () => const _LoadingBalance(),
        error: (_, __) => const _LoadingBalance(),
      ),
    );
  }
}

class _LoadingBalance extends StatelessWidget {
  const _LoadingBalance();
  @override
  Widget build(BuildContext context) => const AnimatedBalanceHero(
      totalBalance: 0, monthlyIncome: 0, monthlyExpense: 0);
}

class _HomeFinanceGrid extends ConsumerWidget {
  const _HomeFinanceGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalAssetBalanceAsync = ref.watch(totalAssetBalanceProvider);
    // Watch accountsStreamProvider to ensure the grid updates when accounts change
    ref.watch(accountsStreamProvider);
    final selectedCurrency = ref.watch(currencyProvider);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        delegate: SliverChildListDelegate([
          OverviewCard(
            icon: Symbols.account_balance,
            title: 'Accounts',
            subtitle: totalAssetBalanceAsync.when(
              data: (v) => '${CurrencyEngine.formatCurrency(v, selectedCurrency)} total',
              loading: () => '...',
              error: (_, __) => 'Error',
            ),
            onTap: () => context.go('/accounts'),
          ),
          OverviewCard(
            icon: Symbols.pie_chart,
            title: 'Budgets',
            subtitle: 'Track spending',
            onTap: () => context.push('/budgets'),
          ),
          OverviewCard(
            icon: Symbols.flag,
            title: 'Goals',
            subtitle: 'Savings targets',
            onTap: () => context.push('/goals'),
          ),
          OverviewCard(
            icon: Symbols.front_loader,
            title: 'Loans',
            subtitle: 'Debts & lending',
            onTap: () => context.push('/loans'),
          ),
          OverviewCard(
            icon: Symbols.event_repeat,
            title: 'Recurring',
            subtitle: 'Subscription & bills',
            onTap: () => context.push('/recurring'),
          ),
          OverviewCard(
            icon: Symbols.category,
            title: 'Categories',
            subtitle: 'Manage groups',
            onTap: () => context.push('/categories'),
          ),
          OverviewCard(
            icon: Symbols.call_split,
            title: 'Bill Splitter',
            subtitle: 'Shared expenses',
            onTap: () => context.push('/bill_splitter'),
          ),
          OverviewCard(
            icon: Symbols.group,
            title: 'People',
            subtitle: 'Friends & contacts',
            onTap: () => context.push('/people'),
          ),
        ]),
      ),
    );
  }
}

class _HomeChartsSection extends ConsumerWidget {
  const _HomeChartsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) return const SizedBox.shrink();

        // --- Process Data for Heatmap ---
        final Map<DateTime, int> heatmapData = {};
        for (var tx in transactions) {
          final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
          heatmapData[date] = (heatmapData[date] ?? 0) + 1;
        }

        // --- Process Data for Line Chart (Last 30 days) ---
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
              incomeByDate[txDate] = (incomeByDate[txDate] ?? 0) + tx.amount;
            } else if (tx.type == TransactionType.expense) {
              expenseByDate[txDate] = (expenseByDate[txDate] ?? 0) + tx.amount;
            }
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // --- HEATMAP ---
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Frequency',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      HeatMap(
                        datasets: heatmapData,
                        colorMode: ColorMode.opacity,
                        showText: false,
                        scrollable: true,
                        colorsets: {
                          1: colorScheme.primary,
                        },
                        onClick: (value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(value.toString())));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // --- LINE CHART ---
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Income vs Expense (Last 30 Days)',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 200,
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
                                color: Colors.green,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.green.withValues(alpha: 0.1),
                                ),
                              ),
                              LineChartBarData(
                                spots: last30Days.asMap().entries.map((e) {
                                  return FlSpot(e.key.toDouble(), expenseByDate[e.value] ?? 0);
                                }).toList(),
                                isCurved: true,
                                color: Colors.red,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.red.withValues(alpha: 0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _HomeRecentTransactions extends ConsumerWidget {
  const _HomeRecentTransactions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text('No activity found'),
              ),
            ),
          );
        }

        final recentTxs = transactions.take(10).toList();
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TransactionListTile(
                        tx: recentTxs[index],
                        onTap: () {
                          
                          context.push('/add_transaction',
                              extra: recentTxs[index]);
                        },
                      ),
                    ),
                  ),
                ),
              ),
              childCount: recentTxs.length,
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator())),
      error: (err, _) =>
          SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
    );
  }
}

