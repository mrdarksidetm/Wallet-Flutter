import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/features/transactions/presentation/add_edit_transaction_screen.dart';
import 'dashboard_screen.dart';
import '../../transactions/presentation/transaction_list_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../insights/presentation/statistics_screen.dart';
import 'widgets/paisa_navigation_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const SizedBox(), 
    const TransactionListScreen(), // Typically Accounts go here, but using Transactions as placeholder
    const StatisticsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFFCF8F7), // M3 background color from screenshot
      body: Stack(
        children: [
          _currentIndex == 0 ? DashboardScreen(onNavigateToTransactions: () => setState(() => _currentIndex = 1)) : _pages[_currentIndex],
          Positioned(
            left: 16,
            right: 16,
            bottom: 24, // Floating above bottom edge
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: PaisaNavigationBar(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: (index) => setState(() => _currentIndex = index),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 64, // Matching navigation bar height roughly
                  width: 64,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditTransactionScreen()));
                    },
                    backgroundColor: const Color(0xFF8B5145), // Dark brown FAB matching screenshot
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
