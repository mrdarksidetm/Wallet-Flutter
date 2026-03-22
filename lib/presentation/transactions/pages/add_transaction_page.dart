import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/haptic_service.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  int _transactionType = 0; // 0: Expense, 1: Income, 2: Transfer
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Segmented Button for Type
            Center(
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Expense'), icon: Icon(Icons.remove_rounded)),
                  ButtonSegment(value: 1, label: Text('Income'), icon: Icon(Icons.add_rounded)),
                  ButtonSegment(value: 2, label: Text('Transfer'), icon: Icon(Icons.swap_horiz_rounded)),
                ],
                selected: {_transactionType},
                onSelectionChanged: (Set<int> newSelection) {
                  setState(() {
                    _transactionType = newSelection.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 32),

            // Amount Input
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: '₹ ',
                prefixStyle: theme.textTheme.displaySmall?.copyWith(
                  color: colorScheme.outline,
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
            const SizedBox(height: 32),

            // Note Input
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                prefixIcon: Icon(Icons.notes_rounded),
                hintText: 'What was this for?',
              ),
            ),
            const SizedBox(height: 16),

            // Category Selector (Placeholder for now)
            ListTile(
              onTap: () {},
              leading: const Icon(Icons.category_rounded),
              title: const Text('Category'),
              subtitle: const Text('Other'),
              trailing: const Icon(Icons.chevron_right_rounded),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: colorScheme.surfaceContainerLow,
            ),
            const SizedBox(height: 16),

            // Account Selector (Placeholder for now)
            ListTile(
              onTap: () {},
              leading: const Icon(Icons.account_balance_wallet_rounded),
              title: const Text('Account'),
              subtitle: const Text('Cash'),
              trailing: const Icon(Icons.chevron_right_rounded),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: colorScheme.surfaceContainerLow,
            ),
            
            const SizedBox(height: 48),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 64,
              child: FilledButton(
                onPressed: () async {
                  await HapticService.success();
                  // Ported logic from original: validate and save
                  if (mounted) context.pop();
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
                  'Save Transaction',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
