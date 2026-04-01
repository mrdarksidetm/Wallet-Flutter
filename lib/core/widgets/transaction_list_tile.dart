import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../database/providers.dart';
import '../database/models/transaction_model.dart';
import '../theme/color_extension.dart';
import 'icon_picker.dart';
import 'expressive_bottom_sheet.dart';

class TransactionListTile extends ConsumerWidget {
  final TransactionModel tx;
  final VoidCallback? onTap;

  const TransactionListTile({
    super.key,
    required this.tx,
    this.onTap,
  });

  void _showContextMenu(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final txService = ref.read(transactionServiceProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ExpressiveBottomSheet(
        title: 'Transaction Options',
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Symbols.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                context.push('/add_transaction', extra: tx);
              },
            ),
            ListTile(
              leading: Icon(tx.isArchived ? Symbols.unarchive : Symbols.archive),
              title: Text(tx.isArchived ? 'Unarchive' : 'Archive'),
              onTap: () async {
                Navigator.pop(context);
                if (tx.isArchived) {
                  await ref.read(transactionRepositoryProvider).unarchive(tx.id);
                } else {
                  await txService.archiveTransaction(tx);
                }
              },
            ),
            ListTile(
              leading: Icon(Symbols.delete, color: colorScheme.error),
              title: Text('Delete', style: TextStyle(color: colorScheme.error)),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Transaction?'),
                    content: const Text('This will permanently delete this transaction and update your balance.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: colorScheme.error),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await txService.deleteTransaction(tx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);
    final isIncome = tx.type == TransactionType.income;

    // Ensure links are loaded if possible, otherwise use fallback
    final category = tx.category.value;
    final icon = AppIcons.getIcon(tx.icon ?? category?.icon);
    final categoryColor = (tx.color ?? category?.color ?? '0xFF9E9E9E').parseHexColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context, ref),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
