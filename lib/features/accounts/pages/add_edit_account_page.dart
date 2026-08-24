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
import '../../../core/widgets/app_back_button.dart';

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
  bool _isDefault = false;
  String _selectedColor = '0xFF2196F3';
  String _selectedIcon = 'account_balance_wallet';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _balanceController =
        TextEditingController(text: widget.account?.balance.toString() ?? '0.0');
    _selectedType = widget.account?.type ?? AccountType.cash;
    _isDefault = widget.account?.isDefault ?? false;
    _selectedColor = widget.account?.color ?? '0xFF2196F3';
    _selectedIcon = widget.account?.icon ?? 'account_balance_wallet';
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
      ..isDefault = _isDefault
      ..color = _selectedColor
      ..icon = _selectedIcon
      ..bankName = widget.account?.bankName ?? ''
      ..number = widget.account?.number ?? ''
      ..validThru = widget.account?.validThru ?? DateTime.now()
      ..createdAt = widget.account?.createdAt ?? DateTime.now()
      ..updatedAt = DateTime.now()
      ..order = widget.account?.order ?? 0;

    if (widget.account != null) {
      account.id = widget.account!.id;
      account.uuid = widget.account!.uuid;
    }

    await ref.read(accountServiceProvider).saveAccount(account);
    
    if (mounted) context.pop();
  }

  Future<void> _showDeleteDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This will hide the account from your list. Transactions will remain.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.account != null) {
      await ref.read(accountServiceProvider).deleteAccount(widget.account!.id);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Color currentColor = _selectedColor.parseHexColor();

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(widget.account == null ? 'New Account' : 'Edit Account'),
        actions: [
          if (widget.account != null)
            IconButton(
              onPressed: _showDeleteDialog,
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            ),
          const SizedBox(width: 8),
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
                        border: Border.all(color: currentColor.withValues(alpha: 0.2)),
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
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.palette_rounded, size: 20, color: currentColor),
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
                prefixIcon: Icon(Symbols.label),
              ),
              validator: (v) => v?.isEmpty == true ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _balanceController,
              decoration: const InputDecoration(
                labelText: 'Current Balance',
                prefixIcon: Icon(Symbols.account_balance),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24),
            Text('Account Type', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SegmentedButton<AccountType>(
              segments: const [
                ButtonSegment(value: AccountType.cash, label: Text('Cash'), icon: Icon(Symbols.payments)),
                ButtonSegment(value: AccountType.card, label: Text('Card'), icon: Icon(Symbols.credit_card)),
                ButtonSegment(value: AccountType.savings, label: Text('Savings'), icon: Icon(Symbols.savings)),
              ],
              selected: {_selectedType},
              onSelectionChanged: (v) => setState(() => _selectedType = v.first),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Default Account'),
              subtitle: const Text('New transactions will use this account by default'),
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: colorScheme.surfaceContainerLow,
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
      isScrollControlled: true,
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
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
    );
    setState(() => _selectedColor = '0x${newColor.value.toRadixString(16).toUpperCase()}');
  }
}
