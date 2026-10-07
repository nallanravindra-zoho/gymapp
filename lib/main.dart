import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'data/providers.dart';
import 'features/reminders/plugin_scheduler.dart';
import 'features/reminders/reminder_actions.dart';
import 'features/reminders/reminder_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final plugin = FlutterLocalNotificationsPlugin();
  final scheduler = PluginNotificationScheduler(plugin);
  late final ProviderContainer container;

  await PluginNotificationScheduler.initialize(
    plugin,
    // Notification taps and actions that open the app run here.
    onResponse: (response) => handleReminderAction(
      actionId: response.actionId,
      payload: response.payload,
      db: container.read(databaseProvider),
      clock: container.read(clockProvider),
      scheduler: scheduler,
    ),
  );

  container = ProviderContainer(
    overrides: [notificationSchedulerProvider.overrideWithValue(scheduler)],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const WellbeingApp(),
    ),
  );
}
