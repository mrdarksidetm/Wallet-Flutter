import 'package:flutter/material.dart';
import 'package:wallet/core/theme/color_extension.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../core/database/models/category.dart';
import '../../../shared/widgets/paisa_list_tile.dart';
import '../../../shared/widgets/app_button.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: budgetsAsync.when(
        data: (budgets) {
          if (budgets.isEmpty) {
            return const Center(child: Text('No budgets set.'));
          }
          return ListView.builder(
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return PaisaListTile(
                title: budget.category.value?.name ?? 'Unknown Category',
                subtitle: budget.period.name,
                amount: '\$${budget.amount}',
                amountColor: Theme.of(context).colorScheme.primary,
                icon: Icons.account_balance_wallet,
                iconColor: Colors.white,
                iconBackgroundColor: (budget.category.value?.color ?? '0xFF9E9E9E').parseHexColor(),
                trailing: IconButton(
                   icon: const Icon(Icons.delete_outline, color: Colors.red),
                   onPressed: () {
                     ref.read(budgetServiceProvider).deleteBudget(budget.id);
                   },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const AddBudgetDialog(),
    );
  }
}

class AddBudgetDialog extends ConsumerStatefulWidget {
  const AddBudgetDialog({super.key});

  @override
  ConsumerState<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends ConsumerState<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  double _amount = 0;
  Category? _selectedCategory;
  BudgetPeriod _period = BudgetPeriod.monthly; // Default

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return AlertDialog(
      title: const Text('New Budget'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             TextFormField(
               decoration: const InputDecoration(labelText: 'Amount'),
               keyboardType: TextInputType.number,
               onSaved: (val) => _amount = double.parse(val!),
             ),
             categoriesAsync.when(
               data: (categories) => DropdownButtonFormField<Category>(
                 decoration: const InputDecoration(labelText: 'Category'),
                 items: categories.where((c) => c.type == CategoryType.expense).map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                 onChanged: (val) => _selectedCategory = val,
               ),
               loading: () => const LinearProgressIndicator(),
               error: (_,__) => const Text('Error'),
             ),
             DropdownButtonFormField<BudgetPeriod>(
               value: _period,
               decoration: const InputDecoration(labelText: 'Period'),
               items: BudgetPeriod.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
               onChanged: (val) => setState(() => _period = val!),
             ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        AppButton(
          onPressed: () async {
            if (_formKey.currentState!.validate() && _selectedCategory != null) {
              _formKey.currentState!.save();
              await ref.read(budgetServiceProvider).addBudget(
                amount: _amount,
                category: _selectedCategory!,
                period: _period,
                startDate: DateTime.now(), // Simplified
                endDate: DateTime.now().add(const Duration(days: 30)), // Simplified
              );
              if (mounted) Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
