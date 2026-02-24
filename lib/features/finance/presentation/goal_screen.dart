import 'package:flutter/material.dart';
import 'package:wallet/core/theme/color_extension.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../shared/widgets/paisa_list_tile.dart';
import '../../../shared/widgets/app_button.dart';

class GoalScreen extends ConsumerWidget {
  const GoalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: goalsAsync.when(
        data: (goals) => ListView.builder(
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            return PaisaListTile(
              title: goal.name,
              subtitle: 'Progress: ${(goal.currentAmount / goal.targetAmount * 100).toStringAsFixed(0)}%',
              amount: '\$${goal.currentAmount} / \$${goal.targetAmount}',
              amountColor: Theme.of(context).colorScheme.primary,
              icon: Icons.flag,
              iconColor: Colors.white,
              iconBackgroundColor: (goal.color).parseHexColor(),
              onTap: () {
                // Simple dialog to update amount
                _showUpdateDialog(context, ref, goal);
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, WidgetRef ref, Goal goal) {
     final controller = TextEditingController(text: goal.currentAmount.toString());
     showDialog(
       context: context,
       builder: (_) => AlertDialog(
         title: const Text('Update Progress'),
         content: TextField(controller: controller, keyboardType: TextInputType.number),
         actions: [
           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
           AppButton(
             onPressed: () async {
               final val = double.tryParse(controller.text) ?? 0.0;
               await ref.read(goalServiceProvider).updateAmount(goal, val);
               if (context.mounted) Navigator.pop(context);
             },
             child: const Text('Save'),
           )
         ],
       ),
     );
  }

  void _showAddGoalDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (_) => const AddGoalDialog());
  }
}

class AddGoalDialog extends ConsumerStatefulWidget {
  const AddGoalDialog({super.key});

  @override
  ConsumerState<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends ConsumerState<AddGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _target = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Goal'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(decoration: const InputDecoration(labelText: 'Goal Name'), onSaved: (val) => _name = val!),
            TextFormField(decoration: const InputDecoration(labelText: 'Target Amount'), keyboardType: TextInputType.number, onSaved: (val) => _target = double.parse(val!)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        AppButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              await ref.read(goalServiceProvider).addGoal(
                name: _name,
                targetAmount: _target,
                deadline: DateTime.now().add(const Duration(days: 365)), // Default 1 year
                color: '0xFF2196F3',
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
