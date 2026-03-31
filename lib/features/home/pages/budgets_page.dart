import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/category.dart';
import '../../../core/widgets/icon_picker.dart';
class BudgetsPage extends ConsumerWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetStatsProvider);
    final allCategoriesAsync = ref.watch(categoriesStreamProvider);
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
      ),
      body: allCategoriesAsync.when(
        data: (categories) => _BudgetList(
          categories: categories,
          budgetsAsync: budgetsAsync,
          currencyFormat: currencyFormat,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _BudgetList extends ConsumerWidget {
  final List<Category> categories;
  final AsyncValue<List<Map<String, dynamic>>> budgetsAsync;
  final NumberFormat currencyFormat;

  const _BudgetList({
    required this.categories,
    required this.budgetsAsync,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories.isEmpty) {
      return const Center(
          child: Text('No categories found. Create one to set a budget.'));
    }

    return budgetsAsync.when(
      data: (budgets) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final budgetData = _getBudgetData(category, budgets);
          return _BudgetCard(
            category: category,
            budgetData: budgetData,
            currencyFormat: currencyFormat,
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Map<String, dynamic> _getBudgetData(
      Category category, List<Map<String, dynamic>> budgets) {
    return budgets.firstWhere(
      (b) => (b['category'] as Category).id == category.id,
      orElse: () => {
        'category': category,
        'spent': 0.0,
        'limit': 0.0,
        'percent': 0.0,
      },
    );
  }
}

class _BudgetCard extends ConsumerWidget {
  final Category category;
  final Map<String, dynamic> budgetData;
  final NumberFormat currencyFormat;

  const _BudgetCard({
    required this.category,
    required this.budgetData,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double limit = budgetData['limit'] as double;
    final double spent = budgetData['spent'] as double;
    final double percent = budgetData['percent'] as double;
    final bool hasBudget = limit > 0;
    final color =
        Color(int.parse(category.color.replaceAll('0x', ''), radix: 16));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(AppIcons.getIcon(category.icon), color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                    child: _BudgetInfo(
                        category: category,
                        hasBudget: hasBudget,
                        spent: spent,
                        limit: limit,
                        currencyFormat: currencyFormat)),
                IconButton(
                  icon: Icon(hasBudget ? Symbols.edit : Symbols.add_circle,
                      color: Theme.of(context).colorScheme.primary),
                  onPressed: () => _showSetBudgetDialog(
                      context, ref, category, limit, currencyFormat),
                ),
              ],
            ),
            if (hasBudget) _BudgetProgress(percent: percent, color: color),
          ],
        ),
      ),
    );
  }

  void _showSetBudgetDialog(BuildContext context, WidgetRef ref,
      Category category, double currentLimit, NumberFormat format) {
    final controller = TextEditingController(
        text: currentLimit > 0 ? currentLimit.toString() : '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Budget for ${category.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Budget Limit',
            prefixText: '${format.currencySymbol} ',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          if (currentLimit > 0)
            TextButton(
              onPressed: () async {
                await ref
                    .read(categoryServiceProvider)
                    .setBudget(category.id, 0);
                
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () async {
              final limitValue = double.tryParse(controller.text) ?? 0;
              await ref
                  .read(categoryServiceProvider)
                  .setBudget(category.id, limitValue);
              
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _BudgetInfo extends StatelessWidget {
  final Category category;
  final bool hasBudget;
  final double spent;
  final double limit;
  final NumberFormat currencyFormat;

  const _BudgetInfo({
    required this.category,
    required this.hasBudget,
    required this.spent,
    required this.limit,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(category.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(
          hasBudget
              ? '${currencyFormat.format(spent)} of ${currencyFormat.format(limit)}'
              : 'No budget set',
          style:
              TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _BudgetProgress extends StatelessWidget {
  final double percent;
  final Color color;

  const _BudgetProgress({required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${(percent * 100).toStringAsFixed(0)}% used'),
            if (percent > 1.0)
              const Text('Over budget!',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percent.clamp(0.0, 1.0),
          backgroundColor: color.withValues(alpha: 0.1),
          color: percent > 1.0 ? Colors.red : color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
