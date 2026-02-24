import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'widgets/balance_card.dart';
import 'widgets/overview_cards.dart';
import 'widgets/analytics_overview_cards.dart';
import 'widgets/calendar_heatmap_card.dart';
import 'widgets/trend_chart_card.dart';
import 'widgets/recent_transaction_list.dart';
import '../../../../core/services/greeting_service.dart';

class DashboardScreen extends ConsumerWidget {
  final VoidCallback onNavigateToTransactions;

  const DashboardScreen({super.key, required this.onNavigateToTransactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = ref.watch(greetingServiceProvider).getGreeting();
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverSafeArea(
             bottom: false,
             sliver: SliverToBoxAdapter(
               child: Padding(
                 padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         // Placeholder for Paisa Icon
                         Container(
                           width: 32,
                           height: 32,
                           decoration: BoxDecoration(
                             color: const Color(0xFFE5A48F).withOpacity(0.2),
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: const Icon(Icons.wallet, color: Color(0xFFE5A48F), size: 18),
                         ),
                         Row(
                           children: [
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                               decoration: BoxDecoration(
                                 color: const Color(0xFF8B5145).withOpacity(0.5),
                                 borderRadius: BorderRadius.circular(16),
                               ),
                               child: const Row(
                                 children: [
                                   Icon(Icons.diamond_outlined, color: Color(0xFFE5A48F), size: 14),
                                   SizedBox(width: 4),
                                   Text('PREMIUM', style: TextStyle(color: Color(0xFFE5A48F), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                 ],
                               ),
                             ),
                             const SizedBox(width: 12),
                             const CircleAvatar(
                               radius: 16,
                               backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'), // Random placeholder
                             ),
                           ],
                         ),
                       ],
                     ),
                     const SizedBox(height: 24),
                     RichText(
                       text: TextSpan(
                         style: const TextStyle(
                           color: Colors.white70,
                           fontSize: 16,
                           fontWeight: FontWeight.w500,
                           height: 1.4,
                         ),
                         children: [
                           TextSpan(text: greeting),
                           const TextSpan(text: ' Abhijeet Yadav.\n', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                           const TextSpan(text: 'You have '),
                           const WidgetSpan(child: Padding(padding: EdgeInsets.symmetric(horizontal: 2), child: Icon(Icons.cloud_done_outlined, size: 16, color: Colors.white70))),
                           const TextSpan(text: ' backup, '),
                           const WidgetSpan(child: Padding(padding: EdgeInsets.symmetric(horizontal: 2), child: Icon(Icons.star_outline, size: 16, color: Colors.white70))),
                           const TextSpan(text: ' rating'),
                         ],
                       ),
                     ).animate().fade().slideY(),
                   ],
                 ),
               ),
             ),
          ),
          SliverToBoxAdapter(
            child: const BalanceCard().animate().fade(duration: 600.ms, curve: Curves.easeOutQuad).slideY(begin: 0.1, end: 0),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            sliver: SliverToBoxAdapter(
              child: const OverviewCards().animate(delay: 100.ms).fade(duration: 600.ms).slideY(begin: 0.1, end: 0),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 16),
            sliver: SliverToBoxAdapter(child: AnalyticsOverviewCards()),
          ),
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 16),
            sliver: SliverToBoxAdapter(child: CalendarHeatmapCard()),
          ),
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 16),
            sliver: SliverToBoxAdapter(child: TrendChartCard()),
          ),
          SliverToBoxAdapter(
            child: RecentTransactions(onSeeAll: onNavigateToTransactions)
                .animate(delay: 200.ms)
                .fade(duration: 600.ms)
                .slideY(begin: 0.1, end: 0),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
        ],
      ),
    );
  }
}
