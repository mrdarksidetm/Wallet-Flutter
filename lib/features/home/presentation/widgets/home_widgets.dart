import 'package:flutter/material.dart';
import '../../../budgets/presentation/budgets_screen.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEADDFF), 
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.wallet, color: Color(0xFF6750A4)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: textTheme.bodyMedium?.copyWith(color: const Color(0xFF757575)),
                children: [
                  const TextSpan(text: 'Good morning '),
                  TextSpan(
                    text: 'Abhijeet Yadav',
                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1B1B1F)),
                  ),
                  const TextSpan(text: '. You have '),
                  const WidgetSpan(
                    child: Icon(Icons.cloud_upload_outlined, size: 16, color: Color(0xFF757575)),
                    alignment: PlaceholderAlignment.middle,
                  ),
                  const TextSpan(text: ' backup, '),
                  const WidgetSpan(
                    child: Icon(Icons.star_border, size: 16, color: Color(0xFF757575)),
                    alignment: PlaceholderAlignment.middle,
                  ),
                  const TextSpan(text: ' rating'),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class HomeBalanceCard extends StatelessWidget {
  const HomeBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFD6C8B8), width: 1.5),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8D3C3), 
              Color(0xFFE4D0C5),
              Color(0xFFC29B8C), 
              Color(0xFFEAD8D0),
            ],
            stops: [0.0, 0.4, 0.8, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total balance',
                    style: textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF5A4D48),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Icon(Icons.visibility_off_outlined, color: Color(0xFF2E2421)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '-₹1,666.81',
                style: textTheme.displayLarge?.copyWith(
                  color: const Color(0xFF2E2421),
                  fontWeight: FontWeight.w900,
                  fontSize: 48,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'This month',
                style: textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF5A4D48),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceStat(
                      context, 
                      title: 'Income', 
                      amount: '₹0.00', 
                      percentage: '0.00%', 
                      isPositive: true,
                    ),
                  ),
                  Expanded(
                    child: _buildBalanceStat(
                      context, 
                      title: 'Expense', 
                      amount: '₹0.00', 
                      percentage: '0.00%', 
                      isPositive: false,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceStat(BuildContext context, {required String title, required String amount, required String percentage, required bool isPositive}) {
    final textTheme = Theme.of(context).textTheme;
    final color = isPositive ? Colors.green : Colors.red;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.bodySmall?.copyWith(color: const Color(0xFF756A63))),
        Row(
          children: [
            Text('$amount ', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF2E2421))),
            Icon(Icons.arrow_upward, color: color, size: 12),
            Text(percentage, style: textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        Text('Compared to ₹0.00 last month', style: textTheme.bodySmall?.copyWith(color: const Color(0xFF756A63), fontSize: 10)),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget trailing;
  final EdgeInsets padding;

  const SectionHeader({
    super.key,
    required this.title,
    required this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 24, 20, 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4A4442)
                ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class OverviewGrid extends StatelessWidget {
  const OverviewGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetsScreen()),
              );
            },
            child: const ExpressiveCard(
              icon: Icons.pie_chart_outline,
              color: Color(0xFFF9EAE8), 
              title: 'Budgets',
              mainValue: '1',
              subLabel: 'Budgets',
              bottomWidget: _BudgetsBottomWidget(),
            ),
          ),
          const ExpressiveCard(
            icon: Icons.account_balance_wallet_outlined,
            color: Color(0xFFF9EAE8),
            title: 'Assets',
            mainValue: '1',
            subLabel: 'Assets',
            bottomWidget: Text('₹500.00\nTotal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFC07062))),
          ),
          const ExpressiveCard(
            icon: Icons.call_split,
            color: Color(0xFFF9EAE8), 
            title: 'Bill Splitter',
            mainValue: '1',
            subLabel: 'Bills\n1 Active',
            bottomWidget: Text('₹500.00\nTotal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFC07062))),
          ),
          const ExpressiveCard(
            icon: Icons.money,
            color: Color(0xFFF9EAE8), 
            title: 'Loans',
            mainValue: '2',
            subLabel: 'Lending\n1 Borrowing',
            bottomWidget: Text('₹1.95K\nLoan Balance', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFC07062))),
          ),
          const ExpressiveCard(
            icon: Icons.flag_outlined,
            color: Color(0xFFF5EBE8), 
            title: 'Goals',
            mainValue: '0',
            subLabel: 'Active\n0 Completed',
          ),
          const ExpressiveCard(
            icon: Icons.label_outline,
            color: Color(0xFFF5EBE8), 
            title: 'Labels',
            mainValue: '0',
            subLabel: 'Labels',
          ),
        ],
      ),
    );
  }
}

