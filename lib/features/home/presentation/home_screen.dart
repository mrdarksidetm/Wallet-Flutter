import 'package:flutter/material.dart';
import '../../budgets/presentation/add_budget_screen.dart';
import 'widgets/home_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFFAF5F2), 
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(const HomeAppBar()),
            pinned: false,
            floating: true,
          ),
          
          const SliverToBoxAdapter(
            child: HomeBalanceCard(),
          ),

          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Overview',
              trailing: Icon(Icons.grid_view_rounded, color: Color(0xFF4A4442)),
            ),
          ),

          const OverviewGrid(),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          
          const AnalyticsGrid(),

           const SliverToBoxAdapter(child: SizedBox(height: 12)),

          const SliverToBoxAdapter(
            child: CalendarHeatmapCard(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Trend',
              trailing: Icon(Icons.chevron_right, color: Color(0xFF4A4442)),
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            ),
          ),
          
          const SliverToBoxAdapter(
            child: TrendCard(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Recent transactions',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF9C4F44)),
                  borderRadius: BorderRadius.circular(16)
                ),
                child: const Text('See All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF9C4F44))),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final colors = [Colors.green, Colors.red, Colors.orange, Colors.orange, Colors.red];
                final icons = [Icons.account_balance, Icons.person, Icons.person, Icons.person, Icons.person];
                final names = ['Rishav', 'Transfer Faiz', '3:18 PM • Aug 18', '3:18 PM • Aug 18', 'Transfer Faiz'];
                final amounts = ['₹78.00', '-₹550.00', '-₹350.00', '-₹250.00', '-₹250.00'];
                final badges = ['Rishav', 'Faiz', 'Shanvi', 'Shambhavi', 'Faiz'];
                
                if (index > 4) return const SizedBox.shrink();

                return TransactionTile(
                  name: names[index],
                  amount: amounts[index],
                  color: colors[index],
                  icon: icons[index],
                  badge: badges[index],
                  date: 'Sep 11, 2025 • Bank Balance',
                );
              },
              childCount: 5,
            ),
          ),
          
          const SliverPadding(padding: EdgeInsets.only(bottom: 120)), 
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: const Color(0xFFFAF5F2),
        elevation: 0,
        indicatorColor: const Color(0xFFEADDFF),
        onDestinationSelected: (int index) {
          setState(() {
             _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF381E72)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: _buildDynamicFAB(),
      ),
    );
  }

  Widget _buildDynamicFAB() {
    IconData fabIcon;
    VoidCallback fabAction;
    Key fabKey;

    switch (_currentIndex) {
      case 0:
        fabIcon = Icons.add;
        fabKey = const ValueKey('home_fab');
        fabAction = () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBudgetScreen()),
          );
        };
        break;
      case 1:
        fabIcon = Icons.account_balance;
        fabKey = const ValueKey('accounts_fab');
        fabAction = () {};
        break;
      case 2:
        fabIcon = Icons.picture_as_pdf;
        fabKey = const ValueKey('reports_fab');
        fabAction = () {};
        break;
      case 3:
        fabIcon = Icons.filter_list;
        fabKey = const ValueKey('search_fab');
        fabAction = () {};
        break;
      default:
        fabIcon = Icons.add;
        fabKey = const ValueKey('default_fab');
        fabAction = () {};
    }

    return FloatingActionButton(
      key: fabKey,
      elevation: 2,
      backgroundColor: const Color(0xFFC7A890), 
      onPressed: fabAction,
      child: Icon(fabIcon, size: 28, color: const Color(0xFF4A3428)),
    );
  }

  // Extracted methods remain clean
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final PreferredSizeWidget child;

  _SliverAppBarDelegate(this.child);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  double get maxExtent => child.preferredSize.height;

  @override
  double get minExtent => child.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
