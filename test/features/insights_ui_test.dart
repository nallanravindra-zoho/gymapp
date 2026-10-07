import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/core/time/local_date.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/data/repositories/workout_repository.dart';
import 'package:wellbeing/data/seed_tips.dart';
import 'package:wellbeing/data/tables/tables.dart';

import '../test_helpers.dart';

Future<void> openInsights(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.insights_outlined));
  await tester.pumpAndSettle();
}

Future<void> addWorkouts(
  AppDatabase db,
  List<String> dates, {
  String type = 'builtin-yoga',
  int minutes = 30,
}) async {
  final clock = FixedClock(testNow);
  final user = await UserRepository(db, clock).ensureUser();
  for (final date in dates) {
    final d = parseLocalDate(date);
    await WorkoutRepository(db, clock).add(
      userId: user.id,
      dayCutoffMinutes: 0,
      workoutTypeId: type,
      startedAt: DateTime.utc(d.year, d.month, d.day, 8),
      endedAt: DateTime.utc(d.year, d.month, d.day, 8, minutes),
      source: WorkoutSource.manual,
    );
  }
}

// Today is Wed 2026-05-13; last week is Mon 4 May to Sun 10 May.
const lastWeekDays = ['2026-05-04', '2026-05-05', '2026-05-06', '2026-05-10'];
const weekBefore = ['2026-04-27', '2026-04-28', '2026-04-29'];

void main() {
  appTest('with no data the tab explains plainly and offers no tips', (
    tester,
    db,
  ) async {
    await openInsights(tester);
    expect(find.text('Week summary'), findsOneWidget);
    expect(find.text('4 – 10 May'), findsOneWidget);
    expect(find.text('No workouts logged this week.'), findsOneWidget);
    expect(find.text('No insights for this week yet.'), findsOneWidget);
    expect(find.text('Tips'), findsNothing);
    expect(find.text(tipFooter), findsNothing);
  });

  appTest('a full week shows the recap, insights and tips', (tester, db) async {
    await addWorkouts(db, [...lastWeekDays, ...weekBefore]);
    await tester.pumpAndSettle();
    await openInsights(tester);

    // Recap: 4 active days, 4 x 30 minutes, yoga.
    expect(find.text('Week summary'), findsOneWidget);
    expect(find.text('Active days'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('2 h'), findsOneWidget);
    expect(find.text('Yoga'), findsOneWidget);

    // Insights in plain, factual wording.
    expect(find.text('4 active days last week, up from 3.'), findsOneWidget);
    expect(find.text('Longest gap: 3 days (Thu to Sat).'), findsOneWidget);

    // Tips: at most three, each tied to an insight, with the footer once.
    expect(find.text('Tips'), findsOneWidget);
    expect(find.text(tipFooter), findsOneWidget);
    final shown = seedTips
        .where((t) => find.text(t.text).evaluate().isNotEmpty)
        .toList();
    expect(shown.length, 2);
    expect(shown.map((t) => t.triggerKey).toSet(), {
      'longest_gap',
      'active_days_change',
    });
  });

  appTest('this week so far can be shown, and switched back', (
    tester,
    db,
  ) async {
    await addWorkouts(db, ['2026-05-11', '2026-05-12', '2026-05-13']);
    await tester.pumpAndSettle();
    await openInsights(tester);

    // Last week is empty.
    expect(find.text('No workouts logged this week.'), findsOneWidget);

    await tester.tap(find.text('This week'));
    await tester.pumpAndSettle();
    expect(find.text('11 – 17 May'), findsOneWidget);
    expect(find.text('3 active days this week, up from 0.'), findsOneWidget);
    expect(find.text('No workouts logged this week.'), findsNothing);

    await tester.tap(find.text('Last week'));
    await tester.pumpAndSettle();
    expect(find.text('4 – 10 May'), findsOneWidget);
  });

  appTest('insights update when a workout is added', (tester, db) async {
    await openInsights(tester);
    expect(find.text('No insights for this week yet.'), findsOneWidget);

    await addWorkouts(db, lastWeekDays);
    await tester.pumpAndSettle();
    expect(find.text('4 active days last week, up from 0.'), findsOneWidget);
    expect(find.text('No insights for this week yet.'), findsNothing);
  });

  appTest('the tips library is seeded once and not duplicated', (
    tester,
    db,
  ) async {
    expect((await db.select(db.tipsLibrary).get()).length, seedTips.length);
    await db.seedTipsLibrary();
    await db.seedTipsLibrary();
    expect((await db.select(db.tipsLibrary).get()).length, seedTips.length);
    expect(
      (await db.select(db.tipsLibrary).get()).every(
        (t) => t.sourceLabel == 'Original',
      ),
      isTrue,
    );
  });

  appTest('tips added in a later version reach existing databases', (
    tester,
    db,
  ) async {
    await (db.delete(
      db.tipsLibrary,
    )..where((t) => t.id.equals('tip-water-2'))).go();
    expect((await db.select(db.tipsLibrary).get()).length, seedTips.length - 1);
    await db.seedTipsLibrary();
    expect((await db.select(db.tipsLibrary).get()).length, seedTips.length);
  });

  test('screen copy has no exclamation marks', () {
    const copy = [
      'No insights for this week yet.',
      'No workouts logged this week.',
      'Week summary',
    ];
    expect(copy.any((c) => c.contains('!')), isFalse);
  });
}
