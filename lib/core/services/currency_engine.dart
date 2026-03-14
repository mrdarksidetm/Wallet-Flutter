import 'package:decimal/decimal.dart';

/// Phase 26: Offline Multi-Currency Conversion
///
/// Allows users to log expenses during travel.
///
/// CRITICAL: Mathematical Precision
/// We use the `decimal` package instead of native `double` to prevent 
/// floating-point arithmetic errors when converting currencies.
class CurrencyEngine {
  // In a real app, this rate is fetched once via a "Sync Rates" button and cached.
  static Decimal _cachedExchangeRate = Decimal.one;

  static void updateCachedRate(double newRate) {
    _cachedExchangeRate = Decimal.parse(newRate.toString());
  }

  static double convertToHomeCurrency(double foreignAmount) {
    final foreign = Decimal.parse(foreignAmount.toString());
    final homeAmount = foreign * _cachedExchangeRate;
    
    // Convert back to double with 2 decimal precision
    return double.parse(homeAmount.toStringAsFixed(2));
  }
}
