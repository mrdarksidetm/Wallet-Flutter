import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/providers.dart';
import '../../../core/widgets/icon_picker.dart';
import '../../../core/services/haptic_service.dart';

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
                  ? Color(int.parse(
                      item.category.value!.color.replaceAll('0x', ''),
                      radix: 16))
                  : Theme.of(context).colorScheme.primary;
              final isActive = item.isActive;

              return Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.horizontal,
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    await HapticService.selectionStatic();
                    item.isActive = !isActive;
                    item.updatedAt = DateTime.now();
                    await ref.read(recurringRepositoryProvider).save(item);
                    return false;
                  } else {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Recurring?'),
                        content: const Text(
                            'Are you sure you want to delete this recurring transaction?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.error),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                onDismissed: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    await HapticService.heavyStatic();
                    await ref.read(recurringRepositoryProvider).delete(item.id);
                  }
                },
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 24),
                  child: Icon(isActive ? Symbols.cancel : Symbols.check_circle,
                      color: Colors.white),
                ),
                secondaryBackground: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(Symbols.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isActive ? 1 : 0,
                  color: isActive
                      ? null
                      : Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                  child: ListTile(
                    onTap: () => context.push('/add_recurring', extra: item),
                    leading: CircleAvatar(
                      backgroundColor: categoryColor.withValues(
                          alpha: isActive ? 0.1 : 0.05),
                      child: Icon(
                          AppIcons.getIcon(
                              item.category.value?.icon ?? 'repeat'),
                          color: isActive
                              ? categoryColor
                              : categoryColor.withValues(alpha: 0.5)),
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration:
                            isActive ? null : TextDecoration.lineThrough,
                        color: isActive ? null : Colors.grey,
                      ),
                    ),
                    subtitle: Text(
                      'Next: ${DateFormat('MMM d').format(item.nextDate)} • ${item.frequency.name.toUpperCase()}',
                      style: TextStyle(color: isActive ? null : Colors.grey),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormat.format(item.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isActive ? null : Colors.grey,
                          ),
                        ),
                        Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
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
