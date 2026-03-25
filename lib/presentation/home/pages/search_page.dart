import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/widgets/icon_picker.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resultsAsync = ref.watch(searchTransactionsProvider);
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextField(
            autofocus: true,
            onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
            decoration: const InputDecoration(
              hintText: 'Search transactions...',
              prefixIcon: Icon(Icons.search_rounded),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
      body: resultsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            final query = ref.read(searchQueryProvider);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    query.isEmpty ? Icons.manage_search_rounded : Icons.search_off_rounded,
                    size: 64,
                    color: colorScheme.outline.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    query.isEmpty ? 'Type to start searching' : 'No transactions found',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final isExpense = tx.type == TransactionType.expense;
              final iconData = tx.icon != null 
                  ? AppIcons.getIcon(tx.icon) 
                  : (tx.category.value?.icon != null 
                      ? AppIcons.getIcon(tx.category.value?.icon)
                      : (isExpense ? Icons.shopping_bag_outlined : Icons.payments_outlined));
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      iconData,
                      size: 20,
                    ),
                  ),
                  title: Text(tx.note ?? 'Transaction', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('MMM d, yyyy').format(tx.date)),
                  trailing: Text(
                    '${isExpense ? '-' : '+'}${currencyFormat.format(tx.amount)}',
                    style: TextStyle(
                      color: isExpense ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
