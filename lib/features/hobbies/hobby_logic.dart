/// Pure hobby goal and streak rules (R5). No database, no Flutter.
///
/// Definitions used across the app:
///
/// * A hobby has an optional goal: [HobbyGoal] = a value in minutes or
///   sessions, per day or per week.
/// * A daily goal is met on a date when the hobby's logged amount on that
///   local date reaches the value.
/// * A weekly goal is met for an ISO week (Monday to Sunday) when the amount
///   summed over any days of that week reaches the value. It is never
///   assigned to a single day.
/// * Hobby streak = consecutive completed goal-periods (days for a daily
///   goal, weeks for a weekly goal). The period in progress never breaks a
///   streak: it counts once its goal is met, and is otherwise ignored.
/// * Goals are evaluated with the hobby's current goal over its whole
///   history, so changing a goal re-reads the past with the new target.
/// * Aggregated Hobbies streak = consecutive periods in which at least one
///   active hobby with a goal met its goal. If every goal hobby has a daily
///   goal the unit is days. If any has a weekly goal the unit is weeks; a
///   week then counts when a weekly-goal hobby met its weekly goal, or a
///   daily-goal hobby met its daily goal on all seven days of that week.
library;

import '../../core/time/local_date.dart';
import '../../data/app_database.dart';
import '../../data/tables/tables.dart';

/// The part of a log that goals care about.
class HobbyActivity {
  const HobbyActivity({
    required this.hobbyId,
    required this.localDate,
    required this.minutes,
    this.sessions = 1,
  });

  factory HobbyActivity.fromLog(HobbyLog l) => HobbyActivity(
    hobbyId: l.hobbyId,
    localDate: l.localDate,
    minutes: l.durationMinutes,
    sessions: l.countOrSessions,
  );

  final String hobbyId;
  final String localDate;
  final int minutes;
  final int sessions;
}

/// A hobby's goal: [value] [unit] per [period].
class HobbyGoal {
  const HobbyGoal({
    required this.period,
    required this.value,
    this.unit = HobbyGoalUnit.minutes,
  });

  final HobbyGoalPeriod period;
  final int value;
  final HobbyGoalUnit unit;

  /// The goal stored on [h], or null when none (or an unusable value) is set.
  static HobbyGoal? of(Hobby h) {
    final p = h.goalPeriod;
    final v = h.goalValue;
    if (p == null || v == null || v < 1) return null;
    return HobbyGoal(period: p, value: v, unit: h.goalUnit);
  }

  /// `30 min a day`, `3 sessions a week`.
  String describe() {
    final what = unit == HobbyGoalUnit.minutes
        ? '$value min'
        : '$value ${value == 1 ? 'session' : 'sessions'}';
    return '$what a ${period == HobbyGoalPeriod.daily ? 'day' : 'week'}';
  }

  @override
  bool operator ==(Object other) =>
      other is HobbyGoal &&
      other.period == period &&
      other.value == value &&
      other.unit == unit;

  @override
  int get hashCode => Object.hash(period, value, unit);
}

int _amount(HobbyGoalUnit unit, HobbyActivity a) =>
    unit == HobbyGoalUnit.minutes ? a.minutes : a.sessions;

/// Start key of the goal period containing [localDate]: the date itself for
/// a daily goal, the Monday for a weekly one.
String periodStartOf(HobbyGoalPeriod period, String localDate) =>
    period == HobbyGoalPeriod.daily ? localDate : weekStartOf(localDate);

/// Amount logged for [hobbyId] in the goal period starting at [periodStart].
int amountInPeriod({
  required HobbyGoal goal,
  required Iterable<HobbyActivity> activities,
  required String hobbyId,
  required String periodStart,
}) {
  var sum = 0;
  for (final a in activities) {
    if (a.hobbyId != hobbyId) continue;
    if (periodStartOf(goal.period, a.localDate) == periodStart) {
      sum += _amount(goal.unit, a);
    }
  }
  return sum;
}

