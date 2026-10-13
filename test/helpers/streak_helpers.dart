import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/core/time/local_date.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/repositories/habit_repository.dart';
import 'package:wellbeing/data/repositories/sleep_repository.dart';
import 'package:wellbeing/data/repositories/workout_repository.dart';
import 'package:wellbeing/data/tables/tables.dart';
import 'package:wellbeing/features/streaks/today_streaks.dart';

import '../test_helpers.dart';

/// The fixed test day.
const streakToday = '2026-05-13';

String daysAgo(int n) => shiftLocalDate(streakToday, -n);

DateTime _noon(int n) {
  final d = parseLocalDate(daysAgo(n));
  return DateTime.utc(d.year, d.month, d.day, 8);
}

Future<void> workoutAgo(AppDatabase db, String userId, int n) =>
    WorkoutRepository(db, FixedClock(testNow))
        .add(
          userId: userId,
          dayCutoffMinutes: 0,
          workoutTypeId: 'builtin-yoga',
          startedAt: _noon(n),
          endedAt: _noon(n).add(const Duration(minutes: 30)),
          source: WorkoutSource.manual,
        )
        .then((_) {});

/// Sleep ending on the wake date [n] days ago, [minutes] long.
Future<void> sleepAgo(
  AppDatabase db,
  String userId,
  int n, {
  int minutes = 480,
}) => SleepRepository(db, FixedClock(testNow))
    .log(
      userId: userId,
      dayCutoffMinutes: 0,
      bedtimeAt: _noon(n).subtract(Duration(minutes: minutes)),
      wakeAt: _noon(n),
    )
    .then((_) {});

/// A habit whose daily target is [target], logged [count] times on day [n].
Future<Habit> habitWithLog(
  AppDatabase db,
  String userId, {
  required String name,
  int target = 1,
}) async {
  final repo = HabitRepository(db, FixedClock(testNow));
  final id = await repo.create(
    userId: userId,
    name: name,
    kind: HabitKind.custom,
    dailyTarget: target,
  );
  return (db.select(db.habits)..where((h) => h.id.equals(id))).getSingle();
}

Future<void> habitLogAgo(AppDatabase db, Habit habit, int n, {int count = 1}) =>
    HabitRepository(db, FixedClock(testNow))
        .log(habit: habit, dayCutoffMinutes: 0, count: count, at: _noon(n))
        .then((_) {});

/// Shows [TodayStreaks] on its own page above the app, so these tests do not
/// depend on where Today places it.
Future<void> showTodayStreaks(WidgetTester tester) async {
  final nav = Navigator.of(
    tester.element(find.byType(Scaffold).first),
    rootNavigator: true,
  );
  nav.push(
    MaterialPageRoute<void>(
      builder: (_) => const Scaffold(
        body: SafeArea(child: SingleChildScrollView(child: TodayStreaks())),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
