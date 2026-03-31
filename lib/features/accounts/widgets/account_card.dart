import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/providers.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/database/models/account.dart';
import '../../../core/widgets/icon_picker.dart';

class AccountCard extends ConsumerStatefulWidget {
  final Account account;
  final VoidCallback? onEdit;

  const AccountCard({
    super.key,
    required this.account,
    this.onEdit,
  });

  @override
  ConsumerState<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends ConsumerState<AccountCard> with SingleTickerProviderStateMixin {
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
    final currency = ref.watch(currencyProvider);
    final format = NumberFormat.simpleCurrency(name: currency);
    final isVisible = ref.watch(personalizationProvider.select((p) => p.isBalanceVisible));

    final color = Color(int.parse(
        widget.account.color.replaceAll('0x', '0xFF').replaceAll('0xFFFF', '0xFF'),
        radix: 16));
    
    final blob1Color = color.withValues(alpha: 0.4);
    final blob2Color = color.withValues(alpha: 0.2);
    final baseColor = isDark ? colorScheme.surfaceContainer : color.withValues(alpha: 0.05);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Container(
          decoration: BoxDecoration(
            color: baseColor,
            border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
          ),
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
                  filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
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
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                AppIcons.getIcon(widget.account.icon),
                                color: color,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              widget.account.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (widget.onEdit != null)
                          IconButton(
                            onPressed: widget.onEdit,
                            icon: Icon(Symbols.edit, color: colorScheme.onSurface.withValues(alpha: 0.5), size: 20),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      'Current Balance',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isVisible)
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: widget.account.balance),
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
                            style: theme.textTheme.displaySmall?.copyWith(
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
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colorScheme.onSurface,
                          letterSpacing: 4,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
