import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../data/app_database.dart';
import '../../data/tables/tables.dart';
import '../hobbies/hobby_logic.dart';
import 'streak_engine.dart';

/// Milestones for the category badges (R2).
const categoryMilestones = [7, 30, 50, 100, 200, 500];

/// The four separate category streaks (R2).
///
/// Rest days and the streak freeze belong to the existing `overall` activity
/// streak only. Category streaks are strict: every day (or goal-period for
/// hobbies) must meet the category's rule, nothing bridges a gap, and a missed
/// day is never silently forgiven. [computeStreak] is therefore always called
/// here without `bridge` and with the freeze off.
enum StreakCategory {
  workout(
    key: 'workout',
    label: 'Workout',
    caption: 'Days with at least one workout',
    icon: Icons.fitness_center_rounded,
    cat: Cat.workout,
  ),
  habits(
    key: 'habits',
    label: 'Healthy habits',
    caption: 'At least one habit target met',
    icon: Icons.spa_rounded,
    cat: Cat.habit,
  ),
  hobbies(
    key: 'hobbies',
    label: 'Hobbies',
    caption: 'Goal periods met in a row',
    icon: Icons.palette_rounded,
    cat: Cat.hobby,
  ),
  sleep(
    key: 'sleep',
    label: 'Sleep target',
    caption: 'Sleep duration target met',
    icon: Icons.nightlight_round,
    cat: Cat.sleep,
  );

  const StreakCategory({
    required this.key,
    required this.label,
    required this.caption,
    required this.icon,
    required this.cat,
  });

  final String key;
  final String label;
  final String caption;
  final IconData icon;
  final Cat cat;

  /// Streak cache scope, e.g. `category:workout`.
  String get scope => 'category:$key';

  /// Deterministic badge key, the same on every device: `workout_7`.
  String badgeKey(int milestone) => '${key}_$milestone';
}

/// What one step of a streak is.
enum StreakUnit { day, week }

extension StreakUnitText on StreakUnit {
  String word(int n) => this == StreakUnit.week
      ? (n == 1 ? 'week' : 'weeks')
      : (n == 1 ? 'day' : 'days');
}

class CategoryStreak {
  const CategoryStreak({
    required this.category,
    required this.current,
    required this.longest,
    this.unit = StreakUnit.day,
    this.lastCountedDate,
    this.goalLabel = '',
    this.hasGoal = true,
  });

  final StreakCategory category;
  final int current;
  final int longest;
  final StreakUnit unit;
  final String? lastCountedDate;

  /// Hobbies only: `4-week goal streak`.
  final String goalLabel;

  /// False only for hobbies when no hobby has a goal.
  final bool hasGoal;

  /// Short line under the figure. Always says what is being counted.
  String get caption {
    if (category == StreakCategory.hobbies) {
      if (!hasGoal) return 'Set a hobby goal to start';
      if (goalLabel.isNotEmpty) return goalLabel;
      return unit == StreakUnit.week
          ? 'Weekly goals met in a row'
          : 'Daily goals met in a row';
    }
    return category.caption;
  }

  /// `5 days`, `4 weeks`.
  String get currentText => '$current ${unit.word(current)}';
  String get longestText => '$longest ${unit.word(longest)}';

  String get semanticsLabel =>
      '${category.label}, $currentText. $caption. Longest $longestText.';
}

/// Strict consecutive-day streak: no rest days, no freeze.
CategoryStreak strictDayStreak(
  StreakCategory category,
  Set<String> counted,
  String today,
) {
  final r = computeStreak(counted: counted, today: today);
  return CategoryStreak(
    category: category,
    current: r.current,
    longest: r.longest,
    lastCountedDate: r.lastCountedDate,
  );
}

/// Workout: a day with at least one saved (non-deleted) workout. Pass only
/// live rows; the repository's watchers already leave deleted ones out.
CategoryStreak workoutCategoryStreak({
  required Iterable<Workout> workouts,
  required String today,
}) => strictDayStreak(StreakCategory.workout, {
  for (final w in workouts)
    if (w.deletedAt == null) w.localDate,
}, today);

