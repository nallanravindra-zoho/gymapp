import 'dart:convert';

enum ReminderMode { times, interval }

/// Repeat intervals offered in setup, in minutes (R4): 30 minutes, then
/// 1, 2, 3 and 4 hours.
const reminderIntervals = [30, 60, 120, 180, 240];

/// Shown in red when the To time is earlier than the From time (R4). An
/// overnight window such as 11 PM to 6 AM is not supported in this version, so
/// it is rejected rather than quietly wrapped past midnight.
const windowOrderMessage =
    'The To time cannot be earlier than the From time. Overnight windows '
    'are not supported yet, so choose a window within one day.';

/// When a habit's reminders fire (spec 5, Healthy Habits): either at fixed
/// times, or every N minutes inside a window, on chosen days of the week.
class ReminderConfig {
  const ReminderConfig({
    this.mode = ReminderMode.interval,
    this.times = const [],
    this.windowStart = 9 * 60,
    this.windowEnd = 17 * 60,
    this.everyMinutes = 120,
    this.activeDays = const {1, 2, 3, 4, 5, 6, 7},
  });

  final ReminderMode mode;

  /// Minutes after local midnight, for [ReminderMode.times].
  final List<int> times;

  /// Window and step for [ReminderMode.interval], in minutes after midnight.
  final int windowStart;
  final int windowEnd;
  final int everyMinutes;

  /// ISO weekdays, 1 = Monday ... 7 = Sunday.
  final Set<int> activeDays;

  /// True when an interval window ends before it starts. Such a config fires
  /// at nothing: the window is never wrapped past midnight.
  bool get windowReversed =>
      mode == ReminderMode.interval && windowEnd < windowStart;

  /// What is wrong with this config, or null when it is valid.
  String? get problem {
    if (windowReversed) return windowOrderMessage;
    if (mode == ReminderMode.times && minutesOfDay.isEmpty) {
      return 'Add at least one reminder time.';
    }
    if (activeDays.isEmpty) return 'Choose at least one day.';
    return null;
  }

  /// How many times a day this config fires (both ends of an interval window
  /// count: 12:00 to 17:00 every hour is six).
  int get occurrences => minutesOfDay.length;

  /// Every minute-of-day this config fires at, sorted and de-duplicated.
  List<int> get minutesOfDay {
    final out = <int>{};
    switch (mode) {
      case ReminderMode.times:
        out.addAll(times.where((m) => m >= 0 && m < 1440));
      case ReminderMode.interval:
        if (everyMinutes > 0) {
          for (
            var m = windowStart;
            m <= windowEnd && m < 1440;
            m += everyMinutes
          ) {
            if (m >= 0) out.add(m);
          }
        }
    }
    return out.toList()..sort();
  }

  ReminderConfig copyWith({
    ReminderMode? mode,
    List<int>? times,
    int? windowStart,
    int? windowEnd,
    int? everyMinutes,
    Set<int>? activeDays,
  }) => ReminderConfig(
    mode: mode ?? this.mode,
    times: times ?? this.times,
    windowStart: windowStart ?? this.windowStart,
    windowEnd: windowEnd ?? this.windowEnd,
    everyMinutes: everyMinutes ?? this.everyMinutes,
    activeDays: activeDays ?? this.activeDays,
  );

  String toJson() => jsonEncode({
    'mode': mode.name,
    'times': times,
    'start': windowStart,
    'end': windowEnd,
    'every': everyMinutes,
    'days': (activeDays.toList()..sort()),
  });

  /// Tolerant of missing or malformed data: falls back to defaults.
  static ReminderConfig fromJson(String? raw) {
    if (raw == null || raw.isEmpty) return const ReminderConfig();
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return ReminderConfig(
        mode:
            ReminderMode.values.asNameMap()[m['mode']] ?? ReminderMode.interval,
        times: [for (final t in (m['times'] as List? ?? const [])) t as int],
        windowStart: (m['start'] as int?) ?? 9 * 60,
        windowEnd: (m['end'] as int?) ?? 17 * 60,
        everyMinutes: (m['every'] as int?) ?? 120,
        activeDays: {
          for (final d in (m['days'] as List? ?? const [1, 2, 3, 4, 5, 6, 7]))
            if (d is int && d >= 1 && d <= 7) d,
        },
      );
    } catch (_) {
      return const ReminderConfig();
    }
  }
}
