import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/models/account.dart';
import '../../../core/database/providers.dart';
import '../../../core/services/haptic_service.dart';

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
  String _selectedColor = '0xFF2196F3';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _balanceController = TextEditingController(text: widget.account?.balance.toString() ?? '0');
    _selectedType = widget.account?.type ?? AccountType.cash;
    _selectedColor = widget.account?.color ?? '0xFF2196F3';
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
      ..icon = 'account_balance_wallet'
      ..bankName = ''
      ..number = ''
      ..validThru = DateTime.now()
      ..createdAt = widget.account?.createdAt ?? DateTime.now()
      ..updatedAt = DateTime.now();

    if (widget.account != null) {
      account.id = widget.account!.id;
    }

    await ref.read(accountServiceProvider).saveAccount(account);
    await HapticService.success();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
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
            Text('Account Type', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AccountType.values.map((type) {
                final selected = _selectedType == type;
                return ChoiceChip(
                  label: Text(type.name.toUpperCase()),
                  selected: selected,
                  onSelected: (s) => setState(() => _selectedType = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save Account'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
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
        title: const Text('Delete Account?'),
        content: const Text('All transactions associated with this account will remain, but the account will be permanently removed. Proceed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(accountServiceProvider).deleteAccount(widget.account!.id);
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