/// Whether a DAILY [goal] is met on [date]. A weekly goal is never met "on a
/// day": use [weeklyGoalMet].
bool dailyGoalMet({
  required HobbyGoal goal,
  required Iterable<HobbyActivity> activities,
  required String hobbyId,
  required String date,
}) =>
    goal.period == HobbyGoalPeriod.daily &&
    amountInPeriod(
          goal: goal,
          activities: activities,
          hobbyId: hobbyId,
          periodStart: date,
        ) >=
        goal.value;

/// Whether a WEEKLY [goal] is met for the Monday-to-Sunday week starting
/// [weekStart], on any combination of days.
bool weeklyGoalMet({
  required HobbyGoal goal,
  required Iterable<HobbyActivity> activities,
  required String hobbyId,
  required String weekStart,
}) =>
    goal.period == HobbyGoalPeriod.weekly &&
    amountInPeriod(
          goal: goal,
          activities: activities,
          hobbyId: hobbyId,
          periodStart: weekStart,
        ) >=
        goal.value;

/// Period start keys in which [goal] was met for [hobbyId].
Set<String> metPeriods({
  required HobbyGoal goal,
  required Iterable<HobbyActivity> activities,
  required String hobbyId,
}) {
  final totals = <String, int>{};
  for (final a in activities) {
    if (a.hobbyId != hobbyId) continue;
    final key = periodStartOf(goal.period, a.localDate);
    totals[key] = (totals[key] ?? 0) + _amount(goal.unit, a);
  }
  return {
    for (final e in totals.entries)
      if (e.value >= goal.value) e.key,
  };
}

/// Progress towards a goal in the current period, for display.
class HobbyProgress {
  const HobbyProgress({
    required this.goal,
    required this.amount,
    required this.periodStart,
  });

  final HobbyGoal goal;
  final int amount;
  final String periodStart;

  bool get met => amount >= goal.value;
  double get fraction => (amount / goal.value).clamp(0.0, 1.0);

  /// `35 of 60 min today`, `2 of 3 sessions this week`.
  String describe() {
    final unit = goal.unit == HobbyGoalUnit.minutes
        ? 'min'
        : (goal.value == 1 ? 'session' : 'sessions');
    final when = goal.period == HobbyGoalPeriod.daily ? 'today' : 'this week';
    return '$amount of ${goal.value} $unit $when';
  }
}

/// Progress for the day (daily goal) or week (weekly goal) containing [today].
HobbyProgress hobbyProgress({
  required HobbyGoal goal,
  required Iterable<HobbyActivity> activities,
  required String hobbyId,
  required String today,
}) {
  final start = periodStartOf(goal.period, today);
  return HobbyProgress(
    goal: goal,
    amount: amountInPeriod(
      goal: goal,
      activities: activities,
      hobbyId: hobbyId,
      periodStart: start,
    ),
    periodStart: start,
  );
}

/// A streak of consecutive completed goal-periods.
class HobbyStreakInfo {
  const HobbyStreakInfo({
    required this.current,
    required this.longest,
    required this.unit,
  });

  /// No goal, so no streak.
  static const none = HobbyStreakInfo(current: 0, longest: 0, unit: null);

  /// Completed goal-periods in a row, as of today.
  final int current;
  final int longest;

  /// What a period is: days or weeks. Null when no goal exists.
  final HobbyGoalPeriod? unit;

  bool get hasGoal => unit != null;

  String _label(int n) {
    final u = unit == HobbyGoalPeriod.weekly ? 'week' : 'day';
    return '$n-$u goal streak';
  }

  /// `4-week goal streak` or `5-day goal streak`; never "days" for weekly
  /// goals. Empty text when there is nothing to show.
  String get label => !hasGoal || current == 0 ? '' : _label(current);

  String get longestLabel => !hasGoal || longest == 0 ? '' : _label(longest);
}

