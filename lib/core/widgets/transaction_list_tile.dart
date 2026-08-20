import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../database/providers.dart';
import '../database/models/transaction_model.dart';
import '../theme/color_extension.dart';
import '../services/currency_engine.dart';
import 'icon_picker.dart';
import 'expressive_bottom_sheet.dart';
import '../../features/people/widgets/person_avatar.dart';

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
      builder: (sheetContext) => ExpressiveBottomSheet(
        title: 'Transaction Options',
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Symbols.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(sheetContext);
                if (context.mounted) {
                  context.push('/add_transaction', extra: tx);
                }
              },
            ),
            ListTile(
              leading: Icon(tx.isArchived ? Symbols.unarchive : Symbols.archive),
              title: Text(tx.isArchived ? 'Unarchive' : 'Archive'),
              onTap: () async {
                Navigator.pop(sheetContext);
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
                Navigator.pop(sheetContext);
                if (!context.mounted) return;
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Delete Transaction?'),
                    content: const Text('This will permanently delete this transaction and update your balance.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
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
    final isIncome = tx.type == TransactionType.income;

    // [ACTION]: Determining the primary visual identity of the transaction.
    // [M3 UPDATE]: Using the explicitly saved tx.icon and tx.color with category fallback.
    // [WHY]: This ensures that even if links are not eagerly loaded, the transaction 
    // tile displays the correct icon and brand color inherited from its category.
    final category = tx.category.value;
    final icon = AppIcons.getIcon(tx.icon ?? category?.icon ?? 'category');
    final categoryColor = (tx.color ?? category?.color ?? '0xFF9E9E9E').parseHexColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // [ACTION]: Applying a subtle background hue for grouping.
        // [M3 UPDATE]: Using surfaceContainerHighest to provide a dynamic hue separation.
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
        leading: Hero(
          tag: 'tx_icon_${tx.id}',
          child: Container(
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.yMMMMd().format(tx.date),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _AccountPill(accountId: tx.accountId),
                if (tx.personId != 0) _PersonPill(personId: tx.personId),
              ],
            ),
          ],
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${CurrencyEngine.formatCurrency(tx.amount, selectedCurrency)}',
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

class _AccountPill extends ConsumerWidget {
  final int accountId;
  const _AccountPill({required this.accountId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final theme = Theme.of(context);

    return accountsAsync.when(
      data: (accounts) {
        final account = accounts.where((a) => a.id == accountId).firstOrNull;
        if (account == null) return const SizedBox.shrink();

        final accountColor = account.color.parseHexColor();
        final icon = AppIcons.getIcon(account.icon);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: accountColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: accountColor.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 10,
                color: accountColor,
              ),
              const SizedBox(width: 4),
              Text(
                account.name,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: accountColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _PersonPill extends ConsumerWidget {
  final int personId;
  const _PersonPill({required this.personId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personsAsync = ref.watch(personsStreamProvider);
    final theme = Theme.of(context);

    return personsAsync.when(
      data: (persons) {
        final person = persons.where((p) => p.id == personId).firstOrNull;
        if (person == null) return const SizedBox.shrink();

        final personColor = person.color.parseHexColor();

        return Container(
          padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
          decoration: BoxDecoration(
            color: personColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: personColor.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PersonAvatar(
                person: person,
                radius: 8,
                fontSize: 8,
              ),
              const SizedBox(width: 6),
              Text(
                person.name,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: personColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
