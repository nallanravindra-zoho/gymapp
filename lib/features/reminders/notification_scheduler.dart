import 'dart:convert';

import 'reminder_planner.dart';

/// Ids below this are planned reminders; ids at or above it are snoozes.
/// Rescheduling replaces the planned range and leaves snoozes alone.
const plannedIdBase = 1000;
const snoozeIdBase = 900000;

/// The test reminder. Above the snooze range so rescheduling leaves it alone.
const testNotificationId = 999999;

class ScheduledNotification {
  const ScheduledNotification({
    required this.id,
    required this.at,
    required this.title,
    this.body,
    required this.payload,
  });

  final int id;

  /// Local wall-clock time.
  final DateTime at;
  final String title;
  final String? body;
  final String payload;
}

class PendingNotification {
  const PendingNotification(this.id, this.payload);
  final int id;
  final String? payload;
}

/// What the phone says about this app's notifications.
class NotificationDiagnostics {
  const NotificationDiagnostics({
    required this.enabled,
    this.channelLevel,
    this.canScheduleExact,
    this.shownIds = const [],
  });

  /// Notifications are allowed for the app.
  final bool enabled;

  /// How loudly the phone treats the reminder channel: `High`, `Default`,
  /// `Low`, `Muted`, or null when the channel does not exist yet.
  final String? channelLevel;

  /// Whether exact alarms are permitted (informational only).
  final bool? canScheduleExact;

  /// Ids of the notifications currently showing in the shade.
  final List<int> shownIds;
}

/// Everything the app needs from the platform's notification system, so the
/// scheduling rules can be tested without a device.
abstract class NotificationScheduler {
  Future<bool> hasPermission();

  /// Asks the user (Android 13+). Returns whether notifications are allowed.
  Future<bool> requestPermission();

  /// Cancels planned reminders (ids below [snoozeIdBase]).
  Future<void> cancelPlanned();

  Future<void> cancel(int id);

  Future<void> schedule(ScheduledNotification notification);

  /// Shows a notification immediately.
  Future<void> show(ScheduledNotification notification);

  /// Asks the phone how it is treating this app's notifications.
  Future<NotificationDiagnostics> diagnose();

  Future<List<PendingNotification>> pending();
}

/// Used until a real scheduler is provided (and in tests): does nothing.
class NoopNotificationScheduler implements NotificationScheduler {
  @override
  Future<bool> hasPermission() async => false;
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<void> cancelPlanned() async {}
  @override
  Future<void> cancel(int id) async {}
  @override
  Future<void> schedule(ScheduledNotification notification) async {}
  @override
  Future<void> show(ScheduledNotification notification) async {}
  @override
  Future<NotificationDiagnostics> diagnose() async =>
      const NotificationDiagnostics(enabled: false);
  @override
  Future<List<PendingNotification>> pending() async => const [];
}

/// In-memory scheduler for tests.
class FakeNotificationScheduler implements NotificationScheduler {
  FakeNotificationScheduler({
    this.permitted = true,
    this.grantOnRequest = true,
  });

  bool permitted;

  /// Whether the (simulated) system dialog is accepted when asked.
  bool grantOnRequest;
  int permissionRequests = 0;
  final Map<int, ScheduledNotification> scheduled = {};

  @override
  Future<bool> hasPermission() async => permitted;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    permitted = grantOnRequest;
    return permitted;
  }

  @override
  Future<void> cancelPlanned() async =>
      scheduled.removeWhere((id, _) => id < snoozeIdBase);

  @override
  Future<void> cancel(int id) async => scheduled.remove(id);

  /// Make [schedule] fail, to test error reporting.
  Object? scheduleError;

  @override
  Future<void> schedule(ScheduledNotification n) async {
    if (scheduleError != null) throw scheduleError!;
    scheduled[n.id] = n;
  }

  /// Notifications shown immediately, in order.
  final List<ScheduledNotification> shown = [];

  @override
  Future<void> show(ScheduledNotification n) async {
    if (showError != null) throw showError!;
    shown.add(n);
  }

  /// Make [show] fail, to test error reporting.
  Object? showError;

  /// Pretend the phone swallows what is shown (as some skins do).
  bool phoneHidesNotifications = false;

  String? channelLevel = 'Default';

  @override
  Future<NotificationDiagnostics> diagnose() async => NotificationDiagnostics(
    enabled: permitted,
    channelLevel: channelLevel,
    canScheduleExact: false,
    shownIds: phoneHidesNotifications
        ? const []
        : [for (final n in shown) n.id],
  );

  @override
  Future<List<PendingNotification>> pending() async => [
    for (final n in scheduled.values) PendingNotification(n.id, n.payload),
  ];

  List<ScheduledNotification> get planned =>
      scheduled.values.where((n) => n.id < snoozeIdBase).toList()
        ..sort((a, b) => a.at.compareTo(b.at));

  List<ScheduledNotification> get snoozes => scheduled.values
      .where((n) => n.id >= snoozeIdBase && n.id != testNotificationId)
      .toList();

  /// The scheduled test reminder, if one is pending.
  ScheduledNotification? get testScheduled => scheduled[testNotificationId];
}

/// What a notification carries so its actions know what to log or snooze.
class ReminderPayload {
  const ReminderPayload({
    required this.habitIds,
    required this.habitNames,
    required this.kinds,
    required this.priority,
    required this.snoozeCount,
  });

  factory ReminderPayload.fromPlanned(PlannedReminder r) => ReminderPayload(
    habitIds: r.habitIds,
    habitNames: r.habitNames,
    kinds: r.kinds,
    priority: r.priority,
    snoozeCount: r.snoozeCount,
  );

  final List<String> habitIds;
  final List<String> habitNames;
  final List<String> kinds;
  final int priority;
  final int snoozeCount;

  String encode() => jsonEncode({
    'h': habitIds,
    'n': habitNames,
    'k': kinds,
    'p': priority,
    's': snoozeCount,
  });

  static ReminderPayload? decode(String? raw) {
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return ReminderPayload(
        habitIds: List<String>.from(m['h'] as List),
        habitNames: List<String>.from(m['n'] as List),
        kinds: List<String>.from(m['k'] as List),
        priority: m['p'] as int,
        snoozeCount: m['s'] as int,
      );
    } catch (_) {
      return null;
    }
  }

  PlannedReminder toPlanned(DateTime at) => PlannedReminder(
    at: at,
    habitIds: habitIds,
    habitNames: habitNames,
    kinds: kinds,
    priority: priority,
    snoozeCount: snoozeCount,
  );
}
