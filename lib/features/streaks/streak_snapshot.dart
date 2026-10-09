import '../../core/time/local_date.dart';
import '../../data/app_database.dart';
import 'streak_engine.dart';

/// Everything the streak UI needs, derived from logs.
class StreakSnapshot {
  const StreakSnapshot({
    required this.overall,
    required this.byType,
    required this.bestWeekMinutes,
  });

  final StreakResult overall;

  /// Workout type id -> streak. Rest days do not apply to these.
  final Map<String, StreakResult> byType;

  /// Most active minutes in any single Mon-Sun week (personal best).
  final int bestWeekMinutes;
}

StreakSnapshot buildSnapshot({
  required List<Workout> workouts,
  required Set<String> restDates,
  required String today,
  required bool freezeEnabled,
  required int freezeIntervalDays,
}) {
  final allDates = <String>{};
  final typeDates = <String, Set<String>>{};
  final weekMinutes = <String, int>{};

  for (final w in workouts) {
    allDates.add(w.localDate);
    (typeDates[w.workoutTypeId] ??= {}).add(w.localDate);
    final week = weekStartOf(w.localDate);
    weekMinutes[week] = (weekMinutes[week] ?? 0) + w.durationMinutes;
  }

  StreakResult streak(Set<String> dates, {Set<String> bridge = const {}}) =>
      computeStreak(
        counted: dates,
        bridge: bridge,
        today: today,
        freezeEnabled: freezeEnabled,
        freezeIntervalDays: freezeIntervalDays,
      );

  return StreakSnapshot(
    overall: streak(allDates, bridge: restDates),
    byType: {for (final e in typeDates.entries) e.key: streak(e.value)},
    bestWeekMinutes: weekMinutes.values.fold(0, (a, b) => a > b ? a : b),
  );
}
