import '../../core/time/local_date.dart';
import '../../data/app_database.dart';

/// Used until the user sets their own targets.
const defaultBedtimeMinutes = 22 * 60 + 30;
const defaultWakeMinutes = 6 * 60 + 30;

/// A night counts as on schedule when both bedtime and wake time are within
/// this many minutes of the targets (spec 7.5).
const scheduleToleranceMinutes = 30;

/// Local minute of day (0-1439) of [instant] under a UTC [offsetMinutes].
int minuteOfDay(DateTime instant, int offsetMinutes) {
  final local = instant.toUtc().add(Duration(minutes: offsetMinutes));
  return local.hour * 60 + local.minute;
}

/// Shortest distance between two times of day, across midnight.
int circularDiff(int a, int b) {
  final d = (a - b).abs() % 1440;
  return d > 720 ? 1440 - d : d;
}

bool isOnSchedule({
  required DateTime bedtimeAt,
  required DateTime wakeAt,
  required int offsetMinutes,
  required int targetBedtimeMinutes,
  required int targetWakeMinutes,
}) =>
    circularDiff(minuteOfDay(bedtimeAt, offsetMinutes), targetBedtimeMinutes) <=
        scheduleToleranceMinutes &&
    circularDiff(minuteOfDay(wakeAt, offsetMinutes), targetWakeMinutes) <=
        scheduleToleranceMinutes;

/// Last-7-days consistency (spec 7.5): how many of the days ended on
/// schedule. Days without a log count as not on schedule.
class SleepConsistency {
  const SleepConsistency({
    required this.onSchedule,
    required this.days,
    required this.byDate,
  });

  final int onSchedule;
  final int days;

  /// Oldest first. true = on schedule, false = logged but off schedule,
  /// null = nothing logged.
  final Map<String, bool?> byDate;

  int get logged => byDate.values.where((v) => v != null).length;
}

SleepConsistency sleepConsistency({
  required List<SleepLog> logs,
  required int targetBedtimeMinutes,
  required int targetWakeMinutes,
  required String today,
  int days = 7,
}) {
  final byDate = <String, bool?>{
    for (var i = days - 1; i >= 0; i--) shiftLocalDate(today, -i): null,
  };
  for (final l in logs) {
    if (!byDate.containsKey(l.localDate)) continue;
    byDate[l.localDate] = isOnSchedule(
      bedtimeAt: l.bedtimeAt,
      wakeAt: l.wakeAt,
      offsetMinutes: l.tzOffsetMinutes,
      targetBedtimeMinutes: targetBedtimeMinutes,
      targetWakeMinutes: targetWakeMinutes,
    );
  }
  return SleepConsistency(
    onSchedule: byDate.values.where((v) => v == true).length,
    days: days,
    byDate: byDate,
  );
}

/// Turns two times of day into real moments around a wake date. The bedtime
/// is the latest occurrence before waking, so 22:30 and 06:30 give the
/// previous evening. Returns device-local times.
({DateTime bedtime, DateTime wake}) resolveSleepTimes({
  required DateTime wakeDate,
  required int bedtimeMinutes,
  required int wakeMinutes,
}) {
  final wake = DateTime(
    wakeDate.year,
    wakeDate.month,
    wakeDate.day,
    wakeMinutes ~/ 60,
    wakeMinutes % 60,
  );
  var bed = DateTime(
    wakeDate.year,
    wakeDate.month,
    wakeDate.day,
    bedtimeMinutes ~/ 60,
    bedtimeMinutes % 60,
  );
  if (!bed.isBefore(wake)) {
    bed = DateTime(
      wakeDate.year,
      wakeDate.month,
      wakeDate.day - 1,
      bedtimeMinutes ~/ 60,
      bedtimeMinutes % 60,
    );
  }
  return (bedtime: bed, wake: wake);
}

/// `7 h 20 min`, `8 h`, `45 min`.
String formatSleepDuration(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '$m min';
  if (m == 0) return '$h h';
  return '$h h $m min';
}

/// `Logged. 7 h 20 min sleep.`
String sleepLoggedMessage(int minutes) =>
    'Logged. ${formatSleepDuration(minutes)} sleep.';

String consistencyLabel(SleepConsistency c) =>
    '${c.onSchedule} of ${c.days} days on schedule.';
