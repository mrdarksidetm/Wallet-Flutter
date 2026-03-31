import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restart_app/restart_app.dart';
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
    {'code': 'EGP', 'name': 'Egyptian Pound', 'symbol': 'E£'},
    {'code': 'NGN', 'name': 'Nigerian Naira', 'symbol': '₦'},
    {'code': 'COP', 'name': 'Colombian Peso', 'symbol': 'COL\$'},
    {'code': 'ARS', 'name': 'Argentine Peso', 'symbol': 'AR\$'},
    {'code': 'CLP', 'name': 'Chilean Peso', 'symbol': 'CLP\$'},
    {'code': 'PEN', 'name': 'Peruvian Sol', 'symbol': 'S/.'},
    {'code': 'TWD', 'name': 'New Taiwan Dollar', 'symbol': 'NT\$'},
    {'code': 'KWD', 'name': 'Kuwaiti Dinar', 'symbol': 'KD'},
    {'code': 'QAR', 'name': 'Qatari Rial', 'symbol': 'QR'},
    {'code': 'OMR', 'name': 'Omani Rial', 'symbol': 'OR'},
    {'code': 'BHD', 'name': 'Bahraini Dinar', 'symbol': 'BD'},
    {'code': 'ILS', 'name': 'Israeli New Shekel', 'symbol': '₪'},
    {'code': 'PLN', 'name': 'Polish Zloty', 'symbol': 'zł'},
    {'code': 'SEK', 'name': 'Swedish Krona', 'symbol': 'kr'},
    {'code': 'NOK', 'name': 'Norwegian Krone', 'symbol': 'kr'},
    {'code': 'DKK', 'name': 'Danish Krone', 'symbol': 'kr'},
    {'code': 'HUF', 'name': 'Hungarian Forint', 'symbol': 'Ft'},
    {'code': 'CZK', 'name': 'Czech Koruna', 'symbol': 'Kč'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCurrency = ref.watch(currencyProvider);
    final personalization = ref.watch(personalizationProvider);

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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
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
                ? Icon(Icons.check_circle_rounded,
                    color: Theme.of(context).colorScheme.primary)
                : null,
            onTap: () async {
              ref
                  .read(personalizationProvider.notifier)
                  .updateCurrency(currency['code']!);
              
              if (personalization.shouldRestartOnCurrencyChange) {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      title: const Text('Currency Changed'),
                      content: const Text(
                          'The app needs to restart to apply the new currency settings correctly.'),
                      actions: [
                        FilledButton(
                          onPressed: () => Restart.restartApp(),
                          child: const Text('Restart Now'),
                        ),
                      ],
                    ),
                  );
                }
              } else {
                if (context.mounted) context.pop();
              }
            },
          );
        },
      ),
    );
  }
}
