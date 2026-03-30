import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../database/providers.dart';
import '../database/models/transaction_model.dart';
import '../services/haptic_service.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);
    final isIncome = tx.type == TransactionType.income;

    // Use transaction icon/color if available, otherwise fall back to category
    final category = tx.category.value;
    final iconName = tx.icon ?? category?.icon;
    final icon = AppIcons.getIcon(iconName);

    final String colorStr = category?.color ?? '0xFF9E9E9E';
    final Color categoryColor =
        Color(int.parse(colorStr.replaceFirst('0x', ''), radix: 16));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: ListTile(
        onTap: () {
          if (onTap != null) {
            HapticService.selectionStatic();
            onTap!();
          }
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: categoryColor,
            size: 24,
          ),
        ),
        title: Text(
          tx.note?.isNotEmpty == true ? tx.note! : (category?.name ?? 'Transaction'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          DateFormat.yMMMMd().format(tx.date),
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${currencyFormat.format(tx.amount)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: isIncome ? Colors.green : Colors.red,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}
