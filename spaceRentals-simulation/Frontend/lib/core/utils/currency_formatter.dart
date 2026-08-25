import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatCFA(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
