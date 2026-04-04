import 'package:intl/intl.dart';

extension NumberFormatting on num {
  String toLocaleString({int decimals = 2}) {
    if (!this.isFinite || this.isNaN) return "0.00";
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '',
      decimalDigits: decimals,
    ).format(this).trim();
  }

}
