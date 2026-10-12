import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/nav_a.dart';
import '../test_helpers.dart';

void main() {
  appTest('empty state offers the Workout quick-log tile', (tester, db) async {
    expect(find.text('Quick log'), findsOneWidget);
    expect(find.text('Workout'), findsWidgets);
    expect(find.text('Not logged yet'), findsWidgets);
    expect(find.text('Wed, 13 May'), findsOneWidget);
  });

  appTest('a workout is logged in a few taps: open, type, manual, save', (
    tester,
    db,
  ) async {
    await openLogScreen(tester); // 1
    expect(find.text('Log Workout'), findsOneWidget);
    await tester.tap(find.text('Yoga')); // 2
    await tester.pumpAndSettle();
    await tester.tap(find.text('Or enter manually')); // 3
    await tester.pumpAndSettle();
    await tapSave(tester); // 4

    expect(find.text('Logged. 30 min yoga.'), findsOneWidget);
    final rows = await db.select(db.workouts).get();
    expect(rows.single.workoutTypeId, 'builtin-yoga');
    expect(rows.single.durationMinutes, 30);
    expect(rows.single.intensity, isNull); // never required
    expect(find.text('Yoga • 30 min'), findsOneWidget); // listed on Today
  });

  appTest('the Other workout type is no longer offered', (tester, db) async {
    await openLogScreen(tester);
    expect(find.text('Yoga'), findsOneWidget);
    expect(find.text('Other'), findsNothing);
    expect(find.text('Custom'), findsOneWidget);
  });

  appTest('Start timer is disabled until a type is chosen', (tester, db) async {
    await openLogScreen(tester);
    final start = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Start timer'),
    );
    expect(start.onPressed, isNull);
    await tester.tap(find.text('Yoga'));
    await tester.pumpAndSettle();
    final enabled = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Start timer'),
    );
    expect(enabled.onPressed, isNotNull);
  });

  appTest('Save is disabled until a type is chosen', (tester, db) async {
    await openLogScreen(tester);
    await tester.tap(find.text('Or enter manually'));
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
    await openLogScreen(tester);
    await pickTypeManual(tester, 'Run');
    await scrollToLogItem(tester, find.text('High'));
    await tester.tap(find.text('High'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('High')); // clear
    await tester.pumpAndSettle();
    await tapSave(tester);
    expect((await db.select(db.workouts).get()).single.intensity, isNull);
  });

  appTest('manual entry shows the start and end times', (tester, db) async {
    await openLogScreen(tester);
    await tester.tap(find.text('Or enter manually'));
    await tester.pumpAndSettle();
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('End'), findsOneWidget);
    await scrollToLogItem(tester, find.text('Use timer instead'));
    expect(find.text('Use timer instead'), findsOneWidget);
  });

  appTest('tapping an entry edits it and delete removes it', (
    tester,
    db,
  ) async {
    await logToday(tester, 'Walk');

    await tester.tap(find.text('Walk • 30 min'));
    await tester.pumpAndSettle();
    expect(find.text('Edit workout'), findsOneWidget);
    await scrollToLogItem(tester, find.text('Delete'));
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Entry removed.'), findsOneWidget);
    expect(find.text('Walk • 30 min'), findsNothing);
    expect(find.text('Not logged yet'), findsWidgets);
    expect((await db.select(db.workouts).get()).single.deletedAt, isNotNull);
  });

  appTest('Start timer opens the timer screen and Cancel discards it', (
    tester,
    db,
  ) async {
    await openLogScreen(tester);
    await tester.tap(find.text('Yoga'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Start timer'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('In progress'), findsOneWidget);
    expect(find.text('00:00:00'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Timer running'), findsNothing);
    expect(await db.select(db.workouts).get(), isEmpty);
  });

  appTest('adding a custom workout type selects it and can be saved', (
    tester,
    db,
  ) async {
    await openLogScreen(tester);
    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Climbing');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Climbing'), findsOneWidget);
    await tester.tap(find.text('Or enter manually'));
    await tester.pumpAndSettle();
    await tapSave(tester);

    expect(find.text('Logged. 30 min climbing.'), findsOneWidget);
    final types = await db.select(db.workoutTypes).get();
    expect(types.where((t) => !t.isBuiltin).single.name, 'Climbing');
  });

  appTest('action buttons clear the system navigation bar', (tester, db) async {
    // 132 physical px at 2.75 dpr = 48 logical px of navigation bar.
    tester.view.padding = const FakeViewPadding(bottom: 132);
    tester.view.viewPadding = const FakeViewPadding(bottom: 132);
    await tester.pumpAndSettle();
    await openLogScreen(tester);
    final screenHeight = tester.view.physicalSize.height / 2.75;

    final startBottom = tester
        .getBottomLeft(find.widgetWithText(FilledButton, 'Start timer'))
        .dy;
    expect(startBottom, lessThanOrEqualTo(screenHeight - 48));

    await tester.tap(find.text('Or enter manually'));
    await tester.pumpAndSettle();
    // Scrolled to the end of the form, Save sits above the navigation bar.
    await scrollToLogItem(tester, find.text('Use timer instead'));
    final saveBottom = tester.getBottomLeft(find.text('Save')).dy;
    expect(saveBottom, lessThanOrEqualTo(screenHeight - 48));
  });
}
