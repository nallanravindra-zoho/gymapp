import 'dart:ui' show DartPluginRegistrant;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/time/app_clock.dart';
import '../../data/app_database.dart';
import 'notification_scheduler.dart';
import 'action_bridge.dart';
import 'reminder_actions.dart';

const _channelId = 'habit_reminders';
const logActionId = 'log';
const snoozeActionId = 'snooze';

/// [NotificationScheduler] backed by flutter_local_notifications (Android).
class PluginNotificationScheduler implements NotificationScheduler {
  PluginNotificationScheduler(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  /// Initialises the plugin. [onResponse] runs in the app when a notification
  /// or action is used while the app is running; the background entry point
  /// handles actions that do not open the app.
  static Future<void> initialize(
    FlutterLocalNotificationsPlugin plugin, {
    DidReceiveNotificationResponseCallback? onResponse,
  }) async {
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: onResponse,
      onDidReceiveBackgroundNotificationResponse: reminderBackgroundHandler,
    );
  }

  @override
  Future<bool> hasPermission() async =>
      await _android?.areNotificationsEnabled() ?? false;

  @override
  Future<bool> requestPermission() async =>
      await _android?.requestNotificationsPermission() ?? false;

  @override
  Future<void> cancelPlanned() async {
    for (final p in await _plugin.pendingNotificationRequests()) {
      if (p.id < snoozeIdBase) await _plugin.cancel(id: p.id);
    }
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      'Habit reminders',
      channelDescription: 'Water, stand and stretch breaks',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      actions: [
        AndroidNotificationAction(logActionId, 'Log'),
        AndroidNotificationAction(snoozeActionId, 'Snooze 30 min'),
      ],
    ),
  );

  @override
  Future<void> schedule(ScheduledNotification n) {
    return _plugin.zonedSchedule(
      id: n.id,
      // The instant is what matters; UTC avoids needing the timezone database.
      scheduledDate: tz.TZDateTime.from(n.at, tz.UTC),
      notificationDetails: _details,
      // Inexact is enough for habit reminders and needs no extra permission.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: n.title,
      body: n.body,
      payload: n.payload,
    );
  }

  @override
  Future<void> show(ScheduledNotification n) {
    return _plugin.show(
      id: n.id,
      title: n.title,
      body: n.body,
      notificationDetails: _details,
      payload: n.payload,
    );
  }

  @override
  Future<NotificationDiagnostics> diagnose() async {
    final android = _android;
    final enabled = await hasPermission();

    String? level;
    try {
      final channels = await android?.getNotificationChannels();
      final ours = channels?.where((c) => c.id == _channelId).firstOrNull;
      level = ours == null
          ? null
          : switch (ours.importance) {
              Importance.high || Importance.max => 'High',
              Importance.defaultImportance => 'Default',
              Importance.low || Importance.min => 'Low',
              Importance.none => 'Muted',
              _ => 'Default',
            };
    } catch (_) {
      level = null;
    }

    bool? exact;
    try {
      exact = await android?.canScheduleExactNotifications();
    } catch (_) {
      exact = null;
    }

    var shown = <int>[];
    try {
      shown = [
        for (final n in await _plugin.getActiveNotifications())
          if (n.id != null) n.id!,
      ];
    } catch (_) {
      shown = const [];
    }

    return NotificationDiagnostics(
      enabled: enabled,
      channelLevel: level,
      canScheduleExact: exact,
      shownIds: shown,
    );
  }

  @override
  Future<List<PendingNotification>> pending() async => [
    for (final p in await _plugin.pendingNotificationRequests())
      PendingNotification(p.id, p.payload),
  ];
}

/// Runs when a notification action is used and the app UI is not open. It
/// builds its own database connection and scheduler, since nothing from the
/// main isolate exists here.
@pragma('vm:entry-point')
Future<void> reminderBackgroundHandler(NotificationResponse response) async {
  DartPluginRegistrant.ensureInitialized();
  final plugin = FlutterLocalNotificationsPlugin();
  await PluginNotificationScheduler.initialize(plugin);
  final db = AppDatabase();
  try {
    await handleReminderAction(
      actionId: response.actionId,
      payload: response.payload,
      db: db,
      clock: const AppClock(),
      scheduler: PluginNotificationScheduler(plugin),
    );
  } finally {
    await db.close();
    notifyActionDone();
  }
}
