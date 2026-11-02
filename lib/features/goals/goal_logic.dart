import 'dart:math' as math;

import '../../core/time/local_date.dart';
import '../../data/app_database.dart';
import '../../data/tables/tables.dart' show HobbyGoalPeriod;
import '../habits/habit_providers.dart' show dailyTotals;
import '../hobbies/hobby_logic.dart';
import '../week/week_marks.dart'
    show habitsMarkMet, screenMarkMet, sleepMarkMet;

/// The goal areas on the Goals screen.
enum GoalCategory { workout, habits, sleep, screen, nutrition, hobbies }

enum GoalPeriod { day, week, month }

extension GoalCategoryText on GoalCategory {
  String get label => switch (this) {
    GoalCategory.workout => 'Workout',
    GoalCategory.habits => 'Healthy habits',
    GoalCategory.sleep => 'Sleep',
    GoalCategory.screen => 'Screen time',
    GoalCategory.nutrition => 'Nutrition',
    GoalCategory.hobbies => 'Hobbies',
  };
}

/// Local dates covered by [period] around [anchor]: the day itself, its
/// Monday-to-Sunday week, or its calendar month.
List<String> periodDates(GoalPeriod period, String anchor) {
  switch (period) {
    case GoalPeriod.day:
      return [anchor];
    case GoalPeriod.week:
      final start = weekStartOf(anchor);
      return [for (var i = 0; i < 7; i++) shiftLocalDate(start, i)];
    case GoalPeriod.month:
      final d = DateTime.parse(anchor);
      final days = DateTime.utc(d.year, d.month + 1, 0).day;
      return [
        for (var i = 1; i <= days; i++) formatLocalDate(d.year, d.month, i),
      ];
  }
}

/// Everything goal progress reads, already loaded. All fields cover at least
/// the dates being asked about.
class GoalInputs {
  const GoalInputs({
    this.workoutWeeklyTarget,
    this.workouts = const [],
    this.habits = const [],
    this.habitLogs = const [],
    this.habitThreshold = 1,
    this.hobbyGoals = const {},
    this.hobbyActivities = const [],
    this.sleepLogs = const [],
    this.sleepTargetMinutes = 0,
    this.screenRows = const [],
    this.screenGoalMinutes,
    this.nutritionDailyServings,
    this.meals = const [],
  });

  /// Sessions per week the person aims for; null when no workout goal is set.
  final int? workoutWeeklyTarget;
  final List<Workout> workouts;
  final List<Habit> habits;
  final List<HabitLog> habitLogs;
  final int habitThreshold;
  final Map<String, HobbyGoal> hobbyGoals;
  final List<HobbyActivity> hobbyActivities;
  final List<SleepLog> sleepLogs;
  final int sleepTargetMinutes;
  final List<ScreenTimeDailyData> screenRows;
  final int? screenGoalMinutes;

  /// Servings a day the person aims for; null when no nutrition goal is set.
  final int? nutritionDailyServings;
  final List<MealLog> meals;
}

/// Progress of one category over a period, normalised against its own
/// target so categories with different units can be averaged.
class CategoryGoal {
  const CategoryGoal({
    required this.category,
    required this.fraction,
    required this.met,
    required this.total,
    required this.unit,
  });

  final GoalCategory category;

  /// 0 to 1 share of the target reached. Partial progress counts.
  final double fraction;

  /// Whole targets reached (days, sessions or goals), out of [total].
  final int met;
  final int total;

  /// `days`, `sessions` or `goals`.
  final String unit;

  int get percent => (fraction * 100).round();
}

double _mean(Iterable<double> values) {
  if (values.isEmpty) return 0;
  return values.reduce((a, b) => a + b) / values.length;
}

