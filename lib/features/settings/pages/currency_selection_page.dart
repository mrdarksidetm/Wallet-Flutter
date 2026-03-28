import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/database/providers.dart';
import '../../../core/theme/personalization_provider.dart';

class CurrencySelectionPage extends ConsumerWidget {
  const CurrencySelectionPage({super.key});

  static List<Map<String, String>> currencies = [
    {'code': 'INR', 'name': 'Indian Rupee', 'symbol': '₹'},
    {'code': 'USD', 'name': 'United States Dollar', 'symbol': '\$'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
    {'code': 'GBP', 'name': 'British Pound Sterling', 'symbol': '£'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥'},
    {'code': 'CNY', 'name': 'Chinese Yuan', 'symbol': '¥'},
    {'code': 'AUD', 'name': 'Australian Dollar', 'symbol': 'A\$'},
    {'code': 'CAD', 'name': 'Canadian Dollar', 'symbol': 'C\$'},
    {'code': 'BRL', 'name': 'Brazilian Real', 'symbol': 'R\$'},
    {'code': 'RUB', 'name': 'Russian Ruble', 'symbol': '₽'},
    {'code': 'IDR', 'name': 'Indonesian Rupiah', 'symbol': 'Rp'},
    {'code': 'KRW', 'name': 'South Korean Won', 'symbol': '₩'},
    {'code': 'TRY', 'name': 'Turkish Lira', 'symbol': '₺'},
    {'code': 'ZAR', 'name': 'South African Rand', 'symbol': 'R'},
    {'code': 'MXN', 'name': 'Mexican Peso', 'symbol': 'MX\$'},
    {'code': 'SGD', 'name': 'Singapore Dollar', 'symbol': 'S\$'},
    {'code': 'HKD', 'name': 'Hong Kong Dollar', 'symbol': 'HK\$'},
    {'code': 'NZD', 'name': 'New Zealand Dollar', 'symbol': 'NZ\$'},
    {'code': 'CHF', 'name': 'Swiss Franc', 'symbol': 'CHF'},
    {'code': 'AED', 'name': 'United Arab Emirates Dirham', 'symbol': 'AED'},
    {'code': 'SAR', 'name': 'Saudi Riyal', 'symbol': 'SR'},
    {'code': 'PKR', 'name': 'Pakistani Rupee', 'symbol': '₨'},
    {'code': 'BDT', 'name': 'Bangladeshi Taka', 'symbol': '৳'},
    {'code': 'LKR', 'name': 'Sri Lankan Rupee', 'symbol': 'Rs'},
    {'code': 'MYR', 'name': 'Malaysian Ringgit', 'symbol': 'RM'},
    {'code': 'THB', 'name': 'Thai Baht', 'symbol': '฿'},
    {'code': 'VND', 'name': 'Vietnamese Dong', 'symbol': '₫'},
    {'code': 'PHP', 'name': 'Philippine Peso', 'symbol': '₱'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCurrency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Currency'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: currencies.length,
        itemBuilder: (context, index) {
          final currency = currencies[index];
          final isSelected = selectedCurrency == currency['code'];

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: isSelected 
                  ? Theme.of(context).colorScheme.primaryContainer 
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Text(
                currency['symbol']!,
                style: TextStyle(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.onPrimaryContainer 
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              currency['name']!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(currency['code']!),
            trailing: isSelected 
                ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary) 
                : null,
            onTap: () async {
              await HapticService.selectionStatic();
              ref.read(personalizationProvider.notifier).updateCurrency(currency['code']!);
              if (context.mounted) context.pop();
            },
          );
        },
      ),
    );
  }
}
