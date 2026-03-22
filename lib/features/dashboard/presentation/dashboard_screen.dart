import 'package:flutter/material.dart';
import 'package:wallet/core/theme/colors.dart';
import 'package:wallet/features/home/presentation/home_screen.dart';

import 'package:wallet/features/finance/presentation/loan_screen.dart';
import 'package:wallet/features/finance/presentation/budget_screen.dart';
import 'package:wallet/features/finance/presentation/bill_splitter_screen.dart';
import 'package:wallet/features/accounts/presentation/accounts_screen.dart'; // Assuming this exists or using a placeholder

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        onNavigateToSettings: () {
          setState(() => _currentIndex = 3); // Settings is index 3 in our list
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
              // For Assets, we can show a summary or navigate to accounts
              target = const AccountsScreen(); // Or a specific Assets screen
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
      const Center(child: Text("Accounts Screen")),
      const Center(child: Text("Reports Screen")),
      const Center(child: Text("Search Screen")),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1) 
        ? FloatingActionButton(
            onPressed: () {
              if (_currentIndex == 0) {
                // Navigate to Add Transaction
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home, "Home"),
              _buildNavItem(1, Icons.account_balance_wallet, "Accounts"),
              _buildNavItem(2, Icons.pie_chart, "Reports"),
              _buildNavItem(3, Icons.search, "Search"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected 
        ? AppColors.primary 
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.5);

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
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
