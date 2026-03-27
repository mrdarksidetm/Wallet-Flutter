import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/database/providers.dart';
import '../../../core/widgets/icon_picker.dart';

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(child: Text('No accounts found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  onTap: () => context.push('/add_account', extra: account),
                  leading: CircleAvatar(
                    backgroundColor: Color(int.parse(account.color.replaceAll('0x', ''), radix: 16)).withValues(alpha: 0.1),
                    child: Icon(
                      AppIcons.getIcon(account.icon),
                      color: Color(int.parse(account.color.replaceAll('0x', ''), radix: 16)),
                    ),
                  ),
                  title: Text(
                    account.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(account.type.name.toUpperCase()),
                  trailing: Text(
                    currencyFormat.format(account.balance),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
