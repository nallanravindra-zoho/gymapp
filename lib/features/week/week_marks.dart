import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/time/local_date.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../habits/habit_providers.dart';
import '../hobbies/hobby_providers.dart';
import '../screen_time/screen_time_providers.dart';
import '../sleep/sleep_providers.dart';
import 'week_providers.dart';

/// The categories a Week day can show an icon for (R8), in display order.
enum MarkCategory { workout, habits, hobbies, sleep, screen }

/// Most icons a day cell shows; the rest collapse into a `+N` count.
const maxVisibleMarks = 3;

/// What was achieved on one day, for the week calendar (R8). A category shows
/// only when its own condition is met, so an icon always means "done".
class DayMarks {
  const DayMarks({
    this.workouts = const [],
    this.habits = false,
    this.hobbies = false,
    this.sleep = false,
    this.screen = false,
    this.rest = false,
  });

  /// Workouts logged that day, oldest first.
  final List<Workout> workouts;

  /// At least the configured number of active habits reached their target.
  final bool habits;

  /// A daily hobby goal was met (weekly goals are in the weekly summary).
  final bool hobbies;

  /// Sleep duration met the target (counted on the day of waking).
  final bool sleep;

  /// Screen time stayed at or under the limit.
  final bool screen;

  final bool rest;

  /// The achieved categories, in display order.
  List<MarkCategory> get categories => [
    if (workouts.isNotEmpty) MarkCategory.workout,
    if (habits) MarkCategory.habits,
    if (hobbies) MarkCategory.hobbies,
    if (sleep) MarkCategory.sleep,
    if (screen) MarkCategory.screen,
  ];

  bool get hasAny => categories.isNotEmpty;

  /// How many categories are marked (workouts count once).
  int get count => categories.length;
}

/// The icons to draw for [categories] and how many were left out.
class VisibleMarks {
  const VisibleMarks(this.shown, this.overflow);
  final List<MarkCategory> shown;
  final int overflow;
}

/// Shows at most [max] icons; any others become a `+N` count.
VisibleMarks limitMarks(
  List<MarkCategory> categories, {
  int max = maxVisibleMarks,
}) {
  if (categories.length <= max) return VisibleMarks(categories, 0);
  return VisibleMarks(categories.sublist(0, max), categories.length - max);
}

/// Whether enough habits reached their daily target. [threshold] is the
/// number of active habits needed (at least 1); it can never ask for more
/// habits than exist, so a person with two habits and a threshold of three is
/// not locked out of the icon.
bool habitsMarkMet({
  required List<Habit> habits,
  required Map<String, int> counts,
  required int threshold,
}) {
  if (habits.isEmpty) return false;
  final met = habits
      .where((h) => (counts[h.id] ?? 0) >= h.dailyTarget)
      .length;
  final needed = threshold.clamp(1, habits.length);
  return met >= needed;
}

/// Sleep counts when the log for this (wake) date reaches the target.
bool sleepMarkMet(SleepLog? log, int targetMinutes) =>
    log != null && log.durationMinutes >= targetMinutes;

/// Screen time counts when a day was recorded and stayed at or under the
/// limit. The limit recorded with the day wins over the current one; with no
/// limit at all there is nothing to achieve, so no icon.
bool screenMarkMet(ScreenTimeDailyData? row, int? currentGoalMinutes) {
  if (row == null) return false;
  final limit = row.targetMinutes ?? currentGoalMinutes;
  return limit != null && row.totalMinutes <= limit;
}

/// The marks for one day from already-loaded data. Pure.
DayMarks buildDayMarks({
  required String date,
  required List<Workout> workouts,
  required bool isRest,
  required List<Habit> habits,
  required Map<String, int> habitCounts,
  required int habitThreshold,
  required bool hobbyGoalMet,
  required SleepLog? sleepLog,
  required int sleepTargetMinutes,
  required ScreenTimeDailyData? screenRow,
  required int? screenGoalMinutes,
}) {
  return DayMarks(
    workouts: workouts.where((w) => w.localDate == date).toList()
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt)),
    habits: habitsMarkMet(
      habits: habits,
      counts: habitCounts,
      threshold: habitThreshold,
    ),
    hobbies: hobbyGoalMet,
    sleep: sleepMarkMet(sleepLog, sleepTargetMinutes),
    screen: screenMarkMet(screenRow, screenGoalMinutes),
    rest: isRest,
  );
}

/// The seven days' marks. Pure, so the rules are easy to test.
Map<String, DayMarks> buildWeekMarks({
  required List<String> dates,
  required List<Workout> workouts,
  required Set<String> restDays,
  required List<Habit> habits,
  required List<HabitLog> habitLogs,
  required int habitThreshold,
  required Set<String> hobbyDates,
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

  return {
    for (final d in dates)
      d: buildDayMarks(
        date: d,
        workouts: workouts,
        isRest: restDays.contains(d),
        habits: habits,
        habitCounts: counts[d] ?? const {},
        habitThreshold: habitThreshold,
        hobbyGoalMet: hobbyDates.contains(d),
        sleepLog: sleepLogs.where((s) => s.localDate == d).firstOrNull,
        sleepTargetMinutes: sleepTargetMinutes,
        screenRow: screenRows.where((r) => r.localDate == d).firstOrNull,
        screenGoalMinutes: screenGoalMinutes,
      ),
  };
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

/// Habits needed for the Healthy Habits icon (Settings > Goals).
final habitThresholdProvider = Provider<int>(
  (ref) => ref.watch(userStreamProvider).value?.habitThreshold ?? 1,
);

/// Marks for each day of the week on screen.
final weekMarksProvider = Provider<Map<String, DayMarks>>((ref) {
  final start = ref.watch(weekStartProvider);
  if (start == null) return const {};
  final dates = weekDatesFrom(start);
  return buildWeekMarks(
    dates: dates,
    workouts: ref.watch(weekWorkoutsProvider).value ?? const [],
    restDays: ref.watch(weekRestDaysProvider).value ?? const {},
    habits: ref.watch(activeHabitsProvider).value ?? const [],
    habitLogs: ref.watch(allHabitLogsProvider).value ?? const [],
    habitThreshold: ref.watch(habitThresholdProvider),
    hobbyDates: {
      for (final d in dates)
        if (ref.watch(hobbyGoalMetOnDateProvider(d))) d,
    },
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
