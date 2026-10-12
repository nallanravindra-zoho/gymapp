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

  group('separate reminders (no batching)', () {
    HabitReminderInput at(String id, int m, {int priority = 0}) => habit(
      id,
      priority: priority,
      config: ReminderConfig(mode: ReminderMode.times, times: [m]),
    );

    test('habits due within minutes of each other stay separate', () {
      final r = plan([at('water', 600), at('stand', 605, priority: 1)]);
      expect(r.length, 2);
      expect(r[0].habitIds, ['water']);
      expect(r[1].habitIds, ['stand']);
      expect(r.every((x) => x.habitIds.length == 1), isTrue);
    });

    test('habits due at the same minute are both kept, important first', () {
      final r = plan([at('b', 600, priority: 1), at('a', 600)]);
      expect(r.map((x) => x.habitIds.single), ['a', 'b']);
      expect(r.map((x) => x.at).toSet().length, 1);
    });

    test('every planned reminder is for exactly one habit', () {
      final r = plan([
        for (var i = 0; i < 4; i++) at('h$i', 600 + i, priority: i),
      ], cap: 20);
      expect(r.length, 4);
      for (final x in r) {
        expect(x.habitIds.length, 1);
        expect(x.habitNames.length, 1);
        expect(x.kinds.length, 1);
      }
    });
  });

  group('repeating schedules (R4)', () {
    ReminderConfig window(int from, int to, int every) =>
        ReminderConfig(windowStart: from, windowEnd: to, everyMinutes: every);

    test('12:00 to 17:00 hourly is six reminders, both ends included', () {
      final c = window(12 * 60, 17 * 60, 60);
      expect(c.minutesOfDay, [720, 780, 840, 900, 960, 1020]);
      expect(c.occurrences, 6);
      final r = plan(
        [habit('w', config: c)],
        at: DateTime(2026, 5, 13, 6),
        cap: 20,
      );
      expect(r.map((x) => x.at.hour), [12, 13, 14, 15, 16, 17]);
    });

    test('30 minute windows include the end', () {
      final c = window(9 * 60, 11 * 60, 30);
      expect(c.minutesOfDay, [540, 570, 600, 630, 660]);
      expect(c.occurrences, 5);
    });

    test('every offered interval counts occurrences, not hours', () {
      // 09:00 to 17:00.
      final counts = {
        for (final m in reminderIntervals)
          m: window(9 * 60, 17 * 60, m).occurrences,
      };
      expect(counts, {30: 17, 60: 9, 120: 5, 180: 3, 240: 3});
    });

    test('a window that ends off the step stops at the last step inside', () {
      expect(window(9 * 60, 10 * 60 + 45, 60).minutesOfDay, [540, 600]);
    });

    test('start equal to end is a single reminder', () {
      final c = window(9 * 60, 9 * 60, 60);
      expect(c.occurrences, 1);
      expect(c.problem, isNull);
    });

    test('end before start is invalid and plans nothing (no wrap)', () {
      final c = window(23 * 60, 6 * 60, 60);
      expect(c.windowReversed, isTrue);
      expect(c.problem, windowOrderMessage);
      expect(c.minutesOfDay, isEmpty);
      expect(
        plan([habit('w', config: c)], at: DateTime(2026, 5, 13, 0, 1), days: 3),
        isEmpty,
      );
    });

    test('reversed windows are only a problem when repeating', () {
      const c = ReminderConfig(
        mode: ReminderMode.times,
        times: [600],
        windowStart: 23 * 60,
        windowEnd: 6 * 60,
      );
      expect(c.windowReversed, isFalse);
      expect(c.problem, isNull);
    });

    test('problems: no times and no days', () {
      expect(
        const ReminderConfig(mode: ReminderMode.times).problem,
        'Add at least one reminder time.',
      );
      expect(
        const ReminderConfig(activeDays: {}).problem,
        'Choose at least one day.',
      );
      expect(const ReminderConfig().problem, isNull);
    });

    test('offered intervals are 30 minutes and 1 to 4 hours', () {
      expect(reminderIntervals, [30, 60, 120, 180, 240]);
    });

    test('hourly reminders respect quiet hours', () {
      final c = window(20 * 60, 23 * 60, 60); // 20, 21, 22, 23
      final r = plan([habit('w', config: c)], at: DateTime(2026, 5, 13, 6));
      expect(r.map((x) => x.at.hour), [20, 21]); // 22:00 onwards is quiet
    });

    test('hourly reminders respect the daily cap', () {
      final c = window(8 * 60, 18 * 60, 60); // eleven
      final r = plan(
        [habit('w', config: c)],
        at: DateTime(2026, 5, 13, 6),
        cap: 4,
        days: 2,
      );
      expect(r.length, 8);
      expect(r.where((x) => x.at.day == 13).length, 4);
      expect(r.where((x) => x.at.day == 14).length, 4);
    });

    test('a met target suppresses the rest of today only', () {
      final c = window(12 * 60, 17 * 60, 60);
      final r = plan(
        [habit('w', config: c)],
        at: DateTime(2026, 5, 13, 6),
        met: {'w'},
        days: 2,
        cap: 20,
      );
      expect(r.length, 6);
      expect(r.every((x) => x.at.day == 14), isTrue);
    });

    test('only the habit that met its target is suppressed', () {
      final c = window(12 * 60, 14 * 60, 60);
      final r = plan(
        [habit('a', config: c), habit('b', priority: 1, config: c)],
        at: DateTime(2026, 5, 13, 6),
        met: {'a'},
        cap: 20,
      );
      expect(r.map((x) => x.habitIds.single).toSet(), {'b'});
      expect(r.length, 3);
    });

    test('reminders are independent per habit', () {
      final r = plan([
        habit('a', config: window(9 * 60, 10 * 60, 60)),
        habit(
          'b',
          priority: 1,
          config: const ReminderConfig(
            mode: ReminderMode.times,
            times: [15 * 60],
          ),
        ),
      ], at: DateTime(2026, 5, 13, 6));
      expect(r.map((x) => '${x.habitIds.single}@${x.at.hour}'), [
        'a@9',
        'a@10',
        'b@15',
      ]);
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

  group('wording', () {
    PlannedReminder one(String kind, String name) => PlannedReminder(
      at: now,
      habitIds: ['x'],
      habitNames: [name],
      kinds: [kind],
      priority: 0,
    );

    test('matches the microcopy rules', () {
      expect(reminderText(one('water', 'Water')).title, 'Time for some water.');
      expect(
        reminderText(one('stand', 'Stand')).title,
        'Stand and move for a minute.',
      );
      expect(
        reminderText(one('stretch', 'Stretch')).title,
        'Time for a stretch.',
      );
      expect(
        reminderText(one('moisturize', 'Moisturize')).title,
        'Time to moisturize.',
      );
      expect(
        reminderText(one('skinCare', 'Skin care')).title,
        'Time for skin care.',
      );
      expect(reminderText(one('custom', 'Meditation')).title, 'Meditation.');
    });

    test('no exclamation marks and no snooze wording', () {
      for (final k in [
        'water',
        'stand',
        'stretch',
        'moisturize',
        'skinCare',
        'custom',
      ]) {
        final t = reminderText(one(k, 'Name')).title;
        expect(t.contains('!'), isFalse);
        expect(t.toLowerCase().contains('snooze'), isFalse);
      }
    });
  });
}
