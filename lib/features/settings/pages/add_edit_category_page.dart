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
      category.uuid = widget.category!.uuid;
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
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Symbols.arrow_back_rounded),
        ),
        title: Text(
          widget.category == null ? 'Add Category' : 'Edit Category',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (widget.category != null)
            IconButton(
              onPressed: _showDeleteDialog,
              icon: Icon(Symbols.delete_rounded, color: colorScheme.error),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Category Icon and Color Selector
            Center(
              child: Stack(
                children: [
                  InkWell(
                    onTap: _showIconPicker,
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: currentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: currentColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          AppIcons.getIcon(_selectedIcon),
                          size: 52,
                          color: currentColor,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _showColorPicker,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Symbols.palette_rounded,
                          size: 20,
                          color: currentColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Segmented Type Selector (Expense vs Income)
            Center(
              child: SegmentedButton<CategoryType>(
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: colorScheme.primaryContainer,
                  selectedForegroundColor: colorScheme.onPrimaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                segments: const [
                  ButtonSegment(
                    value: CategoryType.expense,
                    label: Text('Expense', style: TextStyle(fontWeight: FontWeight.w600)),
                    icon: Icon(Symbols.trending_down_rounded),
                  ),
                  ButtonSegment(
                    value: CategoryType.income,
                    label: Text('Income', style: TextStyle(fontWeight: FontWeight.w600)),
                    icon: Icon(Symbols.trending_up_rounded),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) {
                  setState(() => _type = s.first);
                },
              ),
            ),
            const SizedBox(height: 28),

            // Category Details Segmented Card
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      hintText: 'e.g. Groceries, Salary, Coffee',
                      prefixIcon: const Icon(Symbols.label_rounded),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) => v?.trim().isEmpty ?? true ? 'Category name is required' : null,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Symbols.savings_rounded,
                          size: 22,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly Budget',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Set a spending limit for this category',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isBudget,
                        onChanged: (v) {
                          setState(() => _isBudget = v);
                        },
                      ),
                    ],
                  ),
                  if (_isBudget) ...[
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _budgetController,
                      decoration: InputDecoration(
                        labelText: 'Budget Limit',
                        hintText: '0.00',
                        prefixIcon: const Icon(Symbols.payments_rounded),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),

            PrimaryAtelierButton(
              onPressed: _save,
              icon: const Icon(Symbols.check_rounded, color: Colors.white),
              label: const Text(
                'Save Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
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
