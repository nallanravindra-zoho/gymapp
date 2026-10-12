import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:wellbeing/core/time/local_date.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/repositories/badge_repository.dart';
import 'package:wellbeing/data/tables/tables.dart';
import 'package:wellbeing/features/hobbies/hobby_logic.dart';
import 'package:wellbeing/features/streaks/category_streaks.dart';
import 'package:wellbeing/features/streaks/streak_engine.dart';
import 'package:wellbeing/features/streaks/streak_snapshot.dart';

import 'streak_snapshot_test.dart' show w;

const today = '2026-05-13';
final t0 = DateTime.utc(2026, 5, 13);

String ago(int n) => shiftLocalDate(today, -n);

Habit habit(String id, {int target = 1, bool active = true}) => Habit(
  id: id,
  createdAt: t0,
  updatedAt: t0,
  userId: 'u',
  name: id,
  kind: HabitKind.water,
  dailyTarget: target,
  remindersEnabled: false,
  reminderConfig: '{}',
  isActive: active,
);

HabitLog hlog(
  String habitId,
  String date, {
  int count = 1,
  bool dead = false,
}) => HabitLog(
  id: '$habitId$date${count}x',
  createdAt: t0,
  updatedAt: t0,
  deletedAt: dead ? t0 : null,
  habitId: habitId,
  userId: 'u',
  loggedAt: t0,
  count: count,
  tzOffsetMinutes: 0,
  localDate: date,
);

SleepLog slog(String date, int minutes, {bool dead = false}) => SleepLog(
  id: 's$date',
  createdAt: t0,
  updatedAt: t0,
  deletedAt: dead ? t0 : null,
  userId: 'u',
  bedtimeAt: t0,
  wakeAt: t0.add(Duration(minutes: minutes)),
  durationMinutes: minutes,
  tzOffsetMinutes: 0,
  localDate: date,
);

