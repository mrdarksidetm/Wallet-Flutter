import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../../../core/database/models/category.dart';
import '../../../core/database/providers.dart';
import '../../../core/theme/color_extension.dart';
import '../../../core/widgets/icon_picker.dart';
import '../../../core/widgets/primary_atelier_button.dart';

class AddEditCategoryPage extends ConsumerStatefulWidget {
  final Category? category;
  const AddEditCategoryPage({super.key, this.category});

  @override
  ConsumerState<AddEditCategoryPage> createState() =>
      _AddEditCategoryPageState();
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
    _budgetController = TextEditingController(
        text: widget.category?.budgetLimit?.toString() ?? '');
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
      ..budgetLimit =
          _isBudget ? (double.tryParse(_budgetController.text) ?? 0.0) : null
      ..isBudget = _isBudget
      ..createdAt = widget.category?.createdAt ?? DateTime.now()
      ..updatedAt = DateTime.now();

    if (widget.category != null) {
      category.id = widget.category!.id;
    }

    await ref.read(categoryServiceProvider).saveCategory(category);
    
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Color currentColor = _selectedColor.parseHexColor();

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
              child: Stack(
                children: [
                  InkWell(
                    onTap: _showIconPicker,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: currentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: currentColor.withValues(alpha: 0.2),
                            width: 2),
                      ),
                      child: Icon(
                        AppIcons.getIcon(_selectedIcon),
                        size: 48,
                        color: currentColor,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _showColorPicker,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8),
                          ],
                        ),
                        child: Icon(Icons.palette_rounded,
                            size: 20, color: currentColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: SegmentedButton<CategoryType>(
                segments: const [
                  ButtonSegment(
                      value: CategoryType.expense,
                      label: Text('Expense'),
                      icon: Icon(Icons.remove_rounded)),
                  ButtonSegment(
                      value: CategoryType.income,
                      label: Text('Income'),
                      icon: Icon(Icons.add_rounded)),
                ],
                selected: {_type},
                onSelectionChanged: (s) {
                  
                  setState(() => _type = s.first);
                },
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
              onChanged: (v) {
                
                setState(() => _isBudget = v);
              },
            ),
            if (_isBudget)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextFormField(
                  controller: _budgetController,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Limit',
                    prefixIcon: Icon(Symbols.payments),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            const SizedBox(height: 48),
            PrimaryAtelierButton(
              onPressed: _save,
              icon: const Icon(Symbols.save, color: Colors.white),
              label: const Text(
                'Save Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => IconPickerWidget(
        selectedIcon: _selectedIcon,
        selectedColor: _selectedColor.parseHexColor(),
        onIconSelected: (icon) {
          setState(() => _selectedIcon = icon);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _showColorPicker() async {
    final Color colorBefore = _selectedColor.parseHexColor();
    final Color newColor = await showColorPickerDialog(
      context,
      colorBefore,
      title: Text('Select Category Color',
          style: Theme.of(context).textTheme.titleLarge),
      width: 40,
      height: 40,
      spacing: 0,
      runSpacing: 0,
      borderRadius: 0,
      wheelDiameter: 165,
      enableOpacity: false,
      showColorCode: true,
      colorCodeHasColor: true,
      pickersEnabled: <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
    );
    setState(() {
      _selectedColor =
          '0x${newColor.toARGB32().toRadixString(16).toUpperCase()}';
    });
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: const Text(
            'This category will be permanently removed. Transactions using this category will lose their link. Proceed?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref
                  .read(categoryServiceProvider)
                  .deleteCategory(widget.category!.id);
              
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
