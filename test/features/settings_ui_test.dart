import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/data/repositories/workout_repository.dart';
import 'package:wellbeing/data/tables/tables.dart';
import 'package:wellbeing/features/account/auth_service.dart';
import 'package:wellbeing/features/groups/groups_remote.dart';

import '../test_helpers.dart';

FakeAuthService signedInAuth({String? name = 'Divya Account'}) =>
    FakeAuthService(
      signedIn: AccountUser(id: 'acct-1', displayName: name),
    );

Future<void> openSettings(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Profile and settings').first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Settings'));
  await tester.pumpAndSettle();
}

Future<User> user(AppDatabase db) =>
    UserRepository(db, FixedClock(testNow)).ensureUser();

Future<void> addWorkout(AppDatabase db) async {
  final u = await user(db);
  await WorkoutRepository(db, FixedClock(testNow)).add(
    userId: u.id,
    dayCutoffMinutes: 0,
    workoutTypeId: 'builtin-yoga',
    startedAt: testNow,
    endedAt: testNow.add(const Duration(minutes: 30)),
    source: WorkoutSource.manual,
    note: 'before work',
  );
}

IconButton iconButton(WidgetTester tester, String tooltip) =>
    tester.widget<IconButton>(
      find.ancestor(
        of: find.byTooltip(tooltip),
        matching: find.byType(IconButton),
      ),
    );

