import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/local_date.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/data/repositories/workout_repository.dart';
import 'package:wellbeing/data/tables/tables.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/features/streaks/streak_card.dart';

import '../helpers/nav_a.dart';
import '../test_helpers.dart';

/// The Today streak card's stat tile with [label] (`overall activity`, or the
/// best workout type's lower-case name), looked at for its "N day" figure.
Finder streakStat(String label, int days) => find.descendant(
  of: find.widgetWithText(StreakStat, label),
  matching: find.text('$days day'),
);

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
    expect(find.text("Today's streaks"), findsOneWidget);
    expect(streakStat('overall activity', 0), findsOneWidget);
    expect(streakStat('workout', 0), findsOneWidget);
    expect(find.text('Streak kept. Freeze used.'), findsNothing);
  });

  appTest('logging a workout starts a 1-day streak', (tester, db) async {
    await logToday(tester, 'Yoga');
    expect(streakStat('overall activity', 1), findsOneWidget);
    expect(streakStat('yoga', 1), findsOneWidget);
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
    expect(streakStat('overall activity', 3), findsOneWidget);

    final middle = (await db.select(db.workouts).get()).firstWhere(
      (w) => w.localDate == '2026-05-12',
    );
    await WorkoutRepository(db, FixedClock(testNow)).delete(middle.id);
    await tester.pumpAndSettle();
    // Freeze is on by default: it covers the one missed day, so the streak
    // is 2 (the 11th and today) rather than broken.
    expect(streakStat('overall activity', 2), findsOneWidget);
    // The freeze covered yesterday, and the card says so plainly.
    expect(find.text('Streak kept. Freeze used.'), findsOneWidget);
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

    expect(find.text('7-day streak reached.'), findsOneWidget);
    final badges = await db.select(db.badgesAwarded).get();
    expect(badges.map((b) => b.badgeKey), ['streak_overall_7']);

    // The line fades away on its own.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('7-day streak reached.'), findsNothing);

    // More activity and edits do not award it again.
    await addWorkoutOn(db, user.id, 0, type: 'builtin-run');
    await tester.pumpAndSettle();
    expect((await db.select(db.badgesAwarded).get()).length, 1);
    expect(find.text('7-day streak reached.'), findsNothing);
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
    await tester.tap(find.text("Today's streaks"));
    await tester.pumpAndSettle();

    expect(find.text('Milestones'), findsOneWidget);
    expect(find.text('7 days'), findsOneWidget);
    expect(find.text('30 days'), findsOneWidget);
    expect(find.text('100 days'), findsOneWidget);
    expect(find.text('Longest streak'), findsOneWidget);
    expect(find.text('activity streak'), findsOneWidget);
    expect(find.text('3 days'), findsNWidgets(2)); // current and longest
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
      findsNWidgets(2), // overall and Yoga
    );
  });
}
