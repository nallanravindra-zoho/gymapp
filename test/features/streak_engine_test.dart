import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/local_date.dart';
import 'package:wellbeing/features/streaks/badges.dart';
import 'package:wellbeing/features/streaks/streak_engine.dart';

/// Dates relative to a fixed "today" of 2026-05-20 (a Wednesday).
const today = '2026-05-20';
String d(int daysAgo) => shiftLocalDate(today, -daysAgo);
Set<String> days(List<int> ago) => {for (final a in ago) d(a)};

StreakResult run(
  List<int> countedAgo, {
  List<int> restAgo = const [],
  bool freeze = false,
  int interval = 7,
}) => computeStreak(
  counted: days(countedAgo),
  bridge: days(restAgo),
  today: today,
  freezeEnabled: freeze,
  freezeIntervalDays: interval,
);

void main() {
  group('basic streaks', () {
    test('no activity', () {
      final r = run([]);
      expect(r.current, 0);
      expect(r.longest, 0);
    });

    test('consecutive days including today', () {
      expect(run([0, 1, 2]).current, 3);
    });

    test('today not yet logged does not break the streak', () {
      final r = run([1, 2, 3]);
      expect(r.current, 3);
    });

    test('a missed past day breaks it', () {
      final r = run([0, 1, 3, 4, 5]);
      expect(r.current, 2);
      expect(r.longest, 3);
    });

    test('longest is kept after the streak ends', () {
      final r = run([10, 11, 12, 13, 14]);
      expect(r.current, 0);
      expect(r.longest, 5);
    });

    test('several workouts on one day count once', () {
      // Sets de-duplicate, so one date is one day.
      expect(computeStreak(counted: {d(0), d(0)}, today: today).current, 1);
    });
  });

  group('rest days', () {
    test('keep the streak alive without extending it', () {
      // Worked out 3 days ago and 1 day ago, rested 2 days ago.
      final r = run([3, 1], restAgo: [2]);
      expect(r.current, 2);
    });

    test('two rest days in a row still bridge', () {
      final r = run([4, 1], restAgo: [3, 2]);
      expect(r.current, 2);
    });

    test('a rest day alone does not start a streak', () {
      final r = run([], restAgo: [1]);
      expect(r.current, 0);
    });

    test('rest days do not extend the count', () {
      final withRest = run([5, 4, 1, 0], restAgo: [3, 2]);
      expect(withRest.current, 4);
    });

    test('a gap not covered by rest still breaks', () {
      final r = run([4, 1], restAgo: [3]);
      expect(r.current, 1);
    });
  });

  group('freeze', () {
    test('covers a single missed day', () {
      final r = run([3, 2, 0], freeze: true); // missed 1 day ago
      expect(r.current, 3);
      expect(r.freezeDates, [d(1)]);
      expect(r.lastFreezeDate, d(1));
    });

    test('does not cover two missed days in a row', () {
      final r = run([4, 3, 0], freeze: true); // missed 2 and 1 days ago
      expect(r.current, 1);
    });

    test('is off when disabled', () {
      expect(run([3, 2, 0]).current, 1);
    });

    test('only one freeze per interval', () {
      // Missed 5 days ago (frozen) and 1 day ago (no freeze left).
      final r = run([7, 6, 4, 3, 2, 0], freeze: true);
      expect(r.freezeDates, [d(5)]);
      expect(r.current, 1);
    });

    test('is available again after the interval', () {
      // Frozen 9 days ago, so a second freeze is allowed 1 day ago.
      final r = run([11, 10, 8, 7, 6, 5, 4, 3, 2, 0], freeze: true);
      expect(r.freezeDates, [d(9), d(1)]);
      expect(r.current, 10);
    });

    test('interval is configurable', () {
      // With a 3-day interval, two misses 3 days apart are both covered.
      final r = run([6, 5, 3, 2, 0], freeze: true, interval: 3);
      expect(r.freezeDates, [d(4), d(1)]);
      expect(r.current, 5);
    });

    test('freezeAvailable reflects the last use', () {
      expect(run([3, 2, 0], freeze: true).freezeAvailable, isFalse);
      expect(run([3, 2, 1, 0], freeze: true).freezeAvailable, isTrue);
      expect(run([3, 2, 1, 0]).freezeAvailable, isFalse);
    });

    test('freeze does not extend the count', () {
      expect(run([2, 0], freeze: true).current, 2);
    });
  });

  group('edits and deletes', () {
    test('removing a day recomputes correctly', () {
      final before = run([0, 1, 2, 3, 4]);
      final after = run([0, 1, 3, 4]); // day 2 deleted
      expect(before.current, 5);
      expect(after.current, 2);
    });

    test('moving an entry to another day recomputes correctly', () {
      expect(run([0, 1, 3]).current, 2);
      expect(run([0, 1, 2]).current, 3);
    });
  });

  group('badges', () {
    test('milestones due at 7, 30 and 100 days', () {
      expect(
        milestonesDue(scope: 'overall', currentStreak: 6, alreadyAwarded: {}),
        isEmpty,
      );
      expect(
        milestonesDue(scope: 'overall', currentStreak: 7, alreadyAwarded: {}),
        [7],
      );
      expect(
        milestonesDue(scope: 'overall', currentStreak: 31, alreadyAwarded: {}),
        [7, 30],
      );
      expect(
        milestonesDue(scope: 'overall', currentStreak: 120, alreadyAwarded: {}),
        [7, 30, 100],
      );
    });

    test('each badge is awarded once', () {
      expect(
        milestonesDue(
          scope: 'overall',
          currentStreak: 31,
          alreadyAwarded: {streakBadgeKey('overall', 7)},
        ),
        [30],
      );
    });

    test('copy follows the microcopy rules', () {
      expect(streakMessage(5), '5-day streak.');
      expect(milestoneMessage(7), '7-day streak reached.');
      expect(milestoneMessage(7).contains('!'), isFalse);
    });
  });
}
