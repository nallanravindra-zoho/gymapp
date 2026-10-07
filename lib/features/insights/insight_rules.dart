import 'package:flutter/material.dart';

import '../../core/time/local_date.dart';

/// One observation about a week: a key plus the numbers behind it. The text
/// is produced from a template, so it is always plain, factual and brief.
class Insight {
  const Insight(this.key, this.params);

  final String key;
  final Map<String, Object> params;
}

const insightKeys = [
  'stretch_on_workout_days',
  'active_days_change',
  'longest_gap',
  'water_consistency',
  'sleep_consistency',
  'screen_time_late',
];

const _weekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String _weekday(String date) => _weekdayShort[parseLocalDate(date).weekday - 1];

String _plural(int n, String one, String many) =>
    n == 1 ? '$n $one' : '$n $many';

/// Text templates (spec 7.7 and 4.5): facts only, no verdicts, no guilt.
String insightText(Insight i) {
  final p = i.params;
  switch (i.key) {
    case 'stretch_on_workout_days':
      return 'Stretch breaks were completed more often on workout days.';
    case 'active_days_change':
      final days = p['days'] as int;
      final prev = p['prev'] as int;
      final dir = p['direction'] as String;
      return '${_plural(days, 'active day', 'active days')} ${p['period']}, '
          '$dir from $prev.';
    case 'longest_gap':
      final len = p['length'] as int;
      return 'Longest gap: ${_plural(len, 'day', 'days')} '
          '(${_weekday(p['from'] as String)} to ${_weekday(p['to'] as String)}).';
    case 'water_consistency':
      return 'Water target met on ${p['met']} of ${p['days']} days.';
    case 'sleep_consistency':
      final base =
          'Sleep schedule matched on ${p['matched']} of ${p['days']} days';
      final prev = p['prev'];
      if (prev is int && prev != p['matched']) {
        return '$base, ${(p['matched'] as int) > prev ? 'up' : 'down'} from $prev.';
      }
      return '$base.';
    case 'screen_time_late':
      return 'Later bedtimes followed higher evening screen time.';
  }
  return '';
}

IconData insightIcon(String key) => switch (key) {
  'stretch_on_workout_days' => Icons.self_improvement_rounded,
  'active_days_change' => Icons.calendar_today_outlined,
  'longest_gap' => Icons.timeline_rounded,
  'water_consistency' => Icons.water_drop_outlined,
  'sleep_consistency' => Icons.bedtime_outlined,
  'screen_time_late' => Icons.smartphone_outlined,
  _ => Icons.lightbulb_outline,
};

/// How a week of sleep matched the targets.
class SleepWeek {
  const SleepWeek({
    required this.matched,
    required this.logged,
    required this.days,
  });

  final int matched;
  final int logged;
  final int days;
}

/// A night's pair: evening screen time and when bed followed.
class LatePair {
  const LatePair({required this.lateMinutes, required this.bedtimeOffset});

  /// Screen minutes after 9 PM that evening.
  final int lateMinutes;

  /// Minutes after 18:00 at which the person went to bed.
  final int bedtimeOffset;
}

/// Everything the rules look at for one week.
class InsightInput {
  const InsightInput({
    required this.weekStart,
    required this.complete,
    required this.today,
    required this.periodLabel,
    required this.workoutDates,
    required this.restDates,
    this.hasStretch = false,
    this.stretchCompletion = const {},
    this.hasWater = false,
    this.waterMet = const {},
    this.sleep,
    this.prevSleep,
    this.latePairs = const [],
  });

  /// Monday of the week.
  final String weekStart;

  /// The whole week is in the past.
  final bool complete;
  final String today;

  /// `last week` or `this week`, used in the wording.
  final String periodLabel;

  /// Dates with at least one workout, covering this and the previous week.
  final Set<String> workoutDates;
  final Set<String> restDates;

  final bool hasStretch;

  /// Date -> share of the stretch target reached (0 to 1).
  final Map<String, double> stretchCompletion;

  final bool hasWater;

  /// Date -> whether the water target was met.
  final Map<String, bool> waterMet;

  final SleepWeek? sleep;
  final SleepWeek? prevSleep;
  final List<LatePair> latePairs;

  String get weekEnd => shiftLocalDate(weekStart, 6);

  /// Last day that is over. For the current week this is yesterday, since
  /// today is still going.
  String get lastClosedDay => complete ? weekEnd : shiftLocalDate(today, -1);

  /// Last day whose workouts count (today counts if it already has one).
  String get lastCountedDay => complete ? weekEnd : today;
}

