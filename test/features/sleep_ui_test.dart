import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/features/sleep/sleep_log_sheet.dart';

import '../helpers/nav_a.dart';
import '../test_helpers.dart';

/// Opens the Sleep screen from Today's quick-log tile.
Future<void> openSleep(WidgetTester tester) => tapQuickTile(tester, 'Sleep');

/// On the Sleep screen with nothing logged: log the default night.
Future<void> logDefaultSleep(WidgetTester tester) async {
  await tester.tap(find.text('Log sleep'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

void main() {
  appTest('Today offers Sleep, which opens the Sleep screen with Log sleep', (
    tester,
    db,
  ) async {
    expect(find.text('Sleep'), findsWidgets);
    expect(find.text('Not logged yet'), findsWidgets);
    await openSleep(tester);
    expect(find.text('Target bedtime'), findsOneWidget);
    expect(find.text('Log sleep'), findsOneWidget);
  });

  appTest('logging sleep defaults to the targets and saves in two taps', (
    tester,
    db,
  ) async {
    await openSleep(tester);
    await tester.tap(find.text('Log sleep'));
    await tester.pumpAndSettle();
    final sheet = find.byType(SleepLogSheet);
    expect(
      find.descendant(of: sheet, matching: find.text('10:30 PM')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('6:30 AM')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('8 h')),
      findsOneWidget,
    );

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Logged. 8 h sleep.'), findsOneWidget);
    final log = (await db.select(db.sleepLogs).get()).single;
    expect(log.durationMinutes, 480);
    expect(log.localDate, '2026-05-13'); // wake date
    // The screen now shows last night instead of the button.
    expect(find.text('Log sleep'), findsNothing);
    expect(find.text('Slept 8h'), findsOneWidget);
  });

  appTest('Sleep screen shows targets, last night and consistency', (
    tester,
    db,
  ) async {
    await openSleep(tester);
    await logDefaultSleep(tester);

    expect(find.text('Target bedtime'), findsOneWidget);
    expect(find.text('Wake up'), findsWidgets);
    expect(find.text('Actual (last night)'), findsOneWidget);
    expect(find.text('Slept 8h'), findsOneWidget);
    expect(find.text('Consistency score'), findsOneWidget);
    // A night right on target counts; no colour judgement or verdict words.
    expect(find.text('1 of 7 days on schedule.'), findsOneWidget);
    expect(find.textContaining('Good'), findsNothing);
  });

  appTest('the wind-down checklist is gone from the Sleep screen', (
    tester,
    db,
  ) async {
    await openSleep(tester);
    expect(find.text('Wind down'), findsNothing);
    expect(find.text('Screens off'), findsNothing);
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
    await tester.tap(
      find.descendant(
        of: find.byType(SleepLogSheet),
        matching: find.text('Bedtime'),
      ),
    );
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
    await openSleep(tester);
    await logDefaultSleep(tester);
    await tester.tap(find.text('Edit').last);
    await tester.pumpAndSettle();
    expect(find.text('Edit sleep'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Entry removed.'), findsOneWidget);
    expect(find.text('No sleep logged for last night.'), findsOneWidget);
    expect((await db.select(db.sleepLogs).get()).single.deletedAt, isNotNull);
  });

  appTest('Today shows last night once sleep is logged', (tester, db) async {
    await openSleep(tester);
    await logDefaultSleep(tester);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('8h (target 8h)'), findsOneWidget);
  });

  test('sleep copy has no exclamation marks', () {
    const copy = [
      'Logged. 8 h sleep.',
      '1 of 7 days on schedule.',
      'No sleep logged for last night.',
    ];
    expect(copy.any((c) => c.contains('!')), isFalse);
  });
}
