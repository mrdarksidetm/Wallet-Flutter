import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:wallet/core/theme/color_extension.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/category.dart';
import '../../../shared/widgets/paisa_list_tile.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/material_icon_picker.dart';

// Helper to reliably convert the IconData string representation back into an IconData object
IconData getIconDataFromString(String iconString) {
  // Simple heuristic for our custom generic storage format:
  // Usually looks like "IconData(U+0E14B)" or just "U+0E14B"
  try {
    if (iconString.startsWith('U+')) {
      final codePoint = int.parse(iconString.substring(2), radix: 16);
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    }
    // Fallback if we accidentally saved the name 'category' early on
    return Icons.category;
  } catch (e) {
    return Icons.category;
  }
}

String getStringFromIconData(IconData icon) {
  return 'U+${icon.codePoint.toRadixString(16).toUpperCase()}';
}

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) return const Center(child: Text('No categories found.'));
          
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final color = (cat.color).parseHexColor();
              
              return PaisaListTile(
                title: cat.name,
                subtitle: cat.type.name.toUpperCase(),
                icon: getIconDataFromString(cat.icon),
                iconColor: Colors.white,
                iconBackgroundColor: color,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => ref.read(categoryServiceProvider).deleteCategory(cat.id),
                ),
                onTap: () => _showAddEditCategoryDialog(context, ref, cat),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditCategoryDialog(context, ref, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEditCategoryDialog(BuildContext context, WidgetRef ref, Category? category) {
    showDialog(
      context: context,
      builder: (_) => AddEditCategoryDialog(category: category),
    );
  }
}

class AddEditCategoryDialog extends ConsumerStatefulWidget {
  final Category? category;
  const AddEditCategoryDialog({super.key, this.category});

  @override
  ConsumerState<AddEditCategoryDialog> createState() => _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends ConsumerState<AddEditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late Color _color;
  late CategoryType _type;
  late IconData _icon;

  @override
  void initState() {
    super.initState();
    _name = widget.category?.name ?? '';
    _color = widget.category != null ? (widget.category!.color).parseHexColor() : Colors.blue;
    _type = widget.category?.type ?? CategoryType.expense;
    _icon = widget.category != null ? getIconDataFromString(widget.category!.icon) : Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null ? 'New Category' : 'Edit Category'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => _name = val!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<CategoryType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: CategoryType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
                onChanged: (val) => setState(() => _type = val!),
              ),
              const SizedBox(height: 24),
              ListTile(
                title: const Text('Color'),
                trailing: ColorIndicator(
                  width: 32,
                  height: 32,
                  borderRadius: 16,
                  color: _color,
                  onSelectFocus: false,
                  onSelect: () async {
                    final Color newColor = await showColorPickerDialog(
                      context,
                      _color,
                      title: Text('Select Color', style: Theme.of(context).textTheme.titleLarge),
                      pickersEnabled: const <ColorPickerType, bool>{ColorPickerType.wheel: true},
                    );
                    setState(() => _color = newColor);
                  },
                ),
              ),
              ListTile(
                title: const Text('Icon'),
                trailing: Icon(_icon),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: MaterialIconPicker(
                        initialIcon: _icon,
                        onIconSelected: (icon) {
                          setState(() => _icon = icon);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        AppButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              
              final colorString = '0x${_color.value.toRadixString(16).padLeft(8, '0')}';
              
              if (widget.category == null) {
                await ref.read(categoryServiceProvider).addCategory(
                  name: _name,
                  icon: getStringFromIconData(_icon),
                  color: colorString,
                  type: _type,
                );
              } else {
                final upd = Category()
                  ..id = widget.category!.id
                  ..name = _name
                  ..icon = getStringFromIconData(_icon)
                  ..color = colorString
                  ..type = _type
                  ..budgetLimit = widget.category!.budgetLimit;
                await ref.read(categoryServiceProvider).updateCategory(widget.category!, upd);
              }
              if (mounted) Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
