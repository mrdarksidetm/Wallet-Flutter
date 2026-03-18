import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wallet/features/settings/presentation/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD2691E);
    const bgColor = Color(0xFF1A140F);
    const cardColor = Color(0xFF251C15);

    return Scaffold(
      extendBody: true,
      backgroundColor: bgColor,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(primaryColor, context),
                  const SizedBox(height: 24),
                  _buildTotalBalanceCard(primaryColor, cardColor),
                  const SizedBox(height: 24),
                  _buildOverviewGrid(primaryColor, cardColor),
                  const SizedBox(height: 24),
                  _buildRecentActivityHeader(primaryColor),
                  const SizedBox(height: 16),
                  _buildRecentActivityList(cardColor, primaryColor),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: _buildBottomNavigation(primaryColor, cardColor),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color primaryColor, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.account_balance_wallet, color: primaryColor),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good late night', style: TextStyle(color: Colors.slate.shade400, fontSize: 11, fontWeight: FontWeight.w500)),
                const Text('Abhijeet Yadav', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor.withOpacity(0.2), width: 2),
              image: const DecorationImage(
                image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuD7auInrMqEu8-euE8_znCfyyqzmldE0a2Vywhqt3tzIkfLyC8K5NRXSijyhLi44Zl5tb8Az3zEvn05FhzLpSopIhtpE8ZkTY9ANyTzrv_q92Vi1-fKfFw68LO0TamaKRNq3u-52WCMqdcnpb52WQx93w5YaTvm9_nc7UHAZixdu3fxfF386i5oOmtGXOU5DFsUmWDtUYZ_hKR4-P0TgUrUbXD0060xq66pJ3xOm6KdtUrIfsYFnsW40usrCD0RU5A66CXQ5lKDYTg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalBalanceCard(Color primaryColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total balance', style: TextStyle(color: primaryColor.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w600)),
              Icon(Icons.visibility_off, color: Colors.slate.shade500),
            ],
          ),
          const SizedBox(height: 8),
          const Text('-₹1,666.81', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('INCOME', style: TextStyle(color: Colors.slate.shade500, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const Text('₹0.00', style: TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('EXPENSE', style: TextStyle(color: Colors.slate.shade500, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  Text('₹1,666.81', style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewGrid(Color primaryColor, Color cardColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Overview', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Icon(Icons.grid_view, color: Colors.slate.shade400),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildGridItem(Icons.pie_chart, 'Budgets', '0 Budgets', primaryColor, cardColor)),
            const SizedBox(width: 12),
            Expanded(child: _buildGridItem(Icons.account_balance, 'Assets', '₹0.00', primaryColor, cardColor)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildGridItem(Icons.group, 'Bill Splitter', '0 Bills Active', primaryColor, cardColor)),
            const SizedBox(width: 12),
            Expanded(child: _buildGridItem(Icons.currency_exchange, 'Loans', '₹1.95K Balance', primaryColor, cardColor)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildGridItem(Icons.analytics, 'Analytics', '₹0.00 this month', primaryColor, cardColor)),
            const SizedBox(width: 12),
            Expanded(child: _buildGridItem(Icons.event_repeat, 'Recurring', '0 Active', primaryColor, cardColor)),
          ],
        ),
      ],
    );
  }

  Widget _buildGridItem(IconData icon, String title, String subtitle, Color primaryColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          Text(subtitle, style: TextStyle(color: Colors.slate.shade400, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildRecentActivityHeader(Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Recent Activity', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('See All', style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildRecentActivityList(Color cardColor, Color primaryColor) {
    return Column(
      children: [
        _buildTransactionItem('Transfer Faiz', 'Aug 18, 2025 • Bank Balance', '₹550.00', Icons.payments, primaryColor, cardColor),
        const SizedBox(height: 12),
        _buildTransactionItem('Grocery Store', 'Aug 24, 2023', '-₹450.00', Icons.shopping_bag, Colors.white, cardColor),
      ],
    );
  }

  Widget _buildTransactionItem(String title, String subtitle, String amount, IconData icon, Color amountColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.slate.shade800,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.slate.shade300, size: 20),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(color: Colors.slate.shade500, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          Text(amount, style: TextStyle(color: amountColor, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(Color primaryColor, Color cardColor) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: cardColor.withOpacity(0.95),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home, 'Home', primaryColor, true),
              _buildNavItem(Icons.credit_card, 'Accounts', Colors.slate.shade400, false),
              const SizedBox(width: 64), // Space for FAB
              _buildNavItem(Icons.sync_alt, 'Reports', Colors.slate.shade400, false),
              _buildNavItem(Icons.search, 'Search', Colors.slate.shade400, false),
            ],
          ),
        ),
        Positioned(
          top: -24,
          child: FloatingActionButton(
            onPressed: () {},
            backgroundColor: const Color(0xFFEF8E52),
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: const Icon(Icons.add, color: Colors.white, size: 36),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, Color color, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
