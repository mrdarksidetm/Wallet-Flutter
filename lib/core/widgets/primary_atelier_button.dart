import 'package:flutter/material.dart';

class PrimaryAtelierButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget label;
  final Widget? icon;
  final double? width;
  final double height;

  const PrimaryAtelierButton({
    super.key,
    this.onPressed,
    required this.label,
    this.icon,
    this.width = double.infinity,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // [ACTION]: Defining the main background for the primary interactive button.
        // [M3 UPDATE]: Replacing hardcoded AppColors with a dynamic gradient derived from the seed.
        // [WHY]: By using primary and primaryContainer, we ensure the button follows 
        // the global blue hue or the user's dynamic color preference while maintaining 
        // depth and an "Atelier" editorial feel.
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: const Alignment(-0.8, -0.6),
          end: const Alignment(0.8, 0.6),
        ),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
          ),
          // [ACTION]: Setting the foreground color for text and icons.
          // [M3 UPDATE]: Mapping directly to onPrimary to ensure WCAG-compliant contrast.
          foregroundColor: colorScheme.onPrimary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 8),
            ],
            label,
          ],
        ),
      ),
    );
  }
}