Future<void> scrollTo(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  group('profile and look', () {
    appTest('the name is saved on the profile', (tester, db) async {
      await openSettings(tester);
      expect(find.text('Not set'), findsOneWidget);
      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Divya');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect((await user(db)).displayName, 'Divya');
      expect(find.text('Divya'), findsOneWidget);
    });

    appTest('dark mode is applied and remembered', (tester, db) async {
      MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app().themeMode, ThemeMode.system);
      await openSettings(tester);
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(app().themeMode, ThemeMode.dark);
      expect(
        (await SharedPreferences.getInstance()).getString('theme_mode'),
        'dark',
      );
    });
  });

  group('reminder and streak settings', () {
    appTest('quiet hours show the defaults', (tester, db) async {
      await openSettings(tester);
      expect(find.text('10:00 PM'), findsOneWidget);
      expect(find.text('7:00 AM'), findsOneWidget);
    });

    appTest('the daily reminder limit moves within its bounds', (
      tester,
      db,
    ) async {
      await openSettings(tester);
      await scrollTo(tester, 'Most reminders in a day');
      await tester.tap(find.byTooltip('More: Most reminders in a day'));
      await tester.pumpAndSettle();
      expect((await user(db)).dailyReminderCap, 7);
      for (var i = 0; i < 10; i++) {
        if (iconButton(tester, 'Less: Most reminders in a day').onPressed ==
            null) {
          break;
        }
        await tester.tap(find.byTooltip('Less: Most reminders in a day'));
        await tester.pumpAndSettle();
      }
      expect((await user(db)).dailyReminderCap, 1);
      expect(
        iconButton(tester, 'Less: Most reminders in a day').onPressed,
        isNull,
        reason: 'cannot go below 1',
      );
    });

    appTest('rest days and the streak freeze are configurable', (
      tester,
      db,
    ) async {
      await openSettings(tester);
      await scrollTo(tester, 'Rest days per week');
      await tester.tap(find.byTooltip('Less: Rest days per week'));
      await tester.pumpAndSettle();
      expect((await user(db)).weeklyRestDays, 1);

      await scrollTo(tester, 'Freeze interval');
      await tester.tap(find.byTooltip('More: Freeze interval'));
      await tester.pumpAndSettle();
      expect((await user(db)).freezeIntervalDays, 8);

      await tester.tap(find.widgetWithText(SwitchListTile, 'Streak freeze'));
      await tester.pumpAndSettle();
      expect((await user(db)).freezeEnabled, isFalse);
      expect(find.text('Freeze interval'), findsNothing);
    });

    appTest('the start of the day is configurable', (tester, db) async {
      await openSettings(tester);
      await scrollTo(tester, 'A new day starts at');
      expect(find.text('00:00'), findsOneWidget);
      await tester.tap(find.byTooltip('More: A new day starts at'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('More: A new day starts at'));
      await tester.pumpAndSettle();
      expect((await user(db)).dayCutoffMinutes, 120);
      expect(find.text('02:00'), findsOneWidget);
    });
  });

  group('export', () {
    appTest('all data goes out as a JSON file', (tester, db) async {
      await addWorkout(db);
      await openSettings(tester);
      await scrollTo(tester, 'Export all data');
      await tester.tap(find.text('Export all data'));
      await tester.pumpAndSettle();

      final file = testExport.delivered.single;
      expect(file.fileName, 'wellbeing-data-2026-05-13.json');
      final json = jsonDecode(file.content) as Map<String, dynamic>;
      expect((json['workouts'] as List).single['note'], 'before work');
    });

    appTest('workouts go out as a CSV file', (tester, db) async {
      await addWorkout(db);
      await openSettings(tester);
      await scrollTo(tester, 'Export workouts');
      await tester.tap(find.text('Export workouts'));
      await tester.pumpAndSettle();

      final file = testExport.delivered.single;
      expect(file.fileName, 'wellbeing-workouts-2026-05-13.csv');
      expect(file.content, contains('2026-05-13,Yoga,'));
    });

    appTest('a file that cannot be made is explained', (tester, db) async {
      await openSettings(tester);
      await scrollTo(tester, 'Export all data');
      testExport.fail = true;
      await tester.tap(find.text('Export all data'));
      await tester.pumpAndSettle();
      expect(
        find.text('Could not create the file. Try again.'),
        findsOneWidget,
      );
    });
  });

  group('erasing data on this phone (signed out)', () {
    appTest('asks first, then removes entries and settings', (
      tester,
      db,
    ) async {
      await addWorkout(db);
      final u = await user(db);
      await UserRepository(
        db,
        FixedClock(testNow),
      ).update(u.id, const UsersCompanion(displayName: Value('Divya')));
      await openSettings(tester);
      await scrollTo(tester, 'Erase data on this phone');
      await tester.tap(find.text('Erase data on this phone'));
      await tester.pumpAndSettle();
      expect(find.textContaining('cannot be undone'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(await db.select(db.workouts).get(), hasLength(1));

      await tester.tap(find.text('Erase data on this phone'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Erase'));
      await tester.pumpAndSettle();
      expect(await db.select(db.workouts).get(), isEmpty);
      expect((await user(db)).displayName, '');
      expect(find.text('Data on this phone erased.'), findsOneWidget);
      expect(await testSyncState.accountId(), isNull);
    });

    appTest('is not offered, nor is deleting, in the wrong state', (
      tester,
      db,
    ) async {
      await openSettings(tester);
      await scrollTo(tester, 'Export workouts');
      expect(find.text('Delete account'), findsNothing);
    });
  });

  group('deleting the account (signed in)', () {
    appTest(
      'only signed-in people see it, and not the erase option',
      (tester, db) async {
        await openSettings(tester);
        await scrollTo(tester, 'Delete account');
        expect(find.text('Delete account'), findsOneWidget);
        expect(find.text('Erase data on this phone'), findsNothing);
      },
      auth: signedInAuth(),
      groups: FakeGroupsRemote(),
    );

    appTest('cancelling deletes nothing', (tester, db) async {
      await openSettings(tester);
      await scrollTo(tester, 'Delete account');
      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Data on this phone stays'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect((testAuth as FakeAuthService).deleteCalls, 0);
      expect(testAuth.currentUser, isNotNull);
    }, auth: signedInAuth());

    appTest('deleting removes the account but keeps the phone\'s data', (
      tester,
      db,
    ) async {
      await addWorkout(db);
      await testSyncState.setAccountId('acct-1');
      await openSettings(tester);
      await scrollTo(tester, 'Delete account');
      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete account'));
      await tester.pumpAndSettle();

      expect((testAuth as FakeAuthService).deleteCalls, 1);
      expect(testAuth.currentUser, isNull);
      expect(await db.select(db.workouts).get(), hasLength(1));
      expect(
        await testSyncState.accountId(),
        isNull,
        reason: 'a new account can start from this phone\'s data',
      );
      expect(
        find.text('Account deleted. Your data is still on this phone.'),
        findsOneWidget,
      );
    }, auth: signedInAuth());

    appTest('a failed deletion says so and changes nothing', (
      tester,
      db,
    ) async {
      (testAuth as FakeAuthService).deleteSucceeds = false;
      await testSyncState.setAccountId('acct-1');
      await openSettings(tester);
      await scrollTo(tester, 'Delete account');
      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete account'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Could not delete the account. Check your connection and try again.',
        ),
        findsOneWidget,
      );
      expect(testAuth.currentUser, isNotNull);
      expect(await testSyncState.accountId(), 'acct-1');
    }, auth: signedInAuth());
  });

  group('groups use the account name when none is set', () {
    appTest(
      'creating a group fills in an empty name',
      (tester, db) async {
        await tester.tap(find.text('Groups'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Create group'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Crew');
        await tester.tap(find.text('Create'));
        await tester.pumpAndSettle();
        expect((await user(db)).displayName, 'Divya Account');
      },
      auth: signedInAuth(),
      groups: FakeGroupsRemote(me: 'acct-1'),
    );

    appTest(
      'a name you chose is never replaced',
      (tester, db) async {
        final u = await user(db);
        await UserRepository(
          db,
          FixedClock(testNow),
        ).update(u.id, const UsersCompanion(displayName: Value('Chosen')));
        await tester.tap(find.text('Groups'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Create group'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Crew');
        await tester.tap(find.text('Create'));
        await tester.pumpAndSettle();
        expect((await user(db)).displayName, 'Chosen');
      },
      auth: signedInAuth(),
      groups: FakeGroupsRemote(me: 'acct-1'),
    );
  });
}