void main() {
  group('workout category streak', () {
    CategoryStreak run(Iterable<int> daysAgo) => workoutCategoryStreak(
      workouts: [for (final d in daysAgo) w('yoga', ago(d), 30)],
      today: today,
    );

    test('consecutive days including today', () {
      final s = run([0, 1, 2]);
      expect((s.current, s.longest), (3, 3));
    });

    test('today still open does not break yesterday streak', () {
      expect(run([1, 2, 3]).current, 3);
    });

    test('a missed past day breaks the current run, longest is kept', () {
      final s = run([0, 1, 3, 4, 5, 6]);
      expect((s.current, s.longest), (2, 4));
    });

    test('several workouts one day count once', () {
      final s = workoutCategoryStreak(
        workouts: [w('yoga', today, 30), w('run', today, 20)],
        today: today,
      );
      expect(s.current, 1);
    });

    test('empty', () {
      expect(run([]).current, 0);
      expect(run([]).longest, 0);
    });

    test('deleted workouts do not count', () {
      final dead = Workout(
        id: 'd',
        createdAt: t0,
        updatedAt: t0,
        deletedAt: t0,
        userId: 'u',
        workoutTypeId: 'yoga',
        startedAt: t0,
        endedAt: t0,
        durationMinutes: 30,
        intensity: null,
        note: null,
        source: WorkoutSource.manual,
        tzOffsetMinutes: 0,
        localDate: ago(1),
        pausedSeconds: 0,
      );
      final s = workoutCategoryStreak(
        workouts: [w('yoga', today, 30), dead],
        today: today,
      );
      expect(s.current, 1);
    });

    test('edit that moves a workout to another day updates the streak', () {
      expect(run([0, 1, 2]).current, 3);
      expect(run([0, 2, 3]).current, 1); // the middle one moved a day later
    });

    test('rest days and freeze never leak into category streaks', () {
      final ws = [
        w('yoga', ago(3), 30),
        w('yoga', ago(1), 30),
        w('yoga', today, 30),
      ];
      // Overall: rest day on ago(2) bridges and extends nothing but keeps it.
      final snap = buildSnapshot(
        workouts: ws,
        restDates: {ago(2)},
        today: today,
        freezeEnabled: true,
        freezeIntervalDays: 7,
      );
      expect(snap.overall.current, 3);
      final cat = workoutCategoryStreak(workouts: ws, today: today);
      expect(cat.current, 2);
      expect(cat.longest, 2);
      // Same for a freeze: ago(2) missed with freeze on keeps overall alive.
      final withFreeze = buildSnapshot(
        workouts: [w('yoga', ago(3), 30), w('yoga', ago(1), 30)],
        restDates: {},
        today: today,
        freezeEnabled: true,
        freezeIntervalDays: 7,
      );
      expect(withFreeze.overall.current, 2);
      expect(
        workoutCategoryStreak(
          workouts: [w('yoga', ago(3), 30), w('yoga', ago(1), 30)],
          today: today,
        ).current,
        1,
      );
    });

    test(
      'midnight cutoff: 01:30 with a 2 h cutoff belongs to the day before',
      () {
        final late = DateTime.utc(2026, 5, 13, 1, 30);
        final d = localDateOf(late, offsetMinutes: 0, cutoffMinutes: 120);
        expect(d, '2026-05-12');
        final s = workoutCategoryStreak(
          workouts: [
            w('yoga', '2026-05-11', 30),
            w('yoga', d, 30),
            w('yoga', today, 30),
          ],
          today: today,
        );
        expect(s.current, 3);
        // Without the cutoff that late session would be on the 13th: a gap.
        final noCutoff = localDateOf(late, offsetMinutes: 0);
        expect(noCutoff, '2026-05-13');
      },
    );

    test('timezone: stored local dates decide, not UTC', () {
      // 23:30 UTC on the 12th is already the 13th at UTC+2.
      final i = DateTime.utc(2026, 5, 12, 23, 30);
      expect(localDateOf(i, offsetMinutes: 120), '2026-05-13');
      expect(localDateOf(i, offsetMinutes: -300), '2026-05-12');
      final s = workoutCategoryStreak(
        workouts: [
          w('yoga', '2026-05-12', 30),
          w('yoga', localDateOf(i, offsetMinutes: 120), 30),
        ],
        today: today,
      );
      expect(s.current, 2);
    });

    test('month and year boundaries', () {
      final s = strictDayStreak(StreakCategory.workout, {
        '2025-12-30',
        '2025-12-31',
        '2026-01-01',
      }, '2026-01-01');
      expect(s.current, 3);
    });
  });

  group('healthy habits category streak', () {
    test('at least one habit meeting its target counts the day', () {
      final habits = [habit('water', target: 3), habit('stretch', target: 2)];
      final logs = [
        hlog('water', today, count: 3),
        hlog('stretch', today, count: 1), // not met alone
        hlog('stretch', ago(1), count: 2), // met, water not logged
        hlog('water', ago(2), count: 2), // neither met
      ];
      final met = habitTargetMetDates(habits: habits, logs: logs);
      expect(met, {today, ago(1)});
      final s = habitsCategoryStreak(habits: habits, logs: logs, today: today);
      expect((s.current, s.longest), (2, 2));
    });

    test('counts add up across several logs in a day', () {
      final habits = [habit('water', target: 3)];
      final logs = [
        hlog('water', today, count: 1),
        HabitLog(
          id: 'other',
          createdAt: t0,
          updatedAt: t0,
          habitId: 'water',
          userId: 'u',
          loggedAt: t0,
          count: 2,
          tzOffsetMinutes: 0,
          localDate: today,
        ),
      ];
      expect(habitTargetMetDates(habits: habits, logs: logs), {today});
    });

    test('inactive habits and deleted logs are ignored', () {
      final habits = [habit('a'), habit('b', active: false)];
      final logs = [
        hlog('a', today, dead: true),
        hlog('b', today),
        hlog('b', ago(1)),
      ];
      expect(habitTargetMetDates(habits: habits, logs: logs), isEmpty);
    });

    test('a gap breaks it; rest days and freeze are not applied', () {
      final habits = [habit('a')];
      final logs = [hlog('a', today), hlog('a', ago(2)), hlog('a', ago(3))];
      final s = habitsCategoryStreak(habits: habits, logs: logs, today: today);
      expect((s.current, s.longest), (1, 2));
    });

    test('a zero target is treated as one', () {
      expect(
        habitTargetMetDates(
          habits: [habit('a', target: 0)],
          logs: [hlog('a', today)],
        ),
        {today},
      );
    });

    test('per-habit streaks still use their own target', () {
      // The existing habitStreak is untouched by the aggregate.
      final h = habit('a', target: 2);
      final logs = [hlog('a', today, count: 1)];
      expect(
        habitsCategoryStreak(habits: [h], logs: logs, today: today).current,
        0,
      );
    });
  });

  group('sleep target category streak', () {
    test('target is the bedtime to wake window, across midnight', () {
      expect(
        sleepTargetMinutes(
          bedtimeMinutes: 22 * 60 + 30,
          wakeMinutes: 6 * 60 + 30,
        ),
        480,
      );
      expect(sleepTargetMinutes(bedtimeMinutes: 60, wakeMinutes: 7 * 60), 360);
      expect(sleepTargetMinutes(bedtimeMinutes: 100, wakeMinutes: 100), 1440);
    });

    test('consecutive wake dates at or above target', () {
      final s = sleepCategoryStreak(
        logs: [
          slog(today, 480),
          slog(ago(1), 500),
          slog(ago(2), 479),
          slog(ago(3), 600),
        ],
        targetMinutes: 480,
        today: today,
      );
      expect((s.current, s.longest), (2, 2));
    });

    test(
      'duration counts, schedule does not: long sleep at odd times counts',
      () {
        // bedtimeAt/wakeAt are far from any schedule but duration is enough.
        final s = sleepCategoryStreak(
          logs: [slog(today, 540)],
          targetMinutes: 480,
          today: today,
        );
        expect(s.current, 1);
      },
    );

    test('on schedule but short does not count', () {
      final s = sleepCategoryStreak(
        logs: [slog(today, 420)],
        targetMinutes: 480,
        today: today,
      );
      expect(s.current, 0);
    });

    test('deleted logs do not count; today open does not break', () {
      final s = sleepCategoryStreak(
        logs: [slog(ago(1), 500), slog(ago(2), 500, dead: true)],
        targetMinutes: 480,
        today: today,
      );
      expect(s.current, 1);
    });
  });

  group('hobby category streak', () {
    test('weekly goal is expressed in weeks with a clear label', () {
      const info = HobbyStreakInfo(
        current: 4,
        longest: 6,
        unit: HobbyGoalPeriod.weekly,
      );
      final s = hobbyCategoryStreak(info);
      expect(s.unit, StreakUnit.week);
      expect(s.currentText, '4 weeks');
      expect(s.longestText, '6 weeks');
      expect(s.caption, '4-week goal streak');
    });

    test('daily goal in days; no goal says so', () {
      final d = hobbyCategoryStreak(
        const HobbyStreakInfo(
          current: 1,
          longest: 1,
          unit: HobbyGoalPeriod.daily,
        ),
      );
      expect(d.currentText, '1 day');
      expect(d.caption, '1-day goal streak');
      final none = hobbyCategoryStreak(HobbyStreakInfo.none);
      expect(none.caption, 'Set a hobby goal to start');
      expect(none.currentText, '0 days');
    });

    test('zero current keeps a neutral period caption', () {
      final s = hobbyCategoryStreak(
        const HobbyStreakInfo(
          current: 0,
          longest: 3,
          unit: HobbyGoalPeriod.weekly,
        ),
      );
      expect(s.caption, 'Weekly goals met in a row');
    });
  });

  group('milestones and badges', () {
    test('six milestones with deterministic keys', () {
      expect(categoryMilestones, [7, 30, 50, 100, 200, 500]);
      expect(StreakCategory.workout.badgeKey(7), 'workout_7');
      expect(StreakCategory.habits.badgeKey(500), 'habits_500');
      expect(StreakCategory.hobbies.badgeKey(50), 'hobbies_50');
      expect(StreakCategory.sleep.badgeKey(200), 'sleep_200');
      expect(StreakCategory.workout.scope, 'category:workout');
    });

    CategoryStreak st(int longest, {int current = 0}) => CategoryStreak(
      category: StreakCategory.workout,
      current: current,
      longest: longest,
    );

    test('due: none below 7, all reached, minus awarded', () {
      expect(categoryMilestonesDue(streak: st(6), alreadyAwarded: {}), isEmpty);
      expect(categoryMilestonesDue(streak: st(7), alreadyAwarded: {}), [7]);
      expect(
        categoryMilestonesDue(streak: st(120), alreadyAwarded: {'workout_7'}),
        [30, 50, 100],
      );
      expect(
        categoryMilestonesDue(streak: st(500), alreadyAwarded: {}).length,
        6,
      );
    });

    test('a badge in another category does not count as awarded', () {
      expect(
        categoryMilestonesDue(streak: st(7), alreadyAwarded: {'habits_7'}),
        [7],
      );
    });

    test('next milestone and to-go text', () {
      expect(nextMilestone(0), 7);
      expect(nextMilestone(7), 30);
      expect(nextMilestone(499), 500);
      expect(nextMilestone(500), isNull);
      expect(toGoText(7, 4, StreakUnit.day), '3 days to go');
      expect(toGoText(30, 29, StreakUnit.day), '1 day to go');
      expect(toGoText(7, 5, StreakUnit.week), '2 weeks to go');
    });

    test('messages name the category and unit; no exclamation marks', () {
      expect(
        categoryMilestoneMessage(StreakCategory.hobbies, 7, StreakUnit.week),
        '7-week hobby goal streak reached.',
      );
      for (final c in StreakCategory.values) {
        for (final u in StreakUnit.values) {
          expect(categoryMilestoneMessage(c, 30, u), isNot(contains('!')));
        }
      }
    });

    test('badge row ids are deterministic per user and key', () {
      expect(badgeRowId('u1', 'workout_7'), badgeRowId('u1', 'workout_7'));
      expect(
        badgeRowId('u1', 'workout_7'),
        isNot(badgeRowId('u2', 'workout_7')),
      );
      expect(badgeRowId('u1', 'workout_7'), isNot(badgeRowId('u1', 'sleep_7')));
      expect(Uuid.isValidUUID(fromString: badgeRowId('u1', 'x')), isTrue);
    });
  });

  test('streak engine is unchanged for overall: rest day bridges', () {
    final r = computeStreak(
      counted: {ago(2), today},
      today: today,
      bridge: {ago(1)},
    );
    expect(r.current, 2);
  });
}
