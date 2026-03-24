import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/auxiliary_models.dart';

class LoansPage extends ConsumerWidget {
  const LoansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'en_IN');
    final loansAsync = ref.watch(loansStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans & Debts'),
      ),
      body: loansAsync.when(
        data: (loans) {
          final borrowed = loans.where((l) => l.type == LoanType.borrowed).toList();
          final lent = loans.where((l) => l.type == LoanType.lent).toList();

          if (loans.isEmpty) {
            return const Center(child: Text('No loans found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (borrowed.isNotEmpty)
                _buildLoanSection(
                  context,
                  'Borrowed',
                  'You owe others',
                  borrowed,
                  Colors.red,
                  currencyFormat,
                ),
              if (borrowed.isNotEmpty && lent.isNotEmpty) const SizedBox(height: 32),
              if (lent.isNotEmpty)
                _buildLoanSection(
                  context,
                  'Lent',
                  'Others owe you',
                  lent,
                  Colors.green,
                  currencyFormat,
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add_loan'),
        label: const Text('Add Loan'),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildLoanSection(
    BuildContext context,
    String title,
    String subtitle,
    List<Loan> items,
    Color color,
    NumberFormat format,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        ...items.map((item) {
          final personName = item.person.value?.name ?? 'Unknown';
          final dateStr = item.dueDate != null ? 'Due: ${DateFormat('MMM d').format(item.dueDate!)}' : 'No due date';
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(item.type == LoanType.lent ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: color),
              ),
              title: Text(personName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(dateStr),
              trailing: Text(
                format.format(item.amount),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: color),
              ),
            ),
          );
        }),
      ],
    );
  }
}
