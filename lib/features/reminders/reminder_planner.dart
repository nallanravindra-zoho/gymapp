import '../habits/reminder_config.dart';

/// Defaults used while the user has not chosen quiet hours (spec 7.4).
const defaultQuietStart = 22 * 60;
const defaultQuietEnd = 7 * 60;
const defaultDailyCap = 6;

/// How many days ahead reminders are scheduled. They are rebuilt every time
/// the app opens, so this only matters if the app goes unopened.
const planningDays = 7;

class HabitReminderInput {
  const HabitReminderInput({
    required this.id,
    required this.name,
    required this.kind,
    required this.priority,
    required this.config,
  });

  final String id;
  final String name;

  /// `water`, `stand`, `stretch` or `custom`; selects the reminder wording.
  final String kind;

  /// Lower number = more important. Used when the daily cap forces a drop.
  final int priority;
  final ReminderConfig config;
}

class PlannedReminder {
  const PlannedReminder({
    required this.at,
    required this.habitIds,
    required this.habitNames,
    required this.kinds,
    required this.priority,
  });

  /// Local wall-clock time.
  final DateTime at;
  final List<String> habitIds;
  final List<String> habitNames;
  final List<String> kinds;
  final int priority;
}

/// True when [minuteOfDay] falls inside quiet hours. A window that crosses
/// midnight (22:00 to 07:00) is handled; equal start and end means none.
bool inQuietHours(int minuteOfDay, int start, int end) {
  if (start == end) return false;
  return start < end
      ? minuteOfDay >= start && minuteOfDay < end
      : minuteOfDay >= start || minuteOfDay < end;
}

/// Plans notifications for the next [days] days (spec 7.4, R4):
///
/// * only habits with reminders on (the caller passes only those),
/// * only on the habit's active days,
/// * never in quiet hours,
/// * never for a habit whose target is already met today,
/// * one notification per habit per time, so each keeps its own Log and Skip
///   actions (separate habits are never merged),
/// * at most [cap] notifications per day; the lowest priority are dropped.
///
/// Skipping a reminder does not count towards a target, so a skip never
/// changes what is planned here: only a met target suppresses reminders.
List<PlannedReminder> planReminders({
  required List<HabitReminderInput> habits,
  required DateTime now,
  required Set<String> metToday,
  int quietStart = defaultQuietStart,
  int quietEnd = defaultQuietEnd,
  int cap = defaultDailyCap,
  int days = planningDays,
}) {
  final result = <PlannedReminder>[];

  for (var offset = 0; offset < days; offset++) {
    final date = DateTime(now.year, now.month, now.day + offset);
    final day = <PlannedReminder>[];

    for (final h in habits) {
      if (!h.config.activeDays.contains(date.weekday)) continue;
      if (offset == 0 && metToday.contains(h.id)) continue;
      for (final m in h.config.minutesOfDay) {
        if (inQuietHours(m, quietStart, quietEnd)) continue;
        final at = DateTime(date.year, date.month, date.day, m ~/ 60, m % 60);
        if (!at.isAfter(now)) continue;
        day.add(
          PlannedReminder(
            at: at,
            habitIds: [h.id],
            habitNames: [h.name],
            kinds: [h.kind],
            priority: h.priority,
          ),
        );
      }
    }
    // Time order; habits due at the same minute stay separate, most
    // important first.
    day.sort((a, b) {
      final t = a.at.compareTo(b.at);
      return t != 0 ? t : a.priority.compareTo(b.priority);
    });

    // Cap: keep the most important; among equals keep the earlier ones.
    if (day.length > cap) {
      final ranked = [...day]
        ..sort((a, b) {
          final p = a.priority.compareTo(b.priority);
          return p != 0 ? p : a.at.compareTo(b.at);
        });
      final keep = ranked.take(cap).toSet();
      day.retainWhere(keep.contains);
    }
    result.addAll(day);
  }
  return result;
}

/// Notification wording (spec 4.5). Every reminder is for one habit.
({String title, String? body}) reminderText(PlannedReminder r) {
  if (r.habitIds.length == 1) {
    return (title: _single(r.kinds.first, r.habitNames.first), body: null);
  }
  // Only a hand-built payload carries several habits.
  return (title: 'Healthy habits.', body: r.habitNames.join(', '));
}

String _single(String kind, String name) => switch (kind) {
  'water' => 'Time for some water.',
  'stand' => 'Stand and move for a minute.',
  'stretch' => 'Time for a stretch.',
  'moisturize' => 'Time to moisturize.',
  'skinCare' => 'Time for skin care.',
  _ => '$name.',
};
