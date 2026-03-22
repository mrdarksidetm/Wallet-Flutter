import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/total_balance_card.dart';
import '../widgets/overview_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Good late night, Abhi'),
            actions: [
              IconButton(
                onPressed: () => context.push('/settings'),
                icon: const Icon(Icons.person_outline_rounded),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const TotalBalanceCard(
                    totalBalance: 45250.00,
                    monthlyIncome: 85000.00,
                    monthlyExpense: 39750.00,
                  ),
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
                        subtitle: '₹12,000 left',
                        onTap: () {},
                      ),
                      OverviewCard(
                        icon: Icons.account_balance_rounded,
                        title: 'Assets',
                        subtitle: '₹2.5L total',
                        onTap: () {},
                      ),
                      OverviewCard(
                        icon: Icons.share_rounded,
                        title: 'Bill Splitter',
                        subtitle: '2 active',
                        onTap: () {},
                      ),
                      OverviewCard(
                        icon: Icons.currency_exchange_rounded,
                        title: 'Loans',
                        subtitle: '₹5,000 due',
                        onTap: () => context.push('/loans'),
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
                        onPressed: () {},
                        child: const Text('View all'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.shopping_bag_outlined),
                    ),
                    title: const Text('Groceries', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Today, 4:20 PM'),
                    trailing: const Text('-₹450.00', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  );
                },
                childCount: 3,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
