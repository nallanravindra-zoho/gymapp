import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/local_date.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/seed_tips.dart';
import 'package:wellbeing/features/insights/insight_rules.dart';
import 'package:wellbeing/features/insights/tips.dart';

// Week Mon 2026-05-04 .. Sun 2026-05-10, viewed after it ended.
const week = '2026-05-04';
const prevWeek = '2026-04-27';

String d(int offset, [String from = week]) => shiftLocalDate(from, offset);

InsightInput input({
  Set<String> workouts = const {},
  Set<String> rest = const {},
  bool complete = true,
  String today = '2026-05-12',
  bool hasStretch = false,
  Map<String, double> stretch = const {},
  bool hasWater = false,
  Map<String, bool> water = const {},
  SleepWeek? sleep,
  SleepWeek? prevSleep,
  List<LatePair> pairs = const [],
}) => InsightInput(
  weekStart: week,
  complete: complete,
  today: today,
  periodLabel: complete ? 'last week' : 'this week',
  workoutDates: workouts,
  restDates: rest,
  hasStretch: hasStretch,
  stretchCompletion: stretch,
  hasWater: hasWater,
  waterMet: water,
  sleep: sleep,
  prevSleep: prevSleep,
  latePairs: pairs,
);

Insight? find(List<Insight> xs, String key) =>
    xs.where((i) => i.key == key).firstOrNull;

