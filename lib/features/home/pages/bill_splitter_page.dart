import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/providers.dart';

class BillSplitterPage extends ConsumerStatefulWidget {
  const BillSplitterPage({super.key});

  @override
  ConsumerState<BillSplitterPage> createState() => _BillSplitterPageState();
}

class _BillSplitterPageState extends ConsumerState<BillSplitterPage> {
  final _amountController = TextEditingController();
  final _peopleController = TextEditingController(text: '2');
  final _taxController = TextEditingController(text: '0');
  final _tipController = TextEditingController(text: '0');

  double _totalPerPerson = 0.0;
  double _grandTotal = 0.0;

  @override
  void dispose() {
    _amountController.dispose();
    _peopleController.dispose();
    _taxController.dispose();
    _tipController.dispose();
    super.dispose();
  }

  void _calculate() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final people = int.tryParse(_peopleController.text) ?? 1;
    final taxPercent = double.tryParse(_taxController.text) ?? 0.0;
    final tipPercent = double.tryParse(_tipController.text) ?? 0.0;

    if (people <= 0) return;

    final taxAmount = amount * (taxPercent / 100);
    final tipAmount = amount * (tipPercent / 100);

    setState(() {
      _grandTotal = amount + taxAmount + tipAmount;
      _totalPerPerson = _grandTotal / people;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Splitter'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Result Card
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Total Per Person',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(_totalPerPerson),
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Grand Total', style: theme.textTheme.bodyLarge),
                        Text(
                          currencyFormat.format(_grandTotal),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Inputs
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _calculate(),
              decoration: InputDecoration(
                labelText: 'Bill Amount',
                prefixIcon: const Icon(Icons.receipt_long_rounded),
                suffixText: selectedCurrency,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _peopleController,
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculate(),
              decoration: const InputDecoration(
                labelText: 'Number of People',
                prefixIcon: Icon(Icons.people_alt_rounded),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taxController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculate(),
                    decoration: const InputDecoration(
                      labelText: 'Tax (%)',
                      prefixIcon: Icon(Icons.percent_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _tipController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculate(),
                    decoration: const InputDecoration(
                      labelText: 'Tip (%)',
                      prefixIcon: Icon(Icons.volunteer_activism_rounded),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