/// Local dates on which at least one of [habits] met its daily target.
/// Only the given (active) habits count; logs of other habits are ignored.
Set<String> habitTargetMetDates({
  required Iterable<Habit> habits,
  required Iterable<HabitLog> logs,
}) {
  final target = {
    for (final h in habits)
      if (h.isActive && h.deletedAt == null)
        h.id: h.dailyTarget < 1 ? 1 : h.dailyTarget,
  };
  final totals = <String, Map<String, int>>{};
  for (final l in logs) {
    if (l.deletedAt != null || !target.containsKey(l.habitId)) continue;
    final perDate = totals.putIfAbsent(l.habitId, () => {});
    perDate[l.localDate] = (perDate[l.localDate] ?? 0) + l.count;
  }
  final met = <String>{};
  for (final e in totals.entries) {
    for (final d in e.value.entries) {
      if (d.value >= target[e.key]!) met.add(d.key);
    }
  }
  return met;
}

/// Healthy habits: consecutive local days on which the target of at least one
/// active habit was met. Each habit keeps its own streak (habitStreak).
CategoryStreak habitsCategoryStreak({
  required Iterable<Habit> habits,
  required Iterable<HabitLog> logs,
  required String today,
}) => strictDayStreak(
  StreakCategory.habits,
  habitTargetMetDates(habits: habits, logs: logs),
  today,
);

/// The sleep-duration target in minutes: the length of the window between
/// the configured bedtime and wake time (22:30 to 06:30 is 8 h). The app has
/// no separate duration setting, so the schedule window is the target. This
/// is only the amount of sleep wanted; schedule consistency (how close the
/// actual times were) is a different measure in sleep_logic.dart.
int sleepTargetMinutes({
  required int bedtimeMinutes,
  required int wakeMinutes,
}) {
  final d = (wakeMinutes - bedtimeMinutes) % 1440;
  return d == 0 ? 1440 : d;
}

/// Sleep target: consecutive days (by wake date, the same convention as the
/// sleep log) with a slept duration of at least [targetMinutes].
CategoryStreak sleepCategoryStreak({
  required Iterable<SleepLog> logs,
  required int targetMinutes,
  required String today,
}) => strictDayStreak(StreakCategory.sleep, {
  for (final l in logs)
    if (l.deletedAt == null && l.durationMinutes >= targetMinutes) l.localDate,
}, today);

/// Hobbies: completed goal-periods in a row, in the hobby streak's own unit.
CategoryStreak hobbyCategoryStreak(HobbyStreakInfo info) => CategoryStreak(
  category: StreakCategory.hobbies,
  current: info.current,
  longest: info.longest,
  unit: info.unit == HobbyGoalPeriod.weekly ? StreakUnit.week : StreakUnit.day,
  goalLabel: info.label,
  hasGoal: info.hasGoal,
);

/// Milestones reached by [streak] (by its longest run, so a badge earned once
/// is never lost and history is credited) that are not yet awarded.
List<int> categoryMilestonesDue({
  required CategoryStreak streak,
  required Set<String> alreadyAwarded,
}) => [
  for (final m in categoryMilestones)
    if (streak.longest >= m &&
        !alreadyAwarded.contains(streak.category.badgeKey(m)))
      m,
];

/// The first milestone the [current] run has not reached yet, or null when
/// it has passed all of them.
int? nextMilestone(int current) {
  for (final m in categoryMilestones) {
    if (current < m) return m;
  }
  return null;
}

/// `3 days to go`, `1 week to go`.
String toGoText(int milestone, int current, StreakUnit unit) {
  final n = milestone - current;
  return '$n ${unit.word(n)} to go';
}

/// Celebration line: `30-day workout streak reached.`; hobbies say goal
/// periods, never days, for weekly goals.
String categoryMilestoneMessage(StreakCategory c, int m, StreakUnit unit) {
  final u = unit == StreakUnit.week ? 'week' : 'day';
  return switch (c) {
    StreakCategory.workout => '$m-$u workout streak reached.',
    StreakCategory.habits => '$m-$u healthy habits streak reached.',
    StreakCategory.hobbies => '$m-$u hobby goal streak reached.',
    StreakCategory.sleep => '$m-$u sleep target streak reached.',
  };
}
