import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/local_date.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/data/repositories/workout_repository.dart';
import 'package:wellbeing/data/tables/tables.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/features/streaks/streak_card.dart';
import 'package:wellbeing/features/streaks/today_streaks.dart';

import '../helpers/nav_a.dart';
import '../helpers/streak_helpers.dart' show showTodayStreaks;
import '../test_helpers.dart';

/// The category row [label] on the streaks card with its "N day(s)" figure.
Finder categoryStreak(String label, int days) => find.descendant(
  of: find.widgetWithText(CategoryStreakRow, label),
  matching: find.text('$days ${days == 1 ? 'day' : 'days'}'),
);

Future<int> cachedCurrent(dynamic db, String scope) async =>
    (await db.select(db.streakStates).get())
            .firstWhere((s) => s.scope == scope)
            .currentStreak
        as int;

Future<void> addWorkoutOn(
  dynamic db,
  String userId,
  int daysAgo, {
  String type = 'builtin-yoga',
}) async {
  final day = shiftLocalDate('2026-05-13', -daysAgo);
  final d = parseLocalDate(day);
  await WorkoutRepository(db, FixedClock(testNow)).add(
    userId: userId,
    dayCutoffMinutes: 0,
    workoutTypeId: type,
    startedAt: DateTime.utc(d.year, d.month, d.day, 8),
    endedAt: DateTime.utc(d.year, d.month, d.day, 8, 30),
    source: WorkoutSource.manual,
  );
}

void main() {
  appTest('no streak shows plain zeros', (tester, db) async {
    await showTodayStreaks(tester);
    expect(find.text("Today's streaks"), findsOneWidget);
    expect(categoryStreak('Workout', 0), findsOneWidget);
    expect(categoryStreak('Healthy habits', 0), findsOneWidget);
  });

  appTest('logging a workout starts a 1-day streak', (tester, db) async {
    await logToday(tester, 'Yoga');
    expect(await cachedCurrent(db, 'overall'), 1);
    await showTodayStreaks(tester);
    expect(categoryStreak('Workout', 1), findsOneWidget);
  });

  appTest('streak updates when an earlier entry is deleted', (
    tester,
    db,
  ) async {
    final user = await UserRepository(db, FixedClock(testNow)).ensureUser();
    for (final ago in [0, 1, 2]) {
      await addWorkoutOn(db, user.id, ago);
    }
    await tester.pumpAndSettle();
    expect(await cachedCurrent(db, 'overall'), 3);
    expect(await cachedCurrent(db, 'category:workout'), 3);

    final middle = (await db.select(db.workouts).get()).firstWhere(
      (w) => w.localDate == '2026-05-12',
    );
    await WorkoutRepository(db, FixedClock(testNow)).delete(middle.id);
    await tester.pumpAndSettle();
    // Overall activity: the freeze (on by default) covers the one missed day.
    expect(await cachedCurrent(db, 'overall'), 2);
    // The workout streak is strict: the gap ends it, no freeze applies.
    expect(await cachedCurrent(db, 'category:workout'), 1);
    await showTodayStreaks(tester);
    expect(categoryStreak('Workout', 1), findsOneWidget);
  });

  appTest('reaching 7 days awards the badge once and shows one quiet line', (
    tester,
    db,
  ) async {
    final user = await UserRepository(db, FixedClock(testNow)).ensureUser();
    for (final ago in [0, 1, 2, 3, 4, 5, 6]) {
      await addWorkoutOn(db, user.id, ago);
    }
    await tester.pumpAndSettle();

    expect(find.textContaining('streak reached.'), findsOneWidget);
    final badges = await db.select(db.badgesAwarded).get();
    expect(badges.map((b) => b.badgeKey).toSet(), {
      'streak_overall_7',
      'workout_7',
    });

    // The lines fade away on their own.
    await tester.pump(const Duration(seconds: 12));
    await tester.pumpAndSettle();
    expect(find.textContaining('streak reached.'), findsNothing);

    // More activity and edits do not award it again.
    await addWorkoutOn(db, user.id, 0, type: 'builtin-run');
    await tester.pumpAndSettle();
    expect((await db.select(db.badgesAwarded).get()).length, 2);
    expect(find.textContaining('streak reached.'), findsNothing);
  });

  appTest('streak cache is written but streaks come from the logs', (
    tester,
    db,
  ) async {
    final user = await UserRepository(db, FixedClock(testNow)).ensureUser();
    await addWorkoutOn(db, user.id, 0);
    await addWorkoutOn(db, user.id, 1);
    await tester.pumpAndSettle();

    final cached = await db.select(db.streakStates).get();
    final overall = cached.firstWhere((s) => s.scope == 'overall');
    expect(overall.currentStreak, 2);
    expect(cached.any((s) => s.scope == 'workout_type:builtin-yoga'), isTrue);
  });

  appTest('milestones screen shows streak, badges and personal bests', (
    tester,
    db,
  ) async {
    final user = await UserRepository(db, FixedClock(testNow)).ensureUser();
    for (final ago in [0, 1, 2]) {
      await addWorkoutOn(db, user.id, ago);
    }
    await tester.pumpAndSettle();
    await showTodayStreaks(tester);
    await tester.tap(find.text("Today's streaks"));
    await tester.pumpAndSettle();

    expect(find.text('Milestones'), findsOneWidget);
    expect(find.text('overall activity streak'), findsOneWidget);
    expect(find.text('7 days'), findsWidgets);
    expect(find.text('Workout'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Longest streak'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Longest streak'), findsOneWidget);
    expect(find.text('3 days'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('90 min'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('90 min'), findsOneWidget);
  });

  appTest('week tab lists overall and per-type streaks', (tester, db) async {
    final user = await UserRepository(db, FixedClock(testNow)).ensureUser();
    await addWorkoutOn(db, user.id, 0);
    await addWorkoutOn(db, user.id, 1);
    await tester.pumpAndSettle();
    await openWeekTab(tester);

    expect(find.text('Streaks'), findsOneWidget);
    final streaks = find.byType(WeekStreaks);
    expect(
      find.descendant(of: streaks, matching: find.text('Overall activity')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: streaks, matching: find.text('Yoga')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: streaks, matching: find.text('2 days')),
      findsNWidgets(3), // overall, Yoga and the Workout category row
    );
    for (final l in ['Workout', 'Healthy habits', 'Hobbies', 'Sleep target']) {
      expect(
        find.descendant(
          of: streaks,
          matching: find.widgetWithText(CategoryStreakRow, l),
        ),
        findsOneWidget,
      );
    }
  });
}
