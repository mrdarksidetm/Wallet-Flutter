import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Donut Chart
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 60,
                  sections: [
                    PieChartSectionData(
                      color: colorScheme.primary,
                      value: 40,
                      title: '40%',
                      radius: 20,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      color: colorScheme.secondary,
                      value: 30,
                      title: '30%',
                      radius: 20,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      color: colorScheme.tertiary,
                      value: 15,
                      title: '15%',
                      radius: 20,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      color: colorScheme.error,
                      value: 15,
                      title: '15%',
                      radius: 20,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),

            Text(
              'Cash Flow',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Cash Flow Line Chart
            AspectRatio(
              aspectRatio: 1.7,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 3),
                        FlSpot(2.6, 2),
                        FlSpot(4.9, 5),
                        FlSpot(6.8, 3.1),
                        FlSpot(8, 4),
                        FlSpot(9.5, 3),
                        FlSpot(11, 4),
                      ],
                      isCurved: true,
                      color: colorScheme.primary,
                      barWidth: 4,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Summary List
            _buildReportItem(context, 'Food', '₹12,400', colorScheme.primary),
            _buildReportItem(context, 'Shopping', '₹8,200', colorScheme.secondary),
            _buildReportItem(context, 'Transport', '₹4,100', colorScheme.tertiary),
            _buildReportItem(context, 'Bills', '₹3,000', colorScheme.error),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(BuildContext context, String label, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          const Spacer(),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
