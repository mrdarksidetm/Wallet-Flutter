import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../database/models/transaction_model.dart';
import '../database/providers.dart';
import '../services/currency_engine.dart';
import '../theme/colors.dart';
import 'transaction_list_tile.dart';

/// Formats a DateTime into a friendly date header label (Today, Yesterday, etc.)
String formatTransactionGroupDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final dateOnly = DateTime(date.year, date.month, date.day);

  if (dateOnly == today) {
    return 'Today';
  } else if (dateOnly == yesterday) {
    return 'Yesterday';
  } else if (dateOnly.year == now.year) {
    return DateFormat('EEEE, MMM d').format(date);
  } else {
    return DateFormat('MMMM d, yyyy').format(date);
  }
}

/// A segmented squircle card container for a group of transactions.
class TransactionSegmentedCard extends StatelessWidget {
  final List<TransactionModel> transactions;
  final void Function(TransactionModel)? onTap;
  final bool enableDismiss;
  final Future<bool> Function(TransactionModel)? onConfirmDelete;
  final void Function(TransactionModel)? onDelete;
  final void Function(TransactionModel)? onArchive;
  final bool isArchivedView;

  const TransactionSegmentedCard({
    super.key,
    required this.transactions,
    this.onTap,
    this.enableDismiss = false,
    this.onConfirmDelete,
    this.onDelete,
    this.onArchive,
    this.isArchivedView = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainer
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              colorScheme.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.4),
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(transactions.length, (index) {
          final tx = transactions[index];
          final isLast = index == transactions.length - 1;

          final tile = TransactionListTile(
            tx: tx,
            isGrouped: true,
            showDivider: !isLast,
            onTap: () {
              if (onTap != null) {
                onTap!(tx);
              } else {
                context.push('/add_transaction', extra: tx);
              }
            },
          );

          if (!enableDismiss) {
            return tile;
          }

          return Dismissible(
            key: ValueKey('tx-${tx.id}-${tx.updatedAt.millisecondsSinceEpoch}'),
            secondaryBackground: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: colorScheme.primaryContainer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    isArchivedView ? 'Unarchive' : 'Archive',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isArchivedView ? Symbols.unarchive : Symbols.archive,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),
            background: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: colorScheme.errorContainer,
              child: Row(
                children: [
                  Icon(Symbols.delete_forever,
                      color: colorScheme.onErrorContainer),
                  const SizedBox(width: 8),
                  Text(
                    'Delete',
                    style: TextStyle(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                if (onConfirmDelete != null) {
                  return await onConfirmDelete!(tx);
                }
                return true;
              } else {
                if (onArchive != null) {
                  onArchive!(tx);
                }
                return false;
              }
            },
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd && onDelete != null) {
                onDelete!(tx);
              }
            },
            child: tile,
          );
        }),
      ),
    );
  }
}

/// A widget that groups a list of transactions by day into segmented group cards.
class TransactionGroupedList extends ConsumerWidget {
  final List<TransactionModel> transactions;
  final void Function(TransactionModel)? onTap;
  final bool enableDismiss;
  final Future<bool> Function(TransactionModel)? onConfirmDelete;
  final void Function(TransactionModel)? onDelete;
  final void Function(TransactionModel)? onArchive;
  final bool isArchivedView;

  const TransactionGroupedList({
    super.key,
    required this.transactions,
    this.onTap,
    this.enableDismiss = false,
    this.onConfirmDelete,
    this.onDelete,
    this.onArchive,
    this.isArchivedView = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedCurrency = ref.watch(currencyProvider);

    // Group transactions by Date key (year, month, day)
    final Map<DateTime, List<TransactionModel>> grouped = {};
    for (var tx in transactions) {
      final dateKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }

    final sortedDates = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedDates.map((date) {
        final dayTxs = grouped[date]!;
        
        // Calculate daily net total
        double dayTotal = 0;
        for (var tx in dayTxs) {
          if (tx.type == TransactionType.income) {
            dayTotal += tx.amount;
          } else if (tx.type == TransactionType.expense) {
            dayTotal -= tx.amount;
          }
        }

        final isPositive = dayTotal > 0;
        final isNegative = dayTotal < 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatTransactionGroupDate(date),
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (dayTotal != 0)
                      Text(
                        '${isPositive ? '+' : (isNegative ? '-' : '')}${CurrencyEngine.formatCurrency(dayTotal.abs(), selectedCurrency)}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: isPositive
                              ? AppColors.income
                              : (isNegative ? AppColors.expense : colorScheme.onSurfaceVariant),
                        ),
                      ),
                  ],
                ),
              ),
              TransactionSegmentedCard(
                transactions: dayTxs,
                onTap: onTap,
                enableDismiss: enableDismiss,
                onConfirmDelete: onConfirmDelete,
                onDelete: onDelete,
                onArchive: onArchive,
                isArchivedView: isArchivedView,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Sliver version of [TransactionGroupedList] for CustomScrollView.
class SliverTransactionGroupedList extends ConsumerWidget {
  final List<TransactionModel> transactions;
  final void Function(TransactionModel)? onTap;
  final bool enableDismiss;
  final Future<bool> Function(TransactionModel)? onConfirmDelete;
  final void Function(TransactionModel)? onDelete;
  final void Function(TransactionModel)? onArchive;
  final bool isArchivedView;

  const SliverTransactionGroupedList({
    super.key,
    required this.transactions,
    this.onTap,
    this.enableDismiss = false,
    this.onConfirmDelete,
    this.onDelete,
    this.onArchive,
    this.isArchivedView = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedCurrency = ref.watch(currencyProvider);

    // Group transactions by Date key (year, month, day)
    final Map<DateTime, List<TransactionModel>> grouped = {};
    for (var tx in transactions) {
      final dateKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }

    final sortedDates = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return SliverList.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dayTxs = grouped[date]!;

        double dayTotal = 0;
        for (var tx in dayTxs) {
          if (tx.type == TransactionType.income) {
            dayTotal += tx.amount;
          } else if (tx.type == TransactionType.expense) {
            dayTotal -= tx.amount;
          }
        }

        final isPositive = dayTotal > 0;
        final isNegative = dayTotal < 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatTransactionGroupDate(date),
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (dayTotal != 0)
                      Text(
                        '${isPositive ? '+' : (isNegative ? '-' : '')}${CurrencyEngine.formatCurrency(dayTotal.abs(), selectedCurrency)}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: isPositive
                              ? AppColors.income
                              : (isNegative ? AppColors.expense : colorScheme.onSurfaceVariant),
                        ),
                      ),
                  ],
                ),
              ),
              TransactionSegmentedCard(
                transactions: dayTxs,
                onTap: onTap,
                enableDismiss: enableDismiss,
                onConfirmDelete: onConfirmDelete,
                onDelete: onDelete,
                onArchive: onArchive,
                isArchivedView: isArchivedView,
              ),
            ],
          ),
        );
      },
    );
  }
}
