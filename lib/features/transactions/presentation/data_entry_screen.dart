import 'package:flutter/material.dart';

class DataEntryScreen extends StatefulWidget {
  const DataEntryScreen({super.key});

  @override
  State<DataEntryScreen> createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  final TextEditingController _amountController = TextEditingController(text: '0');
  String _transactionType = 'expense';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Transaction'),
      ),
      body: Column(
        children: [
          // Header: Segmented Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'expense',
                    label: Text('Expense'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment(
                    value: 'income',
                    label: Text('Income'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment(
                    value: 'transfer',
                    label: Text('Transfer'),
                    icon: Icon(Icons.swap_horiz),
                  ),
                ],
                selected: {_transactionType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _transactionType = newSelection.first;
                  });
                },
              ),
            ),
          ),

          // Hero Input
          Expanded(
            flex: 2,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: TextField(
                  controller: _amountController,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: _transactionType == 'expense' 
                            ? Colors.red 
                            : _transactionType == 'income' 
                                ? Colors.green 
                                : Theme.of(context).colorScheme.onSurface,
                      ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixText: '₹',
                    prefixStyle: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ),
            ),
          ),

          // Configuration List (Tinted Cards)
          Expanded(
            flex: 3,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildConfigTile(
                  context: context,
                  icon: Icons.category,
                  title: 'Category',
                  subtitle: 'Select category',
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildConfigTile(
                  context: context,
                  icon: Icons.account_balance_wallet,
                  title: 'Account',
                  subtitle: 'Cash',
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildConfigTile(
                  context: context,
                  icon: Icons.calendar_today,
                  title: 'Date',
                  subtitle: 'Today',
                  color: Colors.purple,
                ),
                const SizedBox(height: 12),
                _buildConfigTile(
                  context: context,
                  icon: Icons.note,
                  title: 'Note',
                  subtitle: 'Add a note',
                  color: Colors.teal,
                ),
              ],
            ),
          ),
          
          // Bottom Actions
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  'Save Transaction',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      color: color.withOpacity(0.05), // Lightly tinted card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Slide up ExpressiveBottomSheet here
        },
      ),
    );
  }
}
