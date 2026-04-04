import 'package:intl/intl.dart';

extension NumberFormatting on num {
  String toLocaleString() {
    if (!this.isFinite || this.isNaN) return "0.00";
    return NumberFormat.decimalPattern('en_IN').format(this);
  }
}
