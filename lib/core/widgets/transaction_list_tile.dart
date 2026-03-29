import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../database/providers.dart';
import '../database/models/transaction_model.dart';
import 'icon_picker.dart';

class TransactionListTile extends ConsumerWidget {
  final TransactionModel tx;
  final VoidCallback? onTap;

  const TransactionListTile({
    super.key,
    required this.tx,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isIncome = tx.type == TransactionType.income;

    // Use transaction icon/color if available, otherwise fall back to category
    final category = tx.category.value;
    final iconName = tx.icon ?? category?.icon;
    final icon = AppIcons.getIcon(iconName);

    final String colorStr = category?.color ?? '0xFF9E9E9E';
    final Color categoryColor =
        Color(int.parse(colorStr.replaceFirst('0x', ''), radix: 16));

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: categoryColor.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: categoryColor,
          size: 20,
        ),
      ),
      title: Text(
        tx.note ?? 'Transaction',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        DateFormat.yMMMd().format(tx.date),
        style: TextStyle(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          fontSize: 12,
        ),
      ),
      trailing: Text(
        '${isIncome ? '+' : '-'}${currencyFormat.format(tx.amount)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isIncome ? Colors.green : colorScheme.error,
        ),
      ),
    );
  }
}
