import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/providers.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/services/currency_engine.dart';

class AnimatedBalanceHero extends ConsumerStatefulWidget {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;

  const AnimatedBalanceHero({
    super.key,
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
  });

  @override
  ConsumerState<AnimatedBalanceHero> createState() => _AnimatedBalanceHeroState();
}

class _AnimatedBalanceHeroState extends ConsumerState<AnimatedBalanceHero> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _blobController;

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isVisible = ref.watch(personalizationProvider.select((p) => p.isBalanceVisible));
    final currency = ref.watch(currencyProvider);

    // Using colors from current theme to maintain consistency while achieving the 'vibrant' look
    final blob1Color = isDark ? colorScheme.primary.withValues(alpha: 0.4) : const Color(0xFFD4BFE8);
    final blob2Color = isDark ? colorScheme.secondary.withValues(alpha: 0.4) : const Color(0xFFE5CCF4);
    final baseColor = isDark ? colorScheme.surfaceContainer : const Color(0xFFF3EDF7);

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        height: 240,
        width: double.infinity,
        color: baseColor,
        child: Stack(
          children: [
            // --- BACKGROUND ANIMATION (Blobs) ---
            AnimatedBuilder(
              animation: _blobController,
              builder: (context, child) {
                return Positioned(
                  left: -40 + (60 * _blobController.value),
                  top: -40 + (30 * _blobController.value),
                  child: child!,
                );
              },
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [blob1Color, blob1Color.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
            
            AnimatedBuilder(
              animation: _blobController,
              builder: (context, child) {
                return Positioned(
                  right: -60 + (40 * _blobController.value),
                  bottom: -50 + (35 * _blobController.value),
                  child: child!,
                );
              },
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [blob2Color, blob2Color.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),

            // Glassmorphism Blur Layer
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
                child: Container(color: Colors.transparent),
              ),
            ),

            // --- FOREGROUND CONTENT ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Total balance',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Total Balance'),
                                  content: const Text(
                                      'This is the sum of all your accounts including cash, bank, and investments. It reflects your overall net worth in the app.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Got it'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: Icon(
                              Symbols.info,
                              size: 18,
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => ref.read(personalizationProvider.notifier).toggleBalanceVisibility(),
                        icon: Icon(
                          isVisible ? Symbols.visibility : Symbols.visibility_off,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),

                  // Rolling Balance Text
                  if (isVisible)
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: widget.totalBalance),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Text(
                          CurrencyEngine.formatCurrency(value, currency),
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colorScheme.onSurface,
                            letterSpacing: -1,
                          ),
                        );
                      },
                    )
                  else
                    Text(
                      '••••••',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                        letterSpacing: 4,
                      ),
                    ),
                  
                  const Spacer(),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'This month',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      if (isVisible && widget.monthlyIncome > 0)
                        Text(
                          '${((widget.monthlyExpense / widget.monthlyIncome) * 100).toStringAsFixed(0)}% spent',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniStat(
                          'Income', 
                          widget.monthlyIncome, 
                          Colors.green, 
                          isVisible, 
                          currency,
                          Symbols.trending_up,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMiniStat(
                          'Expense', 
                          widget.monthlyExpense, 
                          Colors.red, 
                          isVisible, 
                          currency,
                          Symbols.trending_down,
                        ),
                      ),
                    ],
                  ),
                  if (isVisible && widget.monthlyIncome > 0) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (widget.monthlyExpense / widget.monthlyIncome).clamp(0.0, 1.0),
                        backgroundColor: colorScheme.onSurface.withValues(alpha: 0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          (widget.monthlyExpense / widget.monthlyIncome) > 0.9 
                              ? Colors.red 
                              : colorScheme.primary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(
    String label, 
    double amount, 
    Color color, 
    bool isVisible, 
    String currency,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600, 
                    fontSize: 10, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isVisible ? CurrencyEngine.formatCurrency(amount, currency) : '•••',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: color.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
