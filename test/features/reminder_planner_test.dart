import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/features/habits/reminder_config.dart';
import 'package:wellbeing/features/reminders/reminder_planner.dart';

HabitReminderInput habit(
  String id, {
  String kind = 'water',
  int priority = 0,
  ReminderConfig? config,
}) => HabitReminderInput(
  id: id,
  name: id,
  kind: kind,
  priority: priority,
  config:
      config ??
      const ReminderConfig(mode: ReminderMode.times, times: [10 * 60, 14 * 60]),
);

// Wednesday 13 May 2026, 08:00 local.
final now = DateTime(2026, 5, 13, 8);

List<PlannedReminder> plan(
  List<HabitReminderInput> hs, {
  Set<String> met = const {},
  int cap = 6,
  int days = 1,
  DateTime? at,
  int quietStart = 22 * 60,
  int quietEnd = 7 * 60,
}) => planReminders(
  habits: hs,
  now: at ?? now,
  metToday: met,
  cap: cap,
  days: days,
  quietStart: quietStart,
  quietEnd: quietEnd,
);

void main() {
  group('config', () {
    test('interval expands to times inside the window', () {
      const c = ReminderConfig(
        windowStart: 9 * 60,
        windowEnd: 17 * 60,
        everyMinutes: 120,
      );
      expect(c.minutesOfDay, [540, 660, 780, 900, 1020]);
    });

    test('fixed times are sorted and de-duplicated', () {
      const c = ReminderConfig(
        mode: ReminderMode.times,
        times: [840, 600, 600],
      );
      expect(c.minutesOfDay, [600, 840]);
    });

    test('JSON round trip', () {
      const c = ReminderConfig(
        mode: ReminderMode.times,
        times: [600, 900],
        activeDays: {1, 3, 5},
      );
      final back = ReminderConfig.fromJson(c.toJson());
      expect(back.mode, ReminderMode.times);
      expect(back.times, [600, 900]);
      expect(back.activeDays, {1, 3, 5});
    });

    test('bad JSON falls back to defaults', () {
      expect(ReminderConfig.fromJson('nope').mode, ReminderMode.interval);
      expect(ReminderConfig.fromJson('{}').everyMinutes, 120);
      expect(ReminderConfig.fromJson(null).activeDays.length, 7);
    });
  });

  group('quiet hours', () {
    test('window crossing midnight', () {
      expect(inQuietHours(23 * 60, 22 * 60, 7 * 60), isTrue);
      expect(inQuietHours(3 * 60, 22 * 60, 7 * 60), isTrue);
      expect(inQuietHours(7 * 60, 22 * 60, 7 * 60), isFalse);
      expect(inQuietHours(12 * 60, 22 * 60, 7 * 60), isFalse);
    });

    test('same-day window and empty window', () {
      expect(inQuietHours(13 * 60, 12 * 60, 14 * 60), isTrue);
      expect(inQuietHours(15 * 60, 12 * 60, 14 * 60), isFalse);
      expect(inQuietHours(3 * 60, 0, 0), isFalse);
    });

    test('reminders inside quiet hours are dropped', () {
      final h = habit(
        'w',
        config: const ReminderConfig(
          mode: ReminderMode.times,
          times: [6 * 60, 10 * 60, 23 * 60],
        ),
      );
      final r = plan([h], at: DateTime(2026, 5, 13, 0, 30));
      expect(r.map((x) => x.at.hour), [10]);
    });
  });

  group('filters', () {
    test('past times today are skipped', () {
      final r = plan([habit('w')], at: DateTime(2026, 5, 13, 12));
      expect(r.map((x) => x.at.hour), [14]);
    });

    test('target already met suppresses today only', () {
      final r = plan([habit('w')], met: {'w'}, days: 2);
      expect(r.every((x) => x.at.day == 14), isTrue);
      expect(r.length, 2);
    });

    test('active days are respected', () {
      // Wednesday is weekday 3; allow only Thursday and Friday.
      final h = habit(
        'w',
        config: const ReminderConfig(
          mode: ReminderMode.times,
          times: [600],
          activeDays: {4, 5},
        ),
      );
      final r = plan([h], days: 3);
      expect(r.map((x) => x.at.day), [14, 15]);
    });

    test('a habit with no active days plans nothing', () {
      final h = habit(
        'w',
        config: const ReminderConfig(
          mode: ReminderMode.times,
          times: [600],
          activeDays: {},
        ),
      );
      expect(plan([h], days: 7), isEmpty);
    });

    test('plans several days ahead', () {
      expect(plan([habit('w')], days: 7).length, 14);
    });
  });

  group('batching', () {
    test('reminders within 15 minutes become one notification', () {
      final a = habit(
        'water',
        priority: 0,
        config: const ReminderConfig(mode: ReminderMode.times, times: [600]),
      );
      final b = habit(
        'stand',
        kind: 'stand',
        priority: 1,
        config: const ReminderConfig(mode: ReminderMode.times, times: [610]),
      );
      final r = plan([a, b]);
      expect(r.length, 1);
      expect(r.single.habitIds, ['water', 'stand']);
      expect(r.single.at.minute, 0); // fires at the first time
    });

    test('exactly 15 minutes apart still batches; 16 does not', () {
      HabitReminderInput at(String id, int m) => habit(
        id,
        config: ReminderConfig(mode: ReminderMode.times, times: [m]),
      );
      expect(plan([at('a', 600), at('b', 615)]).length, 1);
      expect(plan([at('a', 600), at('b', 616)]).length, 2);
    });

    test('batch window is measured from the first reminder', () {
      HabitReminderInput at(String id, int m) => habit(
        id,
        config: ReminderConfig(mode: ReminderMode.times, times: [m]),
      );
      // 10:00, 10:10, 10:20: the third is 20 minutes after the first.
      expect(plan([at('a', 600), at('b', 610), at('c', 620)]).length, 2);
    });

    test('batched wording uses one neutral title', () {
      final a = habit(
        'Water',
        config: const ReminderConfig(mode: ReminderMode.times, times: [600]),
      );
      final b = habit(
        'Stand',
        kind: 'stand',
        config: const ReminderConfig(mode: ReminderMode.times, times: [605]),
      );
      final t = reminderText(plan([a, b]).single);
      expect(t.title, 'Break time.');
      expect(t.body, 'Water, Stand');
    });
  });

  group('daily cap', () {
    List<HabitReminderInput> many() => [
      for (var i = 0; i < 4; i++)
        habit(
          'h$i',
          priority: i,
          config: ReminderConfig(
            mode: ReminderMode.times,
            times: [9 * 60 + i * 60, 14 * 60 + i * 60],
          ),
        ),
    ];

    test('never exceeds the cap per day', () {
      final r = plan(many(), cap: 6, days: 2);
      for (final day in [13, 14]) {
        expect(r.where((x) => x.at.day == day).length, lessThanOrEqualTo(6));
      }
    });

    test('drops the lowest priority first', () {
      final r = plan(many(), cap: 4);
      expect(r.length, 4);
      // 8 planned; the four most important habits (priority 0 and 1) stay.
      expect(r.every((x) => x.priority <= 1), isTrue);
    });

    test('a lower cap is respected', () {
      expect(plan(many(), cap: 1).length, 1);
      expect(plan(many(), cap: 0), isEmpty);
    });

    test('under the cap nothing is dropped', () {
      expect(plan(many(), cap: 20).length, 8);
    });
  });

  group('snooze', () {
    PlannedReminder original({int snoozes = 0}) => PlannedReminder(
      at: DateTime(2026, 5, 13, 10),
      habitIds: const ['a', 'b'],
      habitNames: const ['A', 'B'],
      kinds: const ['water', 'stand'],
      priority: 0,
      snoozeCount: snoozes,
    );

    test('schedules 30 minutes from now and counts the snooze', () {
      final s = planSnooze(
        original: original(),
        now: DateTime(2026, 5, 13, 10, 5),
        metToday: {},
      );
      expect(s!.at, DateTime(2026, 5, 13, 10, 35));
      expect(s.snoozeCount, 1);
    });

    test('capped at two snoozes', () {
      final now = DateTime(2026, 5, 13, 10);
      expect(
        planSnooze(
          original: original(snoozes: 1),
          now: now,
          metToday: {},
        )!.snoozeCount,
        2,
      );
      expect(
        planSnooze(original: original(snoozes: 2), now: now, metToday: {}),
        isNull,
      );
    });

    test('not into quiet hours', () {
      expect(
        planSnooze(
          original: original(),
          now: DateTime(2026, 5, 13, 21, 45),
          metToday: {},
        ),
        isNull,
      );
    });

    test('drops habits whose target is met, and nothing if all are', () {
      final now = DateTime(2026, 5, 13, 10);
      final one = planSnooze(original: original(), now: now, metToday: {'a'});
      expect(one!.habitIds, ['b']);
      expect(
        planSnooze(original: original(), now: now, metToday: {'a', 'b'}),
        isNull,
      );
    });
  });

  group('wording', () {
    PlannedReminder one(String kind, String name) => PlannedReminder(
      at: now,
      habitIds: ['x'],
      habitNames: [name],
      kinds: [kind],
      priority: 0,
    );

    test('matches the microcopy rules', () {
      expect(reminderText(one('water', 'Water')).title, 'Water break.');
      expect(
        reminderText(one('stand', 'Stand')).title,
        'Stand and move for a minute.',
      );
      expect(reminderText(one('stretch', 'Stretch')).title, 'Stretch break.');
      expect(reminderText(one('custom', 'Read')).title, 'Read.');
    });

    test('no exclamation marks anywhere', () {
      for (final k in ['water', 'stand', 'stretch', 'custom']) {
        expect(reminderText(one(k, 'Name')).title.contains('!'), isFalse);
      }
    });
  });
}
