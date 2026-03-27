import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/database/providers.dart';
import '../../../core/widgets/icon_picker.dart';

class RecurringPage extends ConsumerWidget {
  const RecurringPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringAsync = ref.watch(recurringsStreamProvider);
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring & Subscriptions'),
      ),
      body: recurringAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No recurring transactions found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final categoryColor = item.category.value?.color != null 
                  ? Color(int.parse(item.category.value!.color.replaceAll('0x', ''), radix: 16))
                  : Theme.of(context).colorScheme.primary;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () => context.push('/add_recurring', extra: item),
                  leading: CircleAvatar(
                    backgroundColor: categoryColor.withOpacity(0.1),
                    child: Icon(
                      AppIcons.getIcon(item.category.value?.icon ?? 'repeat'), 
                      color: categoryColor
                    ),
                  ),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Next: ${DateFormat('MMM d').format(item.nextDate)} • ${item.frequency.name.toUpperCase()}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(item.amount),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        item.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          color: item.isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
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
