import 'package:flutter/material.dart';

class PaisaNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const PaisaNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2E6E2), // Material 3 expressive surface tone matching the screenshots
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(context, 0, Icons.home_filled, Icons.home_outlined, 'Home'),
          _buildItem(context, 1, Icons.account_balance_wallet, Icons.account_balance_wallet_outlined, 'Accounts'),
          _buildItem(context, 2, Icons.data_usage_rounded, Icons.data_usage_outlined, 'Reports'),
          _buildItem(context, 3, Icons.search_rounded, Icons.search_outlined, 'Search'),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, IconData activeIcon, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    
    // M3 Color mappings matching the UI (Brownish active state)
    final activeBgColor = const Color(0xFF8B5145).withOpacity(0.15);
    final activeIconColor = const Color(0xFF8B5145);
    final inactiveIconColor = const Color(0xFF4A4442).withOpacity(0.7);
    
    return GestureDetector(
      onTap: () => onDestinationSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubicEmphasized, // M3 Expressive curve
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey<bool>(isSelected),
                color: isSelected ? activeIconColor : inactiveIconColor,
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 11,
                color: isSelected ? activeIconColor : inactiveIconColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
