import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  appTest('empty state offers Log workout', (tester, db) async {
    expect(find.text('Log workout'), findsOneWidget);
    expect(find.text('Wed, 13 May'), findsOneWidget);
  });

  appTest('a workout is logged in three taps: open, type, save', (
    tester,
    db,
  ) async {
    await tester.tap(find.text('Log workout')); // 1
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yoga')); // 2
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save')); // 3
    await tester.pumpAndSettle();

    expect(find.text('Logged. 30 min yoga.'), findsOneWidget);
    final rows = await db.select(db.workouts).get();
    expect(rows.single.workoutTypeId, 'builtin-yoga');
    expect(rows.single.durationMinutes, 30);
    expect(rows.single.intensity, isNull); // never required
    expect(find.text('30 min'), findsOneWidget); // listed on Today
  });

  appTest('Save is disabled until a type is chosen', (tester, db) async {
    await tester.tap(find.text('Log workout'));
    await tester.pumpAndSettle();
    final save = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save'),
    );
    expect(save.onPressed, isNull);
  });

  appTest('intensity is optional and clears when tapped again', (
    tester,
    db,
  ) async {
    await tester.tap(find.text('Log workout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Run'));
    await tester.tap(find.text('High'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('High')); // clear
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect((await db.select(db.workouts).get()).single.intensity, isNull);
  });

  appTest('manual entry saves the chosen times', (tester, db) async {
    await tester.tap(find.text('Add manual entry'));
    await tester.pumpAndSettle();
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('End'), findsOneWidget);
  });

  appTest('tapping an entry edits it and delete removes it', (
    tester,
    db,
  ) async {
    await tester.tap(find.text('Log workout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Walk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('30 min'));
    await tester.pumpAndSettle();
    expect(find.text('Edit workout'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Entry removed.'), findsOneWidget);
    expect(find.text('Log workout'), findsOneWidget);
    expect((await db.select(db.workouts).get()).single.deletedAt, isNotNull);
  });

  appTest('Start timer opens the timer screen and Cancel discards it', (
    tester,
    db,
  ) async {
    await tester.tap(find.text('Log workout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yoga'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Start timer'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('In progress'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Timer running'), findsNothing);
    expect(await db.select(db.workouts).get(), isEmpty);
  });
}
