import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/widgets/app_back_button.dart';

/// A custom painter that draws a circle split into three colored segments:
/// A top half, a bottom-left quarter, and a bottom-right quarter.
class _PalettePainter extends CustomPainter {
  final Color topColor;
  final Color bottomLeftColor;
  final Color bottomRightColor;

  _PalettePainter({
    required this.topColor,
    required this.bottomLeftColor,
    required this.bottomRightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = min(size.width / 2, size.height / 2);
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // --- DRAWING THE TOP HALF ---
    paint.color = topColor;
    canvas.drawArc(
      rect,
      pi,
      pi,
      true,
      paint,
    );

    // --- DRAWING THE BOTTOM RIGHT QUARTER ---
    paint.color = bottomRightColor;
    canvas.drawArc(
      rect,
      0,
      pi / 2,
      true,
      paint,
    );

    // --- DRAWING THE BOTTOM LEFT QUARTER ---
    paint.color = bottomLeftColor;
    canvas.drawArc(
      rect,
      pi / 2,
      pi / 2,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PalettePainter oldDelegate) {
    return oldDelegate.topColor != topColor ||
        oldDelegate.bottomLeftColor != bottomLeftColor ||
        oldDelegate.bottomRightColor != bottomRightColor;
  }
}

class ThemeSelectionPage extends ConsumerWidget {
  const ThemeSelectionPage({super.key});

  static Map<String, Color> _getVariantColors(String variant, bool isDark) {
    switch (variant) {
      case 'tonalSpot':
        return {
          'top': isDark ? const Color(0xFF9BB1E8) : const Color(0xFFD3DFFF),
          'bottomLeft': isDark ? const Color(0xFFCBBCD6) : const Color(0xFFE8D5EC),
          'bottomRight': isDark ? const Color(0xFF42567D) : const Color(0xFF677799),
        };
      case 'vibrant':
        return {
          'top': isDark ? const Color(0xFFFFB0C8) : const Color(0xFFFFD8E4),
          'bottomLeft': isDark ? const Color(0xFFFFB787) : const Color(0xFFFFDCC1),
          'bottomRight': isDark ? const Color(0xFFB01D56) : const Color(0xFFE91E63),
        };
      case 'expressive':
        return {
          'top': isDark ? const Color(0xFFFFB596) : const Color(0xFFFFDBCA),
          'bottomLeft': isDark ? const Color(0xFFC7BFFF) : const Color(0xFFE5DEFF),
          'bottomRight': isDark ? const Color(0xFFB36700) : const Color(0xFFFF9800),
        };
      case 'rainbow':
        return {
          'top': isDark ? const Color(0xFFFFB0D0) : const Color(0xFFFFD8E6),
          'bottomLeft': isDark ? const Color(0xFFA3DDB3) : const Color(0xFFC4EED0),
          'bottomRight': isDark ? const Color(0xFF7B1FA2) : const Color(0xFF9C27B0),
        };
      case 'fruitSalad':
        return {
          'top': isDark ? const Color(0xFFA1DECA) : const Color(0xFFC3EEDD),
          'bottomLeft': isDark ? const Color(0xFFFFB1C1) : const Color(0xFFFFD8DF),
          'bottomRight': isDark ? const Color(0xFF007A50) : const Color(0xFF00B074),
        };
      case 'fidelity':
        return {
          'top': isDark ? const Color(0xFFB8C4F6) : const Color(0xFFDFE2F9),
          'bottomLeft': isDark ? const Color(0xFFC4B2EE) : const Color(0xFFE1D3F8),
          'bottomRight': isDark ? const Color(0xFF303F9F) : const Color(0xFF3F51B5),
        };
      case 'content':
        return {
          'top': isDark ? const Color(0xFFA8C8FF) : const Color(0xFFD7E2FF),
          'bottomLeft': isDark ? const Color(0xFFB9C9DF) : const Color(0xFFD9E2F1),
          'bottomRight': isDark ? const Color(0xFF1976D2) : const Color(0xFF2196F3),
        };
      case 'neutral':
        return {
          'top': isDark ? const Color(0xFFC7C6CA) : const Color(0xFFE3E2E6),
          'bottomLeft': isDark ? const Color(0xFFC6C6CD) : const Color(0xFFE2E2E9),
          'bottomRight': isDark ? const Color(0xFF5A5C63) : const Color(0xFF75787F),
        };
      case 'monochrome':
      default:
        return {
          'top': isDark ? const Color(0xFFBDBDBD) : const Color(0xFFE0E0E0),
          'bottomLeft': isDark ? const Color(0xFF757575) : const Color(0xFFBDBDBD),
          'bottomRight': isDark ? const Color(0xFF212121) : const Color(0xFF424242),
        };
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeState = ref.watch(themeControllerProvider);
    final themeNotifier = ref.read(themeControllerProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            leading: const AppBackButton(),
            title: Text(
              'Theme & Style',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: (theme.textTheme.headlineLarge?.fontSize ?? 32) + 3,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            sliver: SliverList.list(
              children: [
                _buildSectionHeader(context, 'Theme Mode'),
                _buildThemeTile(
                  context,
                  title: 'System Default',
                  subtitle: 'Follow system settings',
                  icon: Symbols.settings_suggest,
                  mode: ThemeMode.system,
                  currentMode: themeState.themeMode,
                  onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
                ),
                _buildThemeTile(
                  context,
                  title: 'Light Mode',
                  subtitle: 'Always light',
                  icon: Symbols.light_mode,
                  mode: ThemeMode.light,
                  currentMode: themeState.themeMode,
                  onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
                ),
                _buildThemeTile(
                  context,
                  title: 'Dark Mode',
                  subtitle: 'Always dark',
                  icon: Symbols.dark_mode,
                  mode: ThemeMode.dark,
                  currentMode: themeState.themeMode,
                  onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
                ),
                const Divider(indent: 24, endIndent: 24, height: 32),
                _buildSectionHeader(context, 'Dynamic Color Style'),
                _buildVariantInfo(context, themeState.useMaterialYou),
                _buildVariantTile(context, ref, 'Tonal Spot', 'tonalSpot',
                    enabled: themeState.useMaterialYou),
                _buildVariantTile(context, ref, 'Vibrant', 'vibrant',
                    enabled: themeState.useMaterialYou),
                _buildVariantTile(context, ref, 'Expressive', 'expressive',
                    enabled: themeState.useMaterialYou),
                _buildVariantTile(context, ref, 'Rainbow', 'rainbow',
                    enabled: themeState.useMaterialYou),
                _buildVariantTile(context, ref, 'Fruit Salad', 'fruitSalad',
                    enabled: themeState.useMaterialYou),
                _buildVariantTile(context, ref, 'Fidelity', 'fidelity',
                    enabled: themeState.useMaterialYou),
                _buildVariantTile(context, ref, 'Content', 'content',
                    enabled: themeState.useMaterialYou),
                _buildVariantTile(context, ref, 'Neutral', 'neutral',
                    enabled: themeState.useMaterialYou),
                _buildVariantTile(context, ref, 'Monochrome', 'monochrome',
                    enabled: themeState.useMaterialYou),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantInfo(BuildContext context, bool enabled) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Symbols.info_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                enabled
                    ? 'Dynamic Color is on. Select a variant to tune your palette style.'
                    : 'These variants are available only when Dynamic Color is enabled.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildVariantTile(
    BuildContext context,
    WidgetRef ref,
    String title,
    String variant, {
    required bool enabled,
  }) {
    final personalization = ref.watch(personalizationProvider);
    final isSelected = personalization.colorSchemeVariant == variant;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _getVariantColors(variant, isDark);

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: ListTile(
        onTap: enabled
            ? () {
                ref
                    .read(personalizationProvider.notifier)
                    .updateColorSchemeVariant(variant);
              }
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
        leading: SizedBox(
          width: 32,
          height: 32,
          child: CustomPaint(
            painter: _PalettePainter(
              topColor: colors['top']!,
              bottomLeftColor: colors['bottomLeft']!,
              bottomRightColor: colors['bottomRight']!,
            ),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
        trailing: isSelected
            ? Icon(Symbols.check_circle, color: colorScheme.primary, fill: 1)
            : null,
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required VoidCallback onTap,
  }) {
    final isSelected = mode == currentMode;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: () async {
        onTap();
      },
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color:
              isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          fill: isSelected ? 1 : 0,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(Symbols.check_circle, color: colorScheme.primary, fill: 1)
          : null,
    );
  }
}
