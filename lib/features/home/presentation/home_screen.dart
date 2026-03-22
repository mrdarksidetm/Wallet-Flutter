import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wallet/core/database/providers.dart';
import 'package:wallet/core/theme/colors.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onNavigateToSettings;
  final Function(String) onNavigateToSubMenu;
  const HomeScreen({super.key, required this.onNavigateToSettings, required this.onNavigateToSubMenu});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isBalanceVisible = true;
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  Widget build(BuildContext context) {
    final totalBalance = ref.watch(totalBalanceProvider).value ?? 0.0;
    final monthlyStats = ref.watch(monthlyStatsProvider).value ?? {'income': 0.0, 'expense': 0.0};
    // Filter out archived transactions and limit to top 5
    final transactions = (ref.watch(transactionsStreamProvider).value ?? [])
        .where((tx) => !tx.isArchived)
        .take(5)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Good late night",
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                              Text(
                                "Abhijeet Yadav",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Premium Banner
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.star, color: AppColors.primary, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  "PRO",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // UserShape
                          GestureDetector(
                            onTap: widget.onNavigateToSettings,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.2),
                                  width: 2,
                                ),
                                color: Theme.of(context).colorScheme.primaryContainer,
                              ),
                              child: const Center(
                                child: Text(
                                  "A",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Total Balance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total balance",
                              style: TextStyle(
                                color: AppColors.primary.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                              icon: Icon(
                                _isBalanceVisible ? Icons.visibility_off : Icons.visibility,
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _isBalanceVisible 
                              ? _currencyFormat.format(totalBalance)
                              : "••••••",
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildBalanceSummary("Income", monthlyStats['income'] ?? 0.0, AppColors.income),
                            _buildBalanceSummary("Expense", monthlyStats['expense'] ?? 0.0, AppColors.expense),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Overview Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildOverviewGridItem(context, Icons.pie_chart, "Budgets", "₹0.00 left"),
                      _buildOverviewGridItem(context, Icons.account_balance, "Assets", "₹0.00 total"),
                      _buildOverviewGridItem(context, Icons.share, "Bill Splitter", "0 active"),
                      _buildOverviewGridItem(context, Icons.currency_exchange, "Loans", "₹0.00 due"),
                      _buildOverviewGridItem(context, Icons.star, "Goals", "0 active"),
                      _buildOverviewGridItem(context, Icons.info, "Labels", "0 tags"),
                      _buildOverviewGridItem(context, Icons.timeline, "Analytics", "View charts"),
                      _buildOverviewGridItem(context, Icons.refresh, "Recurring", "0 active"),
                      _buildOverviewGridItem(context, Icons.list, "Categories", "12 items"),
                      _buildOverviewGridItem(context, Icons.date_range, "Weekly", "This week"),
                      _buildOverviewGridItem(context, Icons.location_on, "Places", "0 locations"),
                      _buildOverviewGridItem(context, Icons.person, "Person", "0 people"),
                      _buildOverviewGridItem(context, Icons.date_range, "Calendar heatmap", "Activity"),
                      _buildOverviewGridItem(context, Icons.trending_up, "Trend", "Growth"),
                      _buildOverviewGridItem(context, Icons.list, "Recent transactions", "History"),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Transactions Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recent Transactions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Text("View all"),
                        label: const Icon(Icons.chevron_right, size: 16),
                      ),
                    ],
                  ),
                  
                  // Transaction List
                  if (transactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: Text("No transactions yet"),
                      ),
                    )
                  else
                    ...transactions.take(5).map((tx) => _buildTransactionItem(context, tx)),
                  
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSummary(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(
          _currencyFormat.format(amount),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewGridItem(BuildContext context, IconData icon, String title, String subtitle) {
    return GestureDetector(
      onTap: () => widget.onNavigateToSubMenu(title),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, dynamic tx) {
    final isIncome = tx.type == "Income";
    
    return Dismissible(
      key: Key('tx_${tx.id}'),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.blue,
        child: const Icon(Icons.archive, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Archive
          await ref.read(transactionServiceProvider).archiveTransaction(tx);
          return true;
        } else if (direction == DismissDirection.endToStart) {
          // Delete
          await ref.read(transactionServiceProvider).deleteTransaction(tx);
          return true;
        }
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isIncome ? Icons.trending_up : Icons.shopping_bag,
                color: isIncome ? AppColors.income : AppColors.expense,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.note.isEmpty ? tx.category : tx.note,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    tx.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "${isIncome ? '+' : '-'}${_currencyFormat.format(tx.amount)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isIncome ? AppColors.income : AppColors.expense,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
