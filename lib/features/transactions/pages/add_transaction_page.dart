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
  List<Person> _selectedPeople = [];
  bool _splitEqually = true;
  Loan? _selectedLinkedLoan;
  bool _isDebtToggleOn = false;
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

    // Check if this transaction has a linked loan tag and person tags
    Loan? linkedLoan;
    final loadedPeople = <Person>[];
    if (tx.person.value != null) {
      loadedPeople.add(tx.person.value!);
    }

    if (tx.tags != null) {
      for (final tag in tx.tags!) {
        if (tag.startsWith('loan_')) {
          final loanId = int.tryParse(tag.replaceFirst('loan_', ''));
          if (loanId != null) {
            linkedLoan = await ref.read(loanRepositoryProvider).getById(loanId);
          }
        } else if (tag.startsWith('person_')) {
          final personId = int.tryParse(tag.replaceFirst('person_', ''));
          if (personId != null && !loadedPeople.any((p) => p.id == personId)) {
            final p = await ref.read(personRepositoryProvider).getById(personId);
            if (p != null) loadedPeople.add(p);
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
        _selectedPeople = loadedPeople;
        _selectedDateTime = tx.date;
        _selectedLinkedLoan = linkedLoan;
        _isDebtToggleOn = linkedLoan != null;
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

  Widget _buildSectionCard({
    required ColorScheme colorScheme,
    required List<Widget> children,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
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
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(colorScheme),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Segment 1: Type Selector + Extra Big Amount + Note Input
            _buildSectionCard(
              colorScheme: colorScheme,
              padding: const EdgeInsets.all(18),
              children: [
                _buildTypeSelector(),
                const SizedBox(height: 20),
                _buildAmountInput(theme, colorScheme, effectiveColor),
                const SizedBox(height: 16),
                _buildNoteInput(colorScheme),
              ],
            ),

            const SizedBox(height: 16),

            // Segment 2: Timing & Debt Toggle
            _buildSectionCard(
              colorScheme: colorScheme,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              children: [
                _buildDateTimePicker(colorScheme),
                if (_transactionType != TransactionType.transfer) ...[
                  Divider(
                    height: 1,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.15),
                  ),
                  _buildDebtSwitchTile(theme, colorScheme),
                  if (_isDebtToggleOn) ...[
                    const SizedBox(height: 8),
                    _buildDebtSelectionSubCard(theme, colorScheme),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            ),

            const SizedBox(height: 16),

            // Segment 3: Categorization & Visual Overrides (Disabled when Debt is active)
            if (_transactionType != TransactionType.transfer) ...[
              if (_isDebtToggleOn)
                _buildSectionCard(
                  colorScheme: colorScheme,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Category is not required for loan or debt transactions.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                _buildSectionCard(
                  colorScheme: colorScheme,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  children: [
                    _buildCategorySelector(colorScheme),
                    Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.15),
                    ),
                    _buildIconSelector(
                        colorScheme, effectiveIcon, effectiveColor),
                    Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.15),
                    ),
                    _buildColorSelector(colorScheme, effectiveColor),
                    const SizedBox(height: 6),
                    Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.12),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 15,
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.75),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Icon and color default to the chosen category, but can be customized above.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.8),
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
            ],

            // Segment 4: Accounts & People
            _buildSectionCard(
              colorScheme: colorScheme,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              children: [
                _buildAccountSelector(colorScheme),
                if (_transactionType == TransactionType.transfer) ...[
                  Divider(
                    height: 1,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.15),
                  ),
                  _buildTransferAccountSelector(colorScheme),
                ],
                Divider(
                  height: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.15),
                ),
                _buildPeopleSection(theme, colorScheme),
              ],
            ),

            const SizedBox(height: 32),

            // Segment 5: Primary Save Action
            _buildSaveButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Center(
      child: SegmentedButton<TransactionType>(
        style: SegmentedButton.styleFrom(
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
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
            _isDebtToggleOn = false;
            _isNewLoanCreation = false;
          });
        },
      ),
    );
  }

  // --- Extra Big Hero Amount Input with persistent active currency symbol & font variations ---
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
      padding: const EdgeInsets.symmetric(vertical: 16),
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
                fontSize: 58,
                color: effectiveColor,
                letterSpacing: -1.5,
                fontVariations: amountFontVariations,
              ),
            ),
            const SizedBox(width: 8),
            IntrinsicWidth(
              child: TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 58,
                  color: effectiveColor,
                  letterSpacing: -1.5,
                  fontVariations: amountFontVariations,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(
                    fontSize: 58,
                    color: colorScheme.onSurface.withValues(alpha: 0.22),
                    letterSpacing: -1.5,
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

  Widget _buildNoteInput(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: TextField(
        controller: _noteController,
        decoration: const InputDecoration(
          icon: Icon(Icons.notes_rounded, size: 20),
          hintText: 'Add note / memo (optional)',
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(ColorScheme colorScheme) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: _pickDateTime,
      leading: const Icon(Symbols.calendar_month),
      title: const Text('Date & Time',
          style: TextStyle(fontWeight: FontWeight.w700)),
      subtitle:
          Text(DateFormat('MMM dd, yyyy - hh:mm a').format(_selectedDateTime)),
      trailing: const Icon(Icons.chevron_right_rounded),
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

  // --- Switch style for Debt/Loan with short label ("Add to loans" / "Add to debts") ---
  Widget _buildDebtSwitchTile(ThemeData theme, ColorScheme colorScheme) {
    final isExpense = _transactionType == TransactionType.expense;
    final title = isExpense ? 'Add to loans' : 'Add to debts';
    final subtitle = isExpense
        ? 'Repay existing or create a loan'
        : 'Collect existing or create a debt';

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: _isDebtToggleOn,
      onChanged: (val) {
        setState(() {
          _isDebtToggleOn = val;
          if (!val) {
            _selectedLinkedLoan = null;
            _isNewLoanCreation = false;
          } else {
            _selectedCategory = null;
          }
        });
      },
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      secondary: Icon(
        isExpense ? Symbols.money_off_rounded : Symbols.attach_money_rounded,
        color: isExpense ? const Color(0xFFEF4444) : const Color(0xFF10B981),
      ),
    );
  }

  Widget _buildDebtSelectionSubCard(ThemeData theme, ColorScheme colorScheme) {
    final isExpense = _transactionType == TransactionType.expense;
    final targetLoanType = isExpense ? LoanType.borrowed : LoanType.lent;
    final loansAsync = ref.watch(loansStreamProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final selectedCurrency = ref.watch(currencyProvider);

    return loansAsync.when(
      data: (loans) {
        final allTransactions = transactionsAsync.valueOrNull ?? [];
        final activeDebts = loans.where((l) {
          if (l.type != targetLoanType || l.isPaid || l.isDeleted) return false;
          final installments = allTransactions.where((t) =>
              t.tags != null &&
              t.tags!.contains('loan_${l.id}') &&
              !t.isDeleted);
          final paidAmount =
              installments.fold<double>(0.0, (sum, t) => sum + t.amount);
          final remaining = l.amount - paidAmount;
          return remaining > 0.01;
        }).toList();

        return Container(
          margin: const EdgeInsets.only(top: 10, bottom: 4),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: (isExpense ? const Color(0xFFEF4444) : const Color(0xFF10B981))
                .withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (isExpense
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981))
                  .withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isExpense
                    ? 'Select existing loan or record new'
                    : 'Select existing debt or record new',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 14),

              // Dropdown to pick active debt
              DropdownButtonFormField<Loan?>(
                value: _selectedLinkedLoan,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: isExpense
                      ? 'Existing Loan to Repay'
                      : 'Existing Debt to Collect',
                  hintText: 'None (Record new debt / loan)',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.65),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: [
                  const DropdownMenuItem<Loan?>(
                    value: null,
                    child: Text('None (Record new debt / loan)'),
                  ),
                  ...activeDebts.map((loan) {
                    final personName = loan.person.value?.name ?? 'Contact';
                    final installments = allTransactions.where((t) =>
                        t.tags != null &&
                        t.tags!.contains('loan_${loan.id}') &&
                        !t.isDeleted);
                    final paidAmount = installments.fold<double>(
                        0.0, (sum, t) => sum + t.amount);
                    final remaining =
                        (loan.amount - paidAmount).clamp(0.0, double.infinity);
                    return DropdownMenuItem<Loan?>(
                      value: loan,
                      child: Text(
                        '$personName - Remaining: ${CurrencyEngine.formatCurrency(remaining, selectedCurrency)} (Total: ${CurrencyEngine.formatCurrency(loan.amount, selectedCurrency)})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ],
                onChanged: (loan) {
                  setState(() {
                    _selectedLinkedLoan = loan;
                    _selectedCategory = null;
                    if (loan != null) {
                      _isNewLoanCreation = false;
                      if (loan.person.value != null &&
                          !_selectedPeople
                              .any((p) => p.id == loan.person.value!.id)) {
                        _selectedPeople = [loan.person.value!];
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
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: ${CurrencyEngine.formatCurrency(_selectedLinkedLoan!.amount, selectedCurrency)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: () {
                          final installments = allTransactions.where((t) =>
                              t.tags != null &&
                              t.tags!.contains('loan_${_selectedLinkedLoan!.id}') &&
                              !t.isDeleted);
                          final paidAmount = installments.fold<double>(
                              0.0, (sum, t) => sum + t.amount);
                          final remaining =
                              (_selectedLinkedLoan!.amount - paidAmount)
                                  .clamp(0.0, double.infinity);
                          setState(() {
                            _amountController.text = remaining > 0
                                ? remaining.toStringAsFixed(2)
                                : _selectedLinkedLoan!.amount.toStringAsFixed(2);
                          });
                        },
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                        ),
                        child: const Text('Fill Remaining'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: CheckboxListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    value: _isNewLoanCreation,
                    onChanged: (val) =>
                        setState(() => _isNewLoanCreation = val ?? false),
                    title: Text(
                      isExpense
                          ? 'Create new loan entry in Loans & Debts'
                          : 'Create new debt entry in Loans & Debts',
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w600),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCategorySelector(ColorScheme colorScheme) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => _showCategoryPicker(categoriesAsync.value ?? []),
      leading: const Icon(Icons.category_rounded),
      title: const Text('Category',
          style: TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(_selectedCategory?.name ?? 'Select Category'),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }

  Widget _buildIconSelector(
      ColorScheme colorScheme, String effectiveIcon, Color effectiveColor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: _pickIcon,
      leading: Icon(AppIcons.getIcon(effectiveIcon), color: effectiveColor),
      title: const Text('Icon', style: TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(_selectedIcon != null
          ? effectiveIcon
          : 'Default (${_selectedCategory?.name ?? "Category"})'),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }

  Widget _buildColorSelector(ColorScheme colorScheme, Color effectiveColor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: _pickColor,
      leading: CircleAvatar(backgroundColor: effectiveColor, radius: 14),
      title: const Text('Color', style: TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(_selectedColor != null
          ? 'Custom color'
          : 'Default (${_selectedCategory?.name ?? "Category"})'),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }

  Widget _buildPeopleSection(ThemeData theme, ColorScheme colorScheme) {
    final peopleAsync = ref.watch(personsStreamProvider);
    final selectedCurrency = ref.watch(currencyProvider);
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (_selectedPeople.isEmpty) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: () => _showPersonPicker(peopleAsync.value ?? []),
        leading: const Icon(Icons.people_outline_rounded),
        title: const Text('People / Contacts',
            style: TextStyle(fontWeight: FontWeight.w700)),
        subtitle: const Text('None (Optional)'),
        trailing: const Icon(Icons.chevron_right_rounded),
      );
    }

    final perPersonAmount = _selectedPeople.isNotEmpty
        ? amount / _selectedPeople.length
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.people_rounded, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'People (${_selectedPeople.length})',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => _showPersonPicker(peopleAsync.value ?? []),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add / Edit'),
                style:
                    TextButton.styleFrom(visualDensity: VisualDensity.compact),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedPeople.map((p) {
              final pColor = p.color.parseHexColor();
              return InputChip(
                avatar: PersonAvatar(person: p, radius: 10, fontSize: 8),
                label: Text(p.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12)),
                backgroundColor: pColor.withValues(alpha: 0.12),
                side: BorderSide(
                    color: pColor.withValues(alpha: 0.3), width: 0.6),
                onDeleted: () {
                  setState(() {
                    _selectedPeople.removeWhere((item) => item.id == p.id);
                  });
                },
                deleteIconColor: pColor,
              );
            }).toList(),
          ),
          if (_isDebtToggleOn && _selectedPeople.length > 1) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.call_split_rounded,
                      size: 20, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Split bill equally (${CurrencyEngine.formatCurrency(perPersonAmount, selectedCurrency)} each)',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          'Add separate ${_transactionType == TransactionType.income ? "debts" : "loans"} for each person',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _splitEqually,
                    onChanged: (val) => setState(() => _splitEqually = val),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountSelector(ColorScheme colorScheme) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    return accountsAsync.when(
      data: (accounts) {
        if (accounts.isEmpty) {
          return const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('No accounts available'),
            subtitle: Text('Please create an account first'),
          );
        }
        _selectedAccount ??= accounts.first;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: () => _showAccountPicker(accounts, isTransfer: false),
          leading: const Icon(Symbols.account_balance),
          title: Text(
            _transactionType == TransactionType.transfer
                ? 'From Account'
                : 'Account',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(_selectedAccount?.name ?? 'Select Account'),
          trailing: const Icon(Icons.chevron_right_rounded),
        );
      },
      loading: () => const ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('Loading accounts...'),
      ),
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
          contentPadding: EdgeInsets.zero,
          onTap: () => _showAccountPicker(available, isTransfer: true),
          leading: const Icon(Symbols.account_balance_wallet),
          title: const Text('To Account',
              style: TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(_selectedTransferAccount?.name ?? 'Select Account'),
          trailing: const Icon(Icons.chevron_right_rounded),
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
            !_isDebtToggleOn &&
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
      for (final p in _selectedPeople) {
        tags.add('person_${p.id}');
      }

      final primaryPerson =
          _selectedPeople.isNotEmpty ? _selectedPeople.first : null;

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
        updatedTx.person.value = primaryPerson;

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
          person: primaryPerson,
          tags: tags,
        );

        // New Loan / Debt creation
        if ((_isNewLoanCreation ||
                (_isDebtToggleOn && _selectedLinkedLoan == null)) &&
            _selectedPeople.isNotEmpty) {
          final loanService = ref.read(loanServiceProvider);
          final loanType = _transactionType == TransactionType.income
              ? LoanType.borrowed
              : LoanType.lent;

          if (_splitEqually && _selectedPeople.length > 1) {
            final splitAmount = amount / _selectedPeople.length;
            for (final p in _selectedPeople) {
              final loan = Loan()
                ..amount = splitAmount
                ..type = loanType
                ..note = _noteController.text.isNotEmpty
                    ? '${_noteController.text} (Split ${p.name})'
                    : 'Split bill with ${p.name}'
                ..createdAt = _selectedDateTime
                ..updatedAt = DateTime.now();
              loan.person.value = p;
              await loanService.saveLoan(loan);
            }
          } else {
            for (final p in _selectedPeople) {
              final loan = Loan()
                ..amount = _selectedPeople.length > 1
                    ? (amount / _selectedPeople.length)
                    : amount
                ..type = loanType
                ..note = _noteController.text.isNotEmpty
                    ? _noteController.text
                    : 'Debt with ${p.name}'
                ..createdAt = _selectedDateTime
                ..updatedAt = DateTime.now();
              loan.person.value = p;
              await loanService.saveLoan(loan);
            }
          }
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
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          return ExpressiveBottomSheet(
            title: 'Select People',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.person_add_rounded,
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  title: const Text('Add New Person',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(sheetContext);
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
                        Text('No people found. Add a person above.'),
                      ],
                    ),
                  ),
                ...people.map((p) {
                  final color = p.color.parseHexColor();
                  final isSelected =
                      _selectedPeople.any((item) => item.id == p.id);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          if (!_selectedPeople.any((item) => item.id == p.id)) {
                            _selectedPeople.add(p);
                          }
                        } else {
                          _selectedPeople.removeWhere((item) => item.id == p.id);
                        }
                      });
                      setSheetState(() {});
                    },
                    secondary: PersonAvatar(person: p, radius: 20),
                    title: Text(p.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: p.contact != null ? Text(p.contact!) : null,
                    activeColor: color,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  );
                }),
                const SizedBox(height: 16),
                PrimaryAtelierButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  label: Text('Done (${_selectedPeople.length} Selected)'),
                  icon: const Icon(Icons.check_rounded, color: Colors.white),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
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
                  if (!_selectedPeople.any((p) => p.name == person.name)) {
                    _selectedPeople.add(person);
                  }
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
        selectedIcon:
            _selectedIcon ?? _selectedCategory?.icon ?? 'shopping_cart',
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
      showColorCode: true,
      colorCodeHasColor: true,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: true,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
    );

    setState(() {
      _selectedColor =
          '0x${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    });
  }
}
