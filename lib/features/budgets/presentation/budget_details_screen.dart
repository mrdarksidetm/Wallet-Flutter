import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/models/auxiliary_models.dart';
import 'controllers/budget_controller.dart';

class BudgetDetailsScreen extends ConsumerWidget {
  final Budget budget;

  const BudgetDetailsScreen({super.key, required this.budget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF5F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B1B1F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Budget details',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            color: const Color(0xFF1B1B1F),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFE53935)), // Red delete icon
            onPressed: () {
              ref.read(budgetControllerProvider.notifier).deleteBudget(budget.id);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
         child: Column(
            children: [
               BudgetDetailsHeader(budget: budget),
               const SizedBox(height: 16),
               const ShowBudgetToggle(),
               const SizedBox(height: 16),
               const SpendingTrendChart(),
               const SizedBox(height: 16),
               const CategoryBreakdownCard(),
            ],
         ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF90594C), // Terracotta Fab
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text('Edit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}

class BudgetDetailsHeader extends StatelessWidget {
  final Budget budget;
  
  const BudgetDetailsHeader({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    // Calculate stats
    final budgetLimit = budget.amount;
    final categoryName = budget.category.value?.name ?? 'Unknown';
    const double spent = 0; 
    final remaining = budgetLimit - spent;
    final progress = budgetLimit > 0 ? (spent / budgetLimit).clamp(0.0, 1.0) : 0.0;
    final progressStr = (progress * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD3BDB9), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFBE4E1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFFD32F2F), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(categoryName, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFF3B2723))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(budget.period.name, const Color(0xFFFBECE9), const Color(0xFFD32F2F)),
                        _buildChip('Category', const Color(0xFFFBECE9), const Color(0xFFD32F2F)),
                        _buildChip('Automatic', const Color(0xFFD6E3FF), const Color(0xFF0056D4), icon: Icons.auto_awesome),
                      ],
                    )
                ],
              )
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Good', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$progressStr% Used', style: const TextStyle(color: Color(0xFF5A4D48), fontWeight: FontWeight.w500)),
            Text('₹${spent.toStringAsFixed(2)} of ₹${budgetLimit.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF8A7773), fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        // Progress Bar wrapper
        Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFBECE9),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
               widthFactor: progress,
               child: Container(
                 height: 8,
                 decoration: BoxDecoration(
                   color: const Color(0xFFF4CDCA),
                   borderRadius: BorderRadius.circular(4),
                 ),
               ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Remaining', style: TextStyle(color: Color(0xFF8A7773))),
                  Text('₹${remaining.toStringAsFixed(2)}', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF5A4D48))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Spent', style: TextStyle(color: Color(0xFF8A7773))),
                  Text('₹${spent.toStringAsFixed(2)}', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF5A4D48))),
                ],
              )
          ],
        )
      ],
      )
    );
  }

  Widget _buildChip(String label, Color bgColor, Color textColor, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class ShowBudgetToggle extends StatelessWidget {
  const ShowBudgetToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEDDDA),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Show Budget', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B1B1F))),
              SizedBox(height: 4),
              Text('Track this budget on home screen', style: TextStyle(color: Color(0xFF8A7773), fontSize: 13)),
            ],
          ),
          Switch(value: true, onChanged: (v){}, activeColor: const Color(0xFF90594C)),
        ],
      ),
    );
  }
}

class SpendingTrendChart extends StatelessWidget {
  const SpendingTrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEEDDDA),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text('Spending Trend', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF90594C))),
            const SizedBox(height: 32),
            _buildChartLine('8'),
            _buildChartLine('6'),
            _buildChartLine('4'),
            _buildChartLine('2'),
            _buildChartLine('0'),
            _buildChartLine('-2'),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1970 Feb', style: TextStyle(color: Color(0xFF1B1B1F), fontSize: 12)),
                Text('Mar', style: TextStyle(color: Color(0xFF1B1B1F), fontSize: 12)),
                Text('Apr', style: TextStyle(color: Color(0xFF1B1B1F), fontSize: 12)),
                Text('May', style: TextStyle(color: Color(0xFF1B1B1F), fontSize: 12)),
                Text('Jun', style: TextStyle(color: Color(0xFF1B1B1F), fontSize: 12)),
              ],
            )
        ],
      )
    );
  }

  Widget _buildChartLine(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
           SizedBox(width: 24, child: Text(label, style: const TextStyle(color: Color(0xFF1B1B1F)))),
           const SizedBox(width: 8),
           Expanded(child: Container(height: 1, color: const Color(0xFFD3BDB9))), // Line
        ],
      )
    );
  }
}

class CategoryBreakdownCard extends StatelessWidget {
  const CategoryBreakdownCard({super.key});

  @override
  Widget build(BuildContext context) {
     final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEEDDDA),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text('Category Breakdown', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF90594C))),
            const SizedBox(height: 24),
            Column(
              children: [
                Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFCC80),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shopping_bag, color: Color(0xFFF57F17)), // Darker yellow/orange
                    ),
                    const SizedBox(width: 16),
                    const Expanded(child: Text("Mom's Shopping", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3B2723)))),
                    const Text("₹0.00", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F))),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 64.0), // align under text
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE0B2), // Faded yellow
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80), // Fab space
        ],
      )
    );
  }

}
