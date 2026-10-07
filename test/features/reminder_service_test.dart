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
      expect(scheduler.planned.first.title, 'Water break.');
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
      expect(p.snoozeCount, 0);
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

    test('Snooze schedules one notification 30 minutes later', () async {
      final (_, payload) = await setUpHabit();
      await act('snooze', payload, at: DateTime.utc(2026, 5, 13, 10, 2));
      expect(scheduler.snoozes.length, 1);
      expect(scheduler.snoozes.single.at, DateTime(2026, 5, 13, 10, 32));
      expect(
        ReminderPayload.decode(scheduler.snoozes.single.payload)!.snoozeCount,
        1,
      );
    });

    test('snoozes stop after two', () async {
      final (_, payload) = await setUpHabit();
      var at = DateTime.utc(2026, 5, 13, 10, 2);
      var current = payload;
      for (var i = 0; i < 3; i++) {
        await act('snooze', current, at: at);
        if (scheduler.snoozes.length > i) {
          current = scheduler.snoozes.last.payload;
        }
        at = at.add(const Duration(minutes: 31));
      }
      expect(scheduler.snoozes.length, 2);
    });

    test('a snooze is dropped once the target is met', () async {
      final (id, payload) = await setUpHabit();
      await act('snooze', payload, at: DateTime.utc(2026, 5, 13, 10, 2));
      expect(scheduler.snoozes.length, 1);

      final habit = (await habits.byId(id))!;
      await habits.log(habit: habit, dayCutoffMinutes: 0, count: 3);
      await service().reschedule();
      expect(scheduler.snoozes, isEmpty);
    });

    test('a plain tap does nothing', () async {
      final (id, payload) = await setUpHabit();
      await act(null, payload);
      expect(
        (await habits.logsBetween(id, '2026-05-13', '2026-05-13')),
        isEmpty,
      );
      expect(scheduler.snoozes, isEmpty);
    });

    test('a bad payload is ignored', () async {
      await act('log', 'not json');
      expect(await db.select(db.habitLogs).get(), isEmpty);
    });

    test('Log on a batched reminder logs every habit in it', () async {
      final a = await addHabit(name: 'Water', times: [10 * 60]);
      final b = await addHabit(
        name: 'Stand',
        kind: HabitKind.stand,
        times: [10 * 60 + 5],
      );
      await service().reschedule();
      final batched = scheduler.planned.first;
      expect(ReminderPayload.decode(batched.payload)!.habitIds.length, 2);

      await act('log', batched.payload);
      expect(
        (await habits.logsBetween(a, '2026-05-13', '2026-05-13')).length,
        1,
      );
      expect(
        (await habits.logsBetween(b, '2026-05-13', '2026-05-13')).length,
        1,
      );
    });
  });

  test('payload round trip', () {
    const p = ReminderPayload(
      habitIds: ['a', 'b'],
      habitNames: ['A', 'B'],
      kinds: ['water', 'stand'],
      priority: 1,
      snoozeCount: 2,
    );
    final back = ReminderPayload.decode(p.encode())!;
    expect(back.habitIds, ['a', 'b']);
    expect(back.snoozeCount, 2);
    expect(ReminderPayload.decode(null), isNull);
  });
}
