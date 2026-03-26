import 'package:flutter/material.dart';
import '../theme/colors.dart';

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
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDim],
          begin: Alignment(-0.8, -0.6), // Roughly 145 degrees
          end: Alignment(0.8, 0.6),
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
          foregroundColor: Colors.white,
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
