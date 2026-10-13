import 'package:drift/drift.dart' show BooleanExpressionOperators;

import '../../core/time/app_clock.dart';
import '../../data/app_database.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/user_repository.dart';
import 'notification_scheduler.dart';
import 'reminder_service.dart';

const logActionId = 'log';
const skipActionId = 'skip';

/// Handles the Log and Skip notification actions (spec 7.4, R4).
///
/// * Log: adds one completion to the habit in the notification, then
///   rebuilds the schedule so a met target stops further reminders.
/// * Skip: records that this reminder was skipped
///   ([HabitRepository.recordSkip]). A skip is its own record and never
///   counts as a completion or towards a streak, so the habit stays loggable.
///
/// A plain tap, or dismissing the notification, does nothing here: the habit
/// stays available to log in the app.
///
/// Used by both the in-app callback and the background isolate, so it only
/// takes plain dependencies.
Future<void> handleReminderAction({
  required String? actionId,
  required String? payload,
  required AppDatabase db,
  required AppClock clock,
  required NotificationScheduler scheduler,
}) async {
  if (actionId != logActionId && actionId != skipActionId) return;
  final decoded = ReminderPayload.decode(payload);
  if (decoded == null) return;

  final users = UserRepository(db, clock);
  final habitsRepo = HabitRepository(db, clock);
  final user = await users.ensureUser();

  for (final id in decoded.habitIds) {
    final habit = await (db.select(
      db.habits,
    )..where((h) => h.id.equals(id) & h.deletedAt.isNull())).getSingleOrNull();
    if (habit == null) continue;
    if (actionId == logActionId) {
      await habitsRepo.log(
        habit: habit,
        dayCutoffMinutes: user.dayCutoffMinutes,
      );
    } else {
      await habitsRepo.recordSkip(
        habit: habit,
        dayCutoffMinutes: user.dayCutoffMinutes,
      );
    }
  }

  if (actionId == logActionId && decoded.habitIds.isNotEmpty) {
    await ReminderService(
      db: db,
      clock: clock,
      scheduler: scheduler,
    ).reschedule();
  }
}
