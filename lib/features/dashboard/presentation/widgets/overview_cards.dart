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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overview',
                style: TextStyle(fontFamily: 'ProductSans', fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF4A4442)),
              ),
              IconButton(
                icon: const Icon(Icons.grid_view_rounded, color: Color(0xFF4A4442), size: 24),
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
          childAspectRatio: 0.88,
          children: [
            _GridCard(
              title: 'Budgets',
              icon: Icons.savings_outlined,
              content: [
                RichText(text: const TextSpan(children: [
                  TextSpan(text: '1 ', style: TextStyle(fontFamily: 'ProductSans', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B5145))),
                  TextSpan(text: 'Budgets', style: TextStyle(fontFamily: 'ProductSans', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A4442))),
                ])),
                const Spacer(),
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5145).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('0% of total budget spent', style: TextStyle(fontFamily: 'ProductSans', fontSize: 11, color: Color(0xFF7A706D), fontWeight: FontWeight.w500)),
              ],
            ),
            _GridCard(
              title: 'Assets',
              icon: Icons.account_balance_wallet_outlined,
              content: [
                RichText(text: const TextSpan(children: [
                  TextSpan(text: '1 ', style: TextStyle(fontFamily: 'ProductSans', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B5145))),
                  TextSpan(text: 'Assets', style: TextStyle(fontFamily: 'ProductSans', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A4442))),
                ])),
                const Spacer(),
                Text('${currency}500.00', style: const TextStyle(fontFamily: 'ProductSans', fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF8B5145))),
                const Text('Total', style: TextStyle(fontFamily: 'ProductSans', fontSize: 12, color: Color(0xFF7A706D), fontWeight: FontWeight.w500)),
              ],
            ),
            _GridCard(
              title: 'Bill Splitter',
              icon: Icons.call_split_rounded,
              content: [
                RichText(text: const TextSpan(children: [
                  TextSpan(text: '1 ', style: TextStyle(fontFamily: 'ProductSans', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B5145))),
                  TextSpan(text: 'Bills', style: TextStyle(fontFamily: 'ProductSans', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A4442))),
                ])),
                const SizedBox(height: 4),
                RichText(text: const TextSpan(children: [
                  TextSpan(text: '1 ', style: TextStyle(fontFamily: 'ProductSans', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B5145))),
                  TextSpan(text: 'Active', style: TextStyle(fontFamily: 'ProductSans', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A4442))),
                ])),
                const Spacer(),
                Text('${currency}500.00', style: const TextStyle(fontFamily: 'ProductSans', fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF8B5145))),
                const Text('Total', style: TextStyle(fontFamily: 'ProductSans', fontSize: 12, color: Color(0xFF7A706D), fontWeight: FontWeight.w500)),
              ],
            ),
            _GridCard(
              title: 'Loans',
              icon: Icons.money_outlined,
              content: [
                RichText(text: const TextSpan(children: [
                  TextSpan(text: '2 ', style: TextStyle(fontFamily: 'ProductSans', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B5145))),
                  TextSpan(text: 'Lending', style: TextStyle(fontFamily: 'ProductSans', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A4442))),
                ])),
                const SizedBox(height: 4),
                RichText(text: const TextSpan(children: [
                  TextSpan(text: '1 ', style: TextStyle(fontFamily: 'ProductSans', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B5145))),
                  TextSpan(text: 'Borrowing', style: TextStyle(fontFamily: 'ProductSans', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A4442))),
                ])),
                const Spacer(),
                Text('${currency}1.95K', style: const TextStyle(fontFamily: 'ProductSans', fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF8B5145))),
                const Text('Loan Balance', style: TextStyle(fontFamily: 'ProductSans', fontSize: 12, color: Color(0xFF7A706D), fontWeight: FontWeight.w500)),
              ],
            ),
            _GridCard(
              title: 'Goals',
              icon: Icons.track_changes_outlined,
              content: [
                RichText(text: const TextSpan(children: [
                  TextSpan(text: '0 ', style: TextStyle(fontFamily: 'ProductSans', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B5145))),
                  TextSpan(text: 'Active', style: TextStyle(fontFamily: 'ProductSans', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A4442))),
                ])),
                const SizedBox(height: 4),
                RichText(text: const TextSpan(children: [
                  TextSpan(text: '0 ', style: TextStyle(fontFamily: 'ProductSans', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B5145))),
                  TextSpan(text: 'Completed', style: TextStyle(fontFamily: 'ProductSans', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A4442))),
                ])),
              ],
            ),
            _GridCard(
              title: 'Labels',
              icon: Icons.label_outlined,
              content: [
                RichText(text: const TextSpan(children: [
                  TextSpan(text: '0 ', style: TextStyle(fontFamily: 'ProductSans', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B5145))),
                  TextSpan(text: 'Labels', style: TextStyle(fontFamily: 'ProductSans', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A4442))),
                ])),
              ],
            ),
            _GridCard(
              title: 'Analytics',
              icon: Icons.show_chart_rounded,
              content: [
                const Text('This month spending', style: TextStyle(fontFamily: 'ProductSans', fontSize: 12, color: Color(0xFF7A706D), fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('${currency}0.00', style: const TextStyle(fontFamily: 'ProductSans', fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF8B5145))),
                const Spacer(),
                Text('→ Stable compared to\nlast month', style: TextStyle(fontFamily: 'ProductSans', fontSize: 11, color: const Color(0xFF7A706D).withOpacity(0.8), fontWeight: FontWeight.w500)),
              ],
            ),
            _GridCard(
              title: 'Recurring',
              icon: Icons.autorenew_rounded,
              content: [
                RichText(text: const TextSpan(children: [
                  TextSpan(text: '0 ', style: TextStyle(fontFamily: 'ProductSans', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B5145))),
                  TextSpan(text: 'Active', style: TextStyle(fontFamily: 'ProductSans', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A4442))),
                ])),
                const Spacer(),
                Text('${currency}0.00', style: const TextStyle(fontFamily: 'ProductSans', fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF8B5145))),
                const Text('Monthly Payment', style: TextStyle(fontFamily: 'ProductSans', fontSize: 12, color: Color(0xFF7A706D), fontWeight: FontWeight.w500)),
              ],
            ),
            _GridCard(
              title: 'Categories',
              icon: Icons.category_outlined,
              content: [
                RichText(text: const TextSpan(children: [
                  TextSpan(text: '15 ', style: TextStyle(fontFamily: 'ProductSans', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B5145))),
                  TextSpan(text: 'Categories', style: TextStyle(fontFamily: 'ProductSans', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A4442))),
                ])),
                const Spacer(),
                _buildCategoryRow('Miscellaneous', '${currency}5.53K', Icons.help_outline),
                _buildCategoryRow('Food', '${currency}2.18K', Icons.lunch_dining_outlined),
                _buildCategoryRow('Item Not Sp...', '${currency}864.88', Icons.receipt_long_outlined),
              ],
            ),
            _GridCard(
              title: 'Weekly',
              icon: Icons.view_week_outlined,
              content: [
                const Spacer(),
                Center(child: Icon(Icons.calendar_today_outlined, size: 36, color: const Color(0xFF7A706D).withOpacity(0.5))),
                const SizedBox(height: 12),
                Center(child: const Text('No transactions this week', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'ProductSans', fontSize: 11, color: Color(0xFF7A706D), fontWeight: FontWeight.w500))),
                const Spacer(),
              ],
            ),
            _GridCard(
              title: 'Places',
              icon: Icons.place_outlined,
              content: [
                RichText(text: const TextSpan(children: [
                  TextSpan(text: '0 ', style: TextStyle(fontFamily: 'ProductSans', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B5145))),
                  TextSpan(text: 'Places', style: TextStyle(fontFamily: 'ProductSans', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A4442))),
                ])),
              ],
            ),
            _GridCard(
              title: 'Person',
              icon: Icons.person_outline,
              content: [
                RichText(text: const TextSpan(children: [
                  TextSpan(text: '1 ', style: TextStyle(fontFamily: 'ProductSans', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B5145))),
                  TextSpan(text: 'Person', style: TextStyle(fontFamily: 'ProductSans', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A4442))),
                ])),
                const Spacer(),
                const Text('You have spent the most\nwith Faiz, totaling ₹0.00.', style: TextStyle(fontFamily: 'ProductSans', fontSize: 11, color: Color(0xFF7A706D), fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryRow(String name, String amount, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 12, color: const Color(0xFF8B5145)),
          const SizedBox(width: 4),
          Expanded(child: Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'ProductSans', fontSize: 11, color: Color(0xFF4A4442), fontWeight: FontWeight.w600))),
          Text(amount, style: const TextStyle(fontFamily: 'ProductSans', fontSize: 11, color: Color(0xFF4A4442), fontWeight: FontWeight.w700)),
        ],
      ),
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
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF6EEEC), // Solid soft M3 surface tone matching screenshot precisely
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF7A706D)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontFamily: 'ProductSans', fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF4A4442)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: const Color(0xFF7A706D).withOpacity(0.8)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Container(
              height: 1, 
              width: double.infinity, 
              color: const Color(0xFFE9C5B5).withOpacity(0.5) // Dividing faint red line matching UI
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content,
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 400.ms).scaleXY(begin: 0.96, end: 1.0, curve: Curves.easeOutCubic);
  }
}
