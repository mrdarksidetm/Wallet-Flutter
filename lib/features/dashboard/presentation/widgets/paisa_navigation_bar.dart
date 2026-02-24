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
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(context, 0, Icons.home_filled, Icons.home_outlined, 'Home'),
          _buildItem(context, 1, Icons.account_balance_wallet, Icons.account_balance_wallet_outlined, 'Accounts'),
          _buildItem(context, 2, Icons.pie_chart, Icons.pie_chart_outline, 'Reports'),
          _buildItem(context, 3, Icons.search, Icons.search, 'Search'),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, IconData activeIcon, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primaryContainer : Colors.transparent;
    final onColor = isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface.withOpacity(0.8);
    
    return GestureDetector(
      onTap: () => onDestinationSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : icon, color: onColor, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: onColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
