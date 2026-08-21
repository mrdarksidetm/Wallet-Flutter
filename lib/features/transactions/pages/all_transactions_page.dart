import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/widgets/transaction_list_tile.dart';

class AllTransactionsPage extends ConsumerStatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  ConsumerState<AllTransactionsPage> createState() =>
      _AllTransactionsPageState();
}

class _AllTransactionsPageState extends ConsumerState<AllTransactionsPage> {
  bool _ascending = false;
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = _showArchived 
        ? ref.watch(archivedTransactionsStreamProvider)
        : ref.watch(allTransactionsStreamProvider);
    
    final sortType = ref.watch(transactionSortProvider);
    final accountsAsync = ref.watch(accountsStreamProvider);
    
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_showArchived ? 'Archived Transactions' : 'All Transactions'),
        actions: [
          IconButton(
            onPressed: () => setState(() => _showArchived = !_showArchived),
            icon: Icon(_showArchived ? Symbols.inbox : Symbols.archive),
            tooltip: _showArchived ? 'Show Active' : 'Show Archived',
          ),
          PopupMenuButton<TransactionSort>(
            icon: const Icon(Symbols.sort),
            tooltip: 'Sort Transactions',
            onSelected: (value) {
              ref.read(transactionSortProvider.notifier).state = value;
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: TransactionSort.date,
                child: Row(
                  children: [
                    Icon(Symbols.calendar_month, color: sortType == TransactionSort.date ? colorScheme.primary : null),
                    const SizedBox(width: 8),
                    const Text('Date'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TransactionSort.account,
                child: Row(
                  children: [
                    Icon(Symbols.account_balance_wallet, color: sortType == TransactionSort.account ? colorScheme.primary : null),
                    const SizedBox(width: 8),
                    const Text('Account'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => setState(() => _ascending = !_ascending),
            icon: Icon(_ascending ? Symbols.arrow_upward : Symbols.arrow_downward),
            tooltip: 'Toggle Order',
          ),
        ],
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Symbols.receipt_long, size: 64, color: colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('No transactions found', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            );
          }

          final sortedTxs = [...transactions];
          
          if (sortType == TransactionSort.date) {
            sortedTxs.sort((a, b) => _ascending 
                ? a.date.compareTo(b.date) 
                : b.date.compareTo(a.date));
          } else if (sortType == TransactionSort.account) {
            // Sort by Account basis with date & time sorting
            accountsAsync.whenData((accounts) {
              sortedTxs.sort((a, b) {
                final accA = accounts.where((acc) => acc.id == a.accountId).firstOrNull;
                final accB = accounts.where((acc) => acc.id == b.accountId).firstOrNull;
                
                final nameA = accA?.name ?? '';
                final nameB = accB?.name ?? '';
                
                final accountCompare = _ascending ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
                
                if (accountCompare != 0) return accountCompare;
                
                // Secondary sort by date
                return b.date.compareTo(a.date); // Always show newest first within same account? 
                // Or follow _ascending for date too? 
                // User said "via Account basis with date & time sorting". 
                // Usually this means newest first.
              });
            });
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: sortedTxs.length,
            itemBuilder: (context, index) {
              final tx = sortedTxs[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Dismissible(
                  key: ValueKey('tx-${tx.id}-${tx.updatedAt.millisecondsSinceEpoch}'),
                  secondaryBackground: _buildArchiveBackground(context),
                  background: _buildDeleteBackground(context),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      return await _confirmDelete(context, tx);
                    } else {
                      await _handleArchive(tx);
                      return false; // Don't remove from list manually, stream will handle it
                    }
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.startToEnd) {
                      _handleDelete(tx);
                    }
                  },
                  child: TransactionListTile(
                    tx: tx,
                    onTap: () => context.push('/add_transaction', extra: tx),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildDeleteBackground(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Symbols.delete_forever, color: colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          Text('Delete', style: TextStyle(color: colorScheme.onErrorContainer, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildArchiveBackground(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(_showArchived ? 'Unarchive' : 'Archive', 
              style: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Icon(_showArchived ? Symbols.unarchive : Symbols.archive, color: colorScheme.onPrimaryContainer),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, TransactionModel tx) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text('This will permanently delete this transaction and update your balance.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
}
