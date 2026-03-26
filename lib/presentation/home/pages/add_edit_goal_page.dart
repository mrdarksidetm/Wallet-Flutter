import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../core/database/providers.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/widgets/icon_picker.dart';
import '../../../core/widgets/primary_atelier_button.dart';

class AddEditGoalPage extends ConsumerStatefulWidget {
  final Goal? goal;
  const AddEditGoalPage({super.key, this.goal});

  @override
  ConsumerState<AddEditGoalPage> createState() => _AddEditGoalPageState();
}

class _AddEditGoalPageState extends ConsumerState<AddEditGoalPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _targetController;
  late TextEditingController _currentController;
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  String _selectedColor = '0xFF4CAF50';
  String _selectedIcon = 'savings';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal?.name ?? '');
    _targetController = TextEditingController(text: widget.goal?.targetAmount.toString() ?? '');
    _currentController = TextEditingController(text: widget.goal?.currentAmount.toString() ?? '0');
    _deadline = widget.goal?.deadline ?? DateTime.now().add(const Duration(days: 30));
    _selectedColor = widget.goal?.color ?? '0xFF4CAF50';
    _selectedIcon = widget.goal?.icon ?? 'savings';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final goal = Goal()
      ..name = _nameController.text
      ..targetAmount = double.tryParse(_targetController.text) ?? 0.0
      ..currentAmount = double.tryParse(_currentController.text) ?? 0.0
      ..deadline = _deadline
      ..color = _selectedColor
      ..icon = _selectedIcon
      ..createdAt = widget.goal?.createdAt ?? DateTime.now()
      ..updatedAt = DateTime.now();

    if (widget.goal != null) {
      goal.id = widget.goal!.id;
    }

    await ref.read(goalServiceProvider).saveGoal(goal);
    await HapticService.success();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal == null ? 'Add Goal' : 'Edit Goal'),
        actions: [
          if (widget.goal != null)
            IconButton(
              onPressed: _showDeleteDialog,
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => IconPickerWidget(
                      selectedIcon: _selectedIcon,
                      selectedColor: Color(int.parse(_selectedColor.replaceAll('0x', ''), radix: 16)),
                      onIconSelected: (icon) {
                        setState(() => _selectedIcon = icon);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Color(int.parse(_selectedColor.replaceAll('0x', ''), radix: 16)).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.getIcon(_selectedIcon),
                    size: 40,
                    color: Color(int.parse(_selectedColor.replaceAll('0x', ''), radix: 16)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Goal Name (e.g. New Car, Vacation)',
                prefixIcon: Icon(Icons.flag_rounded),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetController,
              decoration: const InputDecoration(
                labelText: 'Target Amount',
                prefixIcon: Icon(Icons.ads_click_rounded),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _currentController,
              decoration: const InputDecoration(
                labelText: 'Already Saved',
                prefixIcon: Icon(Icons.savings_rounded),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ListTile(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _deadline,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _deadline = date);
              },
              leading: const Icon(Icons.event_rounded),
              title: const Text('Deadline'),
              subtitle: Text(DateFormat('MMM d, yyyy').format(_deadline)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
            ),
            const SizedBox(height: 48),
            PrimaryAtelierButton(
              onPressed: _save,
              icon: const Icon(Symbols.save, color: Colors.white),
              label: const Text(
                'Save Goal',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal?'),
        content: const Text('This savings goal will be permanently removed. Proceed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(goalServiceProvider).deleteGoal(widget.goal!.id);
              await HapticService.error();
              if (mounted) {
                Navigator.pop(context); // Pop dialog
                context.pop(); // Pop page
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
