import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A Material 3 Expressive circular/squircle back button matching the About page design.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.icon = Symbols.arrow_back_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      widthFactor: 1.0,
      heightFactor: 1.0,
      child: Material(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed ??
              () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: Icon(
                icon,
                size: 22,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
