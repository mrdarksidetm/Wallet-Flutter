import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/providers.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/services/currency_engine.dart';
import '../../../core/widgets/expressive_shape.dart';

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isVisible = ref.watch(personalizationProvider.select((p) => p.isBalanceVisible));
    final currency = ref.watch(currencyProvider);

    // Using dynamic theme seed colors to maintain full harmony in expressive mode
    final blob1Color = colorScheme.primary.withValues(alpha: isDark ? 0.35 : 0.22);
    final blob2Color = colorScheme.tertiary.withValues(alpha: isDark ? 0.30 : 0.18);
    final baseColor = isDark ? colorScheme.surfaceContainer : colorScheme.surfaceContainerHigh;

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
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: widget.totalBalance),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Text(
                            CurrencyEngine.formatCurrency(value, currency),
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontFamily: 'GoogleSansFlex',
                              fontVariations: _getBalanceFontVariations(widget.totalBalance),
                              color: colorScheme.onSurface,
                              letterSpacing: -1,
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ExpressiveObscuredBalance(
                        dotSize: 26,
                        color: colorScheme.onSurface,
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
                          const Color(0xFF10B981), 
                          isVisible, 
                          currency,
                          Symbols.trending_up,
                          colorScheme,
                          isDark,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMiniStat(
                          'Expense', 
                          widget.monthlyExpense, 
                          const Color(0xFFEF4444), 
                          isVisible, 
                          currency,
                          Symbols.trending_down,
                          colorScheme,
                          isDark,
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
                              ? const Color(0xFFEF4444) 
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
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
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
                    color: colorScheme.onSurfaceVariant, 
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
                      color: color.withValues(alpha: 0.9),
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
