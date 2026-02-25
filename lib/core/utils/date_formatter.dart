import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class DateFormatter {
  static String formatDate(DateTime date) =>
      DateFormat('dd MMM yyyy').format(date);

  static String formatTime(DateTime date) => DateFormat('HH:mm').format(date);

  static String formatDateTime(DateTime date) =>
      DateFormat('dd MMM yyyy, HH:mm').format(date);

  static String timeAgo(DateTime date) =>
      timeago.format(date, locale: 'es');

  static String dayOfWeek(DateTime date) =>
      DateFormat('EEEE', 'es').format(date);

  static String greetingDate(DateTime date) =>
      DateFormat("EEEE, d 'de' MMMM", 'es').format(date);

  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos dias';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }
}
