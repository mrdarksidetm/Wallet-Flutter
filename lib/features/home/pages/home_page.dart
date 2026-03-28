import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/greeting_service.dart';
import '../widgets/total_balance_card.dart';
import '../widgets/overview_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = ref.watch(greetingServiceProvider).getGreeting();
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);

    return AnimationLimiter(
      child: CustomScrollView(
        slivers: [
          _HomeAppBar(greeting: greeting),
          const SliverToBoxAdapter(child: _HomeBalanceSection()),
          _buildSectionHeader('Finances'),
          _HomeFinanceGrid(currencyFormat: currencyFormat),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          _buildSectionHeader('Recent Transactions'),
          _HomeRecentTransactions(currencyFormat: currencyFormat),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: OutlinedButton(
                onPressed: () => context.push('/all_transactions'),
                child: const Text('View All Transactions'),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 16, 12),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontVariations: [FontVariation('wdth', 120)],
          ),
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  final String greeting;
  const _HomeAppBar({required this.greeting});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar.large(
      title: Text('$greeting, Abhi'),
      actions: [
        IconButton(
          onPressed: () => context.push('/settings'),
          icon: const Icon(Symbols.person),
        ),
        const SizedBox(width: 8),
      ],
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
          data: (stats) => TotalBalanceCard(
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
  Widget build(BuildContext context) => const TotalBalanceCard(totalBalance: 0, monthlyIncome: 0, monthlyExpense: 0);
}

class _HomeFinanceGrid extends ConsumerWidget {
  final NumberFormat currencyFormat;
  const _HomeFinanceGrid({required this.currencyFormat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalAssetBalanceAsync = ref.watch(totalAssetBalanceProvider);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
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
          OverviewCard(
            icon: Symbols.group,
            title: 'People',
            subtitle: 'Contacts',
            onTap: () => context.push('/people'),
          ),
          OverviewCard(
            icon: Symbols.event_repeat,
            title: 'Recurring',
            subtitle: 'Bills & subs',
            onTap: () => context.push('/recurring'),
          ),
        ]),
      ),
    );
  }
}

class _HomeRecentTransactions extends ConsumerWidget {
  final NumberFormat currencyFormat;
  const _HomeRecentTransactions({required this.currencyFormat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) return const SliverToBoxAdapter(child: Center(child: Text('No transactions yet')));
        
        final recentTxs = transactions.take(20).toList();
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
                    child: _TransactionTile(tx: recentTxs[index], format: currencyFormat),
                  ),
                ),
              ),
              childCount: recentTxs.length,
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
      error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  final NumberFormat format;
  const _TransactionTile({required this.tx, required this.format});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isIncome = tx.type == TransactionType.income;

    return ListTile(
      onTap: () => HapticService.selectionStatic(),
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(Symbols.receipt_long, size: 20, color: colorScheme.onSurfaceVariant),
      ),
      title: Text(tx.note ?? 'Transaction', style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(DateFormat.yMMMd().format(tx.date), style: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
      trailing: Text(
        '${isIncome ? '+' : '-'}${format.format(tx.amount)}',
        style: TextStyle(fontWeight: FontWeight.bold, color: isIncome ? Colors.green : colorScheme.error),
      ),
    );
  }
}
