import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/greeting_service.dart';
import '../../../core/widgets/icon_picker.dart';
import '../widgets/total_balance_card.dart';
import '../widgets/overview_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalBalanceAsync = ref.watch(totalBalanceProvider);
    final totalAssetBalanceAsync = ref.watch(totalAssetBalanceProvider);
    final monthlyStatsAsync = ref.watch(monthlyStatsProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final budgetsAsync = ref.watch(budgetStatsProvider);
    final goalsAsync = ref.watch(goalsStreamProvider);
    final selectedCurrency = ref.watch(currencyProvider);
    final greeting = ref.watch(greetingServiceProvider).getGreeting();
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);

    double totalBudgetLeft = 0;
    if (budgetsAsync.hasValue) {
      for (var b in budgetsAsync.value!) {
        final left = (b['limit'] as double) - (b['spent'] as double);
        if (left > 0) totalBudgetLeft += left;
      }
    }

    return Scaffold(
      body: AnimationLimiter(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text('$greeting, Abhi'),
              actions: [
                IconButton(
                  onPressed: () async {
                    await HapticService.light();
                    if (context.mounted) context.push('/search');
                  },
                  icon: const Hero(tag: 'search_icon', child: Icon(Icons.search_rounded)),
                ),
                IconButton(
                  onPressed: () async {
                    await HapticService.light();
                    if (context.mounted) context.push('/settings');
                  },
                  icon: const Icon(Icons.person_outline_rounded),
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      TotalBalanceCard(
                        totalBalance: totalBalanceAsync.value ?? 0.0,
                        monthlyIncome: monthlyStatsAsync.value?['income'] ?? 0.0,
                        monthlyExpense: monthlyStatsAsync.value?['expense'] ?? 0.0,
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
                      const SizedBox(height: 24),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.1,
                        children: [
                          OverviewCard(
                            icon: Icons.pie_chart_rounded,
                            title: 'Budgets',
                            subtitle: budgetsAsync.when(
                              data: (b) => b.isEmpty ? 'Set budget' : '${currencyFormat.format(totalBudgetLeft)} left',
                              loading: () => '...',
                              error: (_, __) => 'Error',
                            ),
                            onTap: () async {
                              await HapticService.selection();
                              if (context.mounted) context.push('/budgets');
                            },
                          ),
                          OverviewCard(
                            icon: Icons.account_balance_rounded,
                            title: 'Assets',
                            subtitle: totalAssetBalanceAsync.when(
                              data: (v) => '${currencyFormat.format(v)} total',
                              loading: () => '...',
                              error: (_, __) => 'Error',
                            ),
                            onTap: () async {
                              await HapticService.selection();
                              if (context.mounted) context.go('/accounts');
                            },
                          ),
                          OverviewCard(
                            icon: Icons.flag_rounded,
                            title: 'Goals',
                            subtitle: goalsAsync.when(
                              data: (g) => '${g.length} active',
                              loading: () => '...',
                              error: (_, __) => 'Error',
                            ),
                            onTap: () async {
                              await HapticService.selection();
                              if (context.mounted) context.push('/goals');
                            },
                          ),
                          OverviewCard(
                            icon: Icons.currency_exchange_rounded,
                            title: 'Loans',
                            subtitle: 'Manage debts',
                            onTap: () async {
                              await HapticService.selection();
                              if (context.mounted) context.push('/loans');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Transactions',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await HapticService.light();
                              if (context.mounted) context.go('/accounts');
                            },
                            child: const Text('View all'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: Text('No transactions yet')),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tx = transactions[index];
                        final isExpense = tx.type == TransactionType.expense;
                        final color = isExpense ? Colors.red : Colors.green;
                        final iconData = tx.icon != null 
                            ? AppIcons.getIcon(tx.icon) 
                            : (tx.category.value?.icon != null 
                                ? AppIcons.getIcon(tx.category.value?.icon)
                                : (isExpense ? Icons.shopping_bag_outlined : Icons.payments_outlined));
                        
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: ListTile(
                                onTap: () async {
                                  await HapticService.selection();
                                  // Navigate to transaction detail if needed
                                },
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  child: Icon(
                                    iconData,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  tx.note ?? 'Transaction',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(DateFormat('MMM d, h:mm a').format(tx.date)),
                                trailing: Text(
                                  '${isExpense ? '-' : '+'}${currencyFormat.format(tx.amount)}',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: transactions.length > 5 ? 5 : transactions.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverToBoxAdapter(
                child: Center(child: Text('Error: $err')),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
