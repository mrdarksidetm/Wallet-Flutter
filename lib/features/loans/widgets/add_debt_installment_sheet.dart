import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/models/account.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/database/providers.dart';
import '../../../core/services/currency_engine.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/widgets/expressive_bottom_sheet.dart';
import '../../../core/widgets/primary_atelier_button.dart';

/// Bottom Sheet modal to record a partial repayment/installment for a Loan or Debt
class AddDebtInstallmentSheet extends ConsumerStatefulWidget {
  final Loan loan;
  final double remainingAmount;

  const AddDebtInstallmentSheet({
    super.key,
    required this.loan,
    required this.remainingAmount,
  });

  static Future<void> show(
    BuildContext context, {
    required Loan loan,
    required double remainingAmount,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddDebtInstallmentSheet(
        loan: loan,
        remainingAmount: remainingAmount,
      ),
    );
  }

  @override
  ConsumerState<AddDebtInstallmentSheet> createState() =>
      _AddDebtInstallmentSheetState();
}

class _AddDebtInstallmentSheetState
    extends ConsumerState<AddDebtInstallmentSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  Account? _selectedAccount;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.remainingAmount > 0
          ? widget.remainingAmount.toStringAsFixed(2)
          : '',
    );
    _noteController = TextEditingController(
      text: widget.loan.type == LoanType.lent
          ? 'Debt repayment from ${widget.loan.person.value?.name ?? 'borrower'}'
          : 'Debt payment to ${widget.loan.person.value?.name ?? 'lender'}',
    );
    _loadDefaultAccount();
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

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final isLent = widget.loan.type == LoanType.lent;
      final txType = isLent ? TransactionType.income : TransactionType.expense;

      // 1. Record the transaction in database with loan tag
      final txService = ref.read(transactionServiceProvider);
      await txService.addTransaction(
        amount: amount,
        date: _selectedDate,
        type: txType,
        account: _selectedAccount!,
        person: widget.loan.person.value,
        note: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : (isLent ? 'Debt collection' : 'Debt repayment'),
        tags: ['loan_${widget.loan.id}'],
      );

      // 2. Check if this payment completes the debt
      if (amount >= widget.remainingAmount) {
        final loanRepo = ref.read(loanRepositoryProvider);
        widget.loan.isPaid = true;
        widget.loan.updatedAt = DateTime.now();
        await loanRepo.save(widget.loan);
        await ref
            .read(notificationServiceProvider)
            .cancelNotification(500000 + widget.loan.id);
      }

      final personalization = ref.read(personalizationProvider);
      await ref
          .read(hapticServiceProvider)
          .transaction(personalization.vibrateOnTransaction);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Recorded payment of ${CurrencyEngine.formatCurrency(amount, ref.read(currencyProvider))}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedCurrency = ref.watch(currencyProvider);
    final isLent = widget.loan.type == LoanType.lent;
    final accountsAsync = ref.watch(accountsStreamProvider);

    return ExpressiveBottomSheet(
      title: isLent ? 'Record Repayment' : 'Make Payment',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Info Header Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (isLent ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    isLent
                        ? Symbols.arrow_downward_rounded
                        : Symbols.arrow_upward_rounded,
                    color: isLent
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLent
                              ? '${widget.loan.person.value?.name ?? 'Person'} is paying you back'
                              : 'Paying back ${widget.loan.person.value?.name ?? 'Person'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Remaining debt: ${CurrencyEngine.formatCurrency(widget.remainingAmount, selectedCurrency)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Amount Input Field
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'Payment Amount',
                prefixText: '${CurrencyEngine.getSymbol(selectedCurrency)} ',
                prefixStyle: theme.textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Account Selector
            accountsAsync.when(
              data: (accounts) {
                if (accounts.isEmpty) return const SizedBox.shrink();
                _selectedAccount ??= accounts.first;

                return DropdownButtonFormField<Account>(
                  value: _selectedAccount,
                  decoration: InputDecoration(
                    labelText: isLent ? 'Deposit Into Account' : 'Pay From Account',
                    prefixIcon: const Icon(Symbols.account_balance_rounded),
                    filled: true,
                    fillColor:
                        colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  items: accounts.map((acc) {
                    return DropdownMenuItem(
                      value: acc,
                      child: Text(
                        '${acc.name} (${CurrencyEngine.formatCurrency(acc.balance, selectedCurrency)})',
                      ),
                    );
                  }).toList(),
                  onChanged: (acc) => setState(() => _selectedAccount = acc),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // Note Input
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Note / Memo',
                prefixIcon: const Icon(Symbols.notes_rounded),
                filled: true,
                fillColor:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Date Picker Tile
            ListTile(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
              leading: const Icon(Symbols.calendar_today_rounded),
              title: const Text('Payment Date'),
              subtitle: Text(DateFormat.yMMMd().format(_selectedDate)),
              trailing: const Icon(Symbols.edit_calendar_rounded, size: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Submit Button
            PrimaryAtelierButton(
              onPressed: _isSaving ? null : _save,
              label: Text(
                _isSaving ? 'Recording...' : 'Record Installment',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Symbols.check_rounded, color: Colors.white),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
