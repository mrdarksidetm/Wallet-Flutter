import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:wallet/core/theme/color_extension.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/category.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/material_icon_picker.dart';

// Helper to reliably convert the IconData string representation back into an IconData object
IconData getIconDataFromString(String iconString) {
  try {
    if (iconString.startsWith('U+')) {
      final codePoint = int.parse(iconString.substring(2), radix: 16);
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    }
    return Icons.category;
  } catch (e) {
    return Icons.category;
  }
}

String getStringFromIconData(IconData icon) {
  return 'U+${icon.codePoint.toRadixString(16).toUpperCase()}';
}

class AddEditCategoryScreen extends ConsumerStatefulWidget {
  final Category? category;
  const AddEditCategoryScreen({super.key, this.category});

  @override
  ConsumerState<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends ConsumerState<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late Color _color;
  late IconData _icon;
  CategoryType _selectedType = CategoryType.expense;

  final List<Color> _presetColors = const [
    Colors.redAccent, Colors.pinkAccent, Colors.purpleAccent,
    Colors.deepPurpleAccent, Colors.indigoAccent, Colors.blueAccent,
    Colors.lightBlueAccent, Colors.cyanAccent, Colors.tealAccent,
    Colors.greenAccent, Colors.lightGreenAccent, Colors.limeAccent,
    Colors.yellowAccent, Colors.amberAccent, Colors.orangeAccent
  ];

  @override
  void initState() {
    super.initState();
    _name = widget.category?.name ?? '';
    _color = widget.category != null ? (widget.category!.color).parseHexColor() : Colors.redAccent;
    _icon = widget.category != null ? getIconDataFromString(widget.category!.icon) : Icons.category;
    if (widget.category != null) {
      _selectedType = widget.category!.type;
    }
  }

  Widget _buildSegment(String title, CategoryType type) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF9E4B35) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _customInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF9E4B35)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category == null ? 'Add Category' : 'Edit Category',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Segmented Control
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    _buildSegment('Expense', CategoryType.expense),
                    _buildSegment('Income', CategoryType.income),
                    _buildSegment('Transfer', CategoryType.transfer),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Icon + Name
              Row(
                children: [
                  GestureDetector(
                    onTap: _pickIcon,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _color, width: 2),
                      ),
                      child: Center(
                        child: Icon(_icon, color: _color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _name,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                      decoration: _customInputDecoration('Enter category name'),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _name = val!,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              const Text('Colors', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              // Colors Tabs (Static UI representation)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9E4B35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text('Primary', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        child: Text('Accent', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                           final Color newColor = await showColorPickerDialog(
                             context,
                             _color,
                             title: Text('Select Color', style: Theme.of(context).textTheme.titleLarge),
                             pickersEnabled: const <ColorPickerType, bool>{ColorPickerType.wheel: true},
                           );
                           setState(() => _color = newColor);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          child: Text('Wheel', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Color Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _presetColors.length,
                itemBuilder: (context, index) {
                  final color = _presetColors[index];
                  final isSelected = _color.value == color.value;
                  return GestureDetector(
                    onTap: () => setState(() => _color = color),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: AppButton(
                  onPressed: _saveCategory,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save_outlined),
                      const SizedBox(width: 8),
                      Text(widget.category == null ? 'Add' : 'Save', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _pickIcon() {
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
  }

  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final colorString = '0x${_color.value.toRadixString(16).padLeft(8, '0')}';
      
      if (widget.category == null) {
        await ref.read(categoryServiceProvider).addCategory(
          name: _name,
          icon: getStringFromIconData(_icon),
          color: colorString,
          type: _selectedType,
        );
      } else {
        final upd = Category()
          ..id = widget.category!.id
          ..name = _name
          ..icon = getStringFromIconData(_icon)
          ..color = colorString
          ..type = _selectedType
          ..budgetLimit = widget.category!.budgetLimit;
        await ref.read(categoryServiceProvider).updateCategory(widget.category!, upd);
      }
      if (mounted) Navigator.pop(context);
    }
  }
}