class _BudgetsBottomWidget extends StatelessWidget {
  const _BudgetsBottomWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 4, width: double.infinity, decoration: BoxDecoration(color: const Color(0xFFE5D1CF), borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 4),
        const Text('0% of total budget spent', style: TextStyle(fontSize: 10, color: Color(0xFF7D7270))),
      ]
    );
  }
}

class AnalyticsGrid extends StatelessWidget {
  const AnalyticsGrid({super.key});

  @override
  Widget build(BuildContext context) {
     return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
        children: const [
          ExpressiveCard(
            icon: Icons.show_chart,
            color: Color(0xFFFDECE9), 
            title: 'Analytics',
            mainValue: '',
            subLabel: 'This month spending',
            bottomWidget: Text('₹0.00\n→ Stable compared to\nlast month', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8A7773))),
          ),
          ExpressiveCard(
            icon: Icons.calendar_month,
            color: Color(0xFFFDECE9), 
            title: 'Recurring',
            mainValue: '0',
            subLabel: 'Active',
            bottomWidget: Text('₹0.00\nMonthly Payment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFC07062))),
          ),
          ExpressiveCard(
            icon: Icons.category_outlined,
            color: Color(0xFFFDECE9), 
            title: 'Categories',
            mainValue: '15',
            subLabel: 'Categories',
            bottomWidget: Text('Food    ₹2.18k\nOther   ₹1.00k', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8A7773))),
          ),
          ExpressiveCard(
            icon: Icons.view_week_outlined,
            color: Color(0xFFFDECE9), 
            title: 'Weekly',
            mainValue: '',
            subLabel: 'No transactions this week',
            bottomWidget: Icon(Icons.date_range_outlined, size: 32, color: Color(0xFF8A7773)),
          ),
        ]
      )
    );
  }
}

class CalendarHeatmapCard extends StatelessWidget {
  const CalendarHeatmapCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8E9E3),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20, color: Color(0xFF5A4D48)),
                    const SizedBox(width: 8),
                    Text('Calendar heatmap', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF5A4D48))),
                  ]
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF5A4D48)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Mar 2026', style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF5A4D48))),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, 
                crossAxisSpacing: 4, 
                mainAxisSpacing: 4,
              ),
              itemCount: 31,
              itemBuilder: (context, index) {
                  bool isToday = index == 3; 
                  return Container(
                    decoration: BoxDecoration(
                      color: isToday ? Colors.transparent : const Color(0xFFEEDDDA),
                      border: isToday ? Border.all(color: const Color(0xFF745D56), width: 2) : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text('${index + 1}', style: TextStyle(color: isToday ? const Color(0xFF745D56) : const Color(0xFF908381), fontSize: 12, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
                  );
              }
            )
          ]
        )
      )
    );
  }
}

class TrendCard extends StatelessWidget {
  const TrendCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 120, // Simplified trend chart base
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8E9E3),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text('Last 30 Days: ₹0.00', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF5A4D48))),
      )
    );
  }
}

class ExpressiveCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String mainValue;
  final String subLabel;
  final Widget? bottomWidget;

  const ExpressiveCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.mainValue,
    required this.subLabel,
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: const Color(0xFF745D56)),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A4442))),
                ]
              ),
              const Icon(Icons.chevron_right, size: 18, color: Color(0xFF745D56)),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(mainValue, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF9C4F44))),
              const SizedBox(width: 4),
              Text(subLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4A4442))),
            ],
          ),
          if (bottomWidget != null) ...[
            const Spacer(),
            bottomWidget!,
          ]
        ],
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final String name;
  final String amount;
  final Color color;
  final IconData icon;
  final String badge;
  final String date;

  const TransactionTile({
    super.key,
    required this.name,
    required this.amount,
    required this.color,
    required this.icon,
    required this.badge,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = amount.startsWith('-');
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(date, style: const TextStyle(fontSize: 11)),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(badge, style: const TextStyle(fontSize: 10, color: Colors.red)),
            )
        ]
      ),
      trailing: Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isExpense ? Colors.red : Colors.green)),
    );
  }
}
