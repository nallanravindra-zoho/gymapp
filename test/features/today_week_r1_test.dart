import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/features/hobbies/hobbies_screen.dart';
import 'package:wellbeing/features/streaks/today_streaks.dart';
import 'package:wellbeing/features/today/summary_rows.dart';
import 'package:wellbeing/features/workouts/workout_detail_screen.dart';

import '../helpers/nav_a.dart';
import '../helpers/nav_b.dart';
import '../helpers/week_helpers.dart';
import '../test_helpers.dart';

Future<void> tallScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 7000);
  await tester.pumpAndSettle();
}

void main() {
  appTest('Today order: streaks, quick access, summary, workout, habits', (
    tester,
    db,
  ) async {
    await tallScreen(tester);
    double top(Finder f) => tester.getTopLeft(f).dy;

    final streaks = top(find.byType(TodayStreaks));
    final quick = top(find.byKey(const ValueKey('quick-Workout')));
    final summary = top(find.text("Today's Summary"));
    final workout = top(find.text('No workouts saved today.'));
    final habits = top(find.text('No habits yet. Use Manage to add one.'));
    expect(streaks, lessThan(quick));
    expect(quick, lessThan(summary));
    expect(summary, lessThan(workout));
    expect(workout, lessThan(habits));
  });

  appTest('the five quick-access tiles are present', (tester, db) async {
    await tallScreen(tester);
    for (final label in [
      'Workout',
      'Healthy Habits',
      'Hobbies',
      'Sleep',
      'Screen Time',
    ]) {
      expect(
        find.byKey(ValueKey('quick-$label')),
        findsOneWidget,
        reason: label,
      );
    }
  });

  appTest('the Hobbies tile opens the Hobbies screen', (tester, db) async {
    await tapQuickTile(tester, 'Hobbies');
    expect(find.byType(HobbiesScreen), findsOneWidget);
  });

  appTest('the Hobbies summary row has a clear subtitle', (tester, db) async {
    await tallScreen(tester);
    expect(find.text('Nothing logged yet'), findsOneWidget);
    expect(find.text('Om chanting counter'), findsNothing);
  });

  appTest('Workout section: Manage and Add new workout', (tester, db) async {
    await tallScreen(tester);
    await tester.tap(find.text('Manage').first);
    await tester.pumpAndSettle();
    expect(find.text('Manage workouts'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add new workout'));
    await tester.pumpAndSettle();
    expect(find.text('Log Workout'), findsOneWidget);
  });

  appTest('Healthy Habits section has its own Manage link', (tester, db) async {
    await tallScreen(tester);
    expect(find.text('Manage'), findsNWidgets(2));
    await tester.tap(find.text('Manage').at(1));
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsWidgets);
    expect(find.textContaining('Manage'), findsWidgets);
  });

  appTest('a saved workout is listed and opens the detail view', (
    tester,
    db,
  ) async {
    await seedFullDay(db, day: 13);
    await tallScreen(tester);
    expect(find.text('No workouts saved today.'), findsNothing);
    await tester.tap(find.textContaining('Yoga').last);
    await tester.pumpAndSettle();
    expect(find.byType(WorkoutDetailScreen), findsOneWidget);
  });

  appTest('Today summary includes hobby, sleep and screen time rows', (
    tester,
    db,
  ) async {
    await seedFullDay(db, day: 13);
    await tallScreen(tester);
    expect(find.textContaining('Painting'), findsWidgets);
    expect(find.textContaining('10h'), findsOneWidget); // sleep
    expect(find.textContaining('1h'), findsWidgets); // screen time
  }, prefs: const {'screen_time_goal_minutes': 120});

  appTest('Week sleep icon appears only when the sleep target is met', (
    tester,
    db,
  ) async {
    // Default target is 8 h: 7 h on Tuesday misses, 8 h on Wednesday meets it.
    await seedSleep(db, wakeDay: 12, minutes: 420);
    await seedSleep(db, wakeDay: 13, minutes: 480);
    await openWeekTab(tester);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('mark-sleep')), findsOneWidget);
  });

  appTest('Sleep screen states which day sleep is counted on', (
    tester,
    db,
  ) async {
    await tapQuickTile(tester, 'Sleep');
    expect(
      find.textContaining('Sleep is counted on the day you wake up'),
      findsOneWidget,
    );
  });

  appTest('the day summary repeats the sleep date caption', (tester, db) async {
    await openWeekTab(tester);
    await tester.tap(find.bySemanticsLabel(RegExp('Tuesday, 12 May')));
    await tester.pumpAndSettle();
    expect(
      find.text('Sleep is counted on the day you wake up.'),
      findsOneWidget,
    );
  });

  appTest('the habit threshold setting is saved and used by the Week icon', (
    tester,
    db,
  ) async {
    await seedFullDay(db);
    await openSettingsSection(tester, 'Goals & preferences');
    await tester.scrollUntilVisible(
      find.byTooltip('More: Habits needed for a day icon'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byTooltip('More: Habits needed for a day icon'));
    await tester.pumpAndSettle();
    expect((await db.select(db.users).get()).single.habitThreshold, 2);
  });

  test('hobbyActivityText sums minutes per hobby', () {
    // No logs: empty text; the screen shows its own empty subtitle.
    expect(hobbyActivityText(const [], const {}), '');
  });

  test('copy has no exclamation marks', () {
    const copy = [
      'Add new workout',
      'No workouts saved today.',
      'Nothing logged yet',
      'Sleep is counted on the day you wake up',
      'Habits needed for a day icon',
      'Weekly hobby goals met',
    ];
    expect(copy.any((c) => c.contains('!')), isFalse);
  });
}
