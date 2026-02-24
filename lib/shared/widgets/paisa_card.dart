import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';

class PaisaCard extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double elevation;
  final double borderRadius;
  final VoidCallback? onTap;

  const PaisaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.color,
    this.elevation = 0, // Paisa mostly uses flat, tonal cards
    this.borderRadius = 28.0, // High border radius is standard in M3/Paisa
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeState = ref.watch(themeControllerProvider);
    final isLiquid = themeState.isLiquid;
    
    Widget cardChild = Padding(
      padding: padding ?? EdgeInsets.zero,
      child: child,
    );

    if (onTap != null) {
      cardChild = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: cardChild,
      );
    }

    // The true Paisa aesthetic uses flat surfaces in light mode,
    // but relies on subtle glassmorphism/translucent layers in dark mode.
    if ((isDark || isLiquid) && color == null) {
       return Container(
         margin: margin,
         decoration: BoxDecoration(
           color: theme.colorScheme.surface.withOpacity(isLiquid ? 0.3 : 0.8),
           borderRadius: BorderRadius.circular(borderRadius),
           border: Border.all(
             color: theme.colorScheme.onSurface.withOpacity(0.05),
             width: 1,
           ),
           boxShadow: [
             if (isLiquid || !isDark) // Give flat light mode cards a slight drop shadow
               BoxShadow(
                 color: Colors.black.withOpacity(0.03),
                 blurRadius: 10,
                 offset: const Offset(0, 4),
               )
           ]
         ),
         clipBehavior: Clip.antiAlias,
         child: cardChild,
       );
    }

    return Card(
      elevation: elevation,
      margin: margin,
      color: color ?? theme.colorScheme.surfaceContainerHighest, // Standard M3 tonal color
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: isDark ? BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.05), width: 1) : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: cardChild,
    );
  }
}
