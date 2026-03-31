import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

import '../../../core/services/haptic_service.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/database/models/account.dart';
import '../../../core/database/models/category.dart';
import '../../../core/widgets/icon_picker.dart';
import '../../../core/widgets/primary_atelier_button.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  final TransactionModel? transaction;
  const AddTransactionPage({super.key, this.transaction});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  TransactionType _transactionType = TransactionType.expense;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  Account? _selectedAccount;
  Category? _selectedCategory;
  Account? _selectedTransferAccount;
  String? _selectedIcon;
  String? _selectedColor;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _transactionType = widget.transaction!.type;
      _amountController.text = widget.transaction!.amount.toString();
      _noteController.text = widget.transaction!.note ?? '';
      _selectedIcon = widget.transaction!.icon;
      _selectedColor = widget.transaction!.color;
      _selectedAccount = widget.transaction!.account.value;
      _selectedCategory = widget.transaction!.category.value;
      _selectedTransferAccount = widget.transaction!.transferAccount.value;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    if (_selectedAccount == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select account and category')));
      return;
    }

    try {
      final service = ref.read(transactionServiceProvider);
      final personalization = ref.read(personalizationProvider);

      if (widget.transaction != null) {
        final updatedTx = TransactionModel()
          ..id = widget.transaction!.id
          ..amount = amount
          ..date = widget.transaction!.date
          ..type = _transactionType
          ..note = _noteController.text.isNotEmpty ? _noteController.text : null
          ..icon = _selectedIcon
          ..color = _selectedColor
          ..createdAt = widget.transaction!.createdAt
          ..updatedAt = DateTime.now();

        updatedTx.account.value = _selectedAccount;
        updatedTx.category.value = _selectedCategory;
        updatedTx.transferAccount.value = _selectedTransferAccount;

        await service.updateTransaction(widget.transaction!, updatedTx);
      } else {
        await service.addTransaction(
          amount: amount,
          date: DateTime.now(),
          type: _transactionType,
          account: _selectedAccount!,
          category: _selectedCategory!,
          note: _noteController.text.isNotEmpty ? _noteController.text : null,
          transferAccount: _selectedTransferAccount,
          icon: _selectedIcon,
          color: _selectedColor,
        );
      }

      await ref
          .read(hapticServiceProvider)
          .transaction(personalization.vibrateOnTransaction);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text(
            'This action cannot be undone and will revert the account balance.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.transaction != null) {
      try {
        await ref
            .read(transactionServiceProvider)
            .deleteTransaction(widget.transaction!);
        if (mounted) context.pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Delete failed: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final accountsAsync = ref.watch(accountsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    final effectiveColor = _selectedColor != null
        ? Color(int.parse(_selectedColor!.replaceAll('0x', ''), radix: 16))
        : (_selectedCategory != null
            ? Color(int.parse(_selectedCategory!.color.replaceAll('0x', ''), radix: 16))
            : colorScheme.primary);

    final effectiveIcon = _selectedIcon ?? _selectedCategory?.icon ?? 'category';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null
            ? 'Add Transaction'
            : 'Edit Transaction'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        actions: [
          if (widget.transaction != null)
            IconButton(
              onPressed: _delete,
              icon: Icon(Symbols.delete, color: colorScheme.error),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Segmented Button for Type
            Center(
              child: SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Expense'),
                      icon: Icon(Icons.remove_rounded)),
                  ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Income'),
                      icon: Icon(Icons.add_rounded)),
                  ButtonSegment(
                      value: TransactionType.transfer,
                      label: Text('Transfer'),
                      icon: Icon(Icons.swap_horiz_rounded)),
                ],
                selected: {_transactionType},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    _transactionType = newSelection.first;
                    _selectedCategory = null; // Reset category when type changes
                  });
                },
              ),
            ),
            const SizedBox(height: 32),

            // Amount Input
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: effectiveColor,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText:
                    '${NumberFormat.simpleCurrency(name: ref.watch(currencyProvider)).currencySymbol} ',
                prefixStyle: theme.textTheme.displaySmall?.copyWith(
                  color: colorScheme.outline,
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
            const SizedBox(height: 32),

            // Note Input
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                prefixIcon: Icon(Icons.notes_rounded),
                hintText: 'What was this for?',
              ),
            ),
            const SizedBox(height: 16),

            // Category Selector
            ListTile(
              onTap: () => _showCategoryPicker(categoriesAsync.value ?? []),
              leading: const Icon(Icons.category_rounded),
              title: const Text('Category'),
              subtitle: Text(_selectedCategory?.name ?? 'Select Category'),
              trailing: const Icon(Icons.chevron_right_rounded),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              tileColor: colorScheme.surfaceContainerLow,
            ),
            const SizedBox(height: 16),

            // Icon & Color overrides
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => IconPickerWidget(
                          selectedIcon: effectiveIcon,
                          selectedColor: effectiveColor,
                          onIconSelected: (icon) {
                            setState(() => _selectedIcon = icon);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                    leading: Icon(AppIcons.getIcon(effectiveIcon), color: effectiveColor),
                    title: const Text('Icon'),
                    subtitle: Text(_selectedIcon == null ? 'Default' : 'Custom'),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    tileColor: colorScheme.surfaceContainerLow,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ListTile(
                    onTap: () async {
                      final Color newColor = await showColorPickerDialog(
                        context,
                        effectiveColor,
                        title: Text('Select Color', style: theme.textTheme.titleLarge),
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
                    },
                    leading: CircleAvatar(backgroundColor: effectiveColor, radius: 12),
                    title: const Text('Color'),
                    subtitle: Text(_selectedColor == null ? 'Default' : 'Custom'),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    tileColor: colorScheme.surfaceContainerLow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Account Selector
            ListTile(
              onTap: () => _showAccountPicker(accountsAsync.value ?? []),
              leading: const Icon(Icons.account_balance_wallet_rounded),
              title: const Text('Account'),
              subtitle: Text(_selectedAccount?.name ?? 'Select Account'),
              trailing: const Icon(Icons.chevron_right_rounded),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              tileColor: colorScheme.surfaceContainerLow,
            ),

            if (_transactionType == TransactionType.transfer) ...[
              const SizedBox(height: 16),
              ListTile(
                onTap: () => _showAccountPicker(accountsAsync.value ?? [],
                    isTransfer: true),
                leading: const Icon(Icons.swap_horiz_rounded),
                title: const Text('To Account'),
                subtitle: Text(
                    _selectedTransferAccount?.name ?? 'Select Target Account'),
                trailing: const Icon(Icons.chevron_right_rounded),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                tileColor: colorScheme.surfaceContainerLow,
              ),
            ],

            const SizedBox(height: 48),

            // Save Button
            PrimaryAtelierButton(
              onPressed: _save,
              icon: const Icon(Symbols.save, color: Colors.white),
              label: Text(
                widget.transaction != null
                    ? 'Update Transaction'
                    : 'Save Transaction',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(List<Category> categories) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final filtered = categories.where((c) {
          if (_transactionType == TransactionType.transfer) {
            return c.type == CategoryType.transfer;
          }
          return c.type.name == _transactionType.name;
        }).toList();

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final cat = filtered[index];
            return ListTile(
              leading: Icon(
                AppIcons.getIcon(cat.icon),
                color: Color(int.parse(cat.color.replaceAll('0x', ''), radix: 16)),
              ),
              title: Text(cat.name),
              onTap: () {
                setState(() => _selectedCategory = cat);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _showAccountPicker(List<Account> accounts, {bool isTransfer = false}) {
    final selectedCurrency = ref.read(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            final acc = accounts[index];
            return ListTile(
              title: Text(acc.name),
              subtitle: Text('Balance: ${currencyFormat.format(acc.balance)}'),
              onTap: () {
                setState(() {
                  if (isTransfer) {
                    _selectedTransferAccount = acc;
                  } else {
                    _selectedAccount = acc;
                  }
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}
