import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../database/providers.dart';

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
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: amount),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        // String formatting is generated dynamically per frame
        final formatted = currencyFormat.format(value);
        return Text(
          formatted,
          style: style,
        );
      },
    );
  }
}
