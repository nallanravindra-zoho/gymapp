import 'dart:convert';

import 'reminder_planner.dart';

/// Ids from [plannedIdBase] up to (not including) [plannedIdLimit] are
/// planned habit reminders. Rescheduling replaces that range and leaves ids at
/// or above the limit (such as the test reminder) alone.
const plannedIdBase = 1000;
const plannedIdLimit = 900000;

/// Former name of [plannedIdLimit], from when snoozes lived above it. Snooze
/// was removed in R4; kept so older references still compile.
const snoozeIdBase = plannedIdLimit;

/// The test reminder. Above the planned range so rescheduling leaves it alone.
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

  /// Chooses the notification sound ([Users.reminderSound]; null means the
  /// phone's default). Android fixes a channel's sound when it is created, so
  /// the Android implementation uses a channel per sound and removes the old
  /// ones. Call before scheduling.
  Future<void> useSound(String? sound);

  /// Cancels planned reminders (ids below [plannedIdLimit]).
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
  Future<void> useSound(String? sound) async {}
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

  /// The sound last passed to [useSound] (null = phone default).
  String? sound;
  int soundChanges = 0;

  @override
  Future<void> useSound(String? sound) async {
    if (sound != this.sound) soundChanges++;
    this.sound = sound;
  }

  @override
  Future<void> cancelPlanned() async =>
      scheduled.removeWhere((id, _) => id < plannedIdLimit);

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
      scheduled.values.where((n) => n.id < plannedIdLimit).toList()
        ..sort((a, b) => a.at.compareTo(b.at));

  /// The scheduled test reminder, if one is pending.
  ScheduledNotification? get testScheduled => scheduled[testNotificationId];
}

/// What a notification carries so its Log and Skip actions know which habit they are for.
class ReminderPayload {
  const ReminderPayload({
    required this.habitIds,
    required this.habitNames,
    required this.kinds,
    required this.priority,
    this.snoozeCount = 0,
  });

  factory ReminderPayload.fromPlanned(PlannedReminder r) => ReminderPayload(
    habitIds: r.habitIds,
    habitNames: r.habitNames,
    kinds: r.kinds,
    priority: r.priority,
  );

  final List<String> habitIds;
  final List<String> habitNames;
  final List<String> kinds;
  final int priority;

  /// Unused since snooze was removed; accepted so older callers compile.
  final int snoozeCount;

  String encode() =>
      jsonEncode({'h': habitIds, 'n': habitNames, 'k': kinds, 'p': priority});

  static ReminderPayload? decode(String? raw) {
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return ReminderPayload(
        habitIds: List<String>.from(m['h'] as List),
        habitNames: List<String>.from(m['n'] as List),
        kinds: List<String>.from(m['k'] as List),
        priority: m['p'] as int,
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
  );
}
