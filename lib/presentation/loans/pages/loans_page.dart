import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class LoansPage extends StatelessWidget {
  const LoansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'en_IN');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans & Debts'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLoanSection(
            context,
            'Borrowed',
            'You owe others',
            [
              _LoanItem(name: 'Rahul', amount: 5000, date: '2 days ago', type: 'Borrowed'),
              _LoanItem(name: 'Bank EMI', amount: 12000, date: 'Due in 5 days', type: 'Borrowed'),
            ],
            Colors.red,
          ),
          const SizedBox(height: 32),
          _buildLoanSection(
            context,
            'Lent',
            'Others owe you',
            [
              _LoanItem(name: 'Amit', amount: 2500, date: 'Last week', type: 'Lent'),
            ],
            Colors.green,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Show Add Loan Dialog/Sheet
        },
        label: const Text('Add Loan'),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildLoanSection(BuildContext context, String title, String subtitle, List<_LoanItem> items, Color color) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        ...items.map((item) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(item.type == 'Lent' ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: color),
            ),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item.date),
            trailing: Text(
              '₹${item.amount}',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: color),
            ),
          ),
        )),
      ],
    );
  }
}

class _LoanItem {
  final String name;
  final double amount;
  final String date;
  final String type;

  _LoanItem({required this.name, required this.amount, required this.date, required this.type});
}
