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
    final dashboard = DashboardScreen(
      onNavigateToTransactions: () => setState(() => _currentIndex = 1),
    );
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _currentIndex == 0 ? dashboard : _pages[_currentIndex],
          Positioned(
            left: 16,
            right: 16,
            bottom: 24, // Floating above bottom edge
            child: Row(
              children: [
                Expanded(
                  child: PaisaNavigationBar(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: (index) => setState(() => _currentIndex = index),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditTransactionScreen()));
                  },
                  backgroundColor: const Color(0xFFFF9E80), // True Paisa Orange
                  elevation: 4,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, color: Colors.black, size: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
