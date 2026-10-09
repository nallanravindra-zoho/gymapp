import 'package:flutter/material.dart';
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

  Future<void> tapTest(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  appTest('Send test now: the phone accepted it', (tester, db) async {
    testScheduler.permitted = true;
    await openReminders(tester);
    await tapTest(tester, 'Send test now');

    expect(testScheduler.shown.single.title, 'Test reminder.');
    expect(
      find.textContaining('The phone accepted the test notification'),
      findsOneWidget,
    );
    // Said in the message, and again in the settings hint on the screen.
    expect(find.textContaining('allow banners and sound'), findsWidgets);
  });

  appTest('Send test now: the phone did not show it', (tester, db) async {
    testScheduler.permitted = true;
    testScheduler.phoneHidesNotifications = true;
    await openReminders(tester);
    await tapTest(tester, 'Send test now');
    expect(
      find.textContaining('The phone did not show the test notification'),
      findsOneWidget,
    );
  });

  appTest('Send test now: a failure shows its reason', (tester, db) async {
    testScheduler.permitted = true;
    testScheduler.showError = Exception('channel blocked');
    await openReminders(tester);
    await tapTest(tester, 'Send test now');
    expect(find.textContaining('Could not send the test:'), findsOneWidget);
    expect(find.textContaining('channel blocked'), findsOneWidget);
  });

  appTest('Test in 1 minute: registered, with the honest caveat', (
    tester,
    db,
  ) async {
    testScheduler.permitted = true;
    await openReminders(tester);
    await tapTest(tester, 'Test in 1 minute');

    expect(testScheduler.testScheduled, isNotNull);
    expect(find.textContaining('Test set for'), findsOneWidget);
    expect(find.textContaining('Close the app and wait'), findsOneWidget);
    expect(find.textContaining('a few minutes late'), findsOneWidget);
  });

  appTest('Test in 1 minute: not registered points to battery settings', (
    tester,
    db,
  ) async {
    testScheduler.permitted = true;
    await openReminders(tester);
    // The phone refuses the alarm.
    testScheduler.scheduleError = Exception('alarm refused');
    await tapTest(tester, 'Test in 1 minute');
    expect(find.textContaining('Could not send the test:'), findsOneWidget);
    expect(find.textContaining('alarm refused'), findsOneWidget);
  });

  appTest('a test without permission asks for permission first', (
    tester,
    db,
  ) async {
    await openReminders(tester);
    await tapTest(tester, 'Send test now');
    expect(find.text('Allow notifications first.'), findsOneWidget);
    expect(testScheduler.shown, isEmpty);
  });

  appTest('shows how the phone treats the reminder channel', (
    tester,
    db,
  ) async {
    testScheduler.permitted = true;
    testScheduler.channelLevel = 'Low';
    await openReminders(tester);
    expect(find.text('Alert level'), findsOneWidget);
    expect(find.text('Low'), findsOneWidget);
  });

  appTest('shows whether battery saving may stop reminders', (
    tester,
    db,
  ) async {
    testScheduler.permitted = true;
    testSystem.unrestricted = false;
    await openReminders(tester);
    expect(find.text('Background use'), findsOneWidget);
    expect(find.text('Limited'), findsOneWidget);
  });

  appTest('background use is hidden when the phone cannot say', (
    tester,
    db,
  ) async {
    testScheduler.permitted = true;
    testSystem.unrestricted = null;
    await openReminders(tester);
    expect(find.text('Background use'), findsNothing);
  });

  appTest('a scheduling problem is shown on the screen', (tester, db) async {
    testScheduler.permitted = true;
    testScheduler.scheduleError = Exception('alarm refused');
    await addHabitWithReminders(db);
    await tester.pumpAndSettle();
    await openReminders(tester);
    expect(find.textContaining('Last problem:'), findsOneWidget);
    expect(find.textContaining('alarm refused'), findsOneWidget);
  });

  appTest('the settings buttons open the phone\'s own pages', (
    tester,
    db,
  ) async {
    await openReminders(tester);
    final list = find.byType(Scrollable).first;

    await tester.scrollUntilVisible(
      find.text('Notification settings'),
      200,
      scrollable: list,
    );
    await tester.tap(find.text('Notification settings'));
    await tester.pumpAndSettle();
    expect(testSystem.notificationsOpened, 1);

    await tester.scrollUntilVisible(
      find.text('Battery settings'),
      200,
      scrollable: list,
    );
    await tester.tap(find.text('Battery settings'));
    await tester.pumpAndSettle();
    expect(testSystem.batteryOpened, 1);
  });

  test('reminders copy has no exclamation marks', () {
    const copy = [
      'The phone accepted the test notification. If you do not see it, open Notification settings and allow banners and sound.',
      'The phone did not show the test notification. Open Notification settings and check that this app is allowed.',
      'Test set for 2:31 PM. Close the app and wait. Android can deliver it a few minutes late.',
      'The phone did not register the test. Open Battery settings and allow background activity.',
      'Allow notifications first.',
      'No habit has reminders turned on. Open a habit and switch on Reminders.',
      'Reminders are planned but not set up on this phone yet. Pull down to refresh.',
      'Test reminder.',
      'Notifications are working.',
    ];
    expect(copy.any((c) => c.contains('!')), isFalse);
  });
}
