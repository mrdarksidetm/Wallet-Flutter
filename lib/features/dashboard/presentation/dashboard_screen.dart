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
      backgroundColor: Colors.transparent, // Let parent handle background
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
                         // Paisa Icon - Golden colored and angled per screenshot
                         Transform.rotate(
                           angle: -0.2,
                           child: Container(
                             width: 44,
                             height: 44,
                             decoration: BoxDecoration(
                               color: const Color(0xFFD6A848).withOpacity(0.15),
                               borderRadius: BorderRadius.circular(12),
                             ),
                             child: const Icon(Icons.wallet, color: Color(0xFFD6A848), size: 28),
                           ),
                         ),
                         Row(
                           children: [
                             // "New" badge added as it's visibly next to the Avatar
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                               decoration: BoxDecoration(
                                 color: const Color(0xFF8B3A2B), // Dark red
                                 borderRadius: BorderRadius.circular(12),
                               ),
                               child: const Text('New', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'ProductSans')),
                             ),
                             const SizedBox(width: 8),
                             Hero(
                               tag: 'profile_avatar',
                               child: Material(
                                 elevation: 2,
                                 shape: const CircleBorder(),
                                 clipBehavior: Clip.antiAlias,
                                 child: Container(
                                   decoration: BoxDecoration(
                                     shape: BoxShape.circle,
                                     border: Border.all(color: Colors.white, width: 2), // Thin border around avatar
                                   ),
                                   child: const CircleAvatar(
                                     radius: 18,
                                     backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'), // Random placeholder
                                   ),
                                 ),
                               ),
                             ),
                           ],
                         ),
                       ],
                     ),
                     const SizedBox(height: 24),
                     RichText(
                       text: TextSpan(
                         style: const TextStyle(
                           fontFamily: 'ProductSans',
                           color: Color(0xFF7A706D), // M3 expressive muted text color matches screenshot
                           fontSize: 16,
                           fontWeight: FontWeight.w500,
                           height: 1.5,
                           letterSpacing: 0.1,
                         ),
                         children: [
                           TextSpan(text: '$greeting '),
                           const TextSpan(text: 'Abhijeet Yadav. ', style: TextStyle(color: Color(0xFF3E3634), fontWeight: FontWeight.bold, fontSize: 18)),
                           const TextSpan(text: 'You have '),
                           const WidgetSpan(
                             alignment: PlaceholderAlignment.middle,
                             child: Padding(
                               padding: EdgeInsets.symmetric(horizontal: 2), 
                               child: Icon(Icons.cloud_outlined, size: 18, color: Color(0xFF7A706D))
                             ),
                           ),
                           const TextSpan(text: '\nbackup, '),
                           const WidgetSpan(
                             alignment: PlaceholderAlignment.middle,
                             child: Padding(
                               padding: EdgeInsets.symmetric(horizontal: 2), 
                               child: Icon(Icons.star_outline, size: 18, color: Color(0xFF7A706D))
                             ),
                           ),
                           const TextSpan(text: ' rating'),
                         ],
                       ),
                     ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                   ],
                 ),
               ),
             ),
          ),
          SliverToBoxAdapter(
            child: const BalanceCard().animate().fade(duration: 600.ms, curve: Curves.easeOutQuad).slideY(begin: 0.1, end: 0),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            sliver: SliverToBoxAdapter(
              child: const OverviewCards().animate(delay: 100.ms).fade(duration: 600.ms).slideY(begin: 0.1, end: 0),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 24),
            sliver: SliverToBoxAdapter(child: CalendarHeatmapCard()),
          ),
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 24),
            sliver: SliverToBoxAdapter(child: TrendChartCard()),
          ),
          SliverToBoxAdapter(
            child: RecentTransactions(onSeeAll: onNavigateToTransactions)
                .animate(delay: 200.ms)
                .fade(duration: 600.ms)
                .slideY(begin: 0.1, end: 0),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 140)),
        ],
      ),
    );
  }
}
