import 'package:intl/intl.dart';

String formatRupee(double value) {
  return NumberFormat.currency(
    symbol: '',
    decimalDigits: 2,
    locale: 'en_IN',
  ).format(value);
}
