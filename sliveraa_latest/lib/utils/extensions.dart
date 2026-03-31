import 'package:intl/intl.dart';

extension NumberFormatting on num {
  String toLocaleString() {
    return NumberFormat.decimalPattern('en_IN').format(this);
  }
}
