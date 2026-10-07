import '../../core/time/local_date.dart';

/// Result of walking a series of local dates (spec 7.2). Streaks are always
/// recomputed from logs; stored values are only a cache.
class StreakResult {
  const StreakResult({
    required this.current,
    required this.longest,
    required this.lastCountedDate,
    required this.freezeAvailable,
    required this.freezeDates,
  });

  const StreakResult.empty({this.freezeAvailable = false})
    : current = 0,
      longest = 0,
      lastCountedDate = null,
      freezeDates = const [];

  final int current;
  final int longest;
  final String? lastCountedDate;

  /// Whether a freeze could be applied to a missed day starting today.
  final bool freezeAvailable;

  /// Days a freeze was applied to, oldest first.
  final List<String> freezeDates;

  String? get lastFreezeDate => freezeDates.isEmpty ? null : freezeDates.last;
}

/// Computes a streak over [counted] local dates, evaluated as of [today].
///
/// * Each counted day extends the streak by one.
/// * A day in [bridge] (a recorded rest day) keeps the streak alive without
///   extending it.
/// * Any other past day breaks the streak, unless a freeze is available: one
///   freeze can cover a single missed day, and the next one is available
///   [freezeIntervalDays] days after the last was used.
/// * [today] never breaks a streak: the day is still open.
StreakResult computeStreak({
  required Set<String> counted,
  required String today,
  Set<String> bridge = const {},
  bool freezeEnabled = false,
  int freezeIntervalDays = 7,
}) {
  if (counted.isEmpty) {
    return StreakResult.empty(freezeAvailable: freezeEnabled);
  }

  var day = counted.reduce((a, b) => a.compareTo(b) <= 0 ? a : b);
  var current = 0;
  var longest = 0;
  String? lastCounted;
  String? lastFreeze;
  final freezeDates = <String>[];

  while (day.compareTo(today) <= 0) {
    if (counted.contains(day)) {
      current++;
      if (current > longest) longest = current;
      lastCounted = day;
    } else if (bridge.contains(day) || day == today) {
      // Rest day, or a day that is not over yet: streak unchanged.
    } else if (current > 0) {
      final canFreeze =
          freezeEnabled &&
          (lastFreeze == null ||
              _daysBetween(lastFreeze, day) >= freezeIntervalDays);
      if (canFreeze) {
        lastFreeze = day;
        freezeDates.add(day);
      } else {
        current = 0;
      }
    }
    day = shiftLocalDate(day, 1);
  }

  final freezeAvailable =
      freezeEnabled &&
      (lastFreeze == null ||
          _daysBetween(lastFreeze, today) >= freezeIntervalDays);

  return StreakResult(
    current: current,
    longest: longest,
    lastCountedDate: lastCounted,
    freezeAvailable: freezeAvailable,
    freezeDates: freezeDates,
  );
}

int _daysBetween(String from, String to) =>
    parseLocalDate(to).difference(parseLocalDate(from)).inDays;
