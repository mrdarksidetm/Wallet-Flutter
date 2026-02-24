import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/transaction_model.dart';
import 'widgets/date_filter_row.dart';
import 'widgets/total_balance_card.dart';
import 'widgets/quick_insights_cards.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) return const Center(child: Text('Not enough data.'));
          
          final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
          if (expenses.isEmpty) return const Center(child: Text('No expenses to analyze.'));

          // Group by category
          final Map<String, double> categorySums = {};
          final Map<String, Color> categoryColors = {};
          
          for (final tx in expenses) {
            final cat = tx.category.value;
            if (cat != null) {
              categorySums[cat.name] = (categorySums[cat.name] ?? 0) + tx.amount;
              categoryColors[cat.name] = Color(int.parse(cat.color));
            }
          }

          final sortedKeys = categorySums.keys.toList()..sort((a,b) => categorySums[b]!.compareTo(categorySums[a]!));

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: DateFilterRow(),
              ),
              const TotalBalanceCard(),
              const SizedBox(height: 16),
              const QuickInsightsCards(),
              const SizedBox(height: 24),
              // Original Pie Chart wrapped in a layout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Reports', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB39D),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.bar_chart, color: Colors.black, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.show_chart, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 300,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                    sections: List.generate(sortedKeys.length, (i) {
                      final isTouched = i == _touchedIndex;
                      final fontSize = isTouched ? 22.0 : 14.0;
                      final radius = isTouched ? 70.0 : 60.0;
                      final name = sortedKeys[i];
                      final value = categorySums[name]!;
                      
                      return PieChartSectionData(
                        color: categoryColors[name],
                        value: value,
                        title: '\$${value.toStringAsFixed(0)}',
                        radius: radius,
                        titleStyle: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              ),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text('Top Categories', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              ...sortedKeys.map((name) {
                final value = categorySums[name]!;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: CircleAvatar(backgroundColor: categoryColors[name]),
                  title: Text(name),
                  trailing: Text('₹${value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ).animate().fade().slideX();
              }),
              const SizedBox(height: 120), // Bottom padding for FAB/Navigation
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
