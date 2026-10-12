import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/time/local_date.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../sleep/sleep_providers.dart';
import '../streaks/streak_engine.dart';
import '../streaks/streak_providers.dart';
import '../week/week_providers.dart';
import '../workouts/workout_providers.dart';

/// Screen time this week against last, as a rounded percentage (negative
/// when it went down). Null when either week has no data.
int? screenTimeChangePercent(int thisWeekMinutes, int lastWeekMinutes) {
  if (thisWeekMinutes <= 0 || lastWeekMinutes <= 0) return null;
  return (((thisWeekMinutes - lastWeekMinutes) * 100) / lastWeekMinutes)
      .round();
}

/// `Down by 22% from last week`, `Up by 5% ...`, `About the same ...`.
String screenTimeTrendText(int? percent) {
  if (percent == null) return 'Not enough data yet';
  if (percent == 0) return 'Same as last week';
  return percent < 0
      ? 'Down by ${-percent}% from last week'
      : 'Up by $percent% from last week';
}

class ChatReports {
  const ChatReports({
    required this.workouts,
    required this.activeDays,
    required this.longestStreakName,
    required this.longestStreakDays,
    required this.sleepOnSchedule,
    required this.sleepDays,
    required this.screenTimePercent,
  });

  final int workouts;
  final int activeDays;
  final String? longestStreakName;
  final int longestStreakDays;
  final int? sleepOnSchedule;
  final int sleepDays;
  final int? screenTimePercent;
}

/// Minutes of screen time for the 14 days up to today, oldest first.
final _screenTime14Provider = StreamProvider<Map<String, int>>((ref) async* {
  final today = await ref.watch(todayDateProvider.future);
  final user = await ref.watch(currentUserProvider.future);
  yield* ref
      .watch(screenTimeRepositoryProvider)
      .watchBetween(user.id, shiftLocalDate(today, -13), today)
      .map((rows) => {for (final r in rows) r.localDate: r.totalMinutes});
});

final chatReportsProvider = Provider<ChatReports?>((ref) {
  final today = ref.watch(todayDateProvider).value;
  if (today == null) return null;
  final all = ref.watch(allWorkoutsProvider).value ?? const <Workout>[];
  final weekStart = weekStartOf(today);
  final week = all.where((w) => w.localDate.compareTo(weekStart) >= 0);
  final snap = ref.watch(streakSnapshotProvider);
  final types = {
    for (final t
        in ref.watch(workoutTypesProvider).value ?? const <WorkoutType>[])
      t.id: t,
  };

  String? bestName;
  var bestDays = 0;
  for (final e
      in snap?.byType.entries ?? const <MapEntry<String, StreakResult>>[]) {
    if (e.value.current > bestDays) {
      bestDays = e.value.current;
      bestName = types[e.key]?.name;
    }
  }

  final consistency = ref.watch(sleepConsistencyProvider);
  final minutes = ref.watch(_screenTime14Provider).value ?? const {};
  var thisWeek = 0;
  var lastWeek = 0;
  for (var i = 0; i < 7; i++) {
    thisWeek += minutes[shiftLocalDate(today, -i)] ?? 0;
    lastWeek += minutes[shiftLocalDate(today, -7 - i)] ?? 0;
  }

  return ChatReports(
    workouts: week.length,
    activeDays: {for (final w in week) w.localDate}.length,
    longestStreakName: bestName,
    longestStreakDays: bestDays,
    sleepOnSchedule:
        consistency == null || consistency.byDate.values.every((v) => v == null)
        ? null
        : consistency.onSchedule,
    sleepDays: consistency?.days ?? 0,
    screenTimePercent: screenTimeChangePercent(thisWeek, lastWeek),
  );
});
