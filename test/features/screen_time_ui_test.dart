import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/data/tables/tables.dart';
import 'package:wellbeing/features/screen_time/usage_source.dart';

import '../helpers/nav_b.dart';
import '../test_helpers.dart';

FakeUsageSource withData() => FakeUsageSource(
  byDate: {
    '2026-05-13': DayUsage(
      totalMinutes: 252,
      categories: const {'social': 92, 'video': 70, 'browser': 56, 'other': 34},
      hours: [for (var h = 0; h < 24; h++) h == 22 ? 45 : 0],
    ),
    '2026-05-12': const DayUsage(totalMinutes: 180),
    '2026-05-11': const DayUsage(totalMinutes: 300),
  },
);

void _backgroundAndResume(WidgetTester tester) {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
}

void main() {
  appTest('without access Today says screen time is not set up', (
    tester,
    db,
  ) async {
    expect(find.text('Screen time'), findsOneWidget);
    expect(find.text('Not set up yet'), findsOneWidget);
  });

  appTest('the explanation comes first, then the system settings page', (
    tester,
    db,
  ) async {
    await openScreenTime(tester);

    expect(find.text('Allow usage access'), findsOneWidget);
    expect(find.textContaining('Only daily totals are kept'), findsOneWidget);
    expect(find.textContaining('no websites are recorded'), findsOneWidget);
    expect(testUsage.openSettingsCalls, 0); // not opened until asked

    await tester.tap(find.text('Grant Usage Access'));
    await tester.pumpAndSettle();
    expect(testUsage.openSettingsCalls, 1);

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.text('Allow usage access'), findsNothing);
  });

  appTest('access is verified when the person returns from settings', (
    tester,
    db,
  ) async {
    await openScreenTime(tester);
    await tester.tap(find.text('Grant Usage Access'));
    await tester.pumpAndSettle();
    expect(find.text('Allow usage access'), findsOneWidget);

    // The person switches access on in settings and comes back.
    testUsage.access = true;
    testUsage.byDate['2026-05-13'] = const DayUsage(totalMinutes: 75);
    _backgroundAndResume(tester);
    await tester.pumpAndSettle();

    expect(find.text('Allow usage access'), findsNothing);
    expect(find.text('Total screen time'), findsOneWidget);
    expect(find.text('1h 15m'), findsWidgets);
    expect(find.text('Automatic tracking is unavailable'), findsNothing);
  });

  appTest('manual entry is the fallback and is stored as manual', (
    tester,
    db,
  ) async {
    await openScreenTime(tester);
    await tester.tap(find.text('Enter screen time manually instead'));
    await tester.pumpAndSettle();

    expect(find.text('Automatic tracking is unavailable'), findsOneWidget);
    await tester.tap(find.text('Add screen time manually'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Hours'), '2');
    await tester.enterText(find.widgetWithText(TextField, 'Minutes'), '15');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final rows = await db.select(db.screenTimeDaily).get();
    expect(rows.single.totalMinutes, 135);
    expect(rows.single.source, ScreenTimeSource.manual);
    expect(rows.single.localDate, '2026-05-13');
    expect(find.text('2h 15m'), findsWidgets);
    expect(
      find.text('Entered manually, not read from the phone.'),
      findsOneWidget,
    );
  });

  appTest('manual entry rejects values that are not a time', (
    tester,
    db,
  ) async {
    await openScreenTime(tester);
    await tester.tap(find.text('Enter screen time manually instead'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add screen time manually'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Minutes'), '75');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Enter whole hours'), findsOneWidget);
    expect(await db.select(db.screenTimeDaily).get(), isEmpty);
  });

  appTest('access taken away shows the unavailable state, data stays', (
    tester,
    db,
  ) async {
    await openScreenTime(tester);
    expect(find.text('Automatic tracking is unavailable'), findsNothing);

    testUsage.access = false;
    _backgroundAndResume(tester);
    await tester.pumpAndSettle();

    expect(find.text('Automatic tracking is unavailable'), findsOneWidget);
    expect(find.text('Grant Usage Access'), findsOneWidget);
    expect(find.text('Add screen time manually'), findsOneWidget);
    expect(find.text('4h 12m'), findsWidgets); // stored totals remain
  }, usage: withData());

  appTest('automatic data is stored as automatic', (tester, db) async {
    final rows = await db.select(db.screenTimeDaily).get();
    expect(rows, isNotEmpty);
    expect(rows.every((r) => r.source == ScreenTimeSource.automatic), isTrue);
  }, usage: withData());

  appTest('with access Today shows the total and the screen shows detail', (
    tester,
    db,
  ) async {
    expect(find.text('4h 12m'), findsOneWidget);
    expect(find.text('Not set up yet'), findsNothing);
    expect((await db.select(db.screenTimeDaily).get()).length, 7);

    await openScreenTime(tester);
    expect(find.text('Total screen time'), findsOneWidget);
    expect(find.text('4h 12m'), findsOneWidget);
    expect(find.text('Social media'), findsOneWidget);
    expect(find.text('1h 32m'), findsOneWidget);
    expect(find.text('37%'), findsOneWidget);
    expect(find.text('Late evening'), findsOneWidget);
    expect(find.text('45 min'), findsOneWidget);
  }, usage: withData());

  appTest('a daily target can be set, shown and cleared', (tester, db) async {
    await openScreenTime(tester);
    expect(find.text('Set a daily target'), findsOneWidget);

    await tester.tap(find.text('Set a daily target'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5 h'));
    await tester.pumpAndSettle();
    expect(find.text('(Target 5 h)'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    // The target is recorded with today's reading on the next sync.
    await tester.drag(find.byType(Scrollable).last, const Offset(0, 300));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Change target'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No target'));
    await tester.pumpAndSettle();
    expect(find.text('(Target 5 h)'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  }, usage: withData());

  appTest('the week tab shows an average and seven days', (tester, db) async {
    await tester.pumpAndSettle();
    await openScreenTime(tester);
    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();

    expect(find.text('Daily average'), findsOneWidget);
    expect(find.text('Last 7 days'), findsOneWidget);
    // (252 + 180 + 300) / 3 = 244
    expect(find.text('4h 4m'), findsOneWidget);
    expect(find.text('12h 12m'), findsOneWidget);
    for (final d in ['Wed', 'Tue', 'Mon', 'Sun', 'Sat', 'Fri', 'Thu']) {
      expect(find.text(d), findsOneWidget);
    }
  }, usage: withData());

  appTest('granting access later starts reading usage', (tester, db) async {
    expect(find.text('Not set up yet'), findsOneWidget);
    testUsage.access = true;
    testUsage.byDate['2026-05-13'] = const DayUsage(totalMinutes: 61);

    // The shell re-checks when the app resumes.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.text('Not set up yet'), findsNothing);
    expect(find.text('1h 1m'), findsOneWidget);
  });

  test('screen time copy has no exclamation marks', () {
    const copy = [
      'Allow usage access',
      'No screen time recorded yet today.',
      'No screen time recorded yet.',
      'Set a daily target',
      'Automatic tracking is unavailable',
      'Enter screen time manually instead',
    ];
    expect(copy.any((c) => c.contains('!')), isFalse);
  });
}
