import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/core/time/local_date.dart';
import 'package:wellbeing/data/repositories/habit_repository.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/data/tables/tables.dart';

import '../test_helpers.dart';

Future<void> addDefaultHabit(WidgetTester tester) async {
  await tester.tap(find.text('Add habit'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

void main() {
  appTest('no habits shows an empty state with Add habit', (tester, db) async {
    expect(find.text('Breaks'), findsOneWidget);
    expect(find.text('No habits yet.'), findsOneWidget);
    expect(find.text('Add habit'), findsOneWidget);
  });

  appTest('creating a habit uses kind defaults and shows it on Today', (
    tester,
    db,
  ) async {
    await addDefaultHabit(tester);
    expect(find.text('Water'), findsOneWidget);
    expect(find.text('0/6'), findsOneWidget);

    final habit = (await db.select(db.habits).get()).single;
    expect(habit.kind, HabitKind.water);
    expect(habit.dailyTarget, 6);
    expect(habit.remindersEnabled, isFalse); // off by default
    expect(testScheduler.planned, isEmpty);
    expect(testScheduler.permissionRequests, 0);
  });

  appTest('choosing a kind changes name and target; custom needs a name', (
    tester,
    db,
  ) async {
    await tester.tap(find.text('Add habit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stand'));
    await tester.pumpAndSettle();
    expect(find.text('8'), findsOneWidget); // stand default target

    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a name.'), findsOneWidget);
    expect(await db.select(db.habits).get(), isEmpty);

    await tester.enterText(find.byType(TextField), 'Read');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect((await db.select(db.habits).get()).single.name, 'Read');
  });

  appTest('tapping a habit logs one and Undo removes it', (tester, db) async {
    await addDefaultHabit(tester);
    await tester.tap(find.text('Water'));
    await tester.pumpAndSettle();
    expect(find.text('1/6'), findsOneWidget);
    expect(find.text('Logged. Water 1 of 6.'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('0/6'), findsOneWidget);
  });

  appTest('turning reminders on asks for permission, then schedules', (
    tester,
    db,
  ) async {
    await tester.tap(find.text('Add habit'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('Active days'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Allow notifications'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(testScheduler.permissionRequests, 1);
    expect((await db.select(db.habits).get()).single.remindersEnabled, isTrue);
    // Water defaults: 09:00-17:00 every 2 hours; 10:00 UTC "now" skips 09:00.
    expect(testScheduler.planned, isNotEmpty);
    expect(testScheduler.planned.first.title, 'Water break.');
    expect(testScheduler.planned.first.at.isAfter(testNow.toLocal()), isTrue);
  });

  appTest('declining notification access still saves the habit', (
    tester,
    db,
  ) async {
    await tester.tap(find.text('Add habit'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(testScheduler.permissionRequests, 0);
    expect(find.text('Water'), findsOneWidget);
    expect(testScheduler.planned, isEmpty);
  });

  appTest('refusing the system permission dialog explains plainly', (
    tester,
    db,
  ) async {
    testScheduler.grantOnRequest = false;
    await tester.tap(find.text('Add habit'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(testScheduler.permissionRequests, 1);
    expect(find.text('Notifications are off for this app.'), findsOneWidget);
    expect(find.text('Water'), findsOneWidget); // habit still saved
    expect(testScheduler.planned, isEmpty);
  });

  appTest('set-times mode requires at least one time', (tester, db) async {
    await tester.tap(find.text('Add habit'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set times'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Add at least one reminder time.'), findsOneWidget);
    expect(await db.select(db.habits).get(), isEmpty);
  });

  appTest('habit detail shows count, streak and four weeks of history', (
    tester,
    db,
  ) async {
    await addDefaultHabit(tester);
    await tester.tap(find.byTooltip('Water details'));
    await tester.pumpAndSettle();

    expect(find.text('0 of 6'), findsOneWidget);
    expect(find.text('Current streak'), findsOneWidget);
    expect(find.text('Longest streak'), findsOneWidget);
    expect(find.text('Last 4 weeks'), findsOneWidget);

    await tester.tap(find.byTooltip('Log one'));
    await tester.pumpAndSettle();
    expect(find.text('1 of 6'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove one'));
    await tester.pumpAndSettle();
    expect(find.text('0 of 6'), findsOneWidget);
  });

  appTest('deleting a habit removes it from Today', (tester, db) async {
    await addDefaultHabit(tester);
    await tester.tap(find.byTooltip('Water details'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(find.text('No habits yet.'), findsOneWidget);
    expect((await db.select(db.habits).get()).single.deletedAt, isNotNull);
  });

  appTest('seven days of meeting the target awards a habit badge once', (
    tester,
    db,
  ) async {
    final clock = FixedClock(testNow);
    final user = await UserRepository(db, clock).ensureUser();
    final repo = HabitRepository(db, clock);
    final id = await repo.create(
      userId: user.id,
      name: 'Water',
      kind: HabitKind.water,
      dailyTarget: 2,
    );
    final habit = (await repo.byId(id))!;
    for (var ago = 0; ago < 7; ago++) {
      final d = parseLocalDate(shiftLocalDate('2026-05-13', -ago));
      await repo.log(
        habit: habit,
        dayCutoffMinutes: 0,
        count: 2,
        at: DateTime.utc(d.year, d.month, d.day, 8),
      );
    }
    await tester.pumpAndSettle();

    expect(find.text('7-day streak reached.'), findsOneWidget);
    final keys = (await db.select(db.badgesAwarded).get()).map(
      (b) => b.badgeKey,
    );
    expect(keys, ['streak_habit:${habit.id}_7']);
  });

  test('habit copy has no exclamation marks', () {
    const copy = [
      'No habits yet.',
      'Enter a name.',
      'Add at least one reminder time.',
      'Choose at least one day.',
      'Reminders need permission to show notifications.',
      'Reminders will start once notifications are allowed.',
      'Notifications are off for this app.',
      'Logged. Water 1 of 6.',
    ];
    expect(copy.any((c) => c.contains('!')), isFalse);
  });
}
