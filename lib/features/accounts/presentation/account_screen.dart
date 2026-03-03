import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/providers.dart';
import '../../../shared/widgets/paisa_list_tile.dart';
import 'widgets/active_account_card.dart';
import 'widgets/account_tab_filters.dart';
import 'add_edit_account_screen.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/color_extension.dart';
import '../../categories/presentation/category_screen.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) return const Center(child: Text('No accounts found.'));
          
          final themeState = ref.watch(themeControllerProvider); 

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  child: AccountTabFilters(),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ActiveAccountCard(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final acc = accounts[index];
                    final color = (acc.color).parseHexColor();
                    
                    return PaisaListTile(
                      title: acc.name,
                      subtitle: acc.type.name.toUpperCase(),
                      amount: '${themeState.currencySymbol}${acc.balance.toStringAsFixed(2)}',
                      amountColor: Theme.of(context).colorScheme.primary,
                      icon: getIconDataFromString(acc.icon),
                      iconColor: Colors.white,
                      iconBackgroundColor: color,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => ref.read(accountServiceProvider).deleteAccount(acc.id),
                      ),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditAccountScreen(account: acc))),
                    );
                  },
                  childCount: accounts.length,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditAccountScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
