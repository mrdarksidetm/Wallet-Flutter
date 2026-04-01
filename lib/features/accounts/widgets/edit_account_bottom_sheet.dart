import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/models/account.dart';
import '../../../core/database/providers.dart';
import '../../../core/widgets/icon_picker.dart';
import '../../../core/theme/color_extension.dart';

class EditAccountBottomSheet extends ConsumerStatefulWidget {
  final Account account;
  const EditAccountBottomSheet({super.key, required this.account});

  @override
  ConsumerState<EditAccountBottomSheet> createState() => _EditAccountBottomSheetState();
}

class _EditAccountBottomSheetState extends ConsumerState<EditAccountBottomSheet> with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  late AccountType _selectedType;
  late String _selectedColor;
  late String _selectedIcon;
  late TabController _tabController;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account.name);
    _balanceController = TextEditingController(text: widget.account.balance.toString());
    _selectedType = widget.account.type;
    _selectedColor = widget.account.color;
    _selectedIcon = widget.account.icon;
    _tabController = TabController(length: 3, vsync: this, initialIndex: _getTabIndex(_selectedType));
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        _selectedType = _getTypeFromIndex(_tabController.index);
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Color currentColor = _selectedColor.parseHexColor();

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Card'),
              Tab(text: 'Cash'),
              Tab(text: 'Savings'),
            ],
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _showIconPicker,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: currentColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(AppIcons.getIcon(_selectedIcon), color: currentColor, size: 32),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(labelText: 'Account Name', border: InputBorder.none),
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Divider(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _balanceController,
                    decoration: const InputDecoration(
                      labelText: 'Current Balance',
                      prefixIcon: Icon(Icons.account_balance_wallet_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  Text('Theme Color', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: Colors.primaries.length,
                      itemBuilder: (context, index) {
                        final color = Colors.primaries[index];
                        final hexColor = '0x${color.value.toRadixString(16).toUpperCase()}';
                        final isSelected = _selectedColor == hexColor;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = hexColor),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected ? Border.all(color: colorScheme.onSurface, width: 3) : null,
                            ),
                            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text('Default Account'),
                    subtitle: const Text('Use this account by default for new transactions'),
                    value: _isDefault,
                    onChanged: (v) => setState(() => _isDefault = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: currentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getTabIndex(AccountType type) {
    if (type == AccountType.bank || type == AccountType.creditCard) return 0;
    if (type == AccountType.cash) return 1;
    return 2;
  }

  AccountType _getTypeFromIndex(int index) {
    if (index == 0) return AccountType.bank;
    if (index == 1) return AccountType.cash;
    return AccountType.investment;
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

  Future<void> _save() async {
    final updated = Account()
      ..id = widget.account.id
      ..name = _nameController.text
      ..balance = double.tryParse(_balanceController.text) ?? 0.0
      ..icon = _selectedIcon
      ..color = _selectedColor
      ..type = _selectedType
      ..order = widget.account.order
      ..createdAt = widget.account.createdAt
      ..updatedAt = DateTime.now();

    await ref.read(accountServiceProvider).saveAccount(updated);
    if (mounted) Navigator.pop(context);
  }
}
