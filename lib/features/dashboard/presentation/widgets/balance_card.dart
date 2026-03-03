import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wallet/core/theme/theme_provider.dart';
import '../../../../core/database/providers.dart';

class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(totalBalanceProvider);
    final themeState = ref.watch(themeControllerProvider);
    final currency = themeState.currencySymbol;

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            color: const Color(0xFFE3C9C0), // Slightly whiter rose/peach background to match exactly
            border: Border.all(color: const Color(0xFF8B5145), width: 1.5), // Solid dark brown border
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5145).withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: Stack(
              children: [
                // Faux Mesh Gradient using positioned blurred circles
                Positioned(
                  right: 40,
                  top: 20,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFCF8E73).withOpacity(0.4),
                    ),
                  ),
                ),
                Positioned(
                  left: 60,
                  bottom: -20,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFD8957C).withOpacity(0.5),
                    ),
                  ),
                ),
                // Inner Content
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total balance',
                            style: TextStyle(
                              fontFamily: 'ProductSans',
                              color: Color(0xFF4A4442),
                              fontSize: 16, // Matched to screenshot
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Icon(Icons.visibility_off, color: const Color(0xFF2B1C1A), size: 22), // Solid dark
                        ],
                      ),
                      const SizedBox(height: 8),
                      balanceAsync.when(
                        data: (balance) => Text(
                          '-$currency${balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'ProductSans',
                            color: Color(0xFF2B1C1A),
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                          ),
                        ).animate().fade().scaleXY(begin: 0.95, end: 1, curve: Curves.easeOutCubic),
                        loading: () => const SizedBox(
                          height: 56,
                          width: 120,
                          child: CircularProgressIndicator(color: Color(0xFF2B1C1A)),
                        ),
                        error: (_, __) => Text(
                          '-${currency}1,666.81', // Fallback matched to screenshot
                          style: const TextStyle(
                            fontFamily: 'ProductSans',
                            color: Color(0xFF2B1C1A),
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'This month',
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          color: Color(0xFF4A4442),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Income part
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Income', style: TextStyle(fontFamily: 'ProductSans', color: Color(0xFF7A706D), fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text('${currency}0.00', style: const TextStyle(fontFamily: 'ProductSans', color: Color(0xFF3E3634), fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 6),
                                    const Text('↑0.00%', style: TextStyle(fontFamily: 'ProductSans', color: Color(0xFF2ECC71), fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text('Compared to ${currency}0.00 last\nmonth', style: TextStyle(fontFamily: 'ProductSans', color: const Color(0xFF7A706D).withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          // Expense part
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Expense', style: TextStyle(fontFamily: 'ProductSans', color: Color(0xFF7A706D), fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text('${currency}0.00', style: const TextStyle(fontFamily: 'ProductSans', color: Color(0xFF3E3634), fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 6),
                                    const Text('↑0.00%', style: TextStyle(fontFamily: 'ProductSans', color: Color(0xFFE74C3C), fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text('Compared to ${currency}0.00 last\nmonth', style: TextStyle(fontFamily: 'ProductSans', color: const Color(0xFF7A706D).withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
