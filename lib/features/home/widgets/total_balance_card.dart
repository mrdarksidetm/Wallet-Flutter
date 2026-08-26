import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/widgets/animated_counter.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/database/providers.dart';
import '../../../core/services/currency_engine.dart';

class TotalBalanceCard extends ConsumerWidget {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;

  const TotalBalanceCard({
    super.key,
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
  });

  List<FontVariation> _getBalanceFontVariations(double amount) {
    final intVal = amount.abs().truncate();
    final digits = intVal == 0 ? 1 : intVal.toString().length;
    final double t = ((digits - 4) / (12 - 4)).clamp(0.0, 1.0);
    final double weight = 797.0 - (t * (797.0 - 100.0));
    final double width = 131.0 - (t * (131.0 - 50.0));
    const double grade = 59.0;
    const double roundness = 42.0;
    const double opticalSize = 86.0;

    return [
      const FontVariation('GRAD', grade),
      FontVariation('wght', weight),
      FontVariation('wdth', width),
      const FontVariation('ROND', roundness),
      const FontVariation('opsz', opticalSize),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isVisible = ref.watch(personalizationProvider.select((p) => p.isBalanceVisible));
    final currency = ref.watch(currencyProvider);

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(32),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Blobs for Glow Effect
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: isDark ? 0.3 : 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -20,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: isDark ? 0.3 : 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Backdrop Blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(color: Colors.transparent),
          ),
          // Foreground Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Balance',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        ref.read(personalizationProvider.notifier).toggleBalanceVisibility();
                      },
                      icon: Icon(
                        isVisible ? Symbols.visibility : Symbols.visibility_off,
                        size: 20,
                        weight: 600,
                        grade: 0.25,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isVisible)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: AnimatedCounter(
                      amount: totalBalance,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontFamily: 'GoogleSansFlex',
                        fontVariations: _getBalanceFontVariations(totalBalance),
                        color: colorScheme.onSurface,
                        letterSpacing: -1,
                      ),
                    ),
                  )
                else
                  Text(
                    '••••••',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontFamily: 'GoogleSansFlex',
                      fontVariations: _getBalanceFontVariations(totalBalance),
                      color: colorScheme.onSurface,
                      letterSpacing: 4,
                    ),
                  ),
                const Spacer(),
                Row(
                  children: [
                    _buildStatItem(
                      context,
                      'Income',
                      monthlyIncome,
                      Colors.green,
                      Icons.arrow_downward,
                      isVisible,
                      currency,
                    ),
                    const SizedBox(width: 32),
                    _buildStatItem(
                      context,
                      'Expense',
                      monthlyExpense,
                      Colors.red,
                      Icons.arrow_upward,
                      isVisible,
                      currency,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, double amount, Color color, IconData icon, bool isVisible, String currency) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 12,
              color: color,
              weight: 700, // Extra heavy for very small icons
              grade: 0.25,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          isVisible ? CurrencyEngine.formatCurrency(amount, currency) : '•••',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
