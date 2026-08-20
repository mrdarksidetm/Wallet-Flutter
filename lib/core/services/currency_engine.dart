import 'package:intl/intl.dart';

class CurrencyEngine {
  /// Maps a currency code to its primary locale to ensure correct 
  /// numbering systems (e.g., lakh/crore for INR, decimal commas for EUR).
  static String getLocaleForCurrency(String currencyCode) {
    switch (currencyCode) {
      case 'INR': return 'en_IN'; // 1,00,00,000 (Lakh/Crore)
      case 'USD': return 'en_US'; // 100,000,000
      case 'EUR': return 'de_DE'; // 100.000.000,00
      case 'GBP': return 'en_GB';
      case 'JPY': return 'ja_JP';
      case 'CNY': return 'zh_CN';
      case 'AUD': return 'en_AU';
      case 'CAD': return 'en_CA';
      case 'BRL': return 'pt_BR';
      case 'RUB': return 'ru_RU';
      case 'IDR': return 'id_ID';
      case 'KRW': return 'ko_KR';
      case 'TRY': return 'tr_TR';
      case 'ZAR': return 'en_ZA';
      case 'MXN': return 'es_MX';
      case 'SGD': return 'en_SG';
      case 'HKD': return 'zh_HK';
      case 'NZD': return 'en_NZ';
      case 'CHF': return 'de_CH';
      case 'AED': return 'ar_AE';
      case 'SAR': return 'ar_SA';
      case 'PKR': return 'en_PK'; // Similar to India
      case 'BDT': return 'bn_BD'; // Similar to India
      case 'LKR': return 'en_LKR';
      case 'MYR': return 'ms_MY';
      case 'THB': return 'th_TH';
      case 'VND': return 'vi_VN';
      case 'PHP': return 'en_PH';
      case 'EGP': return 'ar_EG';
      case 'NGN': return 'en_NG';
      case 'COP': return 'es_CO';
      case 'ARS': return 'es_AR';
      case 'CLP': return 'es_CL';
      case 'PEN': return 'es_PE';
      case 'TWD': return 'zh_TW';
      case 'KWD': return 'ar_KW';
      case 'QAR': return 'ar_QA';
      case 'OMR': return 'ar_OM';
      case 'BHD': return 'ar_BH';
      case 'ILS': return 'he_IL';
      case 'PLN': return 'pl_PL';
      case 'SEK': return 'sv_SE';
      case 'NOK': return 'nb_NO';
      case 'DKK': return 'da_DK';
      case 'HUF': return 'hu_HU';
      case 'CZK': return 'cs_CZ';
      default: return 'en_US';
    }
  }

  /// Formats a double amount into a localized currency string.
  /// [ACTION]: Formatting currency based on the specific numbering system of the locale.
  /// [M3 UPDATE]: We use NumberFormat.simpleCurrency with the mapped locale.
  /// [WHY]: This ensures that users in regions like India see 1,00,00,000 while 
  /// US users see 100,000,000, respecting local financial customs and readability.
  static String formatCurrency(double amount, String currencyCode, {bool showSymbol = true}) {
    final locale = getLocaleForCurrency(currencyCode);
    final format = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
      decimalDigits: (currencyCode == 'JPY' || currencyCode == 'KRW') ? 0 : 2,
    );

    if (showSymbol) {
      return format.format(amount);
    } else {
      // If we don't want the symbol, we can use NumberFormat.decimalPattern
      // but configured with the specific currency's locale.
      return NumberFormat.decimalPattern(locale).format(amount);
    }
  }

  /// Returns only the currency symbol for the given code.
  static String getSymbol(String currencyCode) {
    final locale = getLocaleForCurrency(currencyCode);
    return NumberFormat.simpleCurrency(locale: locale, name: currencyCode).currencySymbol;
  }
}
