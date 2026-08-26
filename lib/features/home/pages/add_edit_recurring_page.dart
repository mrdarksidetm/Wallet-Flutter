import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/models/account.dart';
import '../../../core/database/models/category.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/database/providers.dart';
import '../../../core/widgets/icon_picker.dart';
import '../../../core/services/currency_engine.dart';
import '../../../core/widgets/app_back_button.dart';

class AddEditRecurringPage extends ConsumerStatefulWidget {
  final Recurring? recurring;
  const AddEditRecurringPage({super.key, this.recurring});

  @override
  ConsumerState<AddEditRecurringPage> createState() =>
      _AddEditRecurringPageState();
}

class _AddEditRecurringPageState extends ConsumerState<AddEditRecurringPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;

  Account? _selectedAccount;
  Category? _selectedCategory;
  TransactionType _type = TransactionType.expense;
  RecurrenceFrequency _frequency = RecurrenceFrequency.monthly;
  DateTime _nextDate = DateTime.now();
  bool _notifyOneDayBefore = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.recurring?.name ?? '');
    _amountController =
        TextEditingController(text: widget.recurring?.amount.toString() ?? '');
    _type = widget.recurring?.type ?? TransactionType.expense;
    _frequency = widget.recurring?.frequency ?? RecurrenceFrequency.monthly;
    _nextDate = widget.recurring?.nextDate ?? DateTime.now();
    _notifyOneDayBefore = widget.recurring?.notifyOneDayBefore ?? false;
    _selectedAccount = widget.recurring?.account.value;
    _selectedCategory = widget.recurring?.category.value;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccount == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select account and category')));
      return;
    }

    final recurring = Recurring()
      ..name = _nameController.text
      ..amount = double.tryParse(_amountController.text) ?? 0.0
      ..type = _type
      ..frequency = _frequency
      ..nextDate = _nextDate
      ..notifyOneDayBefore = _notifyOneDayBefore
      ..createdAt = widget.recurring?.createdAt ?? DateTime.now()
      ..updatedAt = DateTime.now()
      ..isActive = widget.recurring?.isActive ?? true;

    recurring.account.value = _selectedAccount;
    recurring.category.value = _selectedCategory;

    if (widget.recurring != null) {
      recurring.id = widget.recurring!.id;
      recurring.uuid = widget.recurring!.uuid;
    }

    await ref.read(recurringServiceProvider).saveRecurring(recurring);
    
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accountsAsync = ref.watch(accountsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final selectedCurrency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title:
            Text(widget.recurring == null ? 'Add Recurring' : 'Edit Recurring'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
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
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name (e.g. Netflix, Rent)',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixIcon: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  child: Text(
                    CurrencyEngine.getSymbol(selectedCurrency),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            Text('Frequency', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: RecurrenceFrequency.values.map((f) {
                return ChoiceChip(
                  label: Text(f.name.toUpperCase()),
                  selected: _frequency == f,
                  onSelected: (s) => setState(() => _frequency = f),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ListTile(
              onTap: () => _showAccountPicker(accountsAsync.value ?? []),
              leading: const Icon(Icons.account_balance_wallet_rounded),
              title: const Text('Account'),
              subtitle: Text(_selectedAccount?.name ?? 'Select Account'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              tileColor: theme.colorScheme.surfaceContainerLow,
            ),
            const SizedBox(height: 16),
            ListTile(
              onTap: () => _showCategoryPicker(categoriesAsync.value ?? []),
              leading:
                  Icon(AppIcons.getIcon(_selectedCategory?.icon ?? 'category')),
              title: const Text('Category'),
              subtitle: Text(_selectedCategory?.name ?? 'Select Category'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              tileColor: theme.colorScheme.surfaceContainerLow,
            ),
            const SizedBox(height: 16),
            ListTile(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _nextDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _nextDate = date);
              },
              leading: const Icon(Icons.calendar_today_rounded),
              title: const Text('Next Occurrence'),
              subtitle: Text(DateFormat('MMM d, yyyy').format(_nextDate)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              tileColor: theme.colorScheme.surfaceContainerLow,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Symbols.notifications_active_rounded,
                          color: theme.colorScheme.primary, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bill Due Notification',
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Choose when to receive the payment reminder',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(
                          value: false,
                          label: Text('Same Day'),
                          icon: Icon(Symbols.today_rounded, size: 18),
                        ),
                        ButtonSegment<bool>(
                          value: true,
                          label: Text('One Day Before'),
                          icon: Icon(Symbols.event_upcoming_rounded, size: 18),
                        ),
                      ],
                      selected: {_notifyOneDayBefore},
                      onSelectionChanged: (selected) {
                        setState(() => _notifyOneDayBefore = selected.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save Recurring'),
              style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56)),
            ),
          ],
        ),
      ),
    );
  }


  void _showAccountPicker(List<Account> accounts) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: accounts.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(accounts[index].name),
          onTap: () {
            setState(() => _selectedAccount = accounts[index]);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showCategoryPicker(List<Category> categories) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final filtered =
            categories.where((c) => c.type.name == _type.name).toList();
        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) => ListTile(
            leading: Icon(AppIcons.getIcon(filtered[index].icon)),
            title: Text(filtered[index].name),
            onTap: () {
              setState(() => _selectedCategory = filtered[index]);
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}
