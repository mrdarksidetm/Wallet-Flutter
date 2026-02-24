import 'package:flutter/material.dart';
import '../../../../shared/widgets/paisa_card.dart';

class QuickInsightsCards extends StatelessWidget {
  const QuickInsightsCards({super.key});

  Widget _buildInsightItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Text(
            'Quick Insights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        PaisaCard(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildInsightItem(
                        context,
                        icon: Icons.savings_outlined,
                        title: 'Savings Rate',
                        value: '100.0%',
                        valueColor: Colors.greenAccent,
                      ),
                      const SizedBox(height: 24),
                      _buildInsightItem(
                        context,
                        icon: Icons.receipt_long_outlined,
                        title: 'Transaction count',
                        value: '1',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _buildInsightItem(
                        context,
                        icon: Icons.calendar_today_outlined,
                        title: 'Avg. Daily',
                        value: '₹0.00',
                      ),
                      const SizedBox(height: 24),
                      _buildInsightItem(
                        context,
                        icon: Icons.category_outlined,
                        title: 'Top Category',
                        value: '-',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
