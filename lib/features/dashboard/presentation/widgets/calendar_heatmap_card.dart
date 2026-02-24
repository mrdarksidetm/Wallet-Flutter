import 'package:flutter/material.dart';

class CalendarHeatmapCard extends StatelessWidget {
  const CalendarHeatmapCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                const SizedBox(width: 8),
                const Text(
                  'Calendar heatmap',
                  style: TextStyle(fontWeight: 

FontWeight.w600, fontSize: 16),
                ),
                const Spacer(),
                Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.5)),
              ],
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Feb 2026', // Placeholder
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            // Placeholder for the actual heatmap grid
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text('Heatmap Visualization', style: TextStyle(color: Colors.grey.withOpacity(0.5))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
