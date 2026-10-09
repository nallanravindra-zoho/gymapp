import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/features/sleep/sleep_logic.dart';

const bed = 22 * 60 + 30; // 22:30
const wake = 6 * 60 + 30; // 06:30

SleepLog log(
  String date,
  DateTime bedUtc,
  DateTime wakeUtc, {
  int offset = 0,
}) => SleepLog(
  id: date,
  createdAt: wakeUtc,
  updatedAt: wakeUtc,
  deletedAt: null,
  userId: 'u',
  bedtimeAt: bedUtc,
  wakeAt: wakeUtc,
  durationMinutes: wakeUtc.difference(bedUtc).inMinutes,
  tzOffsetMinutes: offset,
  localDate: date,
);

/// A night ending on [date]: bed on the evening before at [bedH:bedM], up at
/// [wakeH:wakeM].
SleepLog night(String date, int bedH, int bedM, int wakeH, int wakeM) {
  final d = DateTime.parse(date);
  final wakeAt = DateTime.utc(d.year, d.month, d.day, wakeH, wakeM);
  var bedAt = DateTime.utc(d.year, d.month, d.day, bedH, bedM);
  if (!bedAt.isBefore(wakeAt)) bedAt = bedAt.subtract(const Duration(days: 1));
  return log(date, bedAt, wakeAt);
}

void main() {
  group('time helpers', () {
    test('minute of day applies the offset', () {
      final t = DateTime.utc(2026, 5, 13, 22, 30);
      expect(minuteOfDay(t, 0), 22 * 60 + 30);
      expect(minuteOfDay(t, 120), 30); // 00:30 next day
      expect(minuteOfDay(t, -60), 21 * 60 + 30);
    });

    test('circular difference wraps midnight', () {
      expect(circularDiff(23 * 60 + 50, 10), 20);
      expect(circularDiff(10, 23 * 60 + 50), 20);
      expect(circularDiff(600, 600), 0);
      expect(circularDiff(0, 720), 720);
    });
  });

  group('on schedule', () {
    bool check(int bedH, int bedM, int wakeH, int wakeM) {
      final n = night('2026-05-13', bedH, bedM, wakeH, wakeM);
      return isOnSchedule(
        bedtimeAt: n.bedtimeAt,
        wakeAt: n.wakeAt,
        offsetMinutes: 0,
        targetBedtimeMinutes: bed,
        targetWakeMinutes: wake,
      );
    }

    test('exactly on target', () => expect(check(22, 30, 6, 30), isTrue));
    test('30 minutes off is within tolerance', () {
      expect(check(23, 0, 7, 0), isTrue);
      expect(check(22, 0, 6, 0), isTrue);
    });
    test('31 minutes off is not', () {
      expect(check(23, 1, 6, 30), isFalse);
      expect(check(22, 30, 7, 1), isFalse);
    });
    test('both times must be within tolerance', () {
      expect(check(22, 30, 8, 0), isFalse);
      expect(check(1, 0, 6, 30), isFalse);
    });
    test('bedtime after midnight near a midnight target', () {
      final n = night('2026-05-13', 0, 10, 6, 30);
      expect(
        isOnSchedule(
          bedtimeAt: n.bedtimeAt,
          wakeAt: n.wakeAt,
          offsetMinutes: 0,
          targetBedtimeMinutes: 23 * 60 + 50,
          targetWakeMinutes: wake,
        ),
        isTrue,
      );
    });
  });

  group('consistency', () {
    SleepConsistency run(List<SleepLog> logs) => sleepConsistency(
      logs: logs,
      targetBedtimeMinutes: bed,
      targetWakeMinutes: wake,
      today: '2026-05-13',
    );

    test('empty week', () {
      final c = run([]);
      expect(c.onSchedule, 0);
      expect(c.days, 7);
      expect(c.logged, 0);
      expect(c.byDate.length, 7);
      expect(c.byDate.keys.first, '2026-05-07');
      expect(c.byDate.keys.last, '2026-05-13');
    });

    test('counts on-schedule nights out of 7', () {
      final c = run([
        night('2026-05-13', 22, 30, 6, 30),
        night('2026-05-12', 22, 45, 6, 40),
        night('2026-05-11', 1, 0, 9, 0), // late
        night('2026-05-10', 22, 20, 6, 20),
        night('2026-05-09', 22, 30, 6, 30),
      ]);
      expect(c.onSchedule, 4);
      expect(c.logged, 5);
      expect(c.byDate['2026-05-11'], isFalse);
      expect(c.byDate['2026-05-08'], isNull);
    });

    test('logs outside the 7-day window are ignored', () {
      final c = run([night('2026-05-06', 22, 30, 6, 30)]);
      expect(c.onSchedule, 0);
      expect(c.logged, 0);
    });

    test('label is the number only, with no judgement', () {
      final c = run([night('2026-05-13', 22, 30, 6, 30)]);
      expect(consistencyLabel(c), '1 of 7 days on schedule.');
    });
  });

  group('resolving times', () {
    test('evening bedtime lands on the previous day', () {
      final r = resolveSleepTimes(
        wakeDate: DateTime(2026, 5, 13),
        bedtimeMinutes: bed,
        wakeMinutes: wake,
      );
      expect(r.bedtime, DateTime(2026, 5, 12, 22, 30));
      expect(r.wake, DateTime(2026, 5, 13, 6, 30));
    });

    test('after-midnight bedtime stays on the wake date', () {
      final r = resolveSleepTimes(
        wakeDate: DateTime(2026, 5, 13),
        bedtimeMinutes: 60,
        wakeMinutes: 9 * 60,
      );
      expect(r.bedtime, DateTime(2026, 5, 13, 1, 0));
    });

    test('month boundary', () {
      final r = resolveSleepTimes(
        wakeDate: DateTime(2026, 6, 1),
        bedtimeMinutes: bed,
        wakeMinutes: wake,
      );
      expect(r.bedtime, DateTime(2026, 5, 31, 22, 30));
    });
  });

  group('copy', () {
    test('duration formats', () {
      expect(formatSleepDuration(440), '7 h 20 min');
      expect(formatSleepDuration(480), '8 h');
      expect(formatSleepDuration(45), '45 min');
    });

    test('logged message follows the microcopy pattern', () {
      expect(sleepLoggedMessage(440), 'Logged. 7 h 20 min sleep.');
      expect(sleepLoggedMessage(440).contains('!'), isFalse);
    });
  });
}
