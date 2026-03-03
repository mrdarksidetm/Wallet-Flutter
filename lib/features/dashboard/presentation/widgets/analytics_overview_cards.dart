import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme_provider.dart';

class AnalyticsOverviewCards extends ConsumerWidget {
  const AnalyticsOverviewCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);
    final currency = themeState.currencySymbol;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _GridCard(
                  title: 'Analytics',
                  icon: Icons.show_chart,
                  height: 160,
                  content: [
                    const Text('This month spending', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text('${currency}0.00', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE5A48F))),
                    const Spacer(),
                    const Text('→ Stable compared to last month', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GridCard(
                  title: 'Recurring',
                  icon: Icons.repeat,
                  height: 160,
                  content: [
                    RichText(text: const TextSpan(children: [
                      TextSpan(text: '0 ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE5A48F))),
                      TextSpan(text: 'Active', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                    ])),
                    const Spacer(),
                    Text('${currency}0.00', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE5A48F))),
                    const Text('Monthly Payment', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GridCard(
                  title: 'Categories',
                  icon: Icons.category_outlined,
                  height: 160,
                  content: [
                    RichText(text: const TextSpan(children: [
                      TextSpan(text: '15 ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE5A48F))),
                      TextSpan(text: 'Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                    ])),
                    const Spacer(),
                    _CategoryRow(icon: Icons.person, color: Colors.redAccent, name: 'Miscellaneous', amount: '${currency}5.53K'),
                    const SizedBox(height: 4),
                    _CategoryRow(icon: Icons.fastfood, color: Colors.orangeAccent, name: 'Food', amount: '${currency}2.18K'),
                    const SizedBox(height: 4),
                    _CategoryRow(icon: Icons.question_mark, color: Colors.tealAccent, name: 'Item Nøt sp3...', amount: '${currency}864.88'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: _GridCard(
                  title: 'Weekly',
                  icon: Icons.calendar_view_week,
                  height: 160,
                  content: [
                    Spacer(),
                    Center(child: Icon(Icons.calendar_today, size: 48, color: Colors.grey)),
                    SizedBox(height: 8),
                    Center(child: Text('No transactions this week', style: TextStyle(fontSize: 11, color: Colors.grey))),
                    Spacer(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GridCard(
                  title: 'Places',
                  icon: Icons.place_outlined,
                  height: 160,
                  content: [
                    RichText(text: const TextSpan(children: [
                      TextSpan(text: '0 ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE5A48F))),
                      TextSpan(text: 'Places', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                    ])),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GridCard(
                  title: 'Person',
                  icon: Icons.person_outline,
                  height: 160,
                  content: [
                    RichText(text: const TextSpan(children: [
                      TextSpan(text: '0 ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE5A48F))),
                      TextSpan(text: 'Person', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                    ])),
                    const Spacer(),
                    const Text('You have spent the most with , totaling ₹0.00.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ).animate().fade().slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
    );
  }
}

class _GridCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> content;
  final double height;

  const _GridCard({
    required this.title,
    required this.icon,
    required this.content,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.7)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const Spacer(),
              Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.5)),
            ],
          ),
          const Divider(height: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String name;
  final String amount;

  const _CategoryRow({
    required this.icon,
    required this.color,
    required this.name,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontSize: 11, color: Colors.white70),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(amount, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}
