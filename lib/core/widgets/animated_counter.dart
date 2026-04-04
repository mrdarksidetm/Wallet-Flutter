import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/providers.dart';
import '../services/currency_engine.dart';

/// Phase 52: Dynamic Number Counting (Odometer Effect)
///
/// Uses an ImplicitlyAnimatedWidget approach to tween between double values.
/// This prevents crashes with string parsing because the animation operates strictly
/// on the underlying floating-point balance, re-formatting the string at each frame.
class AnimatedCounter extends ConsumerWidget {
  final double amount;
  final TextStyle? style;

  const AnimatedCounter({super.key, required this.amount, this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCurrency = ref.watch(currencyProvider);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: amount),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        // [ACTION]: Generating localized currency string per frame.
        // [M3 UPDATE]: Using CurrencyEngine.formatCurrency for region-specific numbering.
        return Text(
          CurrencyEngine.formatCurrency(value, selectedCurrency),
          style: style,
        );
      },
    );
  }
}
