import 'package:intl/intl.dart';

class DateFormatter {
  static String formatShortDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  static String formatTimeAgo(DateTime date) {
    final duration = DateTime.now().difference(date);
    if (duration.inDays > 7) {
      return formatShortDate(date);
    } else if (duration.inDays >= 1) {
      return '${duration.inDays}d ago';
    } else if (duration.inHours >= 1) {
      return '${duration.inHours}h ago';
    } else if (duration.inMinutes >= 1) {
      return '${duration.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
