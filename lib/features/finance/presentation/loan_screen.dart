import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../shared/widgets/paisa_list_tile.dart';
import '../../../shared/widgets/app_button.dart';
import 'package:wallet/core/theme/colors.dart';

class LoanScreen extends ConsumerStatefulWidget {
  const LoanScreen({super.key});

  @override
  ConsumerState<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends ConsumerState<LoanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loansAsync = ref.watch(loansStreamProvider);
    final personsAsync = ref.watch(personsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Lent'), Tab(text: 'Borrowed'), Tab(text: 'People')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Lent List
          loansAsync.when(
            data: (loans) => _LoanList(
              loans: loans.where((l) => l.type == LoanType.lent).toList(),
              ref: ref,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
          // Borrowed List
          loansAsync.when(
            data: (loans) => _LoanList(
              loans: loans.where((l) => l.type == LoanType.borrowed).toList(),
              ref: ref,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
          // People List
          personsAsync.when(
            data: (persons) => _PersonList(persons: persons, ref: ref),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 2) {
            _showAddPersonDialog(context, ref);
          } else {
            _showAddLoanDialog(context, ref);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddLoanDialog(BuildContext context, WidgetRef ref) {
    final persons = ref.read(personsStreamProvider).value ?? [];
    if (persons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a person first.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AddLoanDialog(
        persons: persons,
        initialType: _tabController.index == 1 ? LoanType.borrowed : LoanType.lent,
      ),
    );
  }

  void _showAddPersonDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (_) => const AddPersonDialog());
  }
}

class _LoanList extends StatelessWidget {
  final List<Loan> loans;
  final WidgetRef ref;
  const _LoanList({required this.loans, required this.ref});

  @override
  Widget build(BuildContext context) {
    if (loans.isEmpty) return const Center(child: Text('No loans found.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: loans.length,
      itemBuilder: (context, index) {
        final loan = loans[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedCornerShape(16),
          child: ListTile(
            title: Text(loan.person.value?.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(loan.note ?? 'No note'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${loan.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: loan.isPaid ? Colors.grey : (loan.type == LoanType.lent ? AppColors.income : AppColors.expense),
                  ),
                ),
                if (loan.isPaid) const Text('SETTLED', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            onTap: () {
              ref.read(loanServiceProvider).markAsPaid(loan, !loan.isPaid);
            },
          ),
        );
      },
    );
  }
}

class _PersonList extends StatelessWidget {
  final List<Person> persons;
  final WidgetRef ref;
  const _PersonList({required this.persons, required this.ref});

  @override
  Widget build(BuildContext context) {
    if (persons.isEmpty) return const Center(child: Text('No people found.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: persons.length,
      itemBuilder: (context, index) {
        final person = persons[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(person.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                ref.read(personServiceProvider).deletePerson(person.id);
              },
            ),
          ),
        );
      },
    );
  }
}

class AddPersonDialog extends ConsumerStatefulWidget {
  const AddPersonDialog({super.key});

  @override
  ConsumerState<AddPersonDialog> createState() => _AddPersonDialogState();
}

class _AddPersonDialogState extends ConsumerState<AddPersonDialog> {
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Person'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(labelText: 'Name'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        AppButton(
          onPressed: () async {
            if (_nameController.text.isNotEmpty) {
              await ref.read(personServiceProvider).addPerson(
                name: _nameController.text,
                color: '0xFF2196F3',
              );
              if (mounted) Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class AddLoanDialog extends ConsumerStatefulWidget {
  final List<Person> persons;
  final LoanType initialType;
  const AddLoanDialog({super.key, required this.persons, required this.initialType});

  @override
  ConsumerState<AddLoanDialog> createState() => _AddLoanDialogState();
}

class _AddLoanDialogState extends ConsumerState<AddLoanDialog> {
  late Person _selectedPerson;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedPerson = widget.persons.first;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add ${widget.initialType == LoanType.lent ? "Lent" : "Borrowed"} Loan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<Person>(
            value: _selectedPerson,
            items: widget.persons.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
            onChanged: (val) => setState(() => _selectedPerson = val!),
            decoration: const InputDecoration(labelText: 'Person'),
          ),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Note'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        AppButton(
          onPressed: () async {
            final amount = double.tryParse(_amountController.text);
            if (amount != null && amount > 0) {
              await ref.read(loanServiceProvider).addLoan(
                person: _selectedPerson,
                amount: amount,
                type: widget.initialType,
                note: _noteController.text,
              );
              if (mounted) Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
