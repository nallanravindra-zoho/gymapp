import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/data/repositories/rest_day_repository.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/data/repositories/workout_repository.dart';
import 'package:wellbeing/features/streaks/milestones_screen.dart';
import 'package:wellbeing/features/streaks/today_streaks.dart';

import '../helpers/streak_helpers.dart';
import '../test_helpers.dart';

Future<String> uid(dynamic db) async =>
    (await UserRepository(db, FixedClock(testNow)).ensureUser()).id;

Finder row(String label) => find.widgetWithText(CategoryStreakRow, label);

void main() {
  appTest('TodayStreaks lists the four categories with zeros and captions', (
    tester,
    db,
  ) async {
    await showTodayStreaks(tester);
    expect(find.text("Today's streaks"), findsOneWidget);
    for (final l in ['Workout', 'Healthy habits', 'Hobbies', 'Sleep target']) {
      expect(row(l), findsOneWidget);
    }
    expect(find.text('Days with at least one workout'), findsOneWidget);
    expect(find.text('At least one habit target met'), findsOneWidget);
    expect(find.text('Sleep duration target met'), findsOneWidget);
    expect(find.text('Set a hobby goal to start'), findsOneWidget);
    expect(find.text('Longest 0 days'), findsNWidgets(4));
  });

  appTest('TodayStreaks shows current and longest per category', (
    tester,
    db,
  ) async {
    final id = await uid(db);
    for (final n in [0, 1, 2]) {
      await workoutAgo(db, id, n);
    }
    for (final n in [1, 2, 3, 4]) {
      await sleepAgo(db, id, n);
    }
    await sleepAgo(db, id, 0, minutes: 400); // short night today: not counted
    final h = await habitWithLog(db, id, name: 'Meditation', target: 2);
    await habitLogAgo(db, h, 0, count: 2);
    await habitLogAgo(db, h, 1, count: 1); // target not met yesterday
    await showTodayStreaks(tester);

    expect(
      find.descendant(of: row('Workout'), matching: find.text('3 days')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: row('Healthy habits'), matching: find.text('1 day')),
      findsOneWidget,
    );
    // Today's short sleep does not break it (day still open) but does not add.
    expect(
      find.descendant(of: row('Sleep target'), matching: find.text('4 days')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: row('Sleep target'),
        matching: find.text('Longest 4 days'),
      ),
      findsOneWidget,
    );
  });

  appTest('rest days do not change the workout streak', (tester, db) async {
    final id = await uid(db);
    await workoutAgo(db, id, 0);
    await workoutAgo(db, id, 2);
    await RestDayRepository(
      db,
      FixedClock(testNow),
    ).mark(userId: id, localDate: daysAgo(1), weeklyLimit: 2);
    await showTodayStreaks(tester);
    expect(
      find.descendant(of: row('Workout'), matching: find.text('1 day')),
      findsOneWidget,
    );
  });

  appTest('tapping opens milestones; six per category, earned prominent', (
    tester,
    db,
  ) async {
    final id = await uid(db);
    for (final n in [0, 1, 2, 3, 4, 5, 6]) {
      await workoutAgo(db, id, n);
    }
    await tester.pumpAndSettle();
    await showTodayStreaks(tester);
    await tester.tap(find.text("Today's streaks"));
    await tester.pumpAndSettle();

    expect(find.byType(MilestonesScreen), findsOneWidget);
    final workout = find.byType(CategoryMilestones).first;
    for (final m in [
      '7 days',
      '30 days',
      '50 days',
      '100 days',
      '200 days',
      '500 days',
    ]) {
      await tester.scrollUntilVisible(
        find.descendant(of: workout, matching: find.text(m)),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.descendant(of: workout, matching: find.text(m)),
        findsOneWidget,
      );
    }
    // 7 earned (with its date), 30 is next with 23 to go.
    expect(
      find.descendant(of: workout, matching: find.text('13 May 2026')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: workout, matching: find.text('23 days to go')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: workout, matching: find.text('Not yet')),
      findsNWidgets(4),
    );
    expect(
      find.bySemanticsLabel(RegExp('Workout 7 days badge, earned 13 May 2026')),
      findsOneWidget,
    );
    for (final l in ['Hobbies', 'Sleep target']) {
      await tester.scrollUntilVisible(
        find.descendant(
          of: find.byType(CategoryMilestones),
          matching: find.text(l),
        ),
        200,
        scrollable: find.byType(Scrollable).first,
      );
    }
    await tester.scrollUntilVisible(
      find.text('Overall activity badges'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Overall activity badges'), findsOneWidget);
  });

  appTest('category badges are awarded once with one quiet line each', (
    tester,
    db,
  ) async {
    final id = await uid(db);
    for (final n in [0, 1, 2, 3, 4, 5, 6]) {
      await workoutAgo(db, id, n);
      await sleepAgo(db, id, n);
    }
    await tester.pumpAndSettle();

    final keys =
        (await db.select(db.badgesAwarded).get())
            .map((b) => b.badgeKey)
            .toList()
          ..sort();
    expect(keys, ['sleep_7', 'streak_overall_7', 'workout_7']);
    expect(find.text('7-day workout streak reached.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 12));
    await tester.pumpAndSettle();
    await workoutAgo(db, id, 0);
    await tester.pumpAndSettle();
    expect((await db.select(db.badgesAwarded).get()).length, 3);
    expect(find.text('7-day workout streak reached.'), findsNothing);
  });

  appTest('cache holds category scopes and follows deletes', (
    tester,
    db,
  ) async {
    final id = await uid(db);
    await workoutAgo(db, id, 0);
    await workoutAgo(db, id, 1);
    await tester.pumpAndSettle();

    var cached = await db.select(db.streakStates).get();
    expect(
      cached.map((s) => s.scope).toSet().containsAll([
        'category:workout',
        'category:habits',
        'category:hobbies',
        'category:sleep',
      ]),
      isTrue,
    );
    expect(
      cached.firstWhere((s) => s.scope == 'category:workout').currentStreak,
      2,
    );
    expect(
      cached.firstWhere((s) => s.scope == 'category:workout').freezeAvailable,
      isFalse,
    );

    final yesterday = (await db.select(db.workouts).get()).firstWhere(
      (w) => w.localDate == daysAgo(1),
    );
    await WorkoutRepository(db, FixedClock(testNow)).delete(yesterday.id);
    await tester.pumpAndSettle();
    cached = await db.select(db.streakStates).get();
    final w = cached.firstWhere((s) => s.scope == 'category:workout');
    expect(w.currentStreak, 1);
    expect(w.longestStreak, 1);
  });
}
