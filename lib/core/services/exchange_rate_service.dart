import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class ExchangeRateService {
  // Using a free, no-auth API endpoint for demonstration/open-source purposes
  // https://github.com/fawazahmed0/exchange-api
  static const String _baseUrl = 'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies';

  // Cache to prevent excessive API calls
  Map<String, double>? _rates;
  DateTime? _lastFetch;
  String _baseCurrency = 'usd';

  Future<double> getRate(String fromCurrency, String toCurrency) async {
    fromCurrency = fromCurrency.toLowerCase();
    toCurrency = toCurrency.toLowerCase();

    if (fromCurrency == toCurrency) return 1.0;

    await _fetchRatesIfNeeded(fromCurrency);

    if (_rates == null || !_rates!.containsKey(toCurrency)) {
      throw Exception('Exchange rate not available for $toCurrency');
    }

    return _rates![toCurrency]!;
  }

  Future<void> _fetchRatesIfNeeded(String base) async {
    // Refresh if cache is empty, base currency changed, or cache is older than 12 hours
    if (_rates == null || 
        _baseCurrency != base || 
        _lastFetch == null || 
        DateTime.now().difference(_lastFetch!).inHours > 12) {
      
      try {
        final response = await http.get(Uri.parse('$_baseUrl/$base.json'));
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data.containsKey(base)) {
            _rates = Map<String, double>.from(
              data[base].map((key, value) => MapEntry(key, (value as num).toDouble()))
            );
            _baseCurrency = base;
            _lastFetch = DateTime.now();
          } else {
            throw Exception('Invalid data format from exchange API');
          }
        } else {
          throw Exception('Failed to load exchange rates: ${response.statusCode}');
        }
      } catch (e) {
        // Fallback to older URL structure if latest fails (resilience)
        try {
           final fallbackResponse = await http.get(Uri.parse('https://latest.currency-api.pages.dev/v1/currencies/$base.json'));
           if (fallbackResponse.statusCode == 200) {
             final data = json.decode(fallbackResponse.body);
             _rates = Map<String, double>.from(
                data[base].map((key, value) => MapEntry(key, (value as num).toDouble()))
             );
             _baseCurrency = base;
             _lastFetch = DateTime.now();
           } else {
             throw Exception('Failed fallback API');
           }
        } catch (fallbackError) {
           throw Exception('Could not fetch exchange rates: $e');
        }
      }
    }
  }
}

final exchangeRateServiceProvider = Provider<ExchangeRateService>((ref) {
  return ExchangeRateService();
});
