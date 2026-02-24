import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'customize_dashboard_sheet.dart';

class OverviewCards extends ConsumerWidget {
  const OverviewCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);
    final currency = themeState.currencySymbol;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.grid_view, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const FractionallySizedBox(
                      heightFactor: 0.85,
                      child: CustomizeDashboardBottomSheet(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.9,
          children: [
            _GridCard(
              title: 'Budgets',
              icon: Icons.savings_outlined,
              content: [
                 RichText(text: const TextSpan(children: [
                   TextSpan(text: '0 ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE5A48F))),
                   TextSpan(text: 'Budgets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                 ])),
              ],
            ),
            _GridCard(
              title: 'Assets',
              icon: Icons.account_balance_wallet_outlined,
              content: [
                 RichText(text: const TextSpan(children: [
                   TextSpan(text: '0 ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE5A48F))),
                   TextSpan(text: 'Assets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                 ])),
                 const Spacer(),
                 Text('${currency}0.00', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE5A48F))),
                 const Text('Total', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            _GridCard(
              title: 'Bill Splitter',
              icon: Icons.call_split,
              content: [
                 RichText(text: const TextSpan(children: [
                   TextSpan(text: '0 ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE5A48F))),
                   TextSpan(text: 'Bills', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                 ])),
                 const SizedBox(height: 4),
                 RichText(text: const TextSpan(children: [
                   TextSpan(text: '0 ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE5A48F))),
                   TextSpan(text: 'Active', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                 ])),
              ],
            ),
            _GridCard(
              title: 'Loans',
              icon: Icons.money,
              content: [
                 RichText(text: const TextSpan(children: [
                   TextSpan(text: '2 ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE5A48F))),
                   TextSpan(text: 'Lending', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                 ])),
                 const SizedBox(height: 4),
                 RichText(text: const TextSpan(children: [
                   TextSpan(text: '1 ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE5A48F))),
                   TextSpan(text: 'Borrowing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                 ])),
                 const Spacer(),
                 Text('${currency}1.95K', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE5A48F))),
                 const Text('Loan Balance', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _GridCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> content;

  const _GridCard({
    required this.title,
    required this.icon,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
    ).animate().fade().scaleXY(begin: 0.95, end: 1.0, curve: Curves.easeOutQuad);
  }
}
