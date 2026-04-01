import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../../../core/database/models/account.dart';
import '../../../core/database/providers.dart';
import '../../../core/widgets/icon_picker.dart';
import '../../../core/widgets/primary_atelier_button.dart';
import '../../../core/theme/color_extension.dart';

class AddEditAccountPage extends ConsumerStatefulWidget {
  final Account? account;
  const AddEditAccountPage({super.key, this.account});

  @override
  ConsumerState<AddEditAccountPage> createState() => _AddEditAccountPageState();
}

class _AddEditAccountPageState extends ConsumerState<AddEditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  late AccountType _selectedType;
  String _selectedColor = '0xFF4CAF50';
  String _selectedIcon = 'payments';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _balanceController =
        TextEditingController(text: widget.account?.balance.toString() ?? '0');
    _selectedType = widget.account?.type ?? AccountType.cash;
    _selectedColor = widget.account?.color ?? '0xFF4CAF50';
    _selectedIcon = widget.account?.icon ?? 'payments';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final account = Account()
      ..name = _nameController.text
      ..balance = double.tryParse(_balanceController.text) ?? 0.0
      ..type = _selectedType
      ..color = _selectedColor
      ..icon = _selectedIcon
      ..bankName = ''
      ..number = ''
      ..validThru = DateTime.now()
      ..createdAt = widget.account?.createdAt ?? DateTime.now()
      ..updatedAt = DateTime.now();

    if (widget.account != null) {
      account.id = widget.account!.id;
    }

    await ref.read(accountServiceProvider).saveAccount(account);
    
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Color currentColor = _selectedColor.parseHexColor();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account == null ? 'Add Account' : 'Edit Account'),
        actions: [
          if (widget.account != null)
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
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Account Name',
                prefixIcon: Icon(Icons.badge_rounded),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _balanceController,
              decoration: const InputDecoration(
                labelText: 'Initial Balance',
                prefixIcon: Icon(Icons.account_balance_wallet_rounded),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            Text('Account Type',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: AccountType.values.map((type) {
                final selected = _selectedType == type;
                return ChoiceChip(
                  label: Text(type.name.toUpperCase()),
                  selected: selected,
                  onSelected: (s) {
                    setState(() => _selectedType = type);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 48),
            PrimaryAtelierButton(
              onPressed: _save,
              icon: const Icon(Symbols.save, color: Colors.white),
              label: const Text(
                'Save Account',
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
      title: Text('Select Account Color',
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
        title: const Text('Delete Account?'),
        content: const Text(
            'All transactions associated with this account will remain, but the account will be permanently removed. Proceed?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref
                  .read(accountServiceProvider)
                  .deleteAccount(widget.account!.id);
              
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