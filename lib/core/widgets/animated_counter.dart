import 'package:flutter/material.dart';

/// Phase 52: Dynamic Number Counting (Odometer Effect)
///
/// Uses an ImplicitlyAnimatedWidget approach to tween between double values.
/// This prevents crashes with string parsing because the animation operates strictly
/// on the underlying floating-point balance, re-formatting the string at each frame.
class AnimatedCounter extends StatelessWidget {
  final double amount;
  final TextStyle? style;

  const AnimatedCounter({Key? key, required this.amount, this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: amount),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        // String formatting is generated dynamically per frame
        final formatted = "\$${value.toStringAsFixed(2)}";
        return Text(
          formatted,
          style: style,
        );
      },
    );
  }
}
