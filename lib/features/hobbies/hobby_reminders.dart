/// Hobby reminders (R5): Daily, Weekly, Biweekly and Monthly, each hobby
/// independently on or off. The date math is pure and tested; the service
/// turns it into scheduled notifications.
///
/// Notification ids: [hobbyReminderIdBase] up to [hobbyReminderIdEnd]. This
/// range sits above habit snoozes, so rebuilding habit reminders leaves it
/// alone; [HobbyReminderService.reschedule] rebuilds only this range.
library;

import 'dart:convert';

import 'package:drift/drift.dart' show BooleanExpressionOperators, OrderingTerm;

import '../../core/time/app_clock.dart';
import '../../data/app_database.dart';
import '../reminders/notification_scheduler.dart';

enum HobbyReminderFrequency { daily, weekly, biweekly, monthly }

/// When a hobby's reminder fires. Stored as JSON in `Hobbies.reminderConfig`.
class HobbyReminderConfig {
  const HobbyReminderConfig({
    this.frequency = HobbyReminderFrequency.daily,
    this.minuteOfDay = 18 * 60,
    this.weekday = DateTime.monday,
    this.startDate,
    this.dayOfMonth = 1,
  });

  final HobbyReminderFrequency frequency;

  /// Minutes after local midnight.
  final int minuteOfDay;

  /// ISO weekday, 1 = Monday ... 7 = Sunday (weekly).
  final int weekday;

  /// First occurrence, `YYYY-MM-DD`, then every 14 days (biweekly).
  final String? startDate;

  /// 1..31 (monthly). In a shorter month the last day of that month is used.
  final int dayOfMonth;

  HobbyReminderConfig copyWith({
    HobbyReminderFrequency? frequency,
    int? minuteOfDay,
    int? weekday,
    String? startDate,
    int? dayOfMonth,
  }) => HobbyReminderConfig(
    frequency: frequency ?? this.frequency,
    minuteOfDay: minuteOfDay ?? this.minuteOfDay,
    weekday: weekday ?? this.weekday,
    startDate: startDate ?? this.startDate,
    dayOfMonth: dayOfMonth ?? this.dayOfMonth,
  );

  String toJson() => jsonEncode({
    'frequency': frequency.name,
    'minuteOfDay': minuteOfDay,
    'weekday': weekday,
    'startDate': startDate,
    'dayOfMonth': dayOfMonth,
  });

  factory HobbyReminderConfig.fromJson(String? raw) {
    try {
      if (raw == null || raw.isEmpty) return const HobbyReminderConfig();
      final m = jsonDecode(raw) as Map<String, dynamic>;
      int inRange(Object? v, int lo, int hi, int fallback) =>
          v is num && v >= lo && v <= hi ? v.round() : fallback;
      final start = m['startDate'];
      return HobbyReminderConfig(
        frequency: HobbyReminderFrequency.values.firstWhere(
          (f) => f.name == m['frequency'],
          orElse: () => HobbyReminderFrequency.daily,
        ),
        minuteOfDay: inRange(m['minuteOfDay'], 0, 1439, 18 * 60),
        weekday: inRange(m['weekday'], 1, 7, DateTime.monday),
        startDate: start is String && _validDate(start) ? start : null,
        dayOfMonth: inRange(m['dayOfMonth'], 1, 31, 1),
      );
    } catch (_) {
      return const HobbyReminderConfig();
    }
  }
}

bool _validDate(String s) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s);
  if (m == null) return false;
  final y = int.parse(m[1]!);
  final mo = int.parse(m[2]!);
  final d = int.parse(m[3]!);
  final back = DateTime.utc(y, mo, d);
  return back.year == y && back.month == mo && back.day == d;
}

