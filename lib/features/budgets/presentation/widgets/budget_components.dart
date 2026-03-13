import 'package:flutter/material.dart';
import '../../../../core/database/models/auxiliary_models.dart';

class BudgetSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const BudgetSettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF90594C), size: 28),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B1B1F))),
                   const SizedBox(height: 4),
                   Text(subtitle, style: const TextStyle(color: Color(0xFF8A7773), height: 1.4)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Icon(Icons.chevron_right, color: Color(0xFF1B1B1F)),
            ),
          ],
        ),
      ),
    );
  }
}

class BudgetColorTab extends StatelessWidget {
  final String label;
  final bool isSelected;

  const BudgetColorTab({
    super.key,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF90594C) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF5A4D48),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class BudgetColorBox extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const BudgetColorBox({
    super.key,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: isSelected 
            ? Icon(
                Icons.check, 
                color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
              ) 
            : null,
      ),
    );
  }
}

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback onTap;

  const BudgetCard({
    super.key, 
    required this.budget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Calculate values safely
    final budgetLimit = budget.amount;
    final categoryName = budget.category.value?.name ?? 'Unknown';
    final isAuto = true; // Hardcoded for now until we expand DB schema
    
    // For demo purposes, we will assume 0 spent right now as we haven't wired transactions
    const double spent = 0; 
    final remaining = budgetLimit - spent;
    final progress = budgetLimit > 0 ? (spent / budgetLimit).clamp(0.0, 1.0) : 0.0;
    final progressStr = (progress * 100).toStringAsFixed(0);

    return GestureDetector(
       onTap: onTap,
       child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFBE4E1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardHeader(context, categoryName, isAuto, progressStr),
                const SizedBox(height: 24),
                _buildAmountRow(context, spent, budgetLimit),
                const SizedBox(height: 24),
                _buildProgressBar(progress),
                const SizedBox(height: 16),
                _buildRemainingFooter(context, remaining),
              ],
            ),
          ),
    );
  }

  Widget _buildCardHeader(BuildContext context, String title, bool isAuto, String progressStr) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF945B50),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFF3B2723))),
                 const SizedBox(height: 8),
                 Wrap(
                   spacing: 8,
                   runSpacing: 8,
                   children: [
                     _buildChip(budget.period.name, const Color(0xFFEEDACA), const Color(0xFF7D655A)),
                     _buildChip('Category', const Color(0xFFF3D2CC), const Color(0xFF8B5148)),
                     if (isAuto)
                       _buildChip('Automatic', const Color(0xFFD6E3FF), const Color(0xFF0056D4), icon: Icons.auto_awesome),
                   ],
                 )
              ],
            )
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFB59A94)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF5A4D48)),
              const SizedBox(width: 4),
              Text('$progressStr%', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5A4D48))),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildAmountRow(BuildContext context, double spent, double budgetLimit) {
     return Row(
       children: [
         Expanded(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const Text('Spent', style: TextStyle(color: Color(0xFF8A7773))),
               Text('₹${spent.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF5A4D48))),
             ],
           ),
         ),
         Container(
           width: 1,
           height: 40,
           color: const Color(0xFFD3BDB9), 
         ),
         const SizedBox(width: 16),
         Expanded(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const Text('Budget', style: TextStyle(color: Color(0xFF8A7773))),
               Text('₹${budgetLimit.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF3B2723))),
             ],
           ),
         ),
       ],
     );
  }

  Widget _buildProgressBar(double progress) {
     return Stack(
       children: [
         Container(
           height: 8,
           width: double.infinity,
           decoration: BoxDecoration(
             color: const Color(0xFFCFB8B4), // Track color
             borderRadius: BorderRadius.circular(4),
           ),
         ),
         FractionallySizedBox(
           widthFactor: progress,
           child: Container(
             height: 8,
             decoration: BoxDecoration(
               color: const Color(0xFF945B50), // Fill color
               borderRadius: BorderRadius.circular(4),
             ),
           ),
         ),
       ]
     );
  }
  
  Widget _buildRemainingFooter(BuildContext context, double remaining) {
      return Row(
         children: [
           const Icon(Icons.account_balance_wallet_outlined, size: 16, color: Color(0xFF8A7773)),
           const SizedBox(width: 4),
           const Text('Remaining', style: TextStyle(color: Color(0xFF8A7773))),
           const SizedBox(width: 8),
           Text('₹${remaining.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF5A4D48))),
         ],
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

