import 'dart:ui';
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
import '../../../core/widgets/expressive_shape.dart';
import '../../../core/services/currency_engine.dart';
import '../../../core/widgets/app_back_button.dart';
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

  // People & Debt/Loan Integration
  Person? _selectedPerson;
  Loan? _selectedLinkedLoan;
  bool _isNewLoanCreation = false;
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

    // Check if this transaction has a linked loan tag
    Loan? linkedLoan;
    if (tx.tags != null) {
      for (final tag in tx.tags!) {
        if (tag.startsWith('loan_')) {
          final loanId = int.tryParse(tag.replaceFirst('loan_', ''));
          if (loanId != null) {
            linkedLoan = await ref.read(loanRepositoryProvider).getById(loanId);
            if (linkedLoan != null) break;
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _transactionType = tx.type;
        _amountController.text = tx.amount > 0 ? tx.amount.toString() : '';
        _noteController.text = tx.note ?? '';
        _selectedIcon = tx.icon;
        _selectedColor = tx.color;
        _selectedAccount = acc;
        _selectedCategory = cat;
        _selectedTransferAccount = tx.transferAccount.value;
        _selectedPerson = tx.person.value;
        _selectedDateTime = tx.date;
        _selectedLinkedLoan = linkedLoan;
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
    final effectiveIcon =
        _selectedIcon ?? _selectedCategory?.icon ?? 'category';

    return Scaffold(
      appBar: _buildAppBar(colorScheme),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeSelector(),
            const SizedBox(height: 28),

            // Enlarged Clean Amount Input with persistent active currency symbol and font variations
            _buildAmountInput(theme, colorScheme, effectiveColor),

            const SizedBox(height: 28),

            _buildNoteInput(),
            const SizedBox(height: 16),
            _buildDateTimePicker(colorScheme),
            const SizedBox(height: 16),

            // Debt Payment / Collection Integration Section (Placed below date & time)
            if (_transactionType == TransactionType.expense ||
                _transactionType == TransactionType.income) ...[
              _buildDebtIntegrationCard(theme, colorScheme),
              const SizedBox(height: 16),
            ],

            // Category & Icon section (Disabled/hidden when a debt repayment or collection is initiated)
            if (_transactionType != TransactionType.transfer) ...[
              if (_selectedLinkedLoan != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Category is not required for debt repayments or collections.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                _buildCategorySelector(colorScheme),
                const SizedBox(height: 16),
                _buildIconAndColorOverrides(
                    theme, colorScheme, effectiveIcon, effectiveColor),
              ],
              const SizedBox(height: 24),
            ],

            _buildPeopleSection(theme, colorScheme),
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
    if (_selectedCategory != null) {
      return _selectedCategory!.color.parseHexColor();
    }
    return colorScheme.primary;
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme) {
    return AppBar(
      title: Text(
          widget.transaction == null ? 'Add Transaction' : 'Edit Transaction'),
      leading: AppBackButton(
        icon: Symbols.close_rounded,
        onPressed: () => context.pop(),
      ),
      actions: [
        if (widget.transaction != null)
          IconButton(
            onPressed: _delete,
            icon: Icon(Symbols.delete_rounded, color: colorScheme.error),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Center(
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
            _selectedCategory = null;
            _selectedLinkedLoan = null;
          });
        },
      ),
    );
  }

  // --- Large Clean Amount Input with persistent active currency symbol & font variations ---
  Widget _buildAmountInput(
      ThemeData theme, ColorScheme colorScheme, Color effectiveColor) {
    final selectedCurrency = ref.watch(currencyProvider);
    final symbol = CurrencyEngine.getSymbol(selectedCurrency);

    const amountFontVariations = [
      FontVariation('GRAD', 50.0),
      FontVariation('wght', 585.0),
      FontVariation('wdth', 120.0),
      FontVariation('ROND', 19.0),
      FontVariation('opsz', 68.0),
    ];

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Currency symbol stays permanently visible and active
            Text(
              symbol,
              style: TextStyle(
                fontSize: 48,
                color: effectiveColor,
                letterSpacing: -1.0,
                fontVariations: amountFontVariations,
              ),
            ),
            const SizedBox(width: 6),
            IntrinsicWidth(
              child: TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 48,
                  color: effectiveColor,
                  letterSpacing: -1.0,
                  fontVariations: amountFontVariations,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(
                    fontSize: 48,
                    color: colorScheme.onSurface.withValues(alpha: 0.22),
                    letterSpacing: -1.0,
                    fontVariations: amountFontVariations,
                  ),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Debt Payment (Expense) and Collection (Income) Integration ---
  Widget _buildDebtIntegrationCard(ThemeData theme, ColorScheme colorScheme) {
    final isExpense = _transactionType == TransactionType.expense;
    final targetLoanType = isExpense ? LoanType.borrowed : LoanType.lent;
    final loansAsync = ref.watch(loansStreamProvider);
    final selectedCurrency = ref.watch(currencyProvider);

    return loansAsync.when(
      data: (loans) {
        final activeDebts =
            loans.where((l) => l.type == targetLoanType && !l.isPaid).toList();

        if (activeDebts.isEmpty && _selectedLinkedLoan == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _selectedLinkedLoan != null
                ? (isExpense
                    ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                    : const Color(0xFF10B981).withValues(alpha: 0.12))
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _selectedLinkedLoan != null
                  ? (isExpense
                      ? const Color(0xFFEF4444).withValues(alpha: 0.4)
                      : const Color(0xFF10B981).withValues(alpha: 0.4))
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: _selectedLinkedLoan != null ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isExpense
                        ? Symbols.money_off_rounded
                        : Symbols.attach_money_rounded,
                    size: 20,
                    color: isExpense
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isExpense
                          ? 'Repay a Borrowed Debt'
                          : 'Collect a Lent Debt',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_selectedLinkedLoan != null)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      tooltip: 'Unlink debt',
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        setState(() {
                          _selectedLinkedLoan = null;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Dropdown to pick active debt
              DropdownButtonFormField<Loan?>(
                value: _selectedLinkedLoan,
                decoration: InputDecoration(
                  labelText: isExpense ? 'Select Debt to Repay' : 'Select Debt to Collect',
                  hintText: 'None (Regular transaction)',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: [
                  const DropdownMenuItem<Loan?>(
                    value: null,
                    child: Text('None (Regular transaction)'),
                  ),
                  ...activeDebts.map((loan) {
                    final personName = loan.person.value?.name ?? 'Contact';
                    return DropdownMenuItem<Loan?>(
                      value: loan,
                      child: Text(
                        '$personName - ${CurrencyEngine.formatCurrency(loan.amount, selectedCurrency)}',
                      ),
                    );
                  }),
                ],
                onChanged: (loan) {
                  setState(() {
                    _selectedLinkedLoan = loan;
                    if (loan != null) {
                      _selectedCategory = null;
                      if (loan.person.value != null) {
                        _selectedPerson = loan.person.value;
                      }
                      if (_noteController.text.isEmpty) {
                        _noteController.text = isExpense
                            ? 'Debt repayment to ${loan.person.value?.name ?? 'lender'}'
                            : 'Debt collection from ${loan.person.value?.name ?? 'borrower'}';
                      }
                    }
                  });
                },
              ),

              if (_selectedLinkedLoan != null) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total debt: ${CurrencyEngine.formatCurrency(_selectedLinkedLoan!.amount, selectedCurrency)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _amountController.text =
                              _selectedLinkedLoan!.amount.toStringAsFixed(2);
                        });
                      },
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Fill Full Amount'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
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
      subtitle:
          Text(DateFormat('MMM dd, yyyy - hh:mm a').format(_selectedDateTime)),
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

  Widget _buildIconAndColorOverrides(ThemeData theme, ColorScheme colorScheme,
      String effectiveIcon, Color effectiveColor) {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            onTap: _pickIcon,
            leading: Icon(AppIcons.getIcon(effectiveIcon), color: effectiveColor),
            title: const Text('Icon'),
            subtitle: Text(effectiveIcon),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: colorScheme.surfaceContainerLow,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ListTile(
            onTap: _pickColor,
            leading: CircleAvatar(backgroundColor: effectiveColor, radius: 14),
            title: const Text('Color'),
            subtitle: Text(_selectedColor != null ? 'Custom' : 'Category'),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: colorScheme.surfaceContainerLow,
          ),
        ),
      ],
    );
  }

  Widget _buildPeopleSection(ThemeData theme, ColorScheme colorScheme) {
    final peopleAsync = ref.watch(personsStreamProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          onTap: () => _showPersonPicker(peopleAsync.value ?? []),
          leading: const Icon(Icons.person_outline_rounded),
          title: const Text('Person (Optional)'),
          subtitle: Text(_selectedPerson?.name ?? 'None'),
          trailing: _selectedPerson != null
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => setState(() => _selectedPerson = null),
                )
              : const Icon(Icons.chevron_right_rounded),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          tileColor: colorScheme.surfaceContainerLow,
        ),
        if (_selectedPerson != null &&
            _transactionType != TransactionType.transfer &&
            _selectedLinkedLoan == null) ...[
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _isNewLoanCreation,
            onChanged: (val) =>
                setState(() => _isNewLoanCreation = val ?? false),
            title: Text(_transactionType == TransactionType.income
                ? 'Record as money borrowed (Debt to pay back)'
                : 'Record as money lent (Debt owed to you)'),
            subtitle: const Text('Creates a new entry in Loans & Debts'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ],
    );
  }

  Widget _buildAccountSelector(ColorScheme colorScheme) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    return accountsAsync.when(
      data: (accounts) {
        if (accounts.isEmpty) {
          return const ListTile(
            title: Text('No accounts available'),
            subtitle: Text('Please create an account first'),
          );
        }
        _selectedAccount ??= accounts.first;
        return ListTile(
          onTap: () => _showAccountPicker(accounts, isTransfer: false),
          leading: const Icon(Symbols.account_balance),
          title: Text(
              _transactionType == TransactionType.transfer ? 'From Account' : 'Account'),
          subtitle: Text(_selectedAccount?.name ?? 'Select Account'),
          trailing: const Icon(Icons.chevron_right_rounded),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          tileColor: colorScheme.surfaceContainerLow,
        );
      },
      loading: () => const ListTile(title: Text('Loading accounts...')),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildTransferAccountSelector(ColorScheme colorScheme) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    return accountsAsync.when(
      data: (accounts) {
        final available =
            accounts.where((a) => a.id != _selectedAccount?.id).toList();
        if (available.isEmpty) return const SizedBox.shrink();
        _selectedTransferAccount ??= available.first;
        return ListTile(
          onTap: () => _showAccountPicker(available, isTransfer: true),
          leading: const Icon(Symbols.account_balance_wallet),
          title: const Text('To Account'),
          subtitle: Text(_selectedTransferAccount?.name ?? 'Select Account'),
          trailing: const Icon(Icons.chevron_right_rounded),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          tileColor: colorScheme.surfaceContainerLow,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSaveButton() {
    return PrimaryAtelierButton(
      onPressed: _save,
      label: Text(
        widget.transaction == null ? 'Save Transaction' : 'Update Transaction',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      icon: const Icon(Symbols.check_rounded, color: Colors.white),
    );
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    // Auto-assign default category if user selected a debt repayment without picking category
    if (_selectedCategory == null &&
        _transactionType != TransactionType.transfer) {
      final allCategories =
          await ref.read(categoryRepositoryProvider).getAll();
      final matchingCategories = allCategories
          .where((c) =>
              c.type.name == _transactionType.name && !c.isDeleted)
          .toList();
      if (matchingCategories.isNotEmpty) {
        _selectedCategory = matchingCategories.first;
      }
    }

    if (_selectedAccount == null ||
        (_transactionType != TransactionType.transfer &&
            _selectedLinkedLoan == null &&
            _selectedCategory == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an account and category')));
      return;
    }

    // Overbudget Check
    if (_transactionType == TransactionType.expense &&
        _selectedCategory?.budgetLimit != null) {
      final stats =
          await ref.read(statisticsServiceProvider).watchBudgets().first;
      final categoryStat = stats.firstWhere(
          (s) => s['categoryId'] == _selectedCategory!.id,
          orElse: () => {});
      if (categoryStat.isNotEmpty) {
        final spent = categoryStat['spent'] as double;
        final limit = _selectedCategory!.budgetLimit!;
        if (spent + amount > limit) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Over Budget Warning'),
              content: Text(
                  'This transaction will exceed your monthly budget for ${_selectedCategory!.name}.\n\nLimit: $limit\nCurrently Spent: $spent\nNew Total: ${spent + amount}\n\nDo you want to continue?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Continue')),
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

      final List<String> tags = [];
      if (_selectedLinkedLoan != null) {
        tags.add('loan_${_selectedLinkedLoan!.id}');
      }

      if (widget.transaction != null) {
        final updatedTx = TransactionModel()
          ..id = widget.transaction!.id
          ..amount = amount
          ..date = _selectedDateTime
          ..type = _transactionType
          ..note = _noteController.text.isNotEmpty
              ? _noteController.text
              : null
          ..icon = _selectedIcon
          ..color = _selectedColor
          ..tags = tags
          ..createdAt = widget.transaction!.createdAt
          ..updatedAt = DateTime.now();

        updatedTx.account.value = _selectedAccount;
        updatedTx.category.value = _selectedCategory;
        updatedTx.transferAccount.value = _selectedTransferAccount;
        updatedTx.person.value = _selectedPerson;

        await service.updateTransaction(widget.transaction!, updatedTx);
      } else {
        await service.addTransaction(
          amount: amount,
          date: _selectedDateTime,
          type: _transactionType,
          account: _selectedAccount!,
          category: _selectedCategory,
          note: _noteController.text.isNotEmpty
              ? _noteController.text
              : null,
          transferAccount: _selectedTransferAccount,
          icon: _selectedIcon,
          color: _selectedColor,
          person: _selectedPerson,
          tags: tags,
        );

        // New Loan creation if checkbox was ticked
        if (_isNewLoanCreation && _selectedPerson != null) {
          final loanService = ref.read(loanServiceProvider);
          final loan = Loan()
            ..amount = amount
            ..type = _transactionType == TransactionType.income
                ? LoanType.borrowed
                : LoanType.lent
            ..note = _noteController.text
            ..createdAt = _selectedDateTime
            ..updatedAt = DateTime.now();
          loan.person.value = _selectedPerson;
          await loanService.saveLoan(loan);
        }
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
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                child: Icon(Icons.add_rounded,
                    color:
                        Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              title: const Text('Add New Person',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
                title: Text(p.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: p.contact != null ? Text(p.contact!) : null,
                trailing:
                    isSelected ? Icon(Icons.check_circle, color: color) : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
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
          decoration: const InputDecoration(
              labelText: 'Name', hintText: 'Enter name...'),
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
                  ..color =
                      '0x${Colors.blue.value.toRadixString(16).toUpperCase()}'
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
          if (_transactionType == TransactionType.transfer) {
            return c.type == CategoryType.transfer;
          }
          return c.type.name == _transactionType.name;
        }).toList();

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final cat = filtered[index];
            final color = cat.color.parseHexColor();
            return ListTile(
              leading: Icon(AppIcons.getIcon(cat.icon), color: color),
              title: Text(cat.name),
              trailing: _selectedCategory?.id == cat.id
                  ? Icon(Icons.check, color: color)
                  : null,
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                  _selectedIcon = null;
                  _selectedColor = null;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _showAccountPicker(List<Account> accounts, {required bool isTransfer}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          final acc = accounts[index];
          final color = acc.color.parseHexColor();
          final isSelected = isTransfer
              ? _selectedTransferAccount?.id == acc.id
              : _selectedAccount?.id == acc.id;

          return ListTile(
            leading: Icon(AppIcons.getIcon(acc.icon), color: color),
            title: Text(acc.name),
            subtitle: Text(
                '${acc.type.name.toUpperCase()} • ${CurrencyEngine.formatCurrency(acc.balance, ref.read(currencyProvider))}'),
            trailing: isSelected ? Icon(Icons.check, color: color) : null,
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

  void _pickIcon() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => IconPickerWidget(
        selectedIcon: _selectedIcon ?? _selectedCategory?.icon ?? 'shopping_cart',
        selectedColor: _selectedColor != null
            ? _selectedColor!.parseHexColor()
            : _selectedCategory?.color.parseHexColor() ?? Colors.blue,
        onIconSelected: (icon) {
          setState(() => _selectedIcon = icon);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _pickColor() async {
    Color pickerColor = _selectedColor != null
        ? _selectedColor!.parseHexColor()
        : _selectedCategory?.color.parseHexColor() ?? Colors.blue;

    final color = await showColorPickerDialog(
      context,
      pickerColor,
      title: Text('Select Color', style: Theme.of(context).textTheme.titleLarge),
      width: 40,
      height: 40,
      spacing: 0,
      runSpacing: 0,
      borderRadius: 0,
      wheelDiameter: 165,
      enableOpacity: false,
      showColorCode: false,
      colorCodeHasColor: false,
      pickersEnabled: <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
        ColorPickerType.bw: false,
        ColorPickerType.custom: false,
        ColorPickerType.wheel: true,
      },
    );

    setState(() {
      _selectedColor =
          '0x${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    });
  }
}
