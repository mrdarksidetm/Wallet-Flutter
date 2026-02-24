import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/account.dart';
import '../../../shared/widgets/paisa_list_tile.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/material_icon_picker.dart';
import 'widgets/active_account_card.dart';
import 'widgets/account_tab_filters.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) return const Center(child: Text('No accounts found.'));
          
          final themeState = ref.watch(themeControllerProvider); 

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  child: AccountTabFilters(),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ActiveAccountCard(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final acc = accounts[index];
                    final color = (acc.color).parseHexColor();
                    
                    return PaisaListTile(
                      title: acc.name,
                      subtitle: acc.type.name.toUpperCase(),
                      amount: '${themeState.currencySymbol}${acc.balance.toStringAsFixed(2)}',
                      amountColor: Theme.of(context).colorScheme.primary,
                      icon: getIconDataFromString(acc.icon),
                      iconColor: Colors.white,
                      iconBackgroundColor: color,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => ref.read(accountServiceProvider).deleteAccount(acc.id),
                      ),
                      onTap: () => _showAddEditAccountDialog(context, ref, acc),
                    );
                  },
                  childCount: accounts.length,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditAccountDialog(context, ref, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEditAccountDialog(BuildContext context, WidgetRef ref, Account? account) {
    showDialog(
      context: context,
      builder: (_) => AddEditAccountDialog(account: account),
    );
  }
}

class AddEditAccountDialog extends ConsumerStatefulWidget {
  final Account? account;
  const AddEditAccountDialog({super.key, this.account});

  @override
  ConsumerState<AddEditAccountDialog> createState() => _AddEditAccountDialogState();
}

class _AddEditAccountDialogState extends ConsumerState<AddEditAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _balanceString;
  late Color _color;
  late AccountType _type;

  @override
  void initState() {
    super.initState();
    _name = widget.account?.name ?? '';
    _balanceString = widget.account?.balance.toString() ?? '0.0';
    _color = widget.account != null ? Color(int.parse(widget.account!.color)) : Colors.blue;
    _type = widget.account?.type ?? AccountType.bank;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.account == null ? 'New Account' : 'Edit Account'),
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
              TextFormField(
                initialValue: _balanceString,
                decoration: const InputDecoration(labelText: 'Initial Balance'),
                keyboardType: TextInputType.number,
                validator: (val) => double.tryParse(val ?? '') == null ? 'Invalid Number' : null,
                onSaved: (val) => _balanceString = val!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AccountType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: AccountType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
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
              
              if (widget.account == null) {
                await ref.read(accountServiceProvider).addAccount(
                  name: _name,
                  icon: 'account_balance_wallet',
                  color: colorString,
                  balance: double.parse(_balanceString),
                  type: _type,
                );
              } else {
                final upd = Account()
                  ..id = widget.account!.id
                  ..name = _name
                  ..icon = 'account_balance_wallet'
                  ..color = colorString
                  ..type = _type
                  ..balance = double.parse(_balanceString)
                  ..createdAt = widget.account!.createdAt;
                await ref.read(accountServiceProvider).updateAccount(widget.account!, upd);
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
