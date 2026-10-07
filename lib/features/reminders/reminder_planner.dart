import '../habits/reminder_config.dart';

/// Defaults used while the user has not chosen quiet hours (spec 7.4).
const defaultQuietStart = 22 * 60;
const defaultQuietEnd = 7 * 60;
const defaultDailyCap = 6;

/// Reminders this close together are sent as one notification.
const batchWindow = Duration(minutes: 15);

const snoozeDuration = Duration(minutes: 30);
const maxSnoozes = 2;

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
    this.snoozeCount = 0,
  });

  /// Local wall-clock time.
  final DateTime at;
  final List<String> habitIds;
  final List<String> habitNames;
  final List<String> kinds;
  final int priority;
  final int snoozeCount;
}

/// True when [minuteOfDay] falls inside quiet hours. A window that crosses
/// midnight (22:00 to 07:00) is handled; equal start and end means none.
bool inQuietHours(int minuteOfDay, int start, int end) {
  if (start == end) return false;
  return start < end
      ? minuteOfDay >= start && minuteOfDay < end
      : minuteOfDay >= start || minuteOfDay < end;
}

/// Plans notifications for the next [days] days (spec 7.4):
///
/// * only habits with reminders on (the caller passes only those),
/// * only on the habit's active days,
/// * never in quiet hours,
/// * never for a habit whose target is already met today,
/// * reminders within 15 minutes are batched into one,
/// * at most [cap] notifications per day; the lowest priority are dropped.
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
    final entries = <({DateTime at, HabitReminderInput habit})>[];

    for (final h in habits) {
      if (!h.config.activeDays.contains(date.weekday)) continue;
      if (offset == 0 && metToday.contains(h.id)) continue;
      for (final m in h.config.minutesOfDay) {
        if (inQuietHours(m, quietStart, quietEnd)) continue;
        final at = DateTime(date.year, date.month, date.day, m ~/ 60, m % 60);
        if (!at.isAfter(now)) continue;
        entries.add((at: at, habit: h));
      }
    }
    entries.sort((a, b) => a.at.compareTo(b.at));

    // Batch: a cluster starts at its first reminder and takes any others
    // within the batch window of that start.
    final day = <PlannedReminder>[];
    var i = 0;
    while (i < entries.length) {
      final start = entries[i].at;
      final group = <HabitReminderInput>[];
      while (i < entries.length &&
          entries[i].at.difference(start) <= batchWindow) {
        if (!group.any((g) => g.id == entries[i].habit.id)) {
          group.add(entries[i].habit);
        }
        i++;
      }
      group.sort((a, b) => a.priority.compareTo(b.priority));
      day.add(
        PlannedReminder(
          at: start,
          habitIds: [for (final g in group) g.id],
          habitNames: [for (final g in group) g.name],
          kinds: [for (final g in group) g.kind],
          priority: group.first.priority,
        ),
      );
    }

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

/// The reminder to schedule after a snooze, or null when no snooze is
/// allowed: two snoozes at most, none into quiet hours, none once every habit
/// in it has met its target.
PlannedReminder? planSnooze({
  required PlannedReminder original,
  required DateTime now,
  required Set<String> metToday,
  int quietStart = defaultQuietStart,
  int quietEnd = defaultQuietEnd,
}) {
  if (original.snoozeCount >= maxSnoozes) return null;
  final at = now.add(snoozeDuration);
  if (inQuietHours(at.hour * 60 + at.minute, quietStart, quietEnd)) return null;

  final keep = <int>[
    for (var i = 0; i < original.habitIds.length; i++)
      if (!metToday.contains(original.habitIds[i])) i,
  ];
  if (keep.isEmpty) return null;

  return PlannedReminder(
    at: at,
    habitIds: [for (final i in keep) original.habitIds[i]],
    habitNames: [for (final i in keep) original.habitNames[i]],
    kinds: [for (final i in keep) original.kinds[i]],
    priority: original.priority,
    snoozeCount: original.snoozeCount + 1,
  );
}

/// Notification wording (spec 4.5). Several batched habits share one title.
({String title, String? body}) reminderText(PlannedReminder r) {
  if (r.habitIds.length == 1) {
    return (title: _single(r.kinds.first, r.habitNames.first), body: null);
  }
  return (title: 'Break time.', body: r.habitNames.join(', '));
}

String _single(String kind, String name) => switch (kind) {
  'water' => 'Water break.',
  'stand' => 'Stand and move for a minute.',
  'stretch' => 'Stretch break.',
  _ => '$name.',
};
