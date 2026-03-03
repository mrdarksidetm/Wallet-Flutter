import 'package:flutter/material.dart';

class TrendChartCard extends StatelessWidget {
  const TrendChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF6EEEC), // Solid soft M3 surface tone matching screenshot precisely
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, size: 18, color: Color(0xFF7A706D)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Trend',
                    style: TextStyle(fontFamily: 'ProductSans', fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF4A4442)),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 20, color: const Color(0xFF7A706D).withOpacity(0.8)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Container(
                height: 1, 
                width: double.infinity, 
                color: const Color(0xFFE9C5B5).withOpacity(0.5) // Dividing faint red line matching UI
              ),
            ),
            const Text(
              'Last 30 Days: ₹0.00',
              style: TextStyle(fontFamily: 'ProductSans', fontSize: 13, color: Color(0xFF7A706D), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            // Placeholder for the actual Line Chart
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFFE9C5B5).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('Line Chart Visualization', style: TextStyle(fontFamily: 'ProductSans', color: Color(0xFF7A706D))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
