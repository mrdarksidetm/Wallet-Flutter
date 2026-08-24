import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:restart_app/restart_app.dart';
import '../../../core/database/providers.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/widgets/app_back_button.dart';
import '../widgets/settings_segmented_card.dart';

class CurrencySelectionPage extends ConsumerStatefulWidget {
  const CurrencySelectionPage({super.key});

  static const List<Map<String, String>> currencies = [
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
  ConsumerState<CurrencySelectionPage> createState() =>
      _CurrencySelectionPageState();
}

class _CurrencySelectionPageState extends ConsumerState<CurrencySelectionPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCurrency = ref.watch(currencyProvider);
    final personalization = ref.watch(personalizationProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final filteredCurrencies = CurrencySelectionPage.currencies.where((c) {
      final name = c['name']!.toLowerCase();
      final code = c['code']!.toLowerCase();
      final symbol = c['symbol']!.toLowerCase();
      return name.contains(_searchQuery) ||
          code.contains(_searchQuery) ||
          symbol.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            leading: const AppBackButton(),
            title: Text(
              'Select Currency',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: (theme.textTheme.headlineLarge?.fontSize ?? 32) + 3,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            sliver: SliverList.list(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by currency name or code...',
                      hintStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                        fontSize: 15,
                      ),
                      prefixIcon: Icon(
                        Symbols.search_rounded,
                        color: colorScheme.onSurfaceVariant,
                        size: 22,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Symbols.close_rounded, size: 20),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (filteredCurrencies.isEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Symbols.search_off_rounded,
                          size: 48,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No currencies found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SettingsSegmentedGroup(
                    children: filteredCurrencies.asMap().entries.map((entry) {
                      final index = entry.key;
                      final currency = entry.value;
                      final isLast = index == filteredCurrencies.length - 1;
                      final isSelected = selectedCurrency == currency['code'];

                      return SettingsActionTile(
                        customLeading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primaryContainer
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              currency['symbol']!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        title: currency['name']!,
                        subtitle: currency['code']!,
                        trailing: isSelected
                            ? Icon(
                                Symbols.check_circle_rounded,
                                color: colorScheme.primary,
                                size: 24,
                              )
                            : null,
                        showDivider: !isLast,
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  title: const Text('Currency Changed'),
                                  content: const Text(
                                    'The app needs to restart to apply the new currency settings correctly.',
                                  ),
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
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
