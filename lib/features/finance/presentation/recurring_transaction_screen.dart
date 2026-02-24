import 'package:flutter/material.dart';
import 'package:wallet/core/theme/color_extension.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../shared/widgets/paisa_list_tile.dart';

class RecurringTransactionScreen extends ConsumerWidget {
  const RecurringTransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This is a simplified view. Ideally, we need a way to Create a Recurring Transaction template.
    // For now, let's just list them and verify they exist.
    // Adding recurring transactions is complex (requires setting frequency, etc).
    // I'll add a simple placeholder list.
    final isar = ref.watch(isarProvider).value;
    
    if (isar == null) return const Center(child: CircularProgressIndicator());
    
    return Scaffold(
      appBar: AppBar(title: const Text('Recurring Transactions')),
      body: StreamBuilder<List<Recurring>>(
        stream: isar.recurrings.where().watch(fireImmediately: true),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          
          if (items.isEmpty) {
             return const Center(child: Text('No recurring transactions set up.'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final tx = item.transaction.value;
              return PaisaListTile(
                title: tx?.category.value?.name ?? 'Unknown',
                subtitle: '${item.frequency.name} • Next: ${item.nextDate.toString().split(' ')[0]}',
                icon: Icons.repeat,
                iconColor: Colors.white,
                iconBackgroundColor: (tx?.category.value?.color ?? '0xFF9E9E9E').parseHexColor(),
                trailing: Switch(
                  value: item.isActive,
                  onChanged: (val) {
                    isar.writeTxnSync(() {
                      item.isActive = val;
                      isar.recurrings.putSync(item);
                    });
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add transaction screen with recurring mode?
          // For simplicity, just show a dialog saying "This feature is coming soon" or simple add
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('To add, create transaction and select "Recurring" (Not implemented in Add Screen yet)')));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