/// Progress for every category that has a goal, over [dates].
///
/// Weekly goals (workout sessions, weekly hobbies) are left out of a single
/// day, since they have no daily share. Each daily category is the average of
/// its days, so a day with two habits counts each habit equally however often
/// it is logged or reminded.
List<CategoryGoal> categoryGoals({
  required GoalPeriod period,
  required List<String> dates,
  required GoalInputs inputs,
}) {
  final out = <CategoryGoal>[];
  final i = inputs;

  // Workout: sessions against a weekly target, scaled to the period length.
  final target = i.workoutWeeklyTarget;
  if (target != null && target > 0 && period != GoalPeriod.day) {
    final scaled = math.max(1, (target * dates.length / 7).round());
    final done = i.workouts
        .where((w) => w.deletedAt == null && dates.contains(w.localDate))
        .length;
    out.add(
      CategoryGoal(
        category: GoalCategory.workout,
        fraction: math.min(1, done / scaled),
        met: math.min(done, scaled),
        total: scaled,
        unit: 'sessions',
      ),
    );
  }

  // Healthy habits: each habit against its own daily target.
  if (i.habits.isNotEmpty) {
    final days = <double>[];
    var met = 0;
    final totals = {
      for (final h in i.habits) h.id: dailyTotals(i.habitLogs, h.id),
    };
    for (final d in dates) {
      final counts = {for (final h in i.habits) h.id: totals[h.id]![d] ?? 0};
      days.add(
        _mean([
          for (final h in i.habits)
            math.min(1.0, (counts[h.id] ?? 0) / math.max(1, h.dailyTarget)),
        ]),
      );
      if (habitsMarkMet(
        habits: i.habits,
        counts: counts,
        threshold: i.habitThreshold,
      )) {
        met++;
      }
    }
    out.add(
      CategoryGoal(
        category: GoalCategory.habits,
        fraction: _mean(days),
        met: met,
        total: dates.length,
        unit: 'days',
      ),
    );
  }

  // Sleep: slept duration against the target, per night.
  if (i.sleepTargetMinutes > 0) {
    final days = <double>[];
    var met = 0;
    for (final d in dates) {
      final logs = i.sleepLogs.where(
        (l) => l.deletedAt == null && l.localDate == d,
      );
      if (logs.isEmpty) {
        days.add(0);
        continue;
      }
      final best = logs.reduce(
        (a, b) => a.durationMinutes >= b.durationMinutes ? a : b,
      );
      days.add(math.min(1.0, best.durationMinutes / i.sleepTargetMinutes));
      if (sleepMarkMet(best, i.sleepTargetMinutes)) met++;
    }
    out.add(
      CategoryGoal(
        category: GoalCategory.sleep,
        fraction: _mean(days),
        met: met,
        total: dates.length,
        unit: 'days',
      ),
    );
  }

  // Screen time: a day counts when it stays at or under the limit.
  final limit = i.screenGoalMinutes;
  if (limit != null) {
    var met = 0;
    for (final d in dates) {
      final row = i.screenRows.where((r) => r.localDate == d).firstOrNull;
      if (screenMarkMet(row, limit)) met++;
    }
    out.add(
      CategoryGoal(
        category: GoalCategory.screen,
        fraction: met / dates.length,
        met: met,
        total: dates.length,
        unit: 'days',
      ),
    );
  }

  // Nutrition: servings logged against a daily target. Calories are never
  // used here, so the goal does not depend on a food database.
  final servingsTarget = i.nutritionDailyServings;
  if (servingsTarget != null && servingsTarget > 0) {
    final byDate = <String, double>{};
    for (final m in i.meals) {
      if (m.deletedAt != null) continue;
      byDate[m.localDate] = (byDate[m.localDate] ?? 0) + m.servings;
    }
    final days = <double>[];
    var met = 0;
    for (final d in dates) {
      final eaten = byDate[d] ?? 0;
      days.add(math.min(1.0, eaten / servingsTarget));
      if (eaten >= servingsTarget) met++;
    }
    out.add(
      CategoryGoal(
        category: GoalCategory.nutrition,
        fraction: _mean(days),
        met: met,
        total: dates.length,
        unit: 'days',
      ),
    );
  }

  // Hobbies: each hobby goal against its own period.
  final hobbyFractions = <double>[];
  for (final e in i.hobbyGoals.entries) {
    final goal = e.value;
    if (goal.period == HobbyGoalPeriod.weekly) {
      if (period == GoalPeriod.day) continue;
      final starts = {for (final d in dates) weekStartOf(d)};
      hobbyFractions.add(
        _mean([
          for (final s in starts)
            math.min(
              1.0,
              amountInPeriod(
                    goal: goal,
                    activities: i.hobbyActivities,
                    hobbyId: e.key,
                    periodStart: s,
                  ) /
                  goal.value,
            ),
        ]),
      );
    } else {
      hobbyFractions.add(
        _mean([
          for (final d in dates)
            math.min(
              1.0,
              amountInPeriod(
                    goal: goal,
                    activities: i.hobbyActivities,
                    hobbyId: e.key,
                    periodStart: d,
                  ) /
                  goal.value,
            ),
        ]),
      );
    }
  }
  if (hobbyFractions.isNotEmpty) {
    out.add(
      CategoryGoal(
        category: GoalCategory.hobbies,
        fraction: _mean(hobbyFractions),
        met: hobbyFractions.where((f) => f >= 1).length,
        total: hobbyFractions.length,
        unit: 'goals',
      ),
    );
  }

  return out;
}

/// The share of goals met, as a rounded percentage. Null with no goals.
int? overallPercent(List<CategoryGoal> goals) {
  if (goals.isEmpty) return null;
  return (_mean(goals.map((g) => g.fraction)) * 100).round();
}

/// How one day of a week went: fully met, partly, or nothing.
enum DayStatus { met, partial, missed, upcoming }

/// The status of [date] from its daily-goal share. Days after [today] are
/// upcoming, never missed.
DayStatus dayStatus({
  required String date,
  required String today,
  required double? fraction,
}) {
  if (date.compareTo(today) > 0 || fraction == null) return DayStatus.upcoming;
  if (fraction >= 1) return DayStatus.met;
  if (fraction > 0) return DayStatus.partial;
  return DayStatus.missed;
}

/// One calm, rule-based line for Home: the goal furthest from its target.
/// Names the data it uses and never guesses without any.
String goalSuggestion(List<CategoryGoal> goals) {
  if (goals.isEmpty) return 'Set a goal to see your progress here.';
  final open = goals.where((g) => g.fraction < 1).toList();
  if (open.isEmpty) return 'All of your goals are met for now.';
  open.sort((a, b) => a.fraction.compareTo(b.fraction));
  final g = open.first;
  return '${g.category.label} is furthest from its target. '
      'One small step is enough.';
}