/// Walks the met periods up to the period containing [today].
HobbyStreakInfo streakOfPeriods({
  required Set<String> met,
  required HobbyGoalPeriod unit,
  required String today,
}) {
  if (met.isEmpty) return HobbyStreakInfo(current: 0, longest: 0, unit: unit);
  final step = unit == HobbyGoalPeriod.daily ? 1 : 7;
  final nowKey = periodStartOf(unit, today);
  var key = met.reduce((a, b) => a.compareTo(b) <= 0 ? a : b);
  var run = 0;
  var longest = 0;
  while (key.compareTo(nowKey) <= 0) {
    if (met.contains(key)) {
      run++;
      if (run > longest) longest = run;
    } else if (key != nowKey) {
      run = 0;
    }
    key = shiftLocalDate(key, step);
  }
  return HobbyStreakInfo(current: run, longest: longest, unit: unit);
}

/// One hobby's goal streak.
HobbyStreakInfo hobbyGoalStreak({
  required HobbyGoal goal,
  required Iterable<HobbyActivity> activities,
  required String hobbyId,
  required String today,
}) => streakOfPeriods(
  met: metPeriods(goal: goal, activities: activities, hobbyId: hobbyId),
  unit: goal.period,
  today: today,
);

/// The aggregated Hobbies streak over active hobbies that have a goal
/// (see the library comment for the definition).
HobbyStreakInfo aggregateHobbyStreak({
  required Map<String, HobbyGoal> goals,
  required Iterable<HobbyActivity> activities,
  required String today,
}) {
  if (goals.isEmpty) return HobbyStreakInfo.none;
  final acts = activities.toList();
  final anyWeekly = goals.values.any((g) => g.period == HobbyGoalPeriod.weekly);
  final met = <String>{};
  if (!anyWeekly) {
    for (final e in goals.entries) {
      met.addAll(metPeriods(goal: e.value, activities: acts, hobbyId: e.key));
    }
    return streakOfPeriods(met: met, unit: HobbyGoalPeriod.daily, today: today);
  }
  for (final e in goals.entries) {
    final days = metPeriods(goal: e.value, activities: acts, hobbyId: e.key);
    if (e.value.period == HobbyGoalPeriod.weekly) {
      met.addAll(days);
    } else {
      final perWeek = <String, int>{};
      for (final d in days) {
        final w = weekStartOf(d);
        perWeek[w] = (perWeek[w] ?? 0) + 1;
      }
      met.addAll([
        for (final w in perWeek.entries)
          if (w.value >= 7) w.key,
      ]);
    }
  }
  return streakOfPeriods(met: met, unit: HobbyGoalPeriod.weekly, today: today);
}

/// Hobby ids whose DAILY goal is met on [date].
Set<String> dailyGoalsMetOn({
  required Map<String, HobbyGoal> goals,
  required Iterable<HobbyActivity> activities,
  required String date,
}) {
  final acts = activities.toList();
  return {
    for (final e in goals.entries)
      if (dailyGoalMet(
        goal: e.value,
        activities: acts,
        hobbyId: e.key,
        date: date,
      ))
        e.key,
  };
}

/// Hobby ids whose WEEKLY goal is met for the week starting [weekStart].
Set<String> weeklyGoalsMetIn({
  required Map<String, HobbyGoal> goals,
  required Iterable<HobbyActivity> activities,
  required String weekStart,
}) {
  final acts = activities.toList();
  return {
    for (final e in goals.entries)
      if (weeklyGoalMet(
        goal: e.value,
        activities: acts,
        hobbyId: e.key,
        weekStart: weekStart,
      ))
        e.key,
  };
}

/// Minutes per hobby over [from]..[to] inclusive local dates (hobbies with no
/// time are left out).
Map<String, int> minutesByHobby(
  Iterable<HobbyActivity> activities, {
  required String from,
  required String to,
}) {
  final out = <String, int>{};
  for (final a in activities) {
    if (a.localDate.compareTo(from) < 0 || a.localDate.compareTo(to) > 0) {
      continue;
    }
    if (a.minutes <= 0) continue;
    out[a.hobbyId] = (out[a.hobbyId] ?? 0) + a.minutes;
  }
  return out;
}
