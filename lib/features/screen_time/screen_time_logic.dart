import 'dart:convert';

import '../../data/app_database.dart';

const categoryOrder = [
  'social',
  'video',
  'browser',
  'productivity',
  'games',
  'other',
];

String categoryLabel(String key) => switch (key) {
  'social' => 'Social media',
  'video' => 'Video',
  'browser' => 'Browser',
  'productivity' => 'Productivity',
  'games' => 'Games',
  _ => 'Others',
};

/// `4 h 12 min`, `3 h`, `45 min`, `0 min`.
String formatScreenTime(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '$m min';
  if (m == 0) return '$h h';
  return '$h h $m min';
}

/// Categories from a stored row, largest first.
List<MapEntry<String, int>> categoriesOf(ScreenTimeDailyData row) {
  Map<String, dynamic> raw;
  try {
    raw = jsonDecode(row.categoryMinutes) as Map<String, dynamic>;
  } catch (_) {
    raw = const {};
  }
  final entries =
      [
        for (final e in raw.entries)
          if ((e.value as num) > 0) MapEntry(e.key, (e.value as num).toInt()),
      ]..sort((a, b) {
        final c = b.value.compareTo(a.value);
        return c != 0
            ? c
            : categoryOrder
                  .indexOf(a.key)
                  .compareTo(categoryOrder.indexOf(b.key));
      });
  return entries;
}

/// Share of [total] as a whole percent (0 when there is no total).
int percentOf(int part, int total) =>
    total <= 0 ? 0 : ((part * 100) / total).round();

class WeekScreenTime {
  const WeekScreenTime({
    required this.totalMinutes,
    required this.daysWithData,
  });

  final int totalMinutes;
  final int daysWithData;

  int get averageMinutes =>
      daysWithData == 0 ? 0 : (totalMinutes / daysWithData).round();
}

WeekScreenTime summarizeScreenTime(List<ScreenTimeDailyData> rows) {
  var total = 0;
  var days = 0;
  for (final r in rows) {
    if (r.totalMinutes <= 0) continue;
    total += r.totalMinutes;
    days++;
  }
  return WeekScreenTime(totalMinutes: total, daysWithData: days);
}

/// Daily target choices in minutes (`null` clears the goal).
const goalChoices = [120, 180, 240, 300, 360];

String goalLabel(int minutes) => 'Target ${formatScreenTime(minutes)}';

/// Whether a day stays within the user's daily limit: total at or below it.
/// With no limit there is nothing to achieve, so this is false.
bool withinTarget(int totalMinutes, int? targetMinutes) =>
    targetMinutes != null && totalMinutes <= targetMinutes;

/// Total minutes from hours and minutes typed by hand. Null when either is
/// not a whole number, negative, or the total is not within one day.
int? parseManualMinutes(String hours, String minutes) {
  final h = hours.trim().isEmpty ? 0 : int.tryParse(hours.trim());
  final m = minutes.trim().isEmpty ? 0 : int.tryParse(minutes.trim());
  if (h == null || m == null || h < 0 || m < 0 || m > 59) return null;
  final total = h * 60 + m;
  return total > 1440 ? null : total;
}
