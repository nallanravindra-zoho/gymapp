import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/repositories/hobby_repository.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/features/hobbies/hobby_reminders.dart';
import 'package:wellbeing/features/reminders/notification_scheduler.dart';
import 'package:wellbeing/features/reminders/reminder_service.dart';

void main() {
  group('monthly day math', () {
    test('days in month incl. leap years', () {
      expect(daysInMonth(2026, 2), 28);
      expect(daysInMonth(2028, 2), 29);
      expect(daysInMonth(2026, 4), 30);
      expect(daysInMonth(2026, 12), 31);
    });

    test('day 31 falls back to the last day of shorter months', () {
      expect(monthlyReminderDay(2026, 1, 31), 31);
      expect(monthlyReminderDay(2026, 2, 31), 28);
      expect(monthlyReminderDay(2028, 2, 31), 29);
      expect(monthlyReminderDay(2026, 4, 31), 30);
      expect(monthlyReminderDay(2026, 2, 30), 28);
      expect(monthlyReminderDay(2026, 2, 29), 28);
      expect(monthlyReminderDay(2028, 2, 29), 29);
      expect(monthlyReminderDay(2026, 3, 15), 15);
    });

    test('monthly reminders over a year land on valid dates', () {
      const c = HobbyReminderConfig(
        frequency: HobbyReminderFrequency.monthly,
        dayOfMonth: 31,
        minuteOfDay: 9 * 60,
      );
      final times = <DateTime>[];
      var from = DateTime(2026, 1, 1);
      for (var i = 0; i < 12; i++) {
        times.addAll(upcomingReminderTimes(c, from).take(1));
        from = DateTime(2026, 1 + i + 1, 1);
      }
      expect(times.map((t) => t.day).toList(), [
        31,
        28,
        31,
        30,
        31,
        30,
        31,
        31,
        30,
        31,
        30,
        31,
      ]);
      expect(times.every((t) => t.hour == 9), isTrue);
    });

    test('monthly on the 30th in February', () {
      const c = HobbyReminderConfig(
        frequency: HobbyReminderFrequency.monthly,
        dayOfMonth: 30,
      );
      final next = nextReminderTime(c, DateTime(2026, 2, 1))!;
      expect(next, DateTime(2026, 2, 28, 18));
      expect(reminderOccursOn(c, DateTime(2026, 2, 27)), isFalse);
    });
  });

  group('daily and weekly', () {
    test('daily: later today if the time has not passed, else tomorrow', () {
      const c = HobbyReminderConfig(minuteOfDay: 18 * 60);
      expect(
        nextReminderTime(c, DateTime(2026, 5, 13, 10)),
        DateTime(2026, 5, 13, 18),
      );
      expect(
        nextReminderTime(c, DateTime(2026, 5, 13, 18)),
        DateTime(2026, 5, 14, 18),
      );
      expect(upcomingReminderTimes(c, DateTime(2026, 5, 13, 10)).length, 30);
    });

    test('weekly: the chosen weekday', () {
      const c = HobbyReminderConfig(
        frequency: HobbyReminderFrequency.weekly,
        weekday: DateTime.friday,
        minuteOfDay: 7 * 60 + 30,
      );
      final t = upcomingReminderTimes(c, DateTime(2026, 5, 13, 10));
      expect(t.first, DateTime(2026, 5, 15, 7, 30));
      expect(t[1], DateTime(2026, 5, 22, 7, 30));
      expect(t.every((d) => d.weekday == DateTime.friday), isTrue);
    });
  });

  group('biweekly', () {
    const c = HobbyReminderConfig(
      frequency: HobbyReminderFrequency.biweekly,
      startDate: '2026-05-20',
      minuteOfDay: 20 * 60,
    );

    test('first occurrence is the start date, then every 14 days', () {
      final t = upcomingReminderTimes(c, DateTime(2026, 5, 13, 10));
      expect(t.take(3).toList(), [
        DateTime(2026, 5, 20, 20),
        DateTime(2026, 6, 3, 20),
        DateTime(2026, 6, 17, 20),
      ]);
    });

    test('a start date in the past keeps the two-week rhythm', () {
      const past = HobbyReminderConfig(
        frequency: HobbyReminderFrequency.biweekly,
        startDate: '2026-04-01',
      );
      // 1 Apr + 14k: 15 Apr, 29 Apr, 13 May, 27 May.
      final t = nextReminderTime(past, DateTime(2026, 5, 13, 10))!;
      expect(t, DateTime(2026, 5, 13, 18));
      expect(
        nextReminderTime(past, DateTime(2026, 5, 13, 19)),
        DateTime(2026, 5, 27, 18),
      );
    });

    test('no start date means no occurrences', () {
      const none = HobbyReminderConfig(
        frequency: HobbyReminderFrequency.biweekly,
      );
      expect(upcomingReminderTimes(none, DateTime(2026, 5, 13)), isEmpty);
    });
  });

  group('config json', () {
    test('round trip and bad input', () {
      const c = HobbyReminderConfig(
        frequency: HobbyReminderFrequency.monthly,
        minuteOfDay: 415,
        weekday: 3,
        startDate: '2026-02-28',
        dayOfMonth: 31,
      );
      final back = HobbyReminderConfig.fromJson(c.toJson());
      expect(back.frequency, HobbyReminderFrequency.monthly);
      expect(back.minuteOfDay, 415);
      expect(back.dayOfMonth, 31);
      expect(back.startDate, '2026-02-28');
      final bad = HobbyReminderConfig.fromJson(
        '{"frequency":"x","minuteOfDay":5000,"startDate":"2026-13-40"}',
      );
      expect(bad.frequency, HobbyReminderFrequency.daily);
      expect(bad.minuteOfDay, 18 * 60);
      expect(bad.startDate, isNull);
      expect(HobbyReminderConfig.fromJson('{}').dayOfMonth, 1);
      expect(
        HobbyReminderConfig.fromJson('not json').frequency,
        HobbyReminderFrequency.daily,
      );
    });

    test('descriptions', () {
      expect(
        describeHobbyReminder(const HobbyReminderConfig()),
        'Daily at 6:00 PM',
      );
      expect(
        describeHobbyReminder(
          const HobbyReminderConfig(
            frequency: HobbyReminderFrequency.weekly,
            weekday: 2,
            minuteOfDay: 7 * 60 + 30,
          ),
        ),
        'Tuesdays at 7:30 AM',
      );
      expect(
        describeHobbyReminder(
          const HobbyReminderConfig(
            frequency: HobbyReminderFrequency.monthly,
            dayOfMonth: 31,
          ),
        ),
        contains('31st'),
      );
    });
  });

  group('service', () {
    late AppDatabase db;
    late FakeNotificationScheduler scheduler;
    late ReminderService service;
    late HobbyRepository repo;
    late String userId;
    final clock = FixedClock(DateTime.utc(2026, 5, 13, 10));

    setUp(() async {
      drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      scheduler = FakeNotificationScheduler(permitted: true);
      repo = HobbyRepository(db, clock);
      userId = (await UserRepository(db, clock).ensureUser()).id;
      service = ReminderService(db: db, clock: clock, scheduler: scheduler);
    });

    List<ScheduledNotification> hobbyOnes() => [
      for (final n in scheduler.scheduled.values)
        if (isHobbyReminderId(n.id)) n,
    ];

    test(
      'only hobbies with reminders on are scheduled, independently',
      () async {
        final a = await repo.addCustom(
          userId: userId,
          name: 'Painting',
          reminderEnabled: true,
          reminderConfig: const HobbyReminderConfig(
            frequency: HobbyReminderFrequency.weekly,
            weekday: 5,
          ).toJson(),
        );
        await repo.addCustom(userId: userId, name: 'Knitting');
        await service.reschedule();
        final got = hobbyOnes();
        expect(got, isNotEmpty);
        expect(got.every((n) => n.title == 'Time for Painting'), isTrue);
        expect(got.length, 8);

        // Turn it off: everything for it goes away.
        await repo.update(
          a,
          const HobbiesCompanion(reminderEnabled: drift.Value(false)),
        );
        await service.reschedule();
        expect(hobbyOnes(), isEmpty);
      },
    );

    test('rebuilding replaces, not duplicates, and archive stops it', () async {
      final id = await repo.addCustom(
        userId: userId,
        name: 'Singing',
        reminderEnabled: true,
      );
      await service.reschedule();
      await service.reschedule();
      expect(hobbyOnes().length, 30);
      await repo.archive(id);
      await service.reschedule();
      expect(hobbyOnes(), isEmpty);
    });

    test('no notification permission schedules nothing', () async {
      await repo.addCustom(
        userId: userId,
        name: 'Singing',
        reminderEnabled: true,
      );
      scheduler.permitted = false;
      await service.reschedule();
      expect(hobbyOnes(), isEmpty);
    });

    test('hobby reminders survive habit-reminder rebuilds', () async {
      await repo.addCustom(
        userId: userId,
        name: 'Singing',
        reminderEnabled: true,
      );
      await service.reschedule();
      await scheduler.cancelPlanned();
      expect(hobbyOnes(), isNotEmpty);
    });

    test('ids stay inside the hobby range and above habit snoozes', () {
      expect(hobbyReminderIdBase, greaterThan(snoozeIdBase));
      expect(hobbyReminderIdEnd, lessThan(testNotificationId));
    });
  });
}
