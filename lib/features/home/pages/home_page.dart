import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/theme/personalization_provider.dart';
import '../widgets/home_header.dart';
import '../widgets/total_balance_card.dart';
import '../widgets/animated_balance_hero.dart';
import '../../transactions/pages/add_transaction_page.dart';
import '../../people/widgets/person_avatar.dart';
import '../widgets/home_insights_section.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final personalization = ref.watch(personalizationProvider);
    final personsAsync = ref.watch(personsStreamProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(accountsStreamProvider);
          ref.invalidate(transactionsStreamProvider);
          ref.invalidate(personsStreamProvider);
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: HomeHeader(
                  userName: personalization.userName ?? 'User',
                  greeting: _getGreeting(),
                  userPhoto: personalization.userPhoto,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: transactionsAsync.when(
                data: (txs) {
                  final now = DateTime.now();
                  final thisMonth = txs.where((t) => t.createdAt.month == now.month && t.createdAt.year == now.year).toList();
                  
                  final totalIncome = txs.where((t) => t.type == TransactionType.income).fold(0.0, (s, t) => s + t.amount);
                  final totalExpense = txs.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount);
                  
                  final monthlyIncome = thisMonth.where((t) => t.type == TransactionType.income).fold(0.0, (s, t) => s + t.amount);
                  final monthlyExpense = thisMonth.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount);

                  return AnimatedBalanceHero(
                    totalBalance: totalIncome - totalExpense,
                    monthlyIncome: monthlyIncome,
                    monthlyExpense: monthlyExpense,
                  );
                },
                loading: () => const SizedBox(height: 240, child: Center(child: CircularProgressIndicator())),
                error: (_, __) => const SizedBox(height: 240),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            SliverToBoxAdapter(
              child: transactionsAsync.when(
                data: (txs) {
                  final balance = txs.fold(0.0, (sum, tx) {
                    return tx.type == TransactionType.income 
                        ? sum + tx.amount 
                        : sum - tx.amount;
                  });
                  return TotalBalanceCard(balance: balance);
                },
                loading: () => const TotalBalanceCard(balance: 0),
                error: (_, __) => const TotalBalanceCard(balance: 0),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildQuickAction(
                      context,
                      icon: Symbols.settings_applications,
                      label: 'Bill Splitter',
                      onTap: () => context.push('/bill-splitter'),
                    ),
                    const SizedBox(width: 12),
                    _buildQuickAction(
                      context,
                      icon: Symbols.account_balance_wallet,
                      label: 'Accounts',
                      onTap: () => context.push('/accounts'),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'People',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/people'),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: personsAsync.when(
                      data: (persons) => ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: persons.length,
                        itemBuilder: (context, index) {
                          final person = persons[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: PersonAvatar(
                              person: person,
                              onTap: () => context.push('/people/${person.id}'),
                            ),
                          );
                        },
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            const SliverToBoxAdapter(
              child: HomeInsightsSection(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Activity',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/transactions'),
                      child: const Text('See More'),
                    ),
                  ],
                ),
              ),
            ),

            transactionsAsync.when(
              data: (txs) {
                final recent = txs.take(10).toList();
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tx = recent[index];
                      return _buildTransactionTile(context, tx);
                    },
                    childCount: recent.length,
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddTransactionPage(),
          );
        },
        child: const Icon(Symbols.add),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildQuickAction(BuildContext context,
      {required IconData icon, required String label, required VoidCallback? onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Material(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Icon(icon, color: colorScheme.primary),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, TransactionModel tx) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isExpense = tx.type == TransactionType.expense;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: Icon(
          isExpense ? Symbols.keyboard_arrow_down : Symbols.keyboard_arrow_up,
          color: isExpense ? Colors.red : Colors.green,
        ),
      ),
      title: Text(
        tx.category.value?.name ?? 'Uncategorized',
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(DateFormat('MMM d, h:mm a').format(tx.createdAt)),
      trailing: Text(
        '${isExpense ? "-" : "+"}${tx.amount.toStringAsFixed(2)}',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: isExpense ? Colors.red : Colors.green,
        ),
      ),
    );
  }
}
