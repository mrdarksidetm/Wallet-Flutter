import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/database/providers.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/greeting_service.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/widgets/transaction_list_tile.dart';
import '../widgets/total_balance_card.dart';
import '../widgets/overview_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = ref.watch(greetingServiceProvider).getGreeting();
    final userName =
        ref.watch(personalizationProvider.select((p) => p.userName)) ?? 'User';

    return AnimationLimiter(
      child: CustomScrollView(
        slivers: [
          _HomeAppBar(greeting: greeting, userName: userName),
          const SliverToBoxAdapter(child: _HomeBalanceSection()),
          const _SectionHeader(title: 'Finances'),
          const _HomeFinanceGrid(),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          const _SectionHeader(title: 'Recent Transactions'),
          const _HomeRecentTransactions(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: FilledButton.tonal(
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
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
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

class _HomeAppBar extends ConsumerWidget {
  final String greeting;
  final String userName;
  const _HomeAppBar({required this.greeting, required this.userName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = ref.watch(personalizationProvider).userPhoto;
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar.large(
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: SvgPicture.asset(
          'assets/images/logo.svg',
          height: 32,
          width: 32,
        ),
      ),
      leadingWidth: 48,
      title: Text('$greeting, $userName'),
      actions: [
        GestureDetector(
          onTap: () => context.push('/user_info'),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surfaceContainerHighest,
              image: photo != null
                  ? DecorationImage(
                      image: FileImage(File(photo)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: photo == null ? const Icon(Symbols.person, size: 20) : null,
          ),
        ),
        IconButton(
          onPressed: () => context.push('/settings'),
          icon: const Icon(Symbols.settings),
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
                child: Text('No transactions yet'),
              ),
            ),
          );
        }

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
                    child: TransactionListTile(
                      tx: recentTxs[index],
                      onTap: () {
                        HapticService.selectionStatic();
                        context.push('/add_transaction',
                            extra: recentTxs[index]);
                      },
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
