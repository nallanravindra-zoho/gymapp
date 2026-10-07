import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

Future<void> openWeek(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.calendar_view_week_outlined));
  await tester.pumpAndSettle();
}

Future<void> logToday(WidgetTester tester, String type) async {
  await tester.tap(find.text('Log workout'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(type));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Save'));
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
    expect(find.text('30'), findsOneWidget); // active minutes
    expect(find.text('Active minutes'), findsOneWidget);
    expect(find.text('Active days'), findsOneWidget);
    expect(find.text('Yoga'), findsOneWidget); // per-type row
  });

  appTest('two workouts on one day show a count badge', (tester, db) async {
    await logToday(tester, 'Yoga');
    await tester.pump(const Duration(seconds: 5)); // let the snackbar go
    await tester.tap(find.text('Add manual entry'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Walk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await openWeek(tester);

    expect(find.text('2'), findsWidgets); // badge and totals
    expect(find.text('Yoga'), findsOneWidget);
    expect(find.text('Walk'), findsOneWidget);
  });

  appTest('tapping a day opens it; rest day can be marked and removed', (
    tester,
    db,
  ) async {
    await openWeek(tester);
    await tester.tap(find.bySemanticsLabel(RegExp('Thursday, 14 May')));
    await tester.pumpAndSettle();
    expect(find.text('Thursday, 14 May'), findsOneWidget);
    expect(find.text('No workouts logged this day.'), findsOneWidget);

    await tester.tap(find.text('Mark rest day'));
    await tester.pumpAndSettle();
    expect(find.text('Rest day recorded.'), findsOneWidget);
    expect(find.byIcon(Icons.bedtime_outlined), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp('Thursday, 14 May')));
    await tester.pumpAndSettle();
    expect(find.text('Remove rest day'), findsOneWidget);
    await tester.tap(find.text('Remove rest day'));
    await tester.pumpAndSettle();
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
      await tester.tap(find.text('Mark rest day'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
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
    await tester.tap(find.text('Add workout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Run'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final rows = await db.select(db.workouts).get();
    expect(rows.single.localDate, '2026-05-11');
    expect(rows.single.workoutTypeId, 'builtin-run');
  });
}
