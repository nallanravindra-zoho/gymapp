import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/repositories/habit_repository.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/data/tables/tables.dart';
import 'package:wellbeing/features/habits/reminder_config.dart';
import 'package:wellbeing/features/reminders/notification_scheduler.dart';
import 'package:wellbeing/features/reminders/reminder_actions.dart';
import 'package:wellbeing/features/reminders/reminder_service.dart';

void main() {
  late AppDatabase db;
  late FakeNotificationScheduler scheduler;
  late String userId;
  late HabitRepository habits;
  // Wednesday 13 May 2026, 08:00 in a UTC+0 device.
  final clock = FixedClock(DateTime.utc(2026, 5, 13, 8));

  ReminderService service() =>
      ReminderService(db: db, clock: clock, scheduler: scheduler);

  Future<String> addHabit({
    String name = 'Water',
    HabitKind kind = HabitKind.water,
    int target = 2,
    bool reminders = true,
    List<int> times = const [10 * 60, 14 * 60],
  }) => habits.create(
    userId: userId,
    name: name,
    kind: kind,
    dailyTarget: target,
    remindersEnabled: reminders,
    reminderConfig: ReminderConfig(
      mode: ReminderMode.times,
      times: times,
    ).toJson(),
  );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    scheduler = FakeNotificationScheduler();
    userId = (await UserRepository(db, clock).ensureUser()).id;
    habits = HabitRepository(db, clock);
  });

  tearDown(() => db.close());

  group('rescheduling', () {
    test('reminders are off by default: nothing is scheduled', () async {
      await addHabit(reminders: false);
      await service().reschedule();
      expect(scheduler.planned, isEmpty);
    });

    test('schedules enabled habits for the coming days', () async {
      await addHabit();
      await service().reschedule();
      expect(scheduler.planned.length, 14); // 2 per day for 7 days
      expect(scheduler.planned.first.at, DateTime(2026, 5, 13, 10));
      expect(scheduler.planned.first.title, 'Time for some water.');
    });

    test('nothing is scheduled without notification permission', () async {
      scheduler.permitted = false;
      await addHabit();
      await service().reschedule();
      expect(scheduler.planned, isEmpty);
    });

    test('rescheduling replaces rather than duplicates', () async {
      await addHabit();
      await service().reschedule();
      await service().reschedule();
      expect(scheduler.planned.length, 14);
    });

    test('meeting the target removes the rest of today only', () async {
      final id = await addHabit(target: 2);
      await service().reschedule();
      final habit = (await habits.byId(id))!;
      await habits.log(habit: habit, dayCutoffMinutes: 0, count: 2);
      await service().reschedule();

      expect(scheduler.planned.length, 12);
      expect(scheduler.planned.first.at.day, 14);
    });

    test('a deleted or disabled habit stops reminding', () async {
      final id = await addHabit();
      await service().reschedule();
      await habits.delete(id);
      await service().reschedule();
      expect(scheduler.planned, isEmpty);
    });

    test('respects the daily cap from settings', () async {
      await addHabit(name: 'A', times: [9 * 60, 11 * 60, 13 * 60]);
      await addHabit(
        name: 'B',
        kind: HabitKind.stand,
        times: [10 * 60, 12 * 60],
      );
      await UserRepository(
        db,
        clock,
      ).update(userId, const UsersCompanion(dailyReminderCap: Value(2)));
      await service().reschedule();
      final today = scheduler.planned.where((n) => n.at.day == 13);
      expect(today.length, lessThanOrEqualTo(2));
    });

    test('respects custom quiet hours', () async {
      await addHabit(times: [10 * 60, 14 * 60]);
      await UserRepository(db, clock).update(
        userId,
        const UsersCompanion(
          quietHoursStart: Value(13 * 60),
          quietHoursEnd: Value(15 * 60),
        ),
      );
      await service().reschedule();
      expect(scheduler.planned.every((n) => n.at.hour != 14), isTrue);
    });

    test('payload carries what the actions need', () async {
      final id = await addHabit();
      await service().reschedule();
      final p = ReminderPayload.decode(scheduler.planned.first.payload)!;
      expect(p.habitIds, [id]);
      expect(p.habitNames, ['Water']);
    });
  });

  group('upcoming reminders and test reminders', () {
    test(
      'lists the next reminders in time order with what is set up',
      () async {
        await addHabit(); // 10:00 and 14:00 daily; it is 08:00 on the 13th
        await service().reschedule();

        final u = await service().upcoming(limit: 3);
        expect(u.permitted, isTrue);
        expect(u.enabledHabits, 1);
        expect(u.totalPlanned, 14);
        expect(u.scheduledOnPhone, 14);
        expect(u.next.length, 3);
        expect(u.next.first.at, DateTime(2026, 5, 13, 10));
        expect(u.next[1].at, DateTime(2026, 5, 13, 14));
        expect(u.next[2].at, DateTime(2026, 5, 14, 10));
        expect(u.quietStart, 22 * 60);
        expect(u.quietEnd, 7 * 60);
      },
    );

    test('shows nothing planned when no habit has reminders on', () async {
      await addHabit(reminders: false);
      final u = await service().upcoming();
      expect(u.enabledHabits, 0);
      expect(u.next, isEmpty);
    });

    test('says when notifications are not allowed', () async {
      scheduler.permitted = false;
      await addHabit();
      final u = await service().upcoming();
      expect(u.permitted, isFalse);
      expect(u.scheduledOnPhone, 0);
      expect(u.totalPlanned, 14); // still shows what would be sent
    });

    test('reports when the phone has fewer scheduled than planned', () async {
      await addHabit();
      // Nothing rescheduled yet: planned but not set up.
      final u = await service().upcoming();
      expect(u.totalPlanned, 14);
      expect(u.scheduledOnPhone, 0);
    });

    test(
      'a test now is shown immediately and confirmed by the phone',
      () async {
        final r = await service().sendTest();
        expect(r.error, isNull);
        expect(r.noPermissionGiven, isFalse);
        expect(r.confirmed, isTrue);
        expect(scheduler.shown.single.title, 'Test reminder.');
        expect(scheduler.shown.single.id, testNotificationId);
      },
    );

    test('a test the phone swallows is reported as not confirmed', () async {
      scheduler.phoneHidesNotifications = true;
      final r = await service().sendTest();
      expect(r.confirmed, isFalse);
      expect(r.error, isNull);
    });

    test('a failure to show is reported with its reason', () async {
      scheduler.showError = Exception('channel blocked');
      final r = await service().sendTest();
      expect(r.error, contains('channel blocked'));
      expect(r.confirmed, isFalse);
    });

    test('a test in a minute is scheduled and the alarm confirmed', () async {
      final r = await service().sendTest(delay: const Duration(minutes: 1));
      expect(r.at, DateTime(2026, 5, 13, 8, 1));
      expect(r.confirmed, isTrue);
      expect(scheduler.testScheduled!.at, DateTime(2026, 5, 13, 8, 1));
      expect(scheduler.shown, isEmpty);
    });

    test('a scheduled test that cannot be registered is reported', () async {
      scheduler.scheduleError = Exception('alarm refused');
      final r = await service().sendTest(delay: const Duration(minutes: 1));
      expect(r.error, contains('alarm refused'));
    });

    test('no test without notification permission', () async {
      scheduler.permitted = false;
      final now = await service().sendTest();
      final later = await service().sendTest(delay: const Duration(minutes: 1));
      expect(now.noPermissionGiven, isTrue);
      expect(later.noPermissionGiven, isTrue);
      expect(scheduler.shown, isEmpty);
      expect(scheduler.testScheduled, isNull);
    });

    test('a pending test survives rescheduling', () async {
      await service().sendTest(delay: const Duration(minutes: 1));
      await addHabit();
      await service().reschedule();
      expect(scheduler.testScheduled, isNotNull);
      expect(scheduler.planned.length, 14);
    });

    test(
      'a scheduling failure is kept and shown, then cleared on success',
      () async {
        await addHabit();
        // One service for the whole test, as the app has.
        final svc = service();
        scheduler.scheduleError = Exception('alarm refused');
        await svc.reschedule(); // must not throw
        var u = await svc.upcoming();
        expect(u.problem, contains('alarm refused'));
        expect(u.scheduledOnPhone, 0);

        scheduler.scheduleError = null;
        await svc.reschedule();
        u = await svc.upcoming();
        expect(u.problem, isNull);
        expect(u.scheduledOnPhone, 14);
      },
    );

    test('the phone\'s notification state is passed through', () async {
      scheduler.channelLevel = 'Low';
      final u = await service().upcoming();
      expect(u.diagnostics.channelLevel, 'Low');
      expect(u.diagnostics.enabled, isTrue);
    });

    test('tapping Log or Skip on a test does nothing', () async {
      await service().sendTest();
      final payload = scheduler.shown.single.payload;
      await handleReminderAction(
        actionId: 'log',
        payload: payload,
        db: db,
        clock: clock,
        scheduler: scheduler,
      );
      await handleReminderAction(
        actionId: 'skip',
        payload: payload,
        db: db,
        clock: clock,
        scheduler: scheduler,
      );
      expect(await db.select(db.habitLogs).get(), isEmpty);
      expect(await db.select(db.habitSkips).get(), isEmpty);
    });
  });

  group('notification actions', () {
    Future<(String, String)> setUpHabit() async {
      final id = await addHabit(target: 3);
      await service().reschedule();
      return (id, scheduler.planned.first.payload);
    }

    Future<void> act(String? action, String payload, {DateTime? at}) =>
        handleReminderAction(
          actionId: action,
          payload: payload,
          db: db,
          clock: at == null ? clock : FixedClock(at),
          scheduler: scheduler,
        );

    test('Log adds one completion and reschedules', () async {
      final (id, payload) = await setUpHabit();
      await act('log', payload);
      final logs = await habits.logsBetween(id, '2026-05-13', '2026-05-13');
      expect(logs.length, 1);
      expect(logs.single.count, 1);
    });

    test('Log that meets the target silences the rest of today', () async {
      final (id, payload) = await setUpHabit();
      await act('log', payload);
      await act('log', payload);
      await act('log', payload); // 3 of 3
      expect(scheduler.planned.every((n) => n.at.day != 13), isTrue);
      expect(
        (await habits.logsBetween(id, '2026-05-13', '2026-05-13')).length,
        3,
      );
    });

    Future<int> skips(String id) async =>
        (await habits.skipsForDate(userId, '2026-05-13', habitId: id)).length;

    Future<int> logged(String id) async => (await habits.logsBetween(
      id,
      '2026-05-13',
      '2026-05-13',
    )).fold<int>(0, (n, l) => n + l.count);

    test('Skip records a skip and never a completion', () async {
      final (id, payload) = await setUpHabit();
      await act('skip', payload);
      expect(await skips(id), 1);
      expect(await logged(id), 0);
    });

    test('Skip does not count towards the target or change the plan', () async {
      final (id, payload) = await setUpHabit(); // target 3
      final before = scheduler.planned.length;
      await act('skip', payload);
      await act('skip', payload);
      await act('skip', payload);
      await act('skip', payload);
      expect(await skips(id), 4);
      expect(await logged(id), 0);
      // Still not met: the rest of today's reminders are still planned.
      await service().reschedule();
      expect(scheduler.planned.length, before);
      expect(scheduler.planned.any((n) => n.at.day == 13), isTrue);
    });

    test('Skip then Log: only the Log counts', () async {
      final (id, payload) = await setUpHabit();
      await act('skip', payload);
      await act('log', payload);
      expect(await skips(id), 1);
      expect(await logged(id), 1);
    });

    test('Skip leaves other habits untouched', () async {
      final (id, payload) = await setUpHabit();
      final other = await addHabit(
        name: 'Stand',
        kind: HabitKind.stand,
        times: [11 * 60],
      );
      await act('skip', payload);
      expect(await skips(id), 1);
      expect(await skips(other), 0);
    });

    test('Skip for a deleted habit does nothing', () async {
      final (id, payload) = await setUpHabit();
      await habits.delete(id);
      await act('skip', payload);
      expect(await db.select(db.habitSkips).get(), isEmpty);
    });

    test('a dismissed reminder records nothing', () async {
      final (id, payload) = await setUpHabit();
      // Dismissing sends no action; a tap on the body has no action id.
      await act(null, payload);
      expect(await skips(id), 0);
      expect(await logged(id), 0);
      // The habit can still be logged in the app.
      await habits.log(habit: (await habits.byId(id))!, dayCutoffMinutes: 0);
      expect(await logged(id), 1);
    });

    test('the old Snooze action is ignored', () async {
      final (id, payload) = await setUpHabit();
      await act('snooze', payload, at: DateTime.utc(2026, 5, 13, 10, 2));
      expect(await skips(id), 0);
      expect(await logged(id), 0);
      expect(scheduler.scheduled.keys.every((k) => k < plannedIdLimit), isTrue);
    });

    test('a plain tap does nothing', () async {
      final (id, payload) = await setUpHabit();
      await act(null, payload);
      expect(await logged(id), 0);
      expect(await skips(id), 0);
    });

    test('a bad payload is ignored', () async {
      await act('log', 'not json');
      expect(await db.select(db.habitLogs).get(), isEmpty);
    });

    test(
      'Log on one habit does not log another due at the same time',
      () async {
        final a = await addHabit(name: 'Water', times: [10 * 60]);
        final b = await addHabit(
          name: 'Stand',
          kind: HabitKind.stand,
          times: [10 * 60],
        );
        await service().reschedule();
        final todays = scheduler.planned.where((n) => n.at.day == 13).toList();
        expect(todays.length, 2); // two notifications, not one
        final water = todays.firstWhere(
          (n) => ReminderPayload.decode(n.payload)!.habitIds.single == a,
        );
        await act('log', water.payload);
        expect(await logged(a), 1);
        expect(await logged(b), 0);
      },
    );
  });

  group('separate notifications and settings', () {
    test(
      'each habit gets its own notification, even at the same time',
      () async {
        await addHabit(name: 'Water', times: [10 * 60]);
        await addHabit(
          name: 'Stand',
          kind: HabitKind.stand,
          times: [10 * 60 + 5],
        );
        await service().reschedule();
        final today = scheduler.planned.where((n) => n.at.day == 13).toList();
        expect(today.length, 2);
        for (final n in today) {
          expect(ReminderPayload.decode(n.payload)!.habitIds.length, 1);
        }
        expect(today.map((n) => n.title), [
          'Time for some water.',
          'Stand and move for a minute.',
        ]);
      },
    );

    test('hourly 12 to 5 is six notifications a day', () async {
      await habits.create(
        userId: userId,
        name: 'Water',
        kind: HabitKind.water,
        dailyTarget: 6,
        remindersEnabled: true,
        reminderConfig: const ReminderConfig(
          windowStart: 12 * 60,
          windowEnd: 17 * 60,
          everyMinutes: 60,
        ).toJson(),
      );
      await service().reschedule();
      final today = scheduler.planned.where((n) => n.at.day == 13);
      expect(today.map((n) => n.at.hour), [12, 13, 14, 15, 16, 17]);
    });

    test('a reversed window schedules nothing', () async {
      await habits.create(
        userId: userId,
        name: 'Water',
        kind: HabitKind.water,
        remindersEnabled: true,
        reminderConfig: const ReminderConfig(
          windowStart: 23 * 60,
          windowEnd: 6 * 60,
          everyMinutes: 60,
        ).toJson(),
      );
      await service().reschedule();
      expect(scheduler.planned, isEmpty);
    });

    test('quiet hours and the cap both apply to a repeating habit', () async {
      await habits.create(
        userId: userId,
        name: 'Water',
        kind: HabitKind.water,
        remindersEnabled: true,
        reminderConfig: const ReminderConfig(
          windowStart: 8 * 60,
          windowEnd: 20 * 60,
          everyMinutes: 60,
        ).toJson(),
      );
      await UserRepository(db, clock).update(
        userId,
        const UsersCompanion(
          quietHoursStart: Value(12 * 60),
          quietHoursEnd: Value(14 * 60),
          dailyReminderCap: Value(3),
        ),
      );
      await service().reschedule();
      final today = scheduler.planned.where((n) => n.at.day == 13).toList();
      expect(today.length, 3);
      expect(today.every((n) => n.at.hour < 12 || n.at.hour >= 14), isTrue);
    });

    test('preferences survive revoked permission and resume after', () async {
      final id = await addHabit();
      scheduler.permitted = false;
      await service().reschedule();
      expect(scheduler.planned, isEmpty);
      // The habit and its settings are untouched.
      final h = (await habits.byId(id))!;
      expect(h.remindersEnabled, isTrue);
      expect(ReminderConfig.fromJson(h.reminderConfig).times, [600, 840]);
      // Logging in the app still works.
      await habits.log(habit: h, dayCutoffMinutes: 0);
      expect(
        (await habits.logsBetween(id, '2026-05-13', '2026-05-13')).length,
        1,
      );
      // Permission comes back: a fresh service (as after a restart or boot)
      // rebuilds everything from the stored preferences.
      scheduler.permitted = true;
      await ReminderService(
        db: db,
        clock: clock,
        scheduler: scheduler,
      ).reschedule();
      expect(scheduler.planned.length, 14);
    });

    test('a preference change is picked up on the next reschedule', () async {
      final id = await addHabit();
      await service().reschedule();
      expect(scheduler.planned.length, 14);
      await habits.update(
        id,
        HabitsCompanion(
          reminderConfig: Value(
            const ReminderConfig(
              mode: ReminderMode.times,
              times: [11 * 60],
            ).toJson(),
          ),
        ),
      );
      await service().reschedule();
      expect(scheduler.planned.length, 7);
      expect(scheduler.planned.every((n) => n.at.hour == 11), isTrue);
    });

    test('the chosen reminder sound is passed to the scheduler', () async {
      await addHabit();
      await service().reschedule();
      expect(scheduler.sound, isNull); // phone default
      await UserRepository(db, clock).update(
        userId,
        const UsersCompanion(reminderSound: Value('content://media/chime')),
      );
      await service().reschedule();
      expect(scheduler.sound, 'content://media/chime');
      await UserRepository(
        db,
        clock,
      ).update(userId, const UsersCompanion(reminderSound: Value(null)));
      await service().reschedule();
      expect(scheduler.sound, isNull);
      expect(scheduler.soundChanges, 2);
    });

    test('hobby-range ids above the planned range are left alone', () async {
      await scheduler.schedule(
        ScheduledNotification(
          id: plannedIdLimit + 10,
          at: DateTime(2026, 5, 14, 9),
          title: 'Hobby',
          payload: '{}',
        ),
      );
      await addHabit();
      await service().reschedule();
      expect(scheduler.scheduled.containsKey(plannedIdLimit + 10), isTrue);
    });
  });

  test('payload round trip', () {
    const p = ReminderPayload(
      habitIds: ['a', 'b'],
      habitNames: ['A', 'B'],
      kinds: ['water', 'stand'],
      priority: 1,
    );
    final back = ReminderPayload.decode(p.encode())!;
    expect(back.habitIds, ['a', 'b']);
    expect(back.habitNames, ['A', 'B']);
    expect(ReminderPayload.decode(null), isNull);
  });
}