DateTime _parseDate(String s) {
  final p = s.split('-');
  return DateTime.utc(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

String formatReminderDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Number of days in [month] (1..12) of [year].
int daysInMonth(int year, int month) => DateTime.utc(year, month + 1, 0).day;

/// The day a monthly reminder set for [dayOfMonth] really fires in the given
/// month: the same day, or the last day of the month when it is shorter
/// (30 or 31 in February, 31 in April, ...).
int monthlyReminderDay(int year, int month, int dayOfMonth) {
  final last = daysInMonth(year, month);
  return dayOfMonth > last ? last : dayOfMonth;
}

/// Whether the reminder fires on the calendar date of [date] (only the
/// year, month and day are read).
bool reminderOccursOn(HobbyReminderConfig c, DateTime date) {
  final day = DateTime.utc(date.year, date.month, date.day);
  switch (c.frequency) {
    case HobbyReminderFrequency.daily:
      return true;
    case HobbyReminderFrequency.weekly:
      return day.weekday == c.weekday;
    case HobbyReminderFrequency.biweekly:
      final start = c.startDate;
      if (start == null) return false;
      final diff = day.difference(_parseDate(start)).inDays;
      return diff >= 0 && diff % 14 == 0;
    case HobbyReminderFrequency.monthly:
      return day.day == monthlyReminderDay(day.year, day.month, c.dayOfMonth);
  }
}

/// Notifications kept per hobby.
const hobbyReminderSlots = 32;

({int count, int horizonDays}) _window(HobbyReminderFrequency f) => switch (f) {
  HobbyReminderFrequency.daily => (count: 30, horizonDays: 30),
  HobbyReminderFrequency.weekly => (count: 8, horizonDays: 60),
  HobbyReminderFrequency.biweekly => (count: 5, horizonDays: 90),
  HobbyReminderFrequency.monthly => (count: 4, horizonDays: 130),
};

/// The next reminder times after [now] (local wall-clock), soonest first.
/// A time today that has already passed is skipped. Looks ahead far enough
/// for the frequency and returns at most [hobbyReminderSlots].
List<DateTime> upcomingReminderTimes(HobbyReminderConfig c, DateTime now) {
  final w = _window(c.frequency);
  final out = <DateTime>[];
  final hour = c.minuteOfDay ~/ 60;
  final minute = c.minuteOfDay % 60;
  for (var i = 0; i <= w.horizonDays && out.length < w.count; i++) {
    // Calendar arithmetic in UTC so daylight-saving shifts never skip a day.
    final cal = DateTime.utc(now.year, now.month, now.day + i);
    if (!reminderOccursOn(c, cal)) continue;
    final at = DateTime(cal.year, cal.month, cal.day, hour, minute);
    if (at.isAfter(now)) out.add(at);
  }
  return out;
}

/// The next single reminder time, or null when none is planned.
DateTime? nextReminderTime(HobbyReminderConfig c, DateTime now) {
  final all = upcomingReminderTimes(c, now);
  return all.isEmpty ? null : all.first;
}

String _hhmm(int minuteOfDay) {
  final h = minuteOfDay ~/ 60;
  final m = minuteOfDay % 60;
  final suffix = h >= 12 ? 'PM' : 'AM';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${m.toString().padLeft(2, '0')} $suffix';
}

const _weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

String weekdayName(int isoWeekday) => _weekdayNames[(isoWeekday - 1) % 7];

String _ordinal(int n) {
  if (n >= 11 && n <= 13) return '${n}th';
  return switch (n % 10) {
    1 => '${n}st',
    2 => '${n}nd',
    3 => '${n}rd',
    _ => '${n}th',
  };
}

/// Short description for lists: `Daily at 6:00 PM`, `Mondays at 7:30 AM`,
/// `Every 2 weeks from 2026-05-20 at 6:00 PM`, `Monthly on the 31st at ...`.
String describeHobbyReminder(HobbyReminderConfig c) {
  final at = _hhmm(c.minuteOfDay);
  return switch (c.frequency) {
    HobbyReminderFrequency.daily => 'Daily at $at',
    HobbyReminderFrequency.weekly => '${weekdayName(c.weekday)}s at $at',
    HobbyReminderFrequency.biweekly =>
      'Every 2 weeks from ${c.startDate ?? 'a start date'} at $at',
    HobbyReminderFrequency.monthly =>
      'Monthly on the ${_ordinal(c.dayOfMonth)} at $at'
          '${c.dayOfMonth > 28 ? ' (last day in shorter months)' : ''}',
  };
}

// --- scheduling -------------------------------------------------------------

/// First id of the hobby reminder range. Above habit snoozes
/// ([snoozeIdBase]) and below the test reminder ([testNotificationId]).
const hobbyReminderIdBase = 950000;
const hobbyReminderMaxHobbies = 40;
const hobbyReminderIdEnd =
    hobbyReminderIdBase + hobbyReminderMaxHobbies * hobbyReminderSlots;

bool isHobbyReminderId(int id) =>
    id >= hobbyReminderIdBase && id < hobbyReminderIdEnd;

/// Rebuilds the scheduled hobby reminders from the database. Safe to call as
/// often as needed; it replaces only the hobby reminder range. Called from
/// `ReminderService.reschedule` (app start, preference changes) and from the
/// reminder effects when hobbies change; scheduled notifications themselves
/// are restored after a reboot by the notification plugin's boot receiver.
class HobbyReminderService {
  HobbyReminderService({
    required this.db,
    required this.clock,
    required this.scheduler,
  });

  final AppDatabase db;
  final AppClock clock;
  final NotificationScheduler scheduler;

  /// Returns how many reminders were scheduled.
  Future<int> reschedule() async {
    for (final p in await scheduler.pending()) {
      if (isHobbyReminderId(p.id)) await scheduler.cancel(p.id);
    }
    if (!await scheduler.hasPermission()) return 0;

    final hobbies =
        await (db.select(db.hobbies)
              ..where(
                (h) =>
                    h.deletedAt.isNull() &
                    h.isActive.equals(true) &
                    h.reminderEnabled.equals(true),
              )
              ..orderBy([
                (h) => OrderingTerm.asc(h.createdAt),
                (h) => OrderingTerm.asc(h.id),
              ]))
            .get();

    final now = clock.now().toLocal();
    var scheduled = 0;
    for (final (i, h) in hobbies.take(hobbyReminderMaxHobbies).indexed) {
      final times = upcomingReminderTimes(
        HobbyReminderConfig.fromJson(h.reminderConfig),
        now,
      );
      for (final (k, at) in times.indexed) {
        await scheduler.schedule(
          ScheduledNotification(
            id: hobbyReminderIdBase + i * hobbyReminderSlots + k,
            at: at,
            title: 'Time for ${h.name}',
            body: 'Whenever suits you today.',
            // No habits: the habit buttons do nothing for a hobby reminder.
            payload: ReminderPayload(
              habitIds: const [],
              habitNames: [h.name],
              kinds: const ['hobby'],
              priority: 0,
              snoozeCount: 0,
            ).encode(),
          ),
        );
        scheduled++;
      }
    }
    return scheduled;
  }
}
