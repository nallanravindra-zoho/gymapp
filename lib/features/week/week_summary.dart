import '../../core/time/local_date.dart';
import '../../data/app_database.dart';

/// Totals for one Mon-Sun week (spec section 5, Week).
class WeekSummary {
  const WeekSummary({
    required this.activeMinutes,
    required this.activeDays,
    required this.countByType,
  });

  final int activeMinutes;
  final int activeDays;

  /// Workout count per workout type id.
  final Map<String, int> countByType;

  bool get isEmpty => countByType.isEmpty;
}

WeekSummary summarizeWeek(List<Workout> workouts) {
  var minutes = 0;
  final days = <String>{};
  final counts = <String, int>{};
  for (final w in workouts) {
    minutes += w.durationMinutes;
    days.add(w.localDate);
    counts[w.workoutTypeId] = (counts[w.workoutTypeId] ?? 0) + 1;
  }
  return WeekSummary(
    activeMinutes: minutes,
    activeDays: days.length,
    countByType: counts,
  );
}

/// The seven local dates of the week starting at [weekStart] (a Monday).
List<String> weekDates(String weekStart) => [
  for (var i = 0; i < 7; i++) shiftLocalDate(weekStart, i),
];

/// Groups workouts by local date, each day ordered by start time.
Map<String, List<Workout>> groupByDate(List<Workout> workouts) {
  final map = <String, List<Workout>>{};
  for (final w in workouts) {
    (map[w.localDate] ??= []).add(w);
  }
  for (final list in map.values) {
    list.sort((a, b) => a.startedAt.compareTo(b.startedAt));
  }
  return map;
}
