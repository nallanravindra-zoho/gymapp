import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_helpers.dart';

Future<void> openSleep(WidgetTester tester) async {
  await tester.tap(find.text('Sleep'));
  await tester.pumpAndSettle();
}

Future<void> logDefaultSleep(WidgetTester tester) async {
  await tester.tap(find.text('Log sleep'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

void main() {
  appTest('Today shows a Sleep card that offers Log sleep', (tester, db) async {
    expect(find.text('Sleep'), findsOneWidget);
    expect(find.text('Log sleep'), findsOneWidget);
  });

  appTest('logging sleep defaults to the targets and saves in two taps', (
    tester,
    db,
  ) async {
    await tester.tap(find.text('Log sleep'));
    await tester.pumpAndSettle();
    expect(find.text('10:30 PM'), findsOneWidget);
    expect(find.text('6:30 AM'), findsOneWidget);
    expect(find.text('8 h'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Logged. 8 h sleep.'), findsOneWidget);
    final log = (await db.select(db.sleepLogs).get()).single;
    expect(log.durationMinutes, 480);
    expect(log.localDate, '2026-05-13'); // wake date
    // The card now shows last night instead of the button.
    expect(find.text('Log sleep'), findsNothing);
  });

  appTest('Sleep screen shows targets, last night and consistency', (
    tester,
    db,
  ) async {
    await logDefaultSleep(tester);
    await openSleep(tester);

    expect(find.text('Log'), findsOneWidget); // tab
    expect(find.text('Wind down'), findsOneWidget); // tab
    expect(find.text('Target bedtime'), findsOneWidget);
    expect(find.text('10:30 PM'), findsOneWidget);
    expect(find.text('Last night'), findsOneWidget);
    expect(find.text('8 h'), findsOneWidget);
    // A night right on target counts; no colour judgement or verdict words.
    expect(find.text('1 of 7 days on schedule.'), findsOneWidget);
    expect(find.textContaining('Good'), findsNothing);
  });

  appTest('with nothing logged the score is 0 of 7', (tester, db) async {
    await openSleep(tester);
    expect(find.text('No sleep logged for last night.'), findsOneWidget);
    expect(find.text('0 of 7 days on schedule.'), findsOneWidget);
  });

  appTest('logging from the Sleep screen and accepting a picked time works', (
    tester,
    db,
  ) async {
    await openSleep(tester);
    await tester.tap(find.text('Log sleep'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bedtime'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK')); // keep the suggested time
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('1 of 7 days on schedule.'), findsOneWidget);
  });

  appTest('editing the targets saves them', (tester, db) async {
    await openSleep(tester);
    expect(await db.select(db.sleepTargets).get(), isEmpty);
    await tester.tap(find.text('Edit').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final t = (await db.select(db.sleepTargets).get()).single;
    expect(t.bedtimeMinutes, 22 * 60 + 30);
    expect(t.wakeMinutes, 6 * 60 + 30);
  });

  appTest('a logged night can be edited and deleted', (tester, db) async {
    await logDefaultSleep(tester);
    await openSleep(tester);
    await tester.tap(find.text('Edit').last);
    await tester.pumpAndSettle();
    expect(find.text('Edit sleep'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Entry removed.'), findsOneWidget);
    expect(find.text('No sleep logged for last night.'), findsOneWidget);
    expect((await db.select(db.sleepLogs).get()).single.deletedAt, isNotNull);
  });

  appTest('wind-down checklist has editable items and resets daily', (
    tester,
    db,
  ) async {
    await openSleep(tester);
    await tester.tap(find.text('Wind down'));
    await tester.pumpAndSettle();

    for (final item in ['Screens off', 'Stretch', 'Read a book']) {
      expect(find.text(item), findsOneWidget);
    }

    await tester.tap(find.text('Stretch'));
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('winddown_checked_ids'), ['stretch']);
    expect(prefs.getString('winddown_checked_date'), '2026-05-13');

    // Add an item.
    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Journal');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Journal'), findsOneWidget);

    // Remove one.
    await tester.tap(find.byTooltip('Edit Read a book'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('Read a book'), findsNothing);
  });

  appTest('yesterday\'s ticks do not carry over', (tester, db) async {
    SharedPreferences.setMockInitialValues({
      'winddown_checked_ids': ['stretch'],
      'winddown_checked_date': '2026-05-12',
    });
    await openSleep(tester);
    await tester.tap(find.text('Wind down'));
    await tester.pumpAndSettle();
    final stretch = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'Stretch'),
    );
    expect(stretch.value, isFalse);
  });

  test('sleep copy has no exclamation marks', () {
    const copy = [
      'Logged. 8 h sleep.',
      '1 of 7 days on schedule.',
      'No sleep logged for last night.',
      'No wind-down items.',
    ];
    expect(copy.any((c) => c.contains('!')), isFalse);
  });
}
