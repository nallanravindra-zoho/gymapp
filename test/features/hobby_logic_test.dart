import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/data/tables/tables.dart';
import 'package:wellbeing/features/hobbies/hobby_logic.dart';

HobbyActivity act(String date, int minutes, {String hobby = 'h', int s = 1}) =>
    HobbyActivity(
      hobbyId: hobby,
      localDate: date,
      minutes: minutes,
      sessions: s,
    );

const daily30 = HobbyGoal(period: HobbyGoalPeriod.daily, value: 30);
const weekly60 = HobbyGoal(period: HobbyGoalPeriod.weekly, value: 60);
const weekly3sessions = HobbyGoal(
  period: HobbyGoalPeriod.weekly,
  value: 3,
  unit: HobbyGoalUnit.sessions,
);

void main() {
  // 2026-05-11 is a Monday.
  group('daily goal', () {
    test('met when the day total reaches the goal, summing logs', () {
      final acts = [act('2026-05-13', 20), act('2026-05-13', 10)];
      expect(
        dailyGoalMet(
          goal: daily30,
          activities: acts,
          hobbyId: 'h',
          date: '2026-05-13',
        ),
        isTrue,
      );
      expect(
        dailyGoalMet(
          goal: daily30,
          activities: acts,
          hobbyId: 'h',
          date: '2026-05-12',
        ),
        isFalse,
      );
    });

    test('just under is not met; other hobbies do not count', () {
      expect(
        dailyGoalMet(
          goal: daily30,
          activities: [
            act('2026-05-13', 29),
            act('2026-05-13', 60, hobby: 'x'),
          ],
          hobbyId: 'h',
          date: '2026-05-13',
        ),
        isFalse,
      );
    });

    test('a weekly goal is never met on a single day', () {
      expect(
        dailyGoalMet(
          goal: weekly60,
          activities: [act('2026-05-13', 120)],
          hobbyId: 'h',
          date: '2026-05-13',
        ),
        isFalse,
      );
    });

    test('sessions unit counts sessions, not minutes', () {
      const g = HobbyGoal(
        period: HobbyGoalPeriod.daily,
        value: 2,
        unit: HobbyGoalUnit.sessions,
      );
      expect(
        dailyGoalMet(
          goal: g,
          activities: [act('2026-05-13', 5, s: 2)],
          hobbyId: 'h',
          date: '2026-05-13',
        ),
        isTrue,
      );
    });
  });

  group('weekly goal', () {
    test('met on any days within Monday to Sunday', () {
      final acts = [
        act('2026-05-11', 20),
        act('2026-05-14', 20),
        act('2026-05-17', 20),
      ];
      expect(
        weeklyGoalMet(
          goal: weekly60,
          activities: acts,
          hobbyId: 'h',
          weekStart: '2026-05-11',
        ),
        isTrue,
      );
    });

    test('Sunday belongs to the week that started on Monday', () {
      expect(
        weeklyGoalMet(
          goal: weekly60,
          activities: [act('2026-05-17', 60)],
          hobbyId: 'h',
          weekStart: '2026-05-11',
        ),
        isTrue,
      );
      expect(
        weeklyGoalMet(
          goal: weekly60,
          activities: [act('2026-05-17', 60)],
          hobbyId: 'h',
          weekStart: '2026-05-18',
        ),
        isFalse,
      );
    });

    test('time in two different weeks is not added together', () {
      expect(
        weeklyGoalMet(
          goal: weekly60,
          activities: [act('2026-05-17', 30), act('2026-05-18', 30)],
          hobbyId: 'h',
          weekStart: '2026-05-11',
        ),
        isFalse,
      );
    });

    test('weekly sessions goal', () {
      final acts = [
        act('2026-05-11', 10),
        act('2026-05-13', 10),
        act('2026-05-16', 10),
      ];
      expect(
        weeklyGoalMet(
          goal: weekly3sessions,
          activities: acts,
          hobbyId: 'h',
          weekStart: '2026-05-11',
        ),
        isTrue,
      );
    });
  });

  group('progress and labels', () {
    test('progress text for day and week', () {
      final p = hobbyProgress(
        goal: daily30,
        activities: [act('2026-05-13', 20)],
        hobbyId: 'h',
        today: '2026-05-13',
      );
      expect(p.describe(), '20 of 30 min today');
      expect(p.met, isFalse);
      expect(p.fraction, closeTo(0.667, 0.01));
      final w = hobbyProgress(
        goal: weekly3sessions,
        activities: [act('2026-05-11', 5), act('2026-05-13', 5)],
        hobbyId: 'h',
        today: '2026-05-13',
      );
      expect(w.describe(), '2 of 3 sessions this week');
    });

    test('goal descriptions', () {
      expect(daily30.describe(), '30 min a day');
      expect(weekly3sessions.describe(), '3 sessions a week');
    });

    test('streak labels use weeks for weekly goals', () {
      const w = HobbyStreakInfo(
        current: 4,
        longest: 6,
        unit: HobbyGoalPeriod.weekly,
      );
      const d = HobbyStreakInfo(
        current: 5,
        longest: 5,
        unit: HobbyGoalPeriod.daily,
      );
      expect(w.label, '4-week goal streak');
      expect(d.label, '5-day goal streak');
      expect(w.longestLabel, '6-week goal streak');
      expect(HobbyStreakInfo.none.label, '');
    });
  });

  group('per-hobby streak', () {
    test('daily: consecutive met days, a miss resets', () {
      final acts = [
        act('2026-05-08', 30),
        act('2026-05-09', 30),
        // 10th missed
        act('2026-05-11', 30),
        act('2026-05-12', 45),
        act('2026-05-13', 30),
      ];
      final s = hobbyGoalStreak(
        goal: daily30,
        activities: acts,
        hobbyId: 'h',
        today: '2026-05-13',
      );
      expect(s.current, 3);
      expect(s.longest, 3);
      expect(s.unit, HobbyGoalPeriod.daily);
    });

    test('daily: today not yet met does not break it', () {
      final acts = [act('2026-05-11', 30), act('2026-05-12', 30)];
      final s = hobbyGoalStreak(
        goal: daily30,
        activities: acts,
        hobbyId: 'h',
        today: '2026-05-13',
      );
      expect(s.current, 2);
    });

    test('daily: a missed day before today breaks it', () {
      final s = hobbyGoalStreak(
        goal: daily30,
        activities: [act('2026-05-10', 30), act('2026-05-11', 30)],
        hobbyId: 'h',
        today: '2026-05-13',
      );
      expect(s.current, 0);
      expect(s.longest, 2);
    });

    test('weekly: counts completed weeks, not days', () {
      final acts = [
        // week of 04-27: 60 across two days
        act('2026-04-28', 30), act('2026-04-30', 30),
        // week of 05-04: met on one day
        act('2026-05-06', 70),
        // week of 05-11 (current): met on Sunday-ish already
        act('2026-05-12', 60),
      ];
      final s = hobbyGoalStreak(
        goal: weekly60,
        activities: acts,
        hobbyId: 'h',
        today: '2026-05-13',
      );
      expect(s.current, 3);
      expect(s.label, '3-week goal streak');
    });

    test('weekly: the open current week does not break the streak', () {
      final acts = [act('2026-05-05', 60), act('2026-05-06', 60)];
      final s = hobbyGoalStreak(
        goal: weekly60,
        activities: acts,
        hobbyId: 'h',
        today: '2026-05-13',
      );
      expect(s.current, 1);
    });

    test('weekly: a skipped finished week breaks it', () {
      final acts = [act('2026-04-21', 60), act('2026-05-12', 60)];
      final s = hobbyGoalStreak(
        goal: weekly60,
        activities: acts,
        hobbyId: 'h',
        today: '2026-05-13',
      );
      expect(s.current, 1);
      expect(s.longest, 1);
    });

    test('no activity gives zero', () {
      final s = hobbyGoalStreak(
        goal: weekly60,
        activities: const [],
        hobbyId: 'h',
        today: '2026-05-13',
      );
      expect(s.current, 0);
      expect(s.label, '');
    });
  });

  group('aggregated streak', () {
    test('no goals means no streak', () {
      final s = aggregateHobbyStreak(
        goals: const {},
        activities: [act('2026-05-13', 90)],
        today: '2026-05-13',
      );
      expect(s.hasGoal, isFalse);
      expect(s.current, 0);
    });

    test('all daily goals: days where at least one hobby met its goal', () {
      final acts = [
        act('2026-05-11', 30, hobby: 'a'),
        act('2026-05-12', 30, hobby: 'b'),
        act('2026-05-13', 10, hobby: 'a'), // today, not met, still open
      ];
      final s = aggregateHobbyStreak(
        goals: {'a': daily30, 'b': daily30},
        activities: acts,
        today: '2026-05-13',
      );
      expect(s.unit, HobbyGoalPeriod.daily);
      expect(s.current, 2);
      expect(s.label, '2-day goal streak');
    });

    test('any weekly goal makes the unit weeks', () {
      final acts = [
        act('2026-05-05', 60, hobby: 'w'),
        act('2026-05-12', 60, hobby: 'w'),
      ];
      final s = aggregateHobbyStreak(
        goals: {'w': weekly60, 'd': daily30},
        activities: acts,
        today: '2026-05-13',
      );
      expect(s.unit, HobbyGoalPeriod.weekly);
      expect(s.current, 2);
      expect(s.label, '2-week goal streak');
    });

    test(
      'mixed: a daily-goal hobby counts for a week only if met all 7 days',
      () {
        final all7 = [
          for (var d = 4; d <= 10; d++)
            act('2026-05-${d.toString().padLeft(2, '0')}', 30, hobby: 'd'),
        ];
        final partial = [
          for (var d = 11; d <= 13; d++) act('2026-05-$d', 30, hobby: 'd'),
        ];
        final s = aggregateHobbyStreak(
          goals: {'w': weekly60, 'd': daily30},
          activities: [...all7, ...partial],
          today: '2026-05-13',
        );
        // Week of 05-04 counts through the daily hobby; the current week is
        // open and not complete, so it does not add.
        expect(s.current, 1);
      },
    );
  });

  group('per-date and per-week sets', () {
    final goals = {'a': daily30, 'w': weekly60};
    final acts = [
      act('2026-05-13', 30, hobby: 'a'),
      act('2026-05-12', 61, hobby: 'w'),
    ];

    test('daily goals met on a date', () {
      expect(
        dailyGoalsMetOn(goals: goals, activities: acts, date: '2026-05-13'),
        {'a'},
      );
      // The weekly hobby's 61 minutes do not make 12 May a daily-goal day.
      expect(
        dailyGoalsMetOn(goals: goals, activities: acts, date: '2026-05-12'),
        isEmpty,
      );
    });

    test('weekly goals met in a week', () {
      expect(
        weeklyGoalsMetIn(
          goals: goals,
          activities: acts,
          weekStart: '2026-05-11',
        ),
        {'w'},
      );
      expect(
        weeklyGoalsMetIn(
          goals: goals,
          activities: acts,
          weekStart: '2026-05-04',
        ),
        isEmpty,
      );
    });
  });

  test('minutes by hobby within a range', () {
    final m = minutesByHobby(
      [
        act('2026-05-11', 20, hobby: 'a'),
        act('2026-05-12', 40, hobby: 'a'),
        act('2026-05-12', 15, hobby: 'b'),
        act('2026-05-18', 99, hobby: 'b'),
      ],
      from: '2026-05-11',
      to: '2026-05-17',
    );
    expect(m, {'a': 60, 'b': 15});
  });
}
