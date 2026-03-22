import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../home/presentation/home_screen.dart';

import '../../finance/presentation/loan_screen.dart';
import '../../finance/presentation/budget_screen.dart';
import '../../finance/presentation/bill_splitter_screen.dart';
import '../../../presentation/accounts/pages/accounts_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            onNavigateToSettings: () {
              context.push('/settings');
            },
            onNavigateToSubMenu: (title) {
              Widget target;
              switch (title) {
                case "Loans":
                  target = const LoanScreen();
                  break;
                case "Budgets":
                  target = const BudgetScreen();
                  break;
                case "Bill Splitter":
                  target = const BillSplitterScreen();
                  break;
                case "Assets":
                  target = const AccountsPage();
                  break;
                default:
                  target = HomeSubMenu(title: title);
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => target),
              );
            },
          ),
          const AccountsPage(),
          const Center(child: Text("Reports Screen")),
          const Center(child: Text("Search Screen")),
        ],
      ),
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1) 
        ? FloatingActionButton(
            onPressed: () {
              if (_currentIndex == 0) {
                context.push('/add_transaction');
              } else if (_currentIndex == 1) {
                // Navigate to Add Account
              }
            },
            backgroundColor: AppColors.primary,
            child: Icon(
              _currentIndex == 0 ? Icons.add : Icons.account_balance_wallet,
              color: Colors.white,
            ),
          )
        : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline_rounded),
            selectedIcon: Icon(Icons.pie_chart_rounded),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}

class HomeSubMenu extends StatelessWidget {
  final String title;
  const HomeSubMenu({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text("Sub-menu content for $title"),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Go Back"),
            ),
          ],
        ),
      ),
    );
  }
}
