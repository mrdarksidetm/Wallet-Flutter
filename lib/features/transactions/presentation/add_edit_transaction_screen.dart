import 'package:flutter/material.dart';
import 'package:wallet/core/theme/color_extension.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/database/models/account.dart';
import '../../../core/database/models/category.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/paisa_calculator.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel? transaction;

  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  ConsumerState<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends ConsumerState<AddEditTransactionScreen> {
  late String _amountString;
  late DateTime _date;
  late TransactionType _type;
  String? _note;
  Account? _selectedAccount;
  Category? _selectedCategory;
  Account? _selectedTransferAccount;
  Person? _selectedPerson;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _amountString = widget.transaction!.amount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
      _date = widget.transaction!.date;
      _type = widget.transaction!.type;
      _note = widget.transaction!.note;
      _selectedAccount = widget.transaction!.account.value;
      _selectedCategory = widget.transaction!.category.value;
      _selectedTransferAccount = widget.transaction!.transferAccount.value;
      _selectedPerson = widget.transaction!.person.value;
    } else {
      _amountString = '0';
      _date = DateTime.now();
      _type = TransactionType.expense;
    }
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountString) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    if (_selectedAccount == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select account and category')));
      return;
    }

    final service = ref.read(transactionServiceProvider);

    try {
      if (widget.transaction == null) {
        await service.addTransaction(
          amount: amount,
          date: _date,
          type: _type,
          account: _selectedAccount!,
          category: _selectedCategory!,
          person: _selectedPerson,
          note: _note,
          transferAccount: _selectedTransferAccount,
        );
      } else {
        final updatedTx = TransactionModel()
          ..id = widget.transaction!.id
          ..amount = amount
          ..date = _date
          ..type = _type
          ..note = _note
          ..createdAt = widget.transaction!.createdAt;
        
        updatedTx.account.value = _selectedAccount;
        updatedTx.category.value = _selectedCategory;
        updatedTx.transferAccount.value = _selectedTransferAccount;
        updatedTx.person.value = _selectedPerson;

        await service.updateTransaction(widget.transaction!, updatedTx);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showCategoryPicker(List<Category> categories) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final filtered = categories.where((c) => _type == TransactionType.transfer ? true : c.type.name == _type.name).toList();
        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final cat = filtered[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: (cat.color).parseHexColor(),
                child: const Icon(Icons.category, color: Colors.white, size: 20),
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
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            final acc = accounts[index];
            return ListTile(
              title: Text(acc.name),
              subtitle: Text('\$${acc.balance.toStringAsFixed(2)}'),
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

  void _showPersonPicker(List<Person> persons) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: persons.length,
          itemBuilder: (context, index) {
            final p = persons[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: (p.color).parseHexColor(),
                child: Text(p.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
              ),
              title: Text(p.name),
              onTap: () {
                setState(() => _selectedPerson = p);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeState = ref.watch(themeControllerProvider);
    final accountsAsync = ref.watch(accountsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final personsAsync = ref.watch(personsStreamProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.transaction == null ? 'Add Transaction' : 'Edit Transaction', style: const TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Amount Display
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Type Tabs (Expense / Income / Transfer)
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: TransactionType.values.map((type) {
                          final isSelected = _type == type;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _type = type;
                              _selectedCategory = null; // Reset category on type change
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                type.name[0].toUpperCase() + type.name.substring(1),
                                style: TextStyle(
                                  color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Large Amount Text
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${themeState.currencySymbol}$_amountString',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: _type == TransactionType.expense ? Colors.red : (_type == TransactionType.income ? Colors.green : theme.colorScheme.onSurface),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Selectors (Chips)
                    Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        // Category Chip
                        categoriesAsync.when(
                          data: (categories) => ActionChip(
                            avatar: _selectedCategory != null 
                                ? CircleAvatar(backgroundColor: (_selectedCategory!.color).parseHexColor(), radius: 12, child: const Icon(Icons.category, size: 12, color: Colors.white)) 
                                : const Icon(Icons.category, size: 16),
                            label: Text(_selectedCategory?.name ?? 'Category'),
                            onPressed: () => _showCategoryPicker(categories),
                          ),
                          loading: () => const Chip(label: Text('Loading...')),
                          error: (_, __) => const Chip(label: Text('Error')),
                        ),
                        
                        // Account Chip
                        accountsAsync.when(
                          data: (accounts) => ActionChip(
                            avatar: const Icon(Icons.account_balance_wallet, size: 16),
                            label: Text(_selectedAccount?.name ?? 'Account'),
                            onPressed: () => _showAccountPicker(accounts),
                          ),
                          loading: () => const Chip(label: Text('Loading...')),
                          error: (_, __) => const Chip(label: Text('Error')),
                        ),

                        // Transfer Account Chip (if transfer)
                        if (_type == TransactionType.transfer)
                          accountsAsync.when(
                            data: (accounts) => ActionChip(
                              avatar: const Icon(Icons.arrow_forward, size: 16),
                              label: Text(_selectedTransferAccount?.name ?? 'To Account'),
                              onPressed: () => _showAccountPicker(accounts, isTransfer: true),
                            ),
                            loading: () => const Chip(label: Text('Loading...')),
                            error: (_, __) => const Chip(label: Text('Error')),
                          ),
                          
                        // Person Chip (if expense/income)
                        if (_type != TransactionType.transfer)
                          personsAsync.when(
                            data: (persons) => ActionChip(
                              avatar: _selectedPerson != null 
                                  ? CircleAvatar(backgroundColor: (_selectedPerson!.color).parseHexColor(), radius: 12, child: Text(_selectedPerson!.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10))) 
                                  : const Icon(Icons.person_outline, size: 16),
                              label: Text(_selectedPerson?.name ?? 'Person'),
                              onPressed: () => _showPersonPicker(persons),
                            ),
                            loading: () => const Chip(label: Text('Loading...')),
                            error: (_, __) => const Chip(label: Text('Error')),
                          ),
                          
                        // Date Chip
                        ActionChip(
                          avatar: const Icon(Icons.calendar_today, size: 16),
                          label: Text(DateFormat('MMM dd').format(_date)),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _date,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setState(() => _date = picked);
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    // Note Field
                    TextField(
                      controller: TextEditingController(text: _note)..selection = TextSelection.collapsed(offset: _note?.length ?? 0),
                      onChanged: (val) => _note = val,
                      decoration: InputDecoration(
                        hintText: 'Add a note...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Custom Numpad Keyboard
            PaisaCalculator(
              amountString: _amountString,
              onAmountChanged: (val) => setState(() => _amountString = val),
              onSubmit: _save,
            ),
          ],
        ),
      ),
    );
  }
}

