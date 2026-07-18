import 'en.dart';
import 'hi.dart';

class AppLocalizations {
  static String _currentLanguage = 'en';

  static void setLanguage(String lang) {
    _currentLanguage = lang;
  }

  static String get currentLanguage => _currentLanguage;
  static bool get isHindi => _currentLanguage == 'hi';

  static String translate(String key) {
    final map = _currentLanguage == 'hi' ? hi : en;
    return map[key] ?? en[key] ?? key;
  }

  /// Shorthand for translate
  static String t(String key) => translate(key);

  /// Get month name from month number (1-12)
  static String monthName(int month) {
    const keys = [
      '', 'jan', 'feb', 'mar', 'apr', 'may', 'jun',
      'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
    ];
    if (month < 1 || month > 12) return '';
    return translate(keys[month]);
  }

  /// Format currency in Indian style: ₹1,23,456
  static String formatCurrency(double amount) {
    if (amount < 0) return '-${formatCurrency(-amount)}';
    
    final intPart = amount.toInt();
    final decPart = amount - intPart;
    
    String formatted;
    if (intPart < 1000) {
      formatted = intPart.toString();
    } else {
      final lastThree = intPart % 1000;
      var remaining = intPart ~/ 1000;
      final lastThreeStr = lastThree.toString().padLeft(3, '0');
      
      final parts = <String>[];
      while (remaining > 0) {
        parts.insert(0, (remaining % 100).toString());
        remaining = remaining ~/ 100;
      }
      
      // Fix leading zeros in first part
      if (parts.isNotEmpty) {
        parts[0] = int.parse(parts[0]).toString();
      }
      
      formatted = '${parts.join(',')},${lastThreeStr}';
    }
    
    if (decPart > 0.001) {
      final decStr = decPart.toStringAsFixed(2).substring(1); // .XX
      return '₹$formatted$decStr';
    }
    return '₹$formatted';
  }

  /// Format number with comma separation
  static String formatNumber(double number) {
    if (number == number.toInt().toDouble()) {
      return number.toInt().toString();
    }
    return number.toStringAsFixed(1);
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return translate('good_morning');
    if (hour < 17) return translate('good_afternoon');
    if (hour < 20) return translate('good_evening');
    return translate('good_night');
  }

  /// Get greeting emoji
  static String getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 17) return '🌤️';
    if (hour < 20) return '🌅';
    return '🌙';
  }

  /// Get category display name
  static String categoryName(String categoryKey) {
    return translate('cat_$categoryKey');
  }

  /// Get payment mode display name
  static String paymentModeName(String mode) {
    return translate('pay_$mode');
  }
}
