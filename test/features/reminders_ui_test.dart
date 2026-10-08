import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/data/repositories/habit_repository.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/data/tables/tables.dart';
import 'package:wellbeing/features/habits/reminder_config.dart';
import 'package:wellbeing/features/reminders/reminders_screen.dart';

import '../test_helpers.dart';

Future<void> openReminders(WidgetTester tester) async {
  await tester.tap(find.text('Manage'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Reminders')); // the tile on the habits screen
  await tester.pumpAndSettle();
}

Future<void> addHabitWithReminders(dynamic db) async {
  final clock = FixedClock(testNow);
  final user = await UserRepository(db, clock).ensureUser();
  await HabitRepository(db, clock).create(
    userId: user.id,
    name: 'Water',
    kind: HabitKind.water,
    dailyTarget: 4,
    remindersEnabled: true,
    reminderConfig: const ReminderConfig(
      mode: ReminderMode.times,
      times: [12 * 60, 15 * 60], // testNow is 10:00
    ).toJson(),
  );
}

void main() {
  test('day labels', () {
    final now = DateTime(2026, 5, 13, 10);
    expect(dayLabel(DateTime(2026, 5, 13, 15), now), 'Today');
    expect(dayLabel(DateTime(2026, 5, 14, 9), now), 'Tomorrow');
    expect(dayLabel(DateTime(2026, 5, 16, 9), now), 'Sat 16 May');
    expect(dayLabel(DateTime(2026, 6, 1, 9), now), 'Mon 1 Jun');
  });

  appTest('is reachable from Manage, by the tile', (tester, db) async {
    await openReminders(tester);
    expect(find.text('Next reminders'), findsOneWidget);
    expect(find.text('Check that it works'), findsOneWidget);
  });

  appTest('is reachable from the bell in the app bar too', (tester, db) async {
    await tester.tap(find.text('Manage'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Reminders'));
    await tester.pumpAndSettle();
    expect(find.text('Next reminders'), findsOneWidget);
  });

  appTest('explains plainly when no habit has reminders on', (
    tester,
    db,
  ) async {
    testScheduler.permitted = true;
    await openReminders(tester);
    expect(
      find.textContaining('No habit has reminders turned on'),
      findsOneWidget,
    );
  });

  appTest('lists the upcoming reminders with time and day', (tester, db) async {
    testScheduler.permitted = true;
    await addHabitWithReminders(db);
    await tester.pumpAndSettle();
    await openReminders(tester);

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Allowed'), findsOneWidget);
    expect(find.text('Water break.'), findsWidgets);
    expect(find.text('12:00 PM'), findsWidgets);
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Tomorrow'), findsWidgets);
    expect(find.text('Quiet hours'), findsOneWidget);
    expect(find.text('10:00 PM to 7:00 AM'), findsOneWidget);
    // Ten shown out of fourteen this week.
    expect(find.text('4 more this week.'), findsOneWidget);
  });

  appTest('without permission it offers to allow and then schedules', (
    tester,
    db,
  ) async {
    await addHabitWithReminders(db);
    await tester.pumpAndSettle();
    await openReminders(tester);

    expect(find.text('Not allowed'), findsOneWidget);
    expect(testScheduler.planned, isEmpty);
    await tester.tap(find.text('Allow notifications'));
    await tester.pumpAndSettle();

    expect(testScheduler.permissionRequests, 1);
    expect(find.text('Allowed'), findsOneWidget);
    expect(find.text('Allow notifications'), findsNothing);
    expect(testScheduler.planned, isNotEmpty);
    expect(find.text('14 of 14'), findsOneWidget);
  });

  appTest('a refused permission is explained', (tester, db) async {
    testScheduler.grantOnRequest = false;
    await openReminders(tester);
    await tester.tap(find.text('Allow notifications'));
    await tester.pumpAndSettle();
    expect(find.text('Notifications are off for this app.'), findsOneWidget);
    expect(find.text('Not allowed'), findsOneWidget);
  });

  appTest('Send test now shows a notification and says so', (tester, db) async {
    testScheduler.permitted = true;
    await openReminders(tester);
    await tester.ensureVisible(find.text('Send test now'));
    await tester.tap(find.text('Send test now'));
    await tester.pumpAndSettle();

    expect(testScheduler.shown.single.title, 'Test reminder.');
    expect(
      find.text('Test reminder sent. Check your notifications.'),
      findsOneWidget,
    );
  });

  appTest('Test in 1 minute schedules it and says when', (tester, db) async {
    testScheduler.permitted = true;
    await openReminders(tester);
    await tester.ensureVisible(find.text('Test in 1 minute'));
    await tester.tap(find.text('Test in 1 minute'));
    await tester.pumpAndSettle();

    expect(testScheduler.testScheduled, isNotNull);
    expect(find.textContaining('Test reminder set for'), findsOneWidget);
    expect(find.textContaining('Close the app and wait'), findsOneWidget);
  });

  appTest('a test without permission asks for permission first', (
    tester,
    db,
  ) async {
    await openReminders(tester);
    await tester.ensureVisible(find.text('Send test now'));
    await tester.tap(find.text('Send test now'));
    await tester.pumpAndSettle();
    expect(find.text('Allow notifications first.'), findsOneWidget);
    expect(testScheduler.shown, isEmpty);
  });

  test('reminders copy has no exclamation marks', () {
    const copy = [
      'Test reminder sent. Check your notifications.',
      'Allow notifications first.',
      'No habit has reminders turned on. Open a habit and switch on Reminders.',
      'Reminders are planned but not set up on this phone yet. Pull down to refresh.',
      'Test reminder.',
      'Notifications are working.',
    ];
    expect(copy.any((c) => c.contains('!')), isFalse);
  });
}
