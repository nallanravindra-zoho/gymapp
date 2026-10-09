import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/features/screen_time/usage_source.dart';

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

Future<void> openScreenTime(WidgetTester tester) async {
  await tester.tap(find.text('Screen time').first);
  await tester.pumpAndSettle();
}

void main() {
  appTest('without access the card offers Set up', (tester, db) async {
    expect(find.text('Screen time'), findsOneWidget);
    expect(find.text('Set up'), findsOneWidget);
  });

  appTest('the explanation comes first, then the system settings page', (
    tester,
    db,
  ) async {
    await tester.tap(find.text('Set up'));
    await tester.pumpAndSettle();

    expect(find.text('Allow usage access'), findsOneWidget);
    expect(find.textContaining('Only daily totals are kept'), findsOneWidget);
    expect(testUsage.openSettingsCalls, 0); // not opened until asked

    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    expect(testUsage.openSettingsCalls, 1);

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.text('Allow usage access'), findsNothing);
  });

  appTest('with access the card shows today and the screen shows detail', (
    tester,
    db,
  ) async {
    expect(find.text('4 h 12 min'), findsOneWidget);
    expect(find.text('Set up'), findsNothing);
    expect((await db.select(db.screenTimeDaily).get()).length, 7);

    await openScreenTime(tester);
    expect(find.text('Total screen time'), findsOneWidget);
    expect(find.text('Social media'), findsOneWidget);
    expect(find.text('1 h 32 min'), findsOneWidget);
    expect(find.text('37%'), findsOneWidget);
    expect(find.text('Late evening'), findsOneWidget);
    expect(find.text('45 min'), findsOneWidget);
  }, usage: withData());

  appTest('a daily goal can be set, shown and cleared', (tester, db) async {
    await openScreenTime(tester);
    expect(find.text('Set a daily goal'), findsOneWidget);

    await tester.tap(find.text('Set a daily goal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5 h'));
    await tester.pumpAndSettle();
    expect(find.text('Goal 5 h'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    await tester.tap(find.text('Change goal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No goal'));
    await tester.pumpAndSettle();
    expect(find.text('Goal 5 h'), findsNothing);
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
    expect(find.text('4 h 4 min'), findsOneWidget);
    expect(find.text('12 h 12 min'), findsOneWidget);
    for (final d in ['Wed', 'Tue', 'Mon', 'Sun', 'Sat', 'Fri', 'Thu']) {
      expect(find.text(d), findsOneWidget);
    }
  }, usage: withData());

  appTest('granting access later starts reading usage', (tester, db) async {
    expect(find.text('Set up'), findsOneWidget);
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

    expect(find.text('Set up'), findsNothing);
    expect(find.text('1 h 1 min'), findsOneWidget);
  });

  test('screen time copy has no exclamation marks', () {
    const copy = [
      'Allow usage access',
      'No screen time recorded yet today.',
      'No screen time recorded yet.',
      'Set a daily goal',
    ];
    expect(copy.any((c) => c.contains('!')), isFalse);
  });
}
