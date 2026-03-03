import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionListTile extends StatelessWidget {
  final IconData categoryIcon;
  final Color categoryColor;
  final String title;
  final String subtitle;
  final DateTime date;
  final double amount;
  final bool isExpense;

  const TransactionListTile({
    super.key,
    required this.categoryIcon,
    required this.categoryColor,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.amount,
    this.isExpense = true,
  });

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: categoryColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          categoryIcon,
          color: categoryColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(width: 8),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('MMM d').format(date),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      trailing: Text(
        '${isExpense ? '-' : '+'}${currencyFormat.format(amount)}',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isExpense ? Colors.red.shade400 : Colors.green.shade600,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
