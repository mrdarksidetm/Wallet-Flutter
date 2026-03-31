import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/database/providers.dart';
import '../../../core/widgets/transaction_list_tile.dart';
import '../widgets/total_balance_card.dart';
import '../widgets/overview_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
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
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  const SliverToBoxAdapter(child: _HomeBalanceSection()),
                  const _SectionHeader(title: 'Overview'),
                  const _HomeFinanceGrid(),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  const _SectionHeader(title: 'Recent Transactions'),
                  const _HomeRecentTransactions(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      child: OutlinedButton(
                        onPressed: () => context.push('/all_transactions'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('View All Activity'),
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
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: totalBalanceAsync.when(
        data: (total) => monthlyStatsAsync.when(
          data: (stats) => TotalBalanceCard(
            totalBalance: total,
            monthlyIncome: stats['income'] ?? 0.0,
            monthlyExpense: stats['expense'] ?? 0.0,
            format: currencyFormat,
          ),
          loading: () => _LoadingBalance(format: currencyFormat),
          error: (_, __) => _LoadingBalance(format: currencyFormat),
        ),
        loading: () => _LoadingBalance(format: currencyFormat),
        error: (_, __) => _LoadingBalance(format: currencyFormat),
      ),
    );
  }
}

class _LoadingBalance extends StatelessWidget {
  final NumberFormat format;
  const _LoadingBalance({required this.format});
  @override
  Widget build(BuildContext context) => TotalBalanceCard(
      totalBalance: 0, monthlyIncome: 0, monthlyExpense: 0, format: format);
}

class _HomeFinanceGrid extends ConsumerWidget {
  const _HomeFinanceGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalAssetBalanceAsync = ref.watch(totalAssetBalanceProvider);
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);

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
              data: (v) => '${currencyFormat.format(v)} total',
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
        ]),
      ),
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
