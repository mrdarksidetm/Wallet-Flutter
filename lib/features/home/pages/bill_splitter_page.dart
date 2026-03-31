import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../core/widgets/expressive_bottom_sheet.dart';

class BillSplitterPage extends ConsumerStatefulWidget {
  const BillSplitterPage({super.key});

  @override
  ConsumerState<BillSplitterPage> createState() => _BillSplitterPageState();
}

class _BillSplitterPageState extends ConsumerState<BillSplitterPage> {
  final _amountController = TextEditingController();
  final _taxController = TextEditingController(text: '0');
  final _tipController = TextEditingController(text: '0');
  final _manualNameController = TextEditingController();

  final List<Person> _selectedPeople = [];
  final List<String> _manualPeople = [];

  double _totalPerPerson = 0.0;
  double _grandTotal = 0.0;

  @override
  void dispose() {
    _amountController.dispose();
    _taxController.dispose();
    _tipController.dispose();
    _manualNameController.dispose();
    super.dispose();
  }

  void _calculate() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final totalPeopleCount = _selectedPeople.length + _manualPeople.length + 1; // +1 for user

    final taxPercent = double.tryParse(_taxController.text) ?? 0.0;
    final tipPercent = double.tryParse(_tipController.text) ?? 0.0;

    final taxAmount = amount * (taxPercent / 100);
    final tipAmount = amount * (tipPercent / 100);

    setState(() {
      _grandTotal = amount + taxAmount + tipAmount;
      _totalPerPerson = _grandTotal / totalPeopleCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);
    final peopleAsync = ref.watch(personsStreamProvider);

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
              elevation: 0,
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Total Per Person',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(_totalPerPerson),
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onPrimaryContainer,
                        letterSpacing: -1,
                      ),
                    ),
                    const Divider(height: 32, thickness: 0.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Grand Total', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Text(
                          currencyFormat.format(_grandTotal),
                          style: TextStyle(fontWeight: FontWeight.w900, color: colorScheme.primary),
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _calculate(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Bill Amount',
                prefixIcon: const Icon(Icons.receipt_long_rounded),
                suffixText: selectedCurrency,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
                    decoration: InputDecoration(
                      labelText: 'Tax (%)',
                      prefixIcon: const Icon(Icons.percent_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _tipController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculate(),
                    decoration: InputDecoration(
                      labelText: 'Tip (%)',
                      prefixIcon: const Icon(Icons.volunteer_activism_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // People Selection Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Split With (${_selectedPeople.length + _manualPeople.length + 1})',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _showAddPersonDialog(peopleAsync.value ?? []),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Person'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // List of people
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
                  title: const Text('You'),
                  subtitle: Text('Paying ${currencyFormat.format(_totalPerPerson)}'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  tileColor: colorScheme.surfaceContainerLow,
                ),
                const SizedBox(height: 8),
                ..._selectedPeople.map((p) => _buildPersonTile(p.name, p.color, () {
                  setState(() {
                    _selectedPeople.remove(p);
                    _calculate();
                  });
                })),
                ..._manualPeople.map((name) => _buildPersonTile(name, '0xFF9E9E9E', () {
                  setState(() {
                    _manualPeople.remove(name);
                    _calculate();
                  });
                })),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonTile(String name, String colorStr, VoidCallback onDelete) {
    final color = Color(int.parse(colorStr.replaceAll('0x', '0xFF'), radix: 16));
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Text(name[0].toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
        title: Text(name),
        subtitle: Text('Owes ${currencyFormat.format(_totalPerPerson)}'),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.red),
          onPressed: onDelete,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
    );
  }

  void _showAddPersonDialog(List<Person> availablePeople) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ExpressiveBottomSheet(
        title: 'Add to Bill',
        child: Column(
          children: [
            // Manual Entry
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _manualNameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter name manually...',
                        prefixIcon: Icon(Icons.edit_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () {
                      if (_manualNameController.text.isNotEmpty) {
                        setState(() {
                          _manualPeople.add(_manualNameController.text);
                          _manualNameController.clear();
                          _calculate();
                        });
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Contacts list
            if (availablePeople.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No saved people found.'),
              ),
            ...availablePeople.where((p) => !_selectedPeople.contains(p)).map((p) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(int.parse(p.color.replaceAll('0x', '0xFF'), radix: 16)),
                child: Text(p.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
              ),
              title: Text(p.name),
              onTap: () {
                setState(() {
                  _selectedPeople.add(p);
                  _calculate();
                });
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }
}
