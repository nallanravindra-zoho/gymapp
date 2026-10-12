import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/repositories/habit_repository.dart';
import 'package:wellbeing/data/repositories/hobby_repository.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/data/tables/tables.dart';
import 'package:wellbeing/features/hobbies/hobby_reminders.dart';

import '../helpers/hobby_helpers.dart';
import '../test_helpers.dart';

Future<String> _userId(AppDatabase db) async =>
    (await UserRepository(db, const AppClock()).ensureUser()).id;

HobbyRepository _repo(AppDatabase db) =>
    HobbyRepository(db, FixedClock(testNow));

Future<Hobby> _hobby(AppDatabase db, String name) async =>
    (await db.select(db.hobbies).get()).firstWhere((h) => h.name == name);

void main() {
  appTest('Hobbies lists the six defaults', (tester, db) async {
    await openHobbies(tester);
    for (final n in [
      'Music',
      'Art',
      'Dance',
      'Learning',
      'Reading',
      'Writing',
    ]) {
      await scrollTo(tester, find.text(n));
      expect(find.text(n), findsOneWidget);
    }
    expect(find.text('Set a goal to start a streak'), findsOneWidget);
    expect(find.text('Manage'), findsOneWidget);
    expect(find.text('Om chanting'), findsOneWidget);
    expect((await db.select(db.hobbies).get()).length, 6);
  });

  appTest('Manage then Add hobby creates a custom hobby with a weekly goal', (
    tester,
    db,
  ) async {
    await openHobbies(tester);
    await openManageHobbies(tester);
    await tester.tap(find.text('Add hobby'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Gardening');
    await tester.tap(find.text('Goal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Minutes per week'),
      '90',
    );
    expect(
      find.text('A weekly goal can be met on any days from Monday to Sunday.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final h = await _hobby(db, 'Gardening');
    expect(h.isBuiltin, isFalse);
    expect(h.goalPeriod, HobbyGoalPeriod.weekly);
    expect(h.goalValue, 90);
    expect(h.goalUnit, HobbyGoalUnit.minutes);
    expect(find.text('Gardening'), findsOneWidget);
    expect(find.textContaining('90 min a week'), findsOneWidget);
  });

  appTest('a name is required', (tester, db) async {
    await openHobbies(tester);
    await openManageHobbies(tester);
    await tester.tap(find.text('Add hobby'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a name.'), findsOneWidget);
  });

  appTest('archive hides a hobby and Restore brings it back', (
    tester,
    db,
  ) async {
    await openHobbies(tester);
    await openManageHobbies(tester);
    await tester.tap(find.byTooltip('Archive Dance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();
    expect((await _hobby(db, 'Dance')).isActive, isFalse);
    expect(find.text('Archived'), findsOneWidget);
    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();
    expect((await _hobby(db, 'Dance')).isActive, isTrue);
    expect(find.text('Archived'), findsNothing);
  });

  appTest(
    'manual minutes log shows goal progress and can be edited and deleted',
    (tester, db) async {
      await openHobbies(tester);
      final music = await _hobby(db, 'Music');
      await _repo(db).update(
        music.id,
        const HobbiesCompanion(
          goalPeriod: Value(HobbyGoalPeriod.daily),
          goalValue: Value(60),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('0 of 60 min today'), findsOneWidget);

      await tester.tap(find.text('Music'));
      await tester.pumpAndSettle();
      expect(find.text('Goal: 60 min a day'), findsOneWidget);
      await tester.tap(find.text('Add time manually'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Minutes'), '45');
      await tester.enterText(
        find.widgetWithText(TextField, 'Note (optional)'),
        'Scales',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      var logs = await db.select(db.hobbyLogs).get();
      expect(logs, hasLength(1));
      expect(logs.single.durationMinutes, 45);
      expect(logs.single.source, HobbyLogSource.manual);
      expect(logs.single.note, 'Scales');
      expect(logs.single.localDate, '2026-05-13');
      expect(find.text('45 of 60 min today'), findsOneWidget);
      expect(find.text('45 min'), findsOneWidget);
      expect(find.text('Scales'), findsOneWidget);

      // Edit to 75 minutes: the goal is met.
      await tester.tap(find.text('45 min'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Minutes'), '75');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      logs = await db.select(db.hobbyLogs).get();
      expect(logs.single.durationMinutes, 75);
      expect(find.text('75 of 60 min today'), findsOneWidget);

      // Delete it.
      await tester.tap(find.textContaining('1h 15m'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Delete log'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      logs = await (db.select(
        db.hobbyLogs,
      )..where((l) => l.deletedAt.isNull())).get();
      expect(logs, isEmpty);
      expect(find.text('0 of 60 min today'), findsOneWidget);
    },
  );

  appTest('start and end times: the end must come after the start', (
    tester,
    db,
  ) async {
    await openHobbies(tester);
    await tester.tap(find.text('Reading'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add time manually'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start and end'));
    await tester.pumpAndSettle();
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('End'), findsOneWidget);
    // Defaults are 30 minutes apart (10:00 clock: 9:30 to 10:00).
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final logs = await db.select(db.hobbyLogs).get();
    expect(logs.single.durationMinutes, 30);
    expect(logs.single.endedAt, isNotNull);
  });

  appTest('the timer saves a timer log with a note', (tester, db) async {
    await openHobbies(tester);
    await tester.tap(find.text('Writing'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start timer'));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Stop and save'), findsOneWidget);
    expect(find.text('Discard timer'), findsOneWidget);
    await tester.tap(find.text('Stop and save'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Note (optional)'),
      'Chapter one',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final logs = await db.select(db.hobbyLogs).get();
    expect(logs.single.source, HobbyLogSource.timer);
    expect(logs.single.durationMinutes, 1, reason: 'a short timer counts as 1');
    expect(logs.single.note, 'Chapter one');
    expect(find.text('Start timer'), findsOneWidget);
  });

  appTest('weekly goal: shows progress this week and the week balance', (
    tester,
    db,
  ) async {
    await openHobbies(tester);
    final uid = await _userId(db);
    final art = await _hobby(db, 'Art');
    final dance = await _hobby(db, 'Dance');
    final repo = _repo(db);
    await repo.update(
      art.id,
      const HobbiesCompanion(
        goalPeriod: Value(HobbyGoalPeriod.weekly),
        goalValue: Value(60),
      ),
    );
    // Mon and Tue of the week of 13 May 2026 (Wed).
    await repo.addLog(
      userId: uid,
      hobbyId: art.id,
      dayCutoffMinutes: 0,
      source: HobbyLogSource.manual,
      startedAt: DateTime.utc(2026, 5, 11, 12),
      durationMinutes: 30,
    );
    await repo.addLog(
      userId: uid,
      hobbyId: art.id,
      dayCutoffMinutes: 0,
      source: HobbyLogSource.manual,
      startedAt: DateTime.utc(2026, 5, 12, 12),
      durationMinutes: 35,
    );
    await repo.addLog(
      userId: uid,
      hobbyId: dance.id,
      dayCutoffMinutes: 0,
      source: HobbyLogSource.manual,
      startedAt: DateTime.utc(2026, 5, 12, 18),
      durationMinutes: 20,
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('65 of 60 min this week'), findsOneWidget);
    expect(find.textContaining('1-week goal streak'), findsWidgets);
    expect(find.textContaining('Weekly goals met: 1 of 1'), findsOneWidget);
    await scrollTo(tester, find.text('This week'));
    expect(find.textContaining('across 2 hobbies'), findsOneWidget);
    expect(find.textContaining('76%'), findsOneWidget);
    expect(find.textContaining('day goal streak'), findsNothing);
  });

  appTest('a hobby reminder is scheduled, and turned off again', (
    tester,
    db,
  ) async {
    await openHobbies(tester);
    await openManageHobbies(tester);
    await tester.tap(find.text('Music'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reminder'));
    await tester.pumpAndSettle();
    expect(find.text('Weekly'), findsWidgets);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Weekly'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Fri'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    // Notification access is asked for first.
    expect(find.text('Allow notifications'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    final music = await _hobby(db, 'Music');
    expect(music.reminderEnabled, isTrue);
    final cfg = HobbyReminderConfig.fromJson(music.reminderConfig);
    expect(cfg.frequency, HobbyReminderFrequency.weekly);
    expect(cfg.weekday, DateTime.friday);
    final mine = testScheduler.scheduled.values
        .where((n) => isHobbyReminderId(n.id))
        .toList();
    expect(mine, isNotEmpty);
    expect(mine.every((n) => n.title == 'Time for Music'), isTrue);
    expect(mine.every((n) => n.at.weekday == DateTime.friday), isTrue);
    expect(find.textContaining('Fridays at'), findsOneWidget);

    // Off again.
    await tester.tap(find.text('Music'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reminder'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(
      testScheduler.scheduled.values.where((n) => isHobbyReminderId(n.id)),
      isEmpty,
    );
    expect(find.textContaining('Reminder off'), findsWidgets);
  });

  appTest(
    'Om chanting: set a target, Start, tap +1, ping at the target, save',
    (tester, db) async {
      final uid = await _userId(db);
      await HabitRepository(db, FixedClock(testNow)).create(
        userId: uid,
        name: 'chanting',
        kind: HabitKind.custom,
        dailyTarget: 108,
      );
      await openHobbies(tester);
      await scrollTo(tester, find.text('Om chanting'));
      await tester.tap(find.text('Om chanting'));
      await tester.pumpAndSettle();
      expect(find.text('Ready when you are'), findsOneWidget);
      expect(find.text('of 108'), findsOneWidget);
      expect(
        find.text('+1'),
        findsNothing,
        reason: 'counting starts with Start',
      );

      await tester.tap(find.byTooltip('Chant settings'));
      await tester.pumpAndSettle();
      expect(find.text('Count by listening'), findsOneWidget);
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile).first).value,
        isFalse,
        reason: 'listening is off by default',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Total chants'),
        '3',
      );
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10)); // close the sheet
      await tester.pumpAndSettle();
      expect(find.text('of 3'), findsOneWidget);

      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      expect(testChant.micRequests, 0);
      expect(find.text('Chanting'), findsOneWidget);
      expect(find.byTooltip('Chant settings'), findsOneWidget);
      await tester.tap(find.text('+1'));
      await tester.pump();
      await tester.tap(find.text('+1'));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
      await tester.tap(find.text('Undo one'));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
      await tester.tap(find.text('+1'));
      await tester.tap(find.text('+1'));
      await tester.pumpAndSettle();
      expect(testChant.announced, hasLength(1));
      expect(find.text('3 reached'), findsOneWidget);
      expect(find.text('Save this session?'), findsOneWidget);
      expect(find.text('Add to chanting habit'), findsOneWidget);

      // Also as a hobby.
      await tester.tap(find.byType(DropdownButtonFormField<String?>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reading').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save session'));
      await tester.pumpAndSettle();

      final habitLogs = await db.select(db.habitLogs).get();
      expect(habitLogs.fold<int>(0, (a, l) => a + l.count), 3);
      final hobbyLogs = await db.select(db.hobbyLogs).get();
      expect(hobbyLogs, hasLength(1));
      expect(hobbyLogs.single.note, contains('3 chants'));
      expect(find.text('Session saved.'), findsOneWidget);
      expect(find.text('Ready when you are'), findsOneWidget);
    },
    wrapApp: withFakeChant(),
  );

  appTest('Finish early and discard writes nothing', (tester, db) async {
    await openHobbies(tester);
    await scrollTo(tester, find.text('Om chanting'));
    await tester.tap(find.text('Om chanting'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+1'));
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Finish'), 100);
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(find.text('Finished'), findsOneWidget);
    expect(find.textContaining('Add a habit called Chanting'), findsOneWidget);
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(await db.select(db.habitLogs).get(), isEmpty);
    expect(await db.select(db.hobbyLogs).get(), isEmpty);
  }, wrapApp: withFakeChant());
}
