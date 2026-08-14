import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDisplay(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDisplayTime(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  static String formatIso(DateTime date) {
    return date.toIso8601String();
  }
}
