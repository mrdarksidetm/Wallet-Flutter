import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../core/database/providers.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/currency_engine.dart';

class AddEditLoanPage extends ConsumerStatefulWidget {
  final Loan? loan;
  const AddEditLoanPage({super.key, this.loan});

  @override
  ConsumerState<AddEditLoanPage> createState() => _AddEditLoanPageState();
}

class _AddEditLoanPageState extends ConsumerState<AddEditLoanPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _personController;
  late LoanType _type;
  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.loan?.amount.toString() ?? '');
    _personController =
        TextEditingController(text: widget.loan?.person.value?.name ?? '');
    _type = widget.loan?.type ?? LoanType.borrowed;
    _selectedDate = widget.loan?.createdAt ?? DateTime.now();
    _dueDate = widget.loan?.dueDate;

    if (widget.loan != null) {
      _loadLinks();
    }
  }

  Future<void> _loadLinks() async {
    await widget.loan!.person.load();
    if (mounted) {
      setState(() {
        _personController.text = widget.loan!.person.value?.name ?? '';
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _personController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final loan = widget.loan ?? Loan();
      loan
        ..amount = double.tryParse(_amountController.text) ?? 0.0
        ..type = _type
        ..dueDate = _dueDate
        ..createdAt = _selectedDate
        ..updatedAt = DateTime.now();

      await ref
          .read(loanServiceProvider)
          .saveLoan(loan, personName: _personController.text);
      
      final personalization = ref.read(personalizationProvider);
      await ref.read(hapticServiceProvider).transaction(personalization.vibrateOnTransaction);

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedCurrency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.loan == null ? 'Add Loan' : 'Edit Loan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: SegmentedButton<LoanType>(
                segments: const [
                  ButtonSegment(
                      value: LoanType.borrowed,
                      label: Text('Borrowed'),
                      icon: Icon(Icons.arrow_downward_rounded)),
                  ButtonSegment(
                      value: LoanType.lent,
                      label: Text('Lent'),
                      icon: Icon(Icons.arrow_upward_rounded)),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
            ),
            const SizedBox(height: 32),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _personController,
              decoration: const InputDecoration(
                labelText: 'Person Name',
                prefixIcon: Icon(Icons.person_rounded),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            ListTile(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              leading: const Icon(Icons.calendar_today_rounded),
              title: const Text('Taken Date'),
              subtitle: Text(DateFormat('MMM d, yyyy').format(_selectedDate)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
            ),
            const SizedBox(height: 12),
            ListTile(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _dueDate = date);
              },
              leading: const Icon(Icons.event_rounded),
              title: const Text('Due Date'),
              subtitle: Text(_dueDate != null ? DateFormat('MMM d, yyyy').format(_dueDate!) : 'None'),
              trailing: _dueDate != null ? IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () => setState(() => _dueDate = null),
              ) : null,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save Loan'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

