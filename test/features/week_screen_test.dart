import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/nav_a.dart';
import '../helpers/week_helpers.dart';

import 'package:wellbeing/features/workouts/workout_detail_screen.dart';

import '../test_helpers.dart';

Future<void> openWeek(WidgetTester tester) => openWeekTab(tester);

/// Leaves the day summary screen, back to the week.
/// Scrolls the day summary until [text] is on screen.
Future<void> scrollToText(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> backToWeek(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Back'));
  await tester.pumpAndSettle();
}

void main() {
  appTest('empty week shows the range and the empty state', (tester, db) async {
    await openWeek(tester);
    expect(find.text('11 – 17 May'), findsOneWidget);
    expect(find.text('No workouts logged this week.'), findsOneWidget);
    for (final d in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']) {
      expect(find.text(d), findsOneWidget);
    }
  });

  appTest('a logged workout appears in the strip and totals', (
    tester,
    db,
  ) async {
    await logToday(tester, 'Yoga');
    await openWeek(tester);

    expect(find.text('No workouts logged this week.'), findsNothing);
    expect(find.text('30 min'), findsWidgets); // active minutes and the row
    await scrollToText(tester, 'Active minutes');
    expect(find.text('Active minutes'), findsOneWidget);
    expect(find.text('Active days'), findsOneWidget);
    expect(find.text('Yoga'), findsWidgets); // totals row and streaks row
  });

  appTest('two workouts on one day show a count badge', (tester, db) async {
    await logToday(tester, 'Yoga');
    await tester.pump(const Duration(seconds: 5)); // let the snackbar go
    await logToday(tester, 'Walk');
    await openWeek(tester);

    expect(
      find.bySemanticsLabel(RegExp('Wednesday, 13 May, 2 workouts')),
      findsOneWidget,
    );
    expect(find.text('Yoga'), findsWidgets);
    expect(find.text('Walk'), findsWidgets);
  });

  appTest('tapping a day opens it; rest day can be marked and removed', (
    tester,
    db,
  ) async {
    await openWeek(tester);
    await tester.tap(find.bySemanticsLabel(RegExp('Thursday, 14 May')));
    await tester.pumpAndSettle();
    expect(find.text('Daily Summary'), findsOneWidget);
    expect(find.text('Thursday, 14 May'), findsOneWidget);
    await scrollToText(tester, 'No workouts logged this day.');
    expect(find.text('No workouts logged this day.'), findsOneWidget);

    await tester.tap(find.text('Mark rest day'));
    await tester.pumpAndSettle();
    expect(find.text('Rest day recorded.'), findsOneWidget);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 1500));
    await tester.pumpAndSettle();
    expect(find.text('A rest day'), findsOneWidget);
    await backToWeek(tester);
    expect(find.byIcon(Icons.bedtime_outlined), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp('Thursday, 14 May')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5)); // let the snackbar go
    await tester.pumpAndSettle();
    await scrollToText(tester, 'Remove rest day');
    expect(find.text('Remove rest day'), findsOneWidget);
    await tester.tap(find.text('Remove rest day'));
    await tester.pumpAndSettle();
    expect(find.text('Rest day removed.'), findsOneWidget);
    await backToWeek(tester);
    expect(find.byIcon(Icons.bedtime_outlined), findsNothing);
  });

  appTest('a third rest day in one week is refused (default limit is 2)', (
    tester,
    db,
  ) async {
    await openWeek(tester);
    for (final day in [
      'Monday, 11 May',
      'Tuesday, 12 May',
      'Thursday, 14 May',
    ]) {
      await tester.tap(find.bySemanticsLabel(RegExp(day)));
      await tester.pumpAndSettle();
      await scrollToText(tester, 'Mark rest day');
      await tester.tap(find.text('Mark rest day'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await backToWeek(tester);
    }
    expect(find.byIcon(Icons.bedtime_outlined), findsNWidgets(2));
  });

  appTest('week navigation moves back and returns to this week', (
    tester,
    db,
  ) async {
    await openWeek(tester);
    await tester.tap(find.byTooltip('Previous week'));
    await tester.pumpAndSettle();
    expect(find.text('4 – 10 May'), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);

    await tester.tap(find.text('This week'));
    await tester.pumpAndSettle();
    expect(find.text('11 – 17 May'), findsOneWidget);
  });

  appTest('add workout from a past day logs it on that date', (
    tester,
    db,
  ) async {
    await openWeek(tester);
    await tester.tap(find.bySemanticsLabel(RegExp('Monday, 11 May')));
    await tester.pumpAndSettle();
    await scrollToText(tester, 'Add workout');
    await tester.tap(find.text('Add workout'));
    await tester.pumpAndSettle();
    // Opened for a past day, the form is already in manual mode.
    expect(find.text('Start'), findsOneWidget);
    await tester.tap(find.text('Run'));
    await tester.pumpAndSettle();
    await tapSave(tester);

    final rows = await db.select(db.workouts).get();
    expect(rows.single.localDate, '2026-05-11');
    expect(rows.single.workoutTypeId, 'builtin-run');
  });

  appTest('a logged workout puts a workout icon on that day only', (
    tester,
    db,
  ) async {
    await logToday(tester, 'Yoga');
    await openWeek(tester);
    expect(find.byKey(const ValueKey('mark-workout')), findsOneWidget);
    expect(find.byKey(const ValueKey('mark-sleep')), findsNothing);
    expect(find.byKey(const ValueKey('mark-screen')), findsNothing);
  });

  appTest('five achieved categories show three icons and +2', (
    tester,
    db,
  ) async {
    await seedFullDay(db);
    await openWeek(tester);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('mark-workout')), findsOneWidget);
    expect(find.byKey(const ValueKey('mark-habits')), findsOneWidget);
    expect(find.byKey(const ValueKey('mark-hobbies')), findsOneWidget);
    expect(find.byKey(const ValueKey('mark-sleep')), findsNothing);
    expect(find.byKey(const ValueKey('mark-screen')), findsNothing);
    expect(find.byKey(const ValueKey('mark-overflow')), findsOneWidget);
    expect(find.text('+2'), findsOneWidget);
  }, prefs: const {'screen_time_goal_minutes': 120});

  appTest(
    'sleep and screen icons need their targets; no target, no screen icon',
    (tester, db) async {
      await seedFullDay(db);
      await openWeek(tester);
      await tester.pumpAndSettle();
      // Without a screen-time target the screen icon is never shown.
      expect(find.byKey(const ValueKey('mark-screen')), findsNothing);
      expect(find.text('+1'), findsOneWidget); // sleep only
    },
  );

  appTest('tapping a day shows the Today-style summary with every category', (
    tester,
    db,
  ) async {
    await seedFullDay(db);
    await openWeek(tester);
    await tester.tap(find.bySemanticsLabel(RegExp('Tuesday, 12 May')));
    await tester.pumpAndSettle();
    expect(find.text('Daily Summary'), findsOneWidget);
    expect(find.text('Summary'), findsOneWidget);
    expect(find.textContaining('Yoga'), findsWidgets);
    expect(find.text('Water'), findsWidgets);
    expect(find.text('1/1'), findsWidgets);
    expect(find.textContaining('Painting'), findsOneWidget);
    expect(find.textContaining('10h'), findsOneWidget);
    expect(find.textContaining('1h'), findsWidgets); // screen 60 min
    expect(
      find.text('Sleep is counted on the day you wake up.'),
      findsOneWidget,
    );
  }, prefs: const {'screen_time_goal_minutes': 120});

  appTest('a workout in the day summary opens the shared detail view', (
    tester,
    db,
  ) async {
    await seedFullDay(db);
    await openWeek(tester);
    await tester.tap(find.bySemanticsLabel(RegExp('Tuesday, 12 May')));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Yoga').first);
    await tester.pumpAndSettle();
    expect(find.byType(WorkoutDetailScreen), findsOneWidget);
  });
}