void main() {
  group('active_days_change', () {
    test('up from last week', () {
      final xs = computeInsights(
        input(
          workouts: {
            d(0), d(1), d(2), d(3), // 4 this week
            d(0, prevWeek), d(1, prevWeek), d(2, prevWeek), // 3 before
          },
        ),
      );
      final i = find(xs, 'active_days_change')!;
      expect(insightText(i), '4 active days last week, up from 3.');
    });

    test('down from last week', () {
      final xs = computeInsights(
        input(workouts: {d(0), for (var k = 0; k < 4; k++) d(k, prevWeek)}),
      );
      expect(
        insightText(find(xs, 'active_days_change')!),
        '1 active day last week, down from 4.',
      );
    });

    test('same as last week says nothing', () {
      final xs = computeInsights(
        input(workouts: {d(0), d(1), d(0, prevWeek), d(1, prevWeek)}),
      );
      expect(find(xs, 'active_days_change'), isNull);
    });

    test('two workouts on one day count as one active day', () {
      // Sets hold dates, so this is the same as one.
      final xs = computeInsights(input(workouts: {d(0)}));
      expect(find(xs, 'active_days_change')!.params['days'], 1);
    });

    test('midweek, a drop is not reported but a rise is', () {
      final partialDown = computeInsights(
        input(
          complete: false,
          today: d(2),
          workouts: {d(0), for (var k = 0; k < 5; k++) d(k, prevWeek)},
        ),
      );
      expect(find(partialDown, 'active_days_change'), isNull);

      final partialUp = computeInsights(
        input(
          complete: false,
          today: d(3),
          workouts: {d(0), d(1), d(2), d(0, prevWeek)},
        ),
      );
      expect(
        insightText(find(partialUp, 'active_days_change')!),
        '3 active days this week, up from 1.',
      );
    });
  });

  group('longest_gap', () {
    test('three days without activity is reported with the weekdays', () {
      final xs = computeInsights(input(workouts: {d(0), d(1), d(5), d(6)}));
      expect(
        insightText(find(xs, 'longest_gap')!),
        'Longest gap: 3 days (Wed to Fri).',
      );
    });

    test('two days is not a gap', () {
      final xs = computeInsights(
        input(workouts: {d(0), d(1), d(4), d(5), d(6)}),
      );
      expect(find(xs, 'longest_gap'), isNull);
    });

    test('rest days break a gap', () {
      final xs = computeInsights(
        input(
          workouts: {d(0), d(1), d(5), d(6)},
          rest: {d(3)}, // Wed, Thu rest, Fri: gaps of 1 and 1
        ),
      );
      expect(find(xs, 'longest_gap'), isNull);
    });

    test('the longest of several gaps is reported', () {
      final xs = computeInsights(input(workouts: {d(0), d(4)}));
      // Tue-Thu is 3 days; Sat-Sun is 2.
      final i = find(xs, 'longest_gap')!;
      expect(i.params['length'], 3);
    });

    test('is not reported for someone with no activity at all', () {
      expect(find(computeInsights(input()), 'longest_gap'), isNull);
    });

    test('midweek, today is not counted as a gap day', () {
      final xs = computeInsights(
        input(
          complete: false,
          today: d(3), // Thursday morning
          workouts: {d(0)},
        ),
      );
      // Tue and Wed are closed: 2 days, not 3.
      expect(find(xs, 'longest_gap'), isNull);
    });
  });

  group('water_consistency', () {
    Map<String, bool> met(int n) => {for (var k = 0; k < 7; k++) d(k): k < n};

    test('five days of seven is reported', () {
      final xs = computeInsights(input(hasWater: true, water: met(5)));
      expect(
        insightText(find(xs, 'water_consistency')!),
        'Water target met on 5 of 7 days.',
      );
    });

    test('four days is not', () {
      expect(
        find(
          computeInsights(input(hasWater: true, water: met(4))),
          'water_consistency',
        ),
        isNull,
      );
    });

    test('needs a water habit', () {
      expect(
        find(computeInsights(input(water: met(7))), 'water_consistency'),
        isNull,
      );
    });
  });

  group('stretch_on_workout_days', () {
    Map<String, double> stretch(double on, double off, Set<String> w) => {
      for (var k = 0; k < 7; k++) d(k): w.contains(d(k)) ? on : off,
    };
    final w = {d(0), d(2), d(4)};

    test('20 points higher on workout days is reported', () {
      final xs = computeInsights(
        input(workouts: w, hasStretch: true, stretch: stretch(1.0, 0.8, w)),
      );
      expect(
        insightText(find(xs, 'stretch_on_workout_days')!),
        'Stretch breaks were completed more often on workout days.',
      );
    });

    test('19 points is not enough', () {
      final xs = computeInsights(
        input(workouts: w, hasStretch: true, stretch: stretch(0.99, 0.80, w)),
      );
      expect(find(xs, 'stretch_on_workout_days'), isNull);
    });

    test('needs at least two days of each kind', () {
      final one = {d(0)};
      final xs = computeInsights(
        input(workouts: one, hasStretch: true, stretch: stretch(1.0, 0.0, one)),
      );
      expect(find(xs, 'stretch_on_workout_days'), isNull);
    });

    test('needs a stretch habit', () {
      final xs = computeInsights(
        input(workouts: w, stretch: stretch(1.0, 0.0, w)),
      );
      expect(find(xs, 'stretch_on_workout_days'), isNull);
    });
  });

  group('sleep_consistency', () {
    test('shows how many days matched', () {
      final xs = computeInsights(
        input(sleep: const SleepWeek(matched: 5, logged: 6, days: 7)),
      );
      expect(
        insightText(find(xs, 'sleep_consistency')!),
        'Sleep schedule matched on 5 of 7 days.',
      );
    });

    test('adds the change from the week before', () {
      final up = computeInsights(
        input(
          sleep: const SleepWeek(matched: 5, logged: 6, days: 7),
          prevSleep: const SleepWeek(matched: 3, logged: 5, days: 7),
        ),
      );
      expect(
        insightText(find(up, 'sleep_consistency')!),
        'Sleep schedule matched on 5 of 7 days, up from 3.',
      );
      final down = computeInsights(
        input(
          sleep: const SleepWeek(matched: 2, logged: 6, days: 7),
          prevSleep: const SleepWeek(matched: 4, logged: 5, days: 7),
        ),
      );
      expect(
        insightText(find(down, 'sleep_consistency')!),
        'Sleep schedule matched on 2 of 7 days, down from 4.',
      );
    });

    test('an unchanged score is stated once', () {
      final xs = computeInsights(
        input(
          sleep: const SleepWeek(matched: 4, logged: 5, days: 7),
          prevSleep: const SleepWeek(matched: 4, logged: 5, days: 7),
        ),
      );
      expect(
        insightText(find(xs, 'sleep_consistency')!),
        'Sleep schedule matched on 4 of 7 days.',
      );
    });

    test('nothing is said when no sleep was logged', () {
      final xs = computeInsights(
        input(sleep: const SleepWeek(matched: 0, logged: 0, days: 7)),
      );
      expect(find(xs, 'sleep_consistency'), isNull);
    });
  });

  group('screen_time_late', () {
    LatePair p(int late, int bed) =>
        LatePair(lateMinutes: late, bedtimeOffset: bed);

    test('later beds after heavier evenings are reported', () {
      final xs = computeInsights(
        input(
          pairs: [
            p(10, 240), p(15, 250), p(20, 245), // light evenings, bed ~22:10
            p(90, 300), p(100, 310), p(120, 305), // heavy, bed ~23:05
          ],
        ),
      );
      expect(
        insightText(find(xs, 'screen_time_late')!),
        'Later bedtimes followed higher evening screen time.',
      );
    });

    test('a difference under 30 minutes is not', () {
      final xs = computeInsights(
        input(pairs: [p(10, 240), p(15, 245), p(90, 260), p(100, 262)]),
      );
      expect(find(xs, 'screen_time_late'), isNull);
    });

    test('needs at least four nights of data', () {
      final xs = computeInsights(
        input(pairs: [p(10, 100), p(120, 400), p(110, 390)]),
      );
      expect(find(xs, 'screen_time_late'), isNull);
    });

    test('identical evenings give no insight', () {
      final xs = computeInsights(
        input(pairs: [p(60, 300), p(60, 300), p(60, 300), p(60, 300)]),
      );
      expect(find(xs, 'screen_time_late'), isNull);
    });
  });

  test('the first morning of a new week has nothing to report', () {
    final xs = computeInsights(
      input(complete: false, today: week, workouts: {prevWeek}),
    );
    expect(xs, isEmpty);
  });

  test('every insight text follows the microcopy rules', () {
    final samples = [
      const Insight('stretch_on_workout_days', {}),
      const Insight('active_days_change', {
        'days': 4,
        'prev': 3,
        'direction': 'up',
        'period': 'this week',
      }),
      Insight('longest_gap', {'length': 3, 'from': d(1), 'to': d(3)}),
      const Insight('water_consistency', {'met': 5, 'days': 7}),
      const Insight('sleep_consistency', {'matched': 5, 'days': 7, 'prev': 3}),
      const Insight('screen_time_late', {}),
    ];
    for (final i in samples) {
      final t = insightText(i);
      expect(t, isNotEmpty);
      expect(t.contains('!'), isFalse);
      expect(
        RegExp(
          r'you missed|don.t break|should|failed|good|bad|great',
          caseSensitive: false,
        ).hasMatch(t),
        isFalse,
        reason: t,
      );
    }
    expect(samples.map((s) => s.key).toSet(), insightKeys.toSet());
  });

  group('tips', () {
    final library = [
      for (final t in seedTips)
        TipsLibraryData(
          id: t.id,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
          deletedAt: null,
          triggerKey: t.triggerKey,
          body: t.text,
          sourceLabel: seedTipSource,
          isActive: true,
        ),
    ];

    List<Insight> all() => [for (final k in insightKeys) Insight(k, const {})];

    test('at most one per insight and three per week', () {
      final tips = selectTips(
        insights: all(),
        library: library,
        weekStart: week,
      );
      expect(tips.length, 3);
      expect(tips.map((t) => t.insightKey).toSet().length, 3);
    });

    test('gives priority to insights that suggest something to try', () {
      final tips = selectTips(
        insights: all(),
        library: library,
        weekStart: week,
      );
      expect(tips.map((t) => t.insightKey), [
        'longest_gap',
        'screen_time_late',
        'sleep_consistency',
      ]);
    });

    test('only tips for insights that fired', () {
      final tips = selectTips(
        insights: [const Insight('water_consistency', {})],
        library: library,
        weekStart: week,
      );
      expect(tips.length, 1);
      expect(tips.single.insightKey, 'water_consistency');
    });

    test('no insights, no tips', () {
      expect(
        selectTips(insights: [], library: library, weekStart: week),
        isEmpty,
      );
    });

    test('stable for a week, and varies between weeks', () {
      String pick(String w) => selectTips(
        insights: [const Insight('longest_gap', {})],
        library: library,
        weekStart: w,
      ).single.text;
      expect(pick(week), pick(week));
      final seen = {
        for (var k = 0; k < 12; k++) pick(shiftLocalDate(week, -7 * k)),
      };
      expect(seen.length, greaterThan(1));
    });

    test('inactive and deleted tips are skipped', () {
      final only = library.where((t) => t.triggerKey == 'longest_gap').toList();
      final off = [for (final t in only) t.copyWith(isActive: false)];
      expect(
        selectTips(
          insights: [const Insight('longest_gap', {})],
          library: off,
          weekStart: week,
        ),
        isEmpty,
      );
    });

    test('the library is complete and follows the rules', () {
      for (final key in insightKeys) {
        expect(
          seedTips.where((t) => t.triggerKey == key).length,
          greaterThanOrEqualTo(2),
          reason: '$key needs at least two tips',
        );
      }
      expect(seedTips.map((t) => t.id).toSet().length, seedTips.length);
      for (final t in seedTips) {
        expect(t.text.contains('!'), isFalse, reason: t.id);
        expect(t.text.length, lessThan(160), reason: t.id);
        expect(
          RegExp(
            r'\b(lose weight|cure|treat|diagnos|disease|medication|never|must|always)\b',
            caseSensitive: false,
          ).hasMatch(t.text),
          isFalse,
          reason: t.id,
        );
        // No numeric goals: tips avoid extreme or specific targets.
        expect(RegExp(r'\d').hasMatch(t.text), isFalse, reason: t.id);
      }
      expect(tipFooter, 'General wellness suggestion. Not medical advice.');
    });
  });
}