List<String> _datesBetween(String from, String to) {
  final out = <String>[];
  for (var d = from; d.compareTo(to) <= 0; d = shiftLocalDate(d, 1)) {
    out.add(d);
  }
  return out;
}

/// Runs the rules from spec 7.7, in the order the spec lists them.
List<Insight> computeInsights(InsightInput i) {
  final out = <Insight>[];
  final closed = _datesBetween(i.weekStart, i.lastClosedDay);

  // The first day of a new week has nothing finished to talk about.
  if (closed.isEmpty && i.lastCountedDay.compareTo(i.weekStart) < 0) return out;

  // stretch_on_workout_days: completion at least 20 points higher on workout
  // days, with enough days of each kind to compare.
  if (i.hasStretch) {
    final onWorkout = <double>[];
    final other = <double>[];
    for (final d in closed) {
      final v = i.stretchCompletion[d] ?? 0.0;
      (i.workoutDates.contains(d) ? onWorkout : other).add(v);
    }
    if (onWorkout.length >= 2 && other.length >= 2) {
      double avg(List<double> xs) => xs.reduce((a, b) => a + b) / xs.length;
      // A small tolerance, so exactly 20 points counts despite rounding.
      if (avg(onWorkout) - avg(other) >= 0.20 - 1e-9) {
        out.add(const Insight('stretch_on_workout_days', {}));
      }
    }
  }

  // active_days_change: active days differ from the previous week. Midweek,
  // only a rise is reported, since the week is not finished.
  final active = _datesBetween(
    i.weekStart,
    i.lastCountedDay,
  ).where(i.workoutDates.contains).length;
  final prevStart = shiftLocalDate(i.weekStart, -7);
  final prevActive = _datesBetween(
    prevStart,
    shiftLocalDate(i.weekStart, -1),
  ).where(i.workoutDates.contains).length;
  if (active != prevActive && (i.complete || active > prevActive)) {
    out.add(
      Insight('active_days_change', {
        'days': active,
        'prev': prevActive,
        'direction': active > prevActive ? 'up' : 'down',
        'period': i.periodLabel,
      }),
    );
  }

  // longest_gap: three or more days in a row with neither a workout nor a
  // recorded rest day. Only once the person has been active recently.
  if (active > 0 || prevActive > 0) {
    var run = 0;
    var best = 0;
    String? bestFrom;
    String? bestTo;
    String? runFrom;
    for (final d in closed) {
      if (i.workoutDates.contains(d) || i.restDates.contains(d)) {
        run = 0;
        runFrom = null;
      } else {
        runFrom ??= d;
        run++;
        if (run > best) {
          best = run;
          bestFrom = runFrom;
          bestTo = d;
        }
      }
    }
    if (best >= 3) {
      out.add(
        Insight('longest_gap', {
          'length': best,
          'from': bestFrom!,
          'to': bestTo!,
        }),
      );
    }
  }

  // water_consistency: target met on five or more days.
  if (i.hasWater && closed.isNotEmpty) {
    final met = closed.where((d) => i.waterMet[d] == true).length;
    if (met >= 5) {
      out.add(
        Insight('water_consistency', {'met': met, 'days': closed.length}),
      );
    }
  }

  // sleep_consistency: how the week matched the targets, with the change from
  // the week before when that was logged too.
  final s = i.sleep;
  if (s != null && s.logged > 0) {
    final prev = i.prevSleep;
    out.add(
      Insight('sleep_consistency', {
        'matched': s.matched,
        'days': s.days,
        if (prev != null && prev.logged > 0) 'prev': prev.matched,
      }),
    );
  }

  // screen_time_late: on evenings with more late screen time, bed was at
  // least half an hour later than on the lighter evenings.
  if (i.latePairs.length >= 4) {
    final sorted = [...i.latePairs]
      ..sort((a, b) => a.lateMinutes.compareTo(b.lateMinutes));
    final median = sorted[sorted.length ~/ 2].lateMinutes;
    final high = i.latePairs.where((p) => p.lateMinutes > median).toList();
    final low = i.latePairs.where((p) => p.lateMinutes <= median).toList();
    if (high.isNotEmpty && low.isNotEmpty) {
      double avg(List<LatePair> xs) =>
          xs.map((p) => p.bedtimeOffset).reduce((a, b) => a + b) / xs.length;
      if (avg(high) - avg(low) >= 30) {
        out.add(const Insight('screen_time_late', {}));
      }
    }
  }

  return out;
}
