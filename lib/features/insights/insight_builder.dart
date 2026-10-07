import '../../core/time/local_date.dart';
import '../../data/app_database.dart';
import '../../data/tables/tables.dart';
import '../sleep/sleep_logic.dart';
import 'insight_rules.dart';

List<String> _dates(String from, String to) {
  final out = <String>[];
  for (var d = from; d.compareTo(to) <= 0; d = shiftLocalDate(d, 1)) {
    out.add(d);
  }
  return out;
}

/// Gathers one week's facts from the stored records for the rule engine.
InsightInput buildInsightInput({
  required String weekStart,
  required String today,
  required List<Workout> workouts,
  required Set<String> restDates,
  required List<Habit> habits,
  required List<HabitLog> habitLogs,
  required List<SleepLog> sleepLogs,
  required int targetBedtimeMinutes,
  required int targetWakeMinutes,
  required List<ScreenTimeDailyData> screenTime,
}) {
  final weekEnd = shiftLocalDate(weekStart, 6);
  final complete = weekEnd.compareTo(today) < 0;
  final lastClosed = complete ? weekEnd : shiftLocalDate(today, -1);
  final lastCounted = complete ? weekEnd : today;
  final closed = _dates(weekStart, lastClosed);

  // Habit totals per habit per day.
  final totals = <String, Map<String, int>>{};
  for (final l in habitLogs) {
    final m = totals.putIfAbsent(l.habitId, () => {});
    m[l.localDate] = (m[l.localDate] ?? 0) + l.count;
  }

  final stretch = habits.where((h) => h.kind == HabitKind.stretch).toList();
  final water = habits.where((h) => h.kind == HabitKind.water).toList();

  final stretchCompletion = <String, double>{};
  if (stretch.isNotEmpty) {
    for (final d in closed) {
      var sum = 0.0;
      for (final h in stretch) {
        final done = totals[h.id]?[d] ?? 0;
        sum += (done / h.dailyTarget).clamp(0.0, 1.0);
      }
      stretchCompletion[d] = sum / stretch.length;
    }
  }

  final waterMet = <String, bool>{};
  if (water.isNotEmpty) {
    for (final d in closed) {
      waterMet[d] = water.any((h) => (totals[h.id]?[d] ?? 0) >= h.dailyTarget);
    }
  }

  SleepWeek? sleepWeek(String end, int days) {
    if (days < 1) return null;
    final c = sleepConsistency(
      logs: sleepLogs,
      targetBedtimeMinutes: targetBedtimeMinutes,
      targetWakeMinutes: targetWakeMinutes,
      today: end,
      days: days,
    );
    return SleepWeek(matched: c.onSchedule, logged: c.logged, days: days);
  }

  final sleepDays = lastCounted.compareTo(weekStart) < 0
      ? 0
      : _dates(weekStart, lastCounted).length;

  // Evening screen time paired with the bedtime that followed it.
  final byWake = {for (final l in sleepLogs) l.localDate: l};
  final screenByDate = {for (final r in screenTime) r.localDate: r};
  final pairs = <LatePair>[];
  for (final d in closed) {
    final row = screenByDate[d];
    final night = byWake[shiftLocalDate(d, 1)];
    if (row == null || row.totalMinutes <= 0 || night == null) continue;
    final minute = minuteOfDay(night.bedtimeAt, night.tzOffsetMinutes);
    pairs.add(
      LatePair(
        lateMinutes: row.lateEveningMinutes,
        bedtimeOffset: (minute - 18 * 60) % 1440,
      ),
    );
  }

  return InsightInput(
    weekStart: weekStart,
    complete: complete,
    today: today,
    periodLabel: complete ? 'last week' : 'this week',
    workoutDates: {for (final w in workouts) w.localDate},
    restDates: restDates,
    hasStretch: stretch.isNotEmpty,
    stretchCompletion: stretchCompletion,
    hasWater: water.isNotEmpty,
    waterMet: waterMet,
    sleep: sleepWeek(lastCounted, sleepDays),
    prevSleep: sleepWeek(shiftLocalDate(weekStart, -1), 7),
    latePairs: pairs,
  );
}

/// The week-in-numbers card (spec 7.9).
class WeekRecap {
  const WeekRecap({
    required this.weekStart,
    required this.activeDays,
    required this.totalMinutes,
    required this.topTypeId,
    required this.longestStreak,
  });

  final String weekStart;
  final int activeDays;
  final int totalMinutes;

  /// Workout type done most often (ties: the one with more minutes).
  final String? topTypeId;
  final int longestStreak;

  bool get isEmpty => activeDays == 0;
  String get weekEnd => shiftLocalDate(weekStart, 6);
}

WeekRecap computeRecap({
  required String weekStart,
  required List<Workout> workouts,
  required int longestStreak,
}) {
  final end = shiftLocalDate(weekStart, 6);
  final inWeek = workouts
      .where(
        (w) =>
            w.localDate.compareTo(weekStart) >= 0 &&
            w.localDate.compareTo(end) <= 0,
      )
      .toList();

  final counts = <String, int>{};
  final minutes = <String, int>{};
  for (final w in inWeek) {
    counts[w.workoutTypeId] = (counts[w.workoutTypeId] ?? 0) + 1;
    minutes[w.workoutTypeId] =
        (minutes[w.workoutTypeId] ?? 0) + w.durationMinutes;
  }
  String? top;
  for (final id in counts.keys) {
    if (top == null ||
        counts[id]! > counts[top]! ||
        (counts[id] == counts[top] && minutes[id]! > minutes[top]!)) {
      top = id;
    }
  }

  return WeekRecap(
    weekStart: weekStart,
    activeDays: {for (final w in inWeek) w.localDate}.length,
    totalMinutes: inWeek.fold(0, (a, w) => a + w.durationMinutes),
    topTypeId: top,
    longestStreak: longestStreak,
  );
}
