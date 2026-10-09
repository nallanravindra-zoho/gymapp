import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../habits/habit_providers.dart';
import '../streaks/streak_providers.dart';
import 'notification_scheduler.dart';
import 'reminder_service.dart';
import 'system_settings.dart';

/// Overridden with the Android implementation in main(); does nothing in
/// tests unless they supply a fake.
final notificationSchedulerProvider = Provider<NotificationScheduler>(
  (_) => NoopNotificationScheduler(),
);

/// Overridden with the Android implementation in main().
final systemSettingsProvider = Provider<SystemSettings>(
  (_) => NoopSystemSettings(),
);

/// Whether the app may run in the background despite battery saving.
/// True, false, or null when the phone cannot say.
final batteryUnrestrictedProvider = FutureProvider.autoDispose<bool?>(
  (ref) => ref.watch(systemSettingsProvider).isUnrestrictedByBattery(),
);

final reminderServiceProvider = Provider(
  (ref) => ReminderService(
    db: ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
    scheduler: ref.watch(notificationSchedulerProvider),
  ),
);

/// Rebuilds scheduled reminders whenever habits, today's progress or the
/// user's settings change, and once at startup. Watch it from the app shell.
final reminderEffectsProvider = Provider<void>((ref) {
  var tail = Future<void>.value();

  void run() {
    tail = tail
        .then((_) => ref.read(reminderServiceProvider).reschedule())
        .catchError((Object _) {});
  }

  ref.listen(activeHabitsProvider, (_, _) => run());
  ref.listen(todayHabitCountsProvider, (_, _) => run());
  ref.listen(userStreamProvider, (_, _) => run());
  run();
});

/// The Reminders screen's data. Recomputed when habits, today's progress or
/// settings change.
final upcomingRemindersProvider = FutureProvider.autoDispose<UpcomingReminders>(
  (ref) {
    ref.watch(activeHabitsProvider);
    ref.watch(todayHabitCountsProvider);
    ref.watch(userStreamProvider);
    return ref.watch(reminderServiceProvider).upcoming();
  },
);
