import 'package:intl/intl.dart';

class DateFormatter {
  static String formatFull(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (_) {
      return isoString;
    }
  }

  static String formatShort(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return isoString;
    }
  }
}