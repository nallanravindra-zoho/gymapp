import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../habits/habit_providers.dart';
import '../streaks/streak_providers.dart';
import 'notification_scheduler.dart';
import 'reminder_service.dart';

/// Overridden with the Android implementation in main(); does nothing in
/// tests unless they supply a fake.
final notificationSchedulerProvider = Provider<NotificationScheduler>(
  (_) => NoopNotificationScheduler(),
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
