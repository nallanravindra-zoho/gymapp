import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'data/sync/supabase_remote_store.dart';
import 'features/account/supabase_auth_service.dart';
import 'features/account/sync_providers.dart';
import 'data/providers.dart';
import 'features/reminders/plugin_scheduler.dart';
import 'features/reminders/reminder_actions.dart';
import 'features/reminders/reminder_providers.dart';
import 'features/screen_time/screen_time_providers.dart';
import 'features/screen_time/usage_source.dart';

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

  // Sign-in and sync need the build settings; without them the app runs
  // offline-only. A failure to start them must never stop the app opening.
  SupabaseAuthService? auth;
  SupabaseRemoteStore? remote;
  if (AppConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseKey,
      );
      await GoogleSignIn.instance.initialize(
        serverClientId: AppConfig.googleWebClientId,
      );
      auth = SupabaseAuthService(Supabase.instance.client);
      remote = SupabaseRemoteStore(Supabase.instance.client);
    } catch (e) {
      debugPrint('Sync could not start: $e');
    }
  }

  container = ProviderContainer(
    overrides: [
      notificationSchedulerProvider.overrideWithValue(scheduler),
      usageSourceProvider.overrideWithValue(AndroidUsageSource()),
      if (auth != null) authServiceProvider.overrideWithValue(auth),
      if (remote != null) remoteStoreProvider.overrideWithValue(remote),
    ],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const WellbeingApp(),
    ),
  );
}
