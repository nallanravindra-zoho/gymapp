import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/time/local_date.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../habits/habit_providers.dart';
import '../screen_time/screen_time_providers.dart';
import '../sleep/sleep_providers.dart';
import 'week_providers.dart';

/// What was achieved on one day, for the week calendar (R8). A category shows
/// only when its own condition is met, so an icon always means "done".
class DayMarks {
  const DayMarks({
    this.workouts = const [],
    this.habits = false,
    this.sleep = false,
    this.screen = false,
    this.rest = false,
  });

  /// Workouts logged that day, oldest first.
  final List<Workout> workouts;

  /// At least one active habit reached its daily target.
  final bool habits;

  /// Sleep duration met the target.
  final bool sleep;

  /// Screen time stayed at or under the goal.
  final bool screen;

  final bool rest;

  bool get hasAny => workouts.isNotEmpty || habits || sleep || screen;

  /// How many categories are marked (workouts count once).
  int get count =>
      (workouts.isNotEmpty ? 1 : 0) +
      (habits ? 1 : 0) +
      (sleep ? 1 : 0) +
      (screen ? 1 : 0);
}

/// The seven days' marks. Pure, so the rules are easy to test.
Map<String, DayMarks> buildWeekMarks({
  required List<String> dates,
  required List<Workout> workouts,
  required Set<String> restDays,
  required List<Habit> habits,
  required List<HabitLog> habitLogs,
  required List<SleepLog> sleepLogs,
  required int sleepTargetMinutes,
  required List<ScreenTimeDailyData> screenRows,
  required int? screenGoalMinutes,
}) {
  final counts = <String, Map<String, int>>{};
  for (final l in habitLogs) {
    final byHabit = counts[l.localDate] ??= {};
    byHabit[l.habitId] = (byHabit[l.habitId] ?? 0) + l.count;
  }

  final result = <String, DayMarks>{};
  for (final d in dates) {
    final dayWorkouts = workouts.where((w) => w.localDate == d).toList()
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    final dayCounts = counts[d] ?? const <String, int>{};
    final habitsMet = habits.any(
      (h) => (dayCounts[h.id] ?? 0) >= h.dailyTarget,
    );
    final sleepMet = sleepLogs.any(
      (s) => s.localDate == d && s.durationMinutes >= sleepTargetMinutes,
    );
    final screenMet =
        screenGoalMinutes != null &&
        screenRows.any(
          (r) => r.localDate == d && r.totalMinutes <= screenGoalMinutes,
        );
    result[d] = DayMarks(
      workouts: dayWorkouts,
      habits: habitsMet,
      sleep: sleepMet,
      screen: screenMet,
      rest: restDays.contains(d),
    );
  }
  return result;
}

/// Minutes of sleep the person aims for: bedtime to wake time.
final sleepTargetMinutesProvider = Provider<int>((ref) {
  final t = ref.watch(effectiveSleepTargetProvider);
  return (t.wakeMinutes - t.bedtimeMinutes + 1440) % 1440;
});

final weekSleepLogsProvider = StreamProvider<List<SleepLog>>((ref) async* {
  final start = ref.watch(weekStartProvider);
  if (start == null) return;
  final user = await ref.watch(currentUserProvider.future);
  yield* ref
      .watch(sleepRepositoryProvider)
      .watchBetween(user.id, start, shiftLocalDate(start, 6));
});

final weekScreenRowsProvider = StreamProvider<List<ScreenTimeDailyData>>((
  ref,
) async* {
  final start = ref.watch(weekStartProvider);
  if (start == null) return;
  final user = await ref.watch(currentUserProvider.future);
  yield* ref
      .watch(screenTimeRepositoryProvider)
      .watchBetween(user.id, start, shiftLocalDate(start, 6));
});

/// Marks for each day of the week on screen.
final weekMarksProvider = Provider<Map<String, DayMarks>>((ref) {
  final start = ref.watch(weekStartProvider);
  if (start == null) return const {};
  return buildWeekMarks(
    dates: weekDatesFrom(start),
    workouts: ref.watch(weekWorkoutsProvider).value ?? const [],
    restDays: ref.watch(weekRestDaysProvider).value ?? const {},
    habits: ref.watch(activeHabitsProvider).value ?? const [],
    habitLogs: ref.watch(allHabitLogsProvider).value ?? const [],
    sleepLogs: ref.watch(weekSleepLogsProvider).value ?? const [],
    sleepTargetMinutes: ref.watch(sleepTargetMinutesProvider),
    screenRows: ref.watch(weekScreenRowsProvider).value ?? const [],
    screenGoalMinutes: ref.watch(screenTimeGoalProvider).value,
  );
});

List<String> weekDatesFrom(String weekStart) => [
  for (var i = 0; i < 7; i++) shiftLocalDate(weekStart, i),
];

/// Per-day providers for the day summary page (any date).
final habitCountsOnProvider = StreamProvider.family<Map<String, int>, String>((
  ref,
  date,
) async* {
  final user = await ref.watch(currentUserProvider.future);
  yield* ref.watch(habitRepositoryProvider).watchCountsForDate(user.id, date);
});

final sleepOnProvider = StreamProvider.family<SleepLog?, String>((
  ref,
  date,
) async* {
  final user = await ref.watch(currentUserProvider.future);
  yield* ref
      .watch(sleepRepositoryProvider)
      .watchBetween(user.id, date, date)
      .map((rows) => rows.isEmpty ? null : rows.first);
});

final screenOnProvider = StreamProvider.family<ScreenTimeDailyData?, String>((
  ref,
  date,
) async* {
  final user = await ref.watch(currentUserProvider.future);
  yield* ref
      .watch(screenTimeRepositoryProvider)
      .watchBetween(user.id, date, date)
      .map((rows) => rows.isEmpty ? null : rows.first);
});
