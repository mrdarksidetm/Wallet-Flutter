import 'package:flutter/material.dart';
import '../../../../core/widgets/overview_grid_card.dart';
import '../../../../core/widgets/transaction_list_tile.dart';
import '../../../../core/widgets/expressive_bottom_sheet.dart';
import '../../transactions/presentation/data_entry_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, User',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.cloud_sync_outlined),
                onPressed: () {},
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ),
            ],
          ),
          
          // Hero Section: Total Balance
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              child: Card(
                color: Theme.of(context).cardTheme.color,
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Balance',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_upward, color: Colors.green, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '2.5%',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '₹1,24,500.00',
                                style: Theme.of(context).textTheme.displayLarge,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.visibility_off_outlined),
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Quick Actions (Comprehensive)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                children: [
                  _buildQuickAction(context, Icons.receipt_long, 'Split Bill', Colors.orange),
                  const SizedBox(width: 24),
                  _buildQuickAction(context, Icons.people, 'People', Colors.blue),
                  const SizedBox(width: 24),
                  _buildQuickAction(context, Icons.pie_chart, 'Budgets', Colors.red),
                  const SizedBox(width: 24),
                  _buildQuickAction(context, Icons.account_balance, 'Assets', Colors.green),
                  const SizedBox(width: 24),
                  _buildQuickAction(context, Icons.credit_score, 'Loans', Colors.brown),
                  const SizedBox(width: 24),
                  _buildQuickAction(context, Icons.flag, 'Goals', Colors.purple),
                  const SizedBox(width: 24),
                  _buildQuickAction(context, Icons.label, 'Labels', Colors.pink),
                  const SizedBox(width: 24),
                  _buildQuickAction(context, Icons.analytics, 'Analytics', Colors.indigo),
                  const SizedBox(width: 24),
                  _buildQuickAction(context, Icons.autorenew, 'Recurring', Colors.teal),
                  const SizedBox(width: 24),
                  _buildQuickAction(context, Icons.place, 'Places', Colors.deepOrange),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Overview Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                OverviewGridCard(
                  icon: Icons.arrow_downward,
                  title: 'Income',
                  amount: '₹45,000',
                  subtitle: 'This month',
                  backgroundColor: Colors.green.withOpacity(0.05),
                  iconColor: Colors.green,
                ),
                OverviewGridCard(
                  icon: Icons.arrow_upward,
                  title: 'Expense',
                  amount: '₹12,400',
                  subtitle: 'This month',
                  backgroundColor: Colors.red.withOpacity(0.05),
                  iconColor: Colors.red,
                ),
              ],
            ),
          ),

          // Calendar Heatmap Placeholder
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Card(
                color: Theme.of(context).cardTheme.color,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activity Heatmap',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 16),
                      // Fake Heatmap using an array of containers
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: List.generate(
                          7 * 10,
                          (index) => Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: index % 5 == 0 
                                  ? Colors.green.shade400 
                                  : index % 7 == 0 
                                      ? Colors.green.shade700 
                                      : Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Trend Chart Placeholder
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Card(
                color: Theme.of(context).cardTheme.color,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spending Trend',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 120,
                        child: Center(
                          child: Icon(
                            Icons.show_chart,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Recent Transactions Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
          ),

          // Bottom List: Recent Transactions
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return TransactionListTile(
                  categoryIcon: Icons.shopping_bag,
                  categoryColor: Colors.blue,
                  title: 'Groceries',
                  subtitle: 'Supermarket',
                  date: DateTime.now().subtract(Duration(days: index)),
                  amount: 1250.0 + (index * 100),
                  isExpense: true,
                );
              },
              childCount: 10,
            ),
          ),
          
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)), // Space for FAB
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ExpressiveBottomSheet.show(
            context: context,
            child: const DataEntryScreen(),
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
