import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/widgets/transaction_segmented_group.dart';
import '../../../core/widgets/app_back_button.dart';

class AllTransactionsPage extends ConsumerStatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  ConsumerState<AllTransactionsPage> createState() =>
      _AllTransactionsPageState();
}

class _AllTransactionsPageState extends ConsumerState<AllTransactionsPage> {
  bool _ascending = false;
  bool _showArchived = false;
  TransactionType? _typeFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactionsAsync = _showArchived
        ? ref.watch(archivedTransactionsStreamProvider)
        : ref.watch(allTransactionsStreamProvider);

    final sortType = ref.watch(transactionSortProvider);
    final accountsAsync = ref.watch(accountsStreamProvider);

    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            leading: const AppBackButton(),
            title: Text(
              _showArchived ? 'Archived' : 'Transactions',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: (theme.textTheme.headlineLarge?.fontSize ?? 32) + 3,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildPill(
                      context: context,
                      icon: Symbols.calendar_month_rounded,
                      label: 'Date',
                      isSelected: sortType == TransactionSort.date,
                      onTap: () {
                        ref.read(transactionSortProvider.notifier).state =
                            TransactionSort.date;
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildPill(
                      context: context,
                      icon: Symbols.account_balance_wallet_rounded,
                      label: 'Account',
                      isSelected: sortType == TransactionSort.account,
                      onTap: () {
                        ref.read(transactionSortProvider.notifier).state =
                            TransactionSort.account;
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildPill(
                      context: context,
                      icon: _ascending
                          ? Symbols.arrow_upward_rounded
                          : Symbols.arrow_downward_rounded,
                      label: _ascending ? 'Oldest' : 'Newest',
                      isSelected: _ascending,
                      onTap: () => setState(() => _ascending = !_ascending),
                    ),
                    const SizedBox(width: 8),
                    _buildPill(
                      context: context,
                      icon: _typeFilter == null
                          ? Symbols.filter_list_rounded
                          : _typeFilter == TransactionType.income
                              ? Symbols.arrow_downward_rounded
                              : _typeFilter == TransactionType.expense
                                  ? Symbols.arrow_upward_rounded
                                  : Symbols.sync_alt_rounded,
                      label: _typeFilter == null
                          ? 'All Types'
                          : _typeFilter!.name.toUpperCase(),
                      isSelected: _typeFilter != null,
                      onTap: () {
                        setState(() {
                          if (_typeFilter == null) {
                            _typeFilter = TransactionType.expense;
                          } else if (_typeFilter == TransactionType.expense) {
                            _typeFilter = TransactionType.income;
                          } else if (_typeFilter == TransactionType.income) {
                            _typeFilter = TransactionType.transfer;
                          } else {
                            _typeFilter = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildPill(
                      context: context,
                      icon: _showArchived
                          ? Symbols.archive_rounded
                          : Symbols.inbox_rounded,
                      label: _showArchived ? 'Archived' : 'Active',
                      isSelected: _showArchived,
                      onTap: () =>
                          setState(() => _showArchived = !_showArchived),
                    ),
                  ],
                ),
              ),
            ),
          ),
          transactionsAsync.when(
            data: (transactions) {
              var filteredTxs = transactions;
              if (_typeFilter != null) {
                filteredTxs =
                    filteredTxs.where((t) => t.type == _typeFilter).toList();
              }

              if (filteredTxs.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Symbols.receipt_long,
                            size: 64, color: colorScheme.outline),
                        const SizedBox(height: 16),
                        Text('No transactions found',
                            style: theme.textTheme.titleMedium),
                      ],
                    ),
                  ),
                );
              }

              final sortedTxs = [...filteredTxs];

              if (sortType == TransactionSort.date) {
                sortedTxs.sort((a, b) => _ascending
                    ? a.date.compareTo(b.date)
                    : b.date.compareTo(a.date));
              } else if (sortType == TransactionSort.account) {
                accountsAsync.whenData((accounts) {
                  sortedTxs.sort((a, b) {
                    final accA = accounts
                        .where((acc) => acc.id == a.accountId)
                        .firstOrNull;
                    final accB = accounts
                        .where((acc) => acc.id == b.accountId)
                        .firstOrNull;

                    final nameA = accA?.name ?? '';
                    final nameB = accB?.name ?? '';

                    final accountCompare = _ascending
                        ? nameA.compareTo(nameB)
                        : nameB.compareTo(nameA);

                    if (accountCompare != 0) return accountCompare;

                    return b.date.compareTo(a.date);
                  });
                });
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverTransactionGroupedList(
                  transactions: sortedTxs,
                  enableDismiss: true,
                  isArchivedView: _showArchived,
                  onTap: (tx) => context.push('/add_transaction', extra: tx),
                  onConfirmDelete: (tx) => _confirmDelete(context, tx),
                  onDelete: (tx) => _handleDelete(tx),
                  onArchive: (tx) => _handleArchive(tx),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, TransactionModel tx) async {
    final colorScheme = Theme.of(context).colorScheme;
    return await showDialog<bool>(
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
    ) ?? false;
  }

  Future<void> _handleDelete(TransactionModel tx) async {
    await ref.read(transactionServiceProvider).deleteTransaction(tx);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction deleted')),
      );
    }
  }

  Future<void> _handleArchive(TransactionModel tx) async {
    final repo = ref.read(transactionRepositoryProvider);
    if (_showArchived) {
      await repo.unarchive(tx.id);
    } else {
      await repo.archive(tx.id);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text( _showArchived ? 'Transaction unarchived' : 'Transaction archived')),
      );
    }
  }

  Widget _buildPill({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Material(
      color: isSelected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.4)
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
