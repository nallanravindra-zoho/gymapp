import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/data/tables/tables.dart';
import 'package:wellbeing/features/goals/goal_logic.dart';
import 'package:wellbeing/features/hobbies/hobby_logic.dart';

import 'week_marks_test.dart'
    show dates, habit, habitLog, screen, sleep, workout;

CategoryGoal of(List<CategoryGoal> goals, GoalCategory c) =>
    goals.firstWhere((g) => g.category == c);

void main() {
  group('periodDates', () {
    test('a day is itself', () {
      expect(periodDates(GoalPeriod.day, '2026-05-13'), ['2026-05-13']);
    });

    test('a week runs Monday to Sunday around the anchor', () {
      expect(periodDates(GoalPeriod.week, '2026-05-13'), dates);
    });

    test('a month has every day of the month', () {
      final d = periodDates(GoalPeriod.month, '2026-02-10');
      expect(d.first, '2026-02-01');
      expect(d.last, '2026-02-28');
      expect(periodDates(GoalPeriod.month, '2026-05-13'), hasLength(31));
    });
  });

  group('workout goal', () {
    test('counts sessions against the weekly target, in progress', () {
      final goals = categoryGoals(
        period: GoalPeriod.week,
        dates: dates,
        inputs: GoalInputs(
          workoutWeeklyTarget: 3,
          workouts: [
            workout('a', '2026-05-11', 7),
            workout('b', '2026-05-13', 7),
          ],
        ),
      );
      final g = of(goals, GoalCategory.workout);
      expect(g.met, 2);
      expect(g.total, 3);
      expect(g.fraction, closeTo(2 / 3, 1e-9));
    });

    test('over target is capped at full', () {
      final goals = categoryGoals(
        period: GoalPeriod.week,
        dates: dates,
        inputs: GoalInputs(
          workoutWeeklyTarget: 1,
          workouts: [
            workout('a', '2026-05-11', 7),
            workout('b', '2026-05-12', 7),
          ],
        ),
      );
      expect(of(goals, GoalCategory.workout).fraction, 1);
    });

    test('is absent without a target and for a single day', () {
      expect(
        categoryGoals(
          period: GoalPeriod.week,
          dates: dates,
          inputs: const GoalInputs(),
        ),
        isEmpty,
      );
      expect(
        categoryGoals(
          period: GoalPeriod.day,
          dates: ['2026-05-13'],
          inputs: const GoalInputs(workoutWeeklyTarget: 3),
        ),
        isEmpty,
      );
    });

    test('scales the target for a month', () {
      final goals = categoryGoals(
        period: GoalPeriod.month,
        dates: [
          for (var i = 1; i <= 28; i++)
            '2026-02-${i.toString().padLeft(2, '0')}',
        ],
        inputs: const GoalInputs(workoutWeeklyTarget: 3),
      );
      expect(of(goals, GoalCategory.workout).total, 12);
    });
  });

  group('habits', () {
    test('each habit counts equally however often it is logged', () {
      // Water target 8, stretch target 1. Logging water 8 times and
      // stretching never must not look better than half the goals.
      final goals = categoryGoals(
        period: GoalPeriod.day,
        dates: ['2026-05-13'],
        inputs: GoalInputs(
          habits: [habit('water', target: 8), habit('stretch')],
          habitLogs: [habitLog('water', '2026-05-13', count: 8)],
        ),
      );
      expect(of(goals, GoalCategory.habits).fraction, 0.5);
    });

    test('partial progress counts and days met are whole days', () {
      final goals = categoryGoals(
        period: GoalPeriod.week,
        dates: dates,
        inputs: GoalInputs(
          habits: [habit('water', target: 4)],
          habitLogs: [
            habitLog('water', '2026-05-11', count: 4),
            habitLog('water', '2026-05-12', count: 2),
          ],
        ),
      );
      final g = of(goals, GoalCategory.habits);
      expect(g.met, 1);
      expect(g.total, 7);
      expect(g.fraction, closeTo((1 + 0.5) / 7, 1e-9));
    });

    test('are absent with no active habits', () {
      expect(
        categoryGoals(
          period: GoalPeriod.week,
          dates: dates,
          inputs: const GoalInputs(),
        ).where((g) => g.category == GoalCategory.habits),
        isEmpty,
      );
    });
  });

  group('sleep and screen time', () {
    test('sleep is duration against target per night', () {
      final goals = categoryGoals(
        period: GoalPeriod.week,
        dates: dates,
        inputs: GoalInputs(
          sleepTargetMinutes: 480,
          sleepLogs: [sleep('2026-05-11', 480), sleep('2026-05-12', 240)],
        ),
      );
      final g = of(goals, GoalCategory.sleep);
      expect(g.met, 1);
      expect(g.fraction, closeTo((1 + 0.5) / 7, 1e-9));
    });

    test('screen time counts days at or under the limit', () {
      final goals = categoryGoals(
        period: GoalPeriod.week,
        dates: dates,
        inputs: GoalInputs(
          screenGoalMinutes: 180,
          screenRows: [
            screen('2026-05-11', 170),
            screen('2026-05-12', 181),
            screen('2026-05-13', 180),
          ],
        ),
      );
      final g = of(goals, GoalCategory.screen);
      expect(g.met, 2);
      expect(g.total, 7);
    });

    test('screen time is absent without a limit', () {
      expect(
        categoryGoals(
          period: GoalPeriod.week,
          dates: dates,
          inputs: GoalInputs(screenRows: [screen('2026-05-11', 10)]),
        ),
        isEmpty,
      );
    });
  });

  group('hobbies', () {
    const weekly = HobbyGoal(
      period: HobbyGoalPeriod.weekly,
      value: 2,
      unit: HobbyGoalUnit.sessions,
    );
    const daily = HobbyGoal(period: HobbyGoalPeriod.daily, value: 30);

    test('a weekly goal is progress toward the week', () {
      final goals = categoryGoals(
        period: GoalPeriod.week,
        dates: dates,
        inputs: const GoalInputs(
          hobbyGoals: {'read': weekly},
          hobbyActivities: [
            HobbyActivity(
              hobbyId: 'read',
              localDate: '2026-05-12',
              minutes: 20,
            ),
          ],
        ),
      );
      final g = of(goals, GoalCategory.hobbies);
      expect(g.fraction, 0.5);
      expect(g.met, 0);
      expect(g.total, 1);
    });

    test('a weekly goal is left out of a single day', () {
      final goals = categoryGoals(
        period: GoalPeriod.day,
        dates: ['2026-05-13'],
        inputs: const GoalInputs(hobbyGoals: {'read': weekly}),
      );
      expect(goals, isEmpty);
    });

    test('a daily goal averages over the days', () {
      final goals = categoryGoals(
        period: GoalPeriod.week,
        dates: dates,
        inputs: const GoalInputs(
          hobbyGoals: {'music': daily},
          hobbyActivities: [
            HobbyActivity(
              hobbyId: 'music',
              localDate: '2026-05-11',
              minutes: 30,
            ),
          ],
        ),
      );
      expect(of(goals, GoalCategory.hobbies).fraction, closeTo(1 / 7, 1e-9));
    });
  });

  group('overall and day status', () {
    test('overall is the mean of category fractions, not a total', () {
      final goals = [
        const CategoryGoal(
          category: GoalCategory.workout,
          fraction: 1,
          met: 3,
          total: 3,
          unit: 'sessions',
        ),
        const CategoryGoal(
          category: GoalCategory.sleep,
          fraction: 0.5,
          met: 0,
          total: 7,
          unit: 'days',
        ),
      ];
      expect(overallPercent(goals), 75);
      expect(overallPercent(const []), isNull);
    });

    test('future days are upcoming, never missed', () {
      DayStatus s(String d, double? f) =>
          dayStatus(date: d, today: '2026-05-13', fraction: f);
      expect(s('2026-05-14', 0), DayStatus.upcoming);
      expect(s('2026-05-13', 1), DayStatus.met);
      expect(s('2026-05-12', 0.4), DayStatus.partial);
      expect(s('2026-05-11', 0), DayStatus.missed);
      expect(s('2026-05-11', null), DayStatus.upcoming);
    });
  });
}
