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
import '../../../core/theme/color_extension.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../core/widgets/expressive_bottom_sheet.dart';
import '../../../core/services/currency_engine.dart';
import '../../people/widgets/person_avatar.dart';

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

  // Loan Integration
  Person? _selectedPerson;
  bool _isLoan = false;
  bool _isLoading = false;
  DateTime _selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _isLoading = true;
      _initializeData();
    } else {
      _loadDefaultAccount();
    }
  }

  Future<void> _loadDefaultAccount() async {
    final accountRepo = ref.read(accountRepositoryProvider);
    final defaultAcc = await accountRepo.getDefaultAccount();
    if (mounted && defaultAcc != null) {
      setState(() {
        _selectedAccount = defaultAcc;
      });
    }
  }

  Future<void> _initializeData() async {
    final tx = widget.transaction!;
    
    // [ACTION]: Robustly loading all linked entities for editing.
    // [M3 UPDATE]: We ensure links are loaded from Isar, but use ID fallbacks 
    // from the transaction record if the link returns null.
    // [WHY]: This prevents the "forgotten fields" bug where links might not 
    // be eagerly loaded, ensuring icon, category, color, person, and accounts 
    // are all correctly restored in the UI.

    await Future.wait([
      tx.account.load(),
      tx.category.load(),
      tx.transferAccount.load(),
      tx.person.load(),
    ]);

    Account? acc = tx.account.value;
    if (acc == null && tx.accountId != 0) {
      acc = await ref.read(accountRepositoryProvider).getById(tx.accountId);
    }

    Category? cat = tx.category.value;
    if (cat == null && tx.categoryId != 0) {
      cat = await ref.read(categoryRepositoryProvider).getById(tx.categoryId);
    }

    if (mounted) {
      setState(() {
        _transactionType = tx.type;
        _amountController.text = tx.amount.toString();
        _noteController.text = tx.note ?? '';
        _selectedIcon = tx.icon;
        _selectedColor = tx.color;
        _selectedAccount = acc;
        _selectedCategory = cat;
        _selectedTransferAccount = tx.transferAccount.value;
        _selectedPerson = tx.person.value;
        _selectedDateTime = tx.date;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = _getEffectiveColor(colorScheme);
    final effectiveIcon = _selectedIcon ?? _selectedCategory?.icon ?? 'category';

    return Scaffold(
      appBar: _buildAppBar(colorScheme),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeSelector(),
            const SizedBox(height: 32),
            _buildAmountInput(theme, effectiveColor),
            const SizedBox(height: 32),
            _buildNoteInput(),
            const SizedBox(height: 16),
            _buildDateTimePicker(colorScheme),
            const SizedBox(height: 16),
            if (_transactionType != TransactionType.transfer) ...[
              _buildCategorySelector(colorScheme),
              const SizedBox(height: 16),
              _buildIconAndColorOverrides(theme, colorScheme, effectiveIcon, effectiveColor),
              const SizedBox(height: 24),
            ],
            _buildPeopleAndLoanSection(theme, colorScheme),
            const SizedBox(height: 24),
            _buildAccountSelector(colorScheme),
            if (_transactionType == TransactionType.transfer) ...[
              const SizedBox(height: 16),
              _buildTransferAccountSelector(colorScheme),
            ],
            const SizedBox(height: 48),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Color _getEffectiveColor(ColorScheme colorScheme) {
    if (_selectedColor != null) return _selectedColor!.parseHexColor();
    if (_selectedCategory != null) return _selectedCategory!.color.parseHexColor();
    return colorScheme.primary;
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme) {
    return AppBar(
      title: Text(widget.transaction == null ? 'Add Transaction' : 'Edit Transaction'),
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
    );
  }

  Widget _buildTypeSelector() {
    return Center(
      child: SegmentedButton<TransactionType>(
        segments: const [
          ButtonSegment(value: TransactionType.expense, label: Text('Expense'), icon: Icon(Icons.remove_rounded)),
          ButtonSegment(value: TransactionType.income, label: Text('Income'), icon: Icon(Icons.add_rounded)),
          ButtonSegment(value: TransactionType.transfer, label: Text('Transfer'), icon: Icon(Icons.swap_horiz_rounded)),
        ],
        selected: {_transactionType},
        onSelectionChanged: (Set<TransactionType> newSelection) {
          setState(() {
            _transactionType = newSelection.first;
            _selectedCategory = null;
          });
        },
      ),
    );
  }

  Widget _buildAmountInput(ThemeData theme, Color effectiveColor) {
    final selectedCurrency = ref.watch(currencyProvider);
    return TextField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: theme.textTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: effectiveColor,
      ),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: '0.00',
        prefixText: '${CurrencyEngine.getSymbol(selectedCurrency)} ',
        prefixStyle: theme.textTheme.displaySmall?.copyWith(color: theme.colorScheme.outline),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }

  Widget _buildNoteInput() {
    return TextField(
      controller: _noteController,
      decoration: const InputDecoration(
        labelText: 'Note',
        prefixIcon: Icon(Icons.notes_rounded),
        hintText: 'What was this for?',
      ),
    );
  }

  Widget _buildDateTimePicker(ColorScheme colorScheme) {
    return ListTile(
      onTap: _pickDateTime,
      leading: const Icon(Symbols.calendar_month),
      title: const Text('Date & Time'),
      subtitle: Text(DateFormat('MMM dd, yyyy - hh:mm a').format(_selectedDateTime)),
      trailing: const Icon(Icons.chevron_right_rounded),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: colorScheme.surfaceContainerLow,
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (date != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Widget _buildCategorySelector(ColorScheme colorScheme) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    return ListTile(
      onTap: () => _showCategoryPicker(categoriesAsync.value ?? []),
      leading: const Icon(Icons.category_rounded),
      title: const Text('Category'),
      subtitle: Text(_selectedCategory?.name ?? 'Select Category'),
      trailing: const Icon(Icons.chevron_right_rounded),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: colorScheme.surfaceContainerLow,
    );
  }

  Widget _buildIconAndColorOverrides(ThemeData theme, ColorScheme colorScheme, String effectiveIcon, Color effectiveColor) {
    return Row(
      children: [
        Expanded(
          child: Hero(
            tag: widget.transaction != null ? 'tx_icon_${widget.transaction!.id}' : 'new_tx_icon',
            child: ListTile(
              onTap: () => _pickIcon(effectiveIcon, effectiveColor),
              leading: Icon(AppIcons.getIcon(effectiveIcon), color: effectiveColor),
              title: const Text('Icon'),
              subtitle: Text(_selectedIcon == null ? 'Default' : 'Custom'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: colorScheme.surfaceContainerLow,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ListTile(
            onTap: () => _pickColor(theme, effectiveColor),
            leading: CircleAvatar(backgroundColor: effectiveColor, radius: 12),
            title: const Text('Color'),
            subtitle: Text(_selectedColor == null ? 'Default' : 'Custom'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: colorScheme.surfaceContainerLow,
          ),
        ),
      ],
    );
  }

  void _pickIcon(String effectiveIcon, Color effectiveColor) {
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
  }

  Future<void> _pickColor(ThemeData theme, Color effectiveColor) async {
    final Color newColor = await showColorPickerDialog(
      context,
      effectiveColor,
      title: Text('Select Color', style: theme.textTheme.titleLarge),
      width: 40, height: 40, spacing: 0, runSpacing: 0, borderRadius: 0,
      wheelDiameter: 165, enableOpacity: false, showColorCode: true, colorCodeHasColor: true,
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

  Widget _buildPeopleAndLoanSection(ThemeData theme, ColorScheme colorScheme) {
    final peopleAsync = ref.watch(personsStreamProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('People & Loans', style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListTile(
          onTap: () => _showPersonPicker(peopleAsync.value ?? []),
          leading: _selectedPerson != null 
            ? PersonAvatar(person: _selectedPerson!, radius: 16)
            : const Icon(Symbols.person),
          title: const Text('With Person'),
          subtitle: Text(_selectedPerson?.name ?? 'None'),
          trailing: _selectedPerson != null 
            ? IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() { _selectedPerson = null; _isLoan = false; }))
            : const Icon(Icons.chevron_right_rounded),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          tileColor: colorScheme.surfaceContainerLow,
        ),
        if (_selectedPerson != null && widget.transaction == null) ...[
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Add to Loans'),
            subtitle: const Text('Create a debt entry for this person'),
            value: _isLoan,
            onChanged: (val) => setState(() => _isLoan = val),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: colorScheme.surfaceContainerLow,
          ),
        ],
      ],
    );
  }

  Widget _buildAccountSelector(ColorScheme colorScheme) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    return ListTile(
      onTap: () => _showAccountPicker(accountsAsync.value ?? []),
      leading: const Icon(Icons.account_balance_wallet_rounded),
      title: const Text('Account'),
      subtitle: Text(_selectedAccount?.name ?? 'Select Account'),
      trailing: const Icon(Icons.chevron_right_rounded),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: colorScheme.surfaceContainerLow,
    );
  }

  Widget _buildTransferAccountSelector(ColorScheme colorScheme) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    return ListTile(
      onTap: () => _showAccountPicker(accountsAsync.value ?? [], isTransfer: true),
      leading: const Icon(Icons.swap_horiz_rounded),
      title: const Text('To Account'),
      subtitle: Text(_selectedTransferAccount?.name ?? 'Select Target Account'),
      trailing: const Icon(Icons.chevron_right_rounded),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: colorScheme.surfaceContainerLow,
    );
  }

  Widget _buildSaveButton() {
    return PrimaryAtelierButton(
      onPressed: _save,
      icon: const Icon(Symbols.save, color: Colors.white),
      label: Text(
        widget.transaction != null ? 'Update Transaction' : 'Save Transaction',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    if (_selectedAccount == null || (_transactionType != TransactionType.transfer && _selectedCategory == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select account and category')));
      return;
    }

    // Overbudget Check
    if (_transactionType == TransactionType.expense && _selectedCategory!.budgetLimit != null) {
      final stats = await ref.read(statisticsServiceProvider).watchBudgets().first;
      final categoryStat = stats.firstWhere((s) => s['categoryId'] == _selectedCategory!.id, orElse: () => {});
      if (categoryStat.isNotEmpty) {
        final spent = categoryStat['spent'] as double;
        final limit = _selectedCategory!.budgetLimit!;
        if (spent + amount > limit) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Over Budget Warning'),
              content: Text('This transaction will exceed your monthly budget for ${_selectedCategory!.name}.\n\nLimit: $limit\nCurrently Spent: $spent\nNew Total: ${spent + amount}\n\nDo you want to continue?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Continue')),
              ],
            ),
          );
          if (confirmed != true) return;
        }
      }
    }

    try {
      final service = ref.read(transactionServiceProvider);
      final personalization = ref.read(personalizationProvider);

      if (widget.transaction != null) {
        final updatedTx = TransactionModel()
          ..id = widget.transaction!.id
          ..amount = amount
          ..date = _selectedDateTime
          ..type = _transactionType
          ..note = _noteController.text.isNotEmpty ? _noteController.text : null
          ..icon = _selectedIcon
          ..color = _selectedColor
          ..createdAt = widget.transaction!.createdAt
          ..updatedAt = DateTime.now();

        updatedTx.account.value = _selectedAccount;
        updatedTx.category.value = _selectedCategory;
        updatedTx.transferAccount.value = _selectedTransferAccount;
        updatedTx.person.value = _selectedPerson;

        await service.updateTransaction(widget.transaction!, updatedTx);
      } else {
        await service.addTransaction(
          amount: amount, date: _selectedDateTime, type: _transactionType,
          account: _selectedAccount!, category: _selectedCategory,
          note: _noteController.text.isNotEmpty ? _noteController.text : null,
          transferAccount: _selectedTransferAccount, icon: _selectedIcon,
          color: _selectedColor, person: _selectedPerson,
        );

        if (_isLoan && _selectedPerson != null) {
          final loanService = ref.read(loanServiceProvider);
          final loan = Loan()
            ..amount = amount
            ..type = _transactionType == TransactionType.income ? LoanType.borrowed : LoanType.lent
            ..note = _noteController.text
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now();
          loan.person.value = _selectedPerson;
          await loanService.saveLoan(loan);
        }
      }

      await ref.read(hapticServiceProvider).transaction(personalization.vibrateOnTransaction);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text('This action cannot be undone and will revert the account balance.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.transaction != null) {
      try {
        await ref.read(transactionServiceProvider).deleteTransaction(widget.transaction!);
        if (mounted) context.pop();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  void _showPersonPicker(List<Person> people) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ExpressiveBottomSheet(
        title: 'Select Person',
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(Icons.add_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              title: const Text('Add New Person', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _showAddPersonDialog();
              },
            ),
            const Divider(height: 1),
            if (people.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Symbols.person_off, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No people found.'),
                  ],
                ),
              ),
            ...people.map((p) {
              final color = p.color.parseHexColor();
              final isSelected = _selectedPerson?.id == p.id;
              return ListTile(
                leading: PersonAvatar(person: p, radius: 20),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: p.contact != null ? Text(p.contact!) : null,
                trailing: isSelected ? Icon(Icons.check_circle, color: color) : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onTap: () {
                  setState(() => _selectedPerson = p);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showAddPersonDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Person'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name', hintText: 'Enter name...'),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final person = Person()
                  ..name = nameController.text
                  ..color = '0x${Colors.blue.value.toRadixString(16).toUpperCase()}'
                  ..createdAt = DateTime.now()
                  ..updatedAt = DateTime.now();
                await ref.read(personServiceProvider).savePerson(person);
                setState(() {
                  _selectedPerson = person;
                });
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ).then((_) => nameController.dispose());
  }

  void _showCategoryPicker(List<Category> categories) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final filtered = categories.where((c) {
          if (_transactionType == TransactionType.transfer) return c.type == CategoryType.transfer;
          return c.type.name == _transactionType.name;
        }).toList();

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final cat = filtered[index];
            return ListTile(
              leading: Icon(AppIcons.getIcon(cat.icon), color: cat.color.parseHexColor()),
              title: Text(cat.name),
              trailing: _selectedCategory?.id == cat.id ? const Icon(Icons.check_circle, color: Colors.green) : null,
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                  // [SMOOTHNESS]: Automatically sync icon and color from category
                  _selectedIcon = cat.icon;
                  _selectedColor = cat.color;
                });
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
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          final acc = accounts[index];
          return ListTile(
            title: Text(acc.name),
            subtitle: Text('Balance: ${CurrencyEngine.formatCurrency(acc.balance, selectedCurrency)}'),
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
      ),
    );
  }
}
