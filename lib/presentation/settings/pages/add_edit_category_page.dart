import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/models/category.dart';
import '../../../core/database/providers.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/widgets/icon_picker.dart';

class AddEditCategoryPage extends ConsumerStatefulWidget {
  final Category? category;
  const AddEditCategoryPage({super.key, this.category});

  @override
  ConsumerState<AddEditCategoryPage> createState() => _AddEditCategoryPageState();
}

class _AddEditCategoryPageState extends ConsumerState<AddEditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _budgetController;
  late CategoryType _type;
  String _selectedColor = '0xFF2196F3';
  String _selectedIcon = 'category';
  bool _isBudget = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _budgetController = TextEditingController(text: widget.category?.budgetLimit?.toString() ?? '');
    _type = widget.category?.type ?? CategoryType.expense;
    _selectedColor = widget.category?.color ?? '0xFF2196F3';
    _selectedIcon = widget.category?.icon ?? 'category';
    _isBudget = widget.category?.isBudget ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final category = Category()
      ..name = _nameController.text
      ..description = ''
      ..icon = _selectedIcon
      ..color = _selectedColor
      ..type = _type
      ..budgetLimit = _isBudget ? (double.tryParse(_budgetController.text) ?? 0.0) : null
      ..isBudget = _isBudget
      ..createdAt = widget.category?.createdAt ?? DateTime.now()
      ..updatedAt = DateTime.now();

    if (widget.category != null) {
      category.id = widget.category!.id;
    }

    await ref.read(categoryServiceProvider).saveCategory(category);
    await HapticService.success();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
        actions: [
          if (widget.category != null)
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
            Center(
              child: SegmentedButton<CategoryType>(
                segments: const [
                  ButtonSegment(value: CategoryType.expense, label: Text('Expense'), icon: Icon(Icons.remove_rounded)),
                  ButtonSegment(value: CategoryType.income, label: Text('Income'), icon: Icon(Icons.add_rounded)),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                prefixIcon: Icon(Icons.label_rounded),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Enable Budget'),
              subtitle: const Text('Set a monthly spending limit'),
              value: _isBudget,
              onChanged: (v) => setState(() => _isBudget = v),
            ),
            if (_isBudget)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextFormField(
                  controller: _budgetController,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Limit',
                    prefixIcon: Icon(Icons.currency_rupee_rounded),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save Category'),
              style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
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
        title: const Text('Delete Category?'),
        content: const Text('This category will be permanently removed. Transactions using this category will lose their link. Proceed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(categoryServiceProvider).deleteCategory(widget.category!.id);
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
