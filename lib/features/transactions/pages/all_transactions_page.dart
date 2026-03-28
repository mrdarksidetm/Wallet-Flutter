import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/services/haptic_service.dart';
import 'package:go_router/go_router.dart';

class AllTransactionsPage extends ConsumerStatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  ConsumerState<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends ConsumerState<AllTransactionsPage> {
  bool _ascending = false;

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        actions: [
          IconButton(
            onPressed: () async {
              await HapticService.selectionStatic();
              setState(() {
                _ascending = !_ascending;
              });
            },
            icon: Icon(_ascending ? Symbols.keyboard_double_arrow_up : Symbols.keyboard_double_arrow_down),
            tooltip: _ascending ? 'Oldest to Newest' : 'Newest to Oldest',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(child: Text('No transactions found'));
          }

          final sortedTxs = [...transactions];
          if (_ascending) {
            sortedTxs.sort((a, b) => a.date.compareTo(b.date));
          } else {
            sortedTxs.sort((a, b) => b.date.compareTo(a.date));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: sortedTxs.length,
            itemBuilder: (context, index) {
              final tx = sortedTxs[index];
              final isIncome = tx.type == TransactionType.income;

              return ListTile(
                onTap: () async {
                  await HapticService.selectionStatic();
                  context.push('/add_transaction', extra: tx);
                },
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Symbols.receipt_long, size: 20, color: colorScheme.onSurfaceVariant),
                ),
                title: Text(tx.note ?? 'Transaction', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(DateFormat.yMMMd().add_jm().format(tx.date), 
                  style: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 12)),
                trailing: Text(
                  '${isIncome ? '+' : '-'}${currencyFormat.format(tx.amount)}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: isIncome ? Colors.green : colorScheme.error),
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
}
