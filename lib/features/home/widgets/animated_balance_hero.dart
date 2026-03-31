import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/providers.dart';
import '../../../core/theme/personalization_provider.dart';

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
    final format = NumberFormat.simpleCurrency(name: currency);

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
                          const SizedBox(width: 8),
                          Icon(Symbols.info, size: 18, color: colorScheme.onSurface.withValues(alpha: 0.5)),
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
                        final isNegative = value < 0;
                        final absValue = value.abs();
                        
                        final formattedNumber = absValue.toStringAsFixed(2).replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
                          (Match m) => '${m[1]},'
                        );

                        return Text(
                          '${isNegative ? '-' : ''}${format.currencySymbol}$formattedNumber',
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
                  
                  Text(
                    'This month',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStat('Income', widget.monthlyIncome, Colors.green, isVisible, format),
                      _buildMiniStat('Expense', widget.monthlyExpense, Colors.red, isVisible, format),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, double amount, Color color, bool isVisible, NumberFormat format) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          isVisible ? format.format(amount) : '•••',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: color.withValues(alpha: 0.8),
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
