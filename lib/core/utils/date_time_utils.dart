import 'package:intl/intl.dart';

class DateTimeUtils {
  DateTimeUtils._();

  static final DateFormat _dateOnlyFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _readableFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dayOfWeekFormat = DateFormat('EEEE');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');

  static String toDateOnlyString(DateTime date) => _dateOnlyFormat.format(date);
  static String toReadableDate(DateTime date) => _readableFormat.format(date);
  static String toReadableTime(DateTime date) => _timeFormat.format(date);
  static String toDayOfWeek(DateTime date) => _dayOfWeekFormat.format(date);
  static String toMonthYear(DateTime date) => _monthYearFormat.format(date);

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isConsecutiveDay(DateTime older, DateTime newer) {
    final startOlder = startOfDay(older);
    final startNewer = startOfDay(newer);
    return startNewer.difference(startOlder).inDays == 1;
  }

  static List<DateTime> getDaysInCurrentYear() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, 1, 1);
    final totalDays = DateTime(now.year, 12, 31).difference(firstDay).inDays + 1;
    return List.generate(totalDays, (index) => firstDay.add(Duration(days: index)));
  }

  static List<DateTime> getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final nextMonthFirstDay = (month.month == 12)
        ? DateTime(month.year + 1, 1, 1)
        : DateTime(month.year, month.month + 1, 1);
    final totalDays = nextMonthFirstDay.difference(firstDay).inDays;
    return List.generate(totalDays, (index) => firstDay.add(Duration(days: index)));
  }

  static List<DateTime> getLastNDays(int n) {
    final now = DateTime.now();
    final today = startOfDay(now);
    return List.generate(n, (index) => today.subtract(Duration(days: n - 1 - index)));
  }
}
