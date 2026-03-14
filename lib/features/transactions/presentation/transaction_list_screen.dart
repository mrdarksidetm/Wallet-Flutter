import 'package:flutter/material.dart';
import 'package:wallet/core/theme/color_extension.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../search/presentation/search_screen.dart';
import '../../../shared/widgets/paisa_list_tile.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/staggered_animated_list.dart';
import 'add_edit_transaction_screen.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final themeState = ref.watch(themeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
        ],
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(child: Text('No transactions yet.'));
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 120.0),
            child: StaggeredAnimatedList(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final account = tx.account.value;
                final category = tx.category.value;

                return PaisaListTile(
                  title: category?.name ?? 'Unknown',
                  subtitle: '${account?.name ?? 'Unknown'} • ${DateFormat.yMMMd().format(tx.date)}',
                  amount: '${tx.type == TransactionType.expense ? '-' : '+'}${themeState.currencySymbol}${tx.amount.toStringAsFixed(2)}',
                  amountColor: tx.type == TransactionType.expense ? Colors.red : Colors.green,
                  icon: Icons.category, // Replace with dynamic icon if available in Category model
                  iconColor: Colors.white,
                  iconBackgroundColor: (category?.color ?? '0xFF9E9E9E').parseHexColor(),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      ref.read(transactionServiceProvider).deleteTransaction(tx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction deleted')));
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditTransactionScreen(transaction: tx),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_add',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
