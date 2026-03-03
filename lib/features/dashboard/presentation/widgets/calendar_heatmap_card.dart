import 'package:flutter/material.dart';

class CalendarHeatmapCard extends StatelessWidget {
  const CalendarHeatmapCard({super.key});

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
                const Icon(Icons.calendar_month_outlined, size: 18, color: Color(0xFF7A706D)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Calendar heatmap',
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
            const Center(
              child: Text(
                'Mar 2026', // Updated to match screenshot timeframe logic assuming recent
                style: TextStyle(fontFamily: 'ProductSans', fontWeight: FontWeight.w700, color: Color(0xFF4A4442)),
              ),
            ),
            const SizedBox(height: 16),
            // Placeholder for the actual heatmap grid
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFFE9C5B5).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('Heatmap Visualization', style: TextStyle(fontFamily: 'ProductSans', color: Color(0xFF7A706D))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
