import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TotalBalanceCard extends StatelessWidget {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;

  const TotalBalanceCard({
    super.key,
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'en_IN');

    return Card(
      color: colorScheme.primaryContainer.withValues(alpha: 0.4),
      // Use the theme's card shape but could override if a specific massive look is needed
      // To keep it massive but still respond to global settings, we add a fixed offset
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Balance',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(totalBalance),
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMiniStat(
                  context,
                  'Income',
                  currencyFormat.format(monthlyIncome),
                  Colors.green,
                ),
                _buildMiniStat(
                  context,
                  'Expense',
                  currencyFormat.format(monthlyExpense),
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
