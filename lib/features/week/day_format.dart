import '../../core/time/local_date.dart';

const weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday', //
];
const monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', //
];

String formatDayTitle(String localDate) {
  final d = parseLocalDate(localDate);
  return '${weekdayNames[d.weekday - 1]}, ${d.day} ${monthNames[d.month - 1]}';
}
