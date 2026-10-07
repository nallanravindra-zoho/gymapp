import 'package:drift/drift.dart' show BooleanExpressionOperators, OrderingTerm;

import '../../core/time/app_clock.dart';
import '../../data/app_database.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/user_repository.dart';
import 'notification_scheduler.dart';
import 'reminder_planner.dart';
import 'reminder_service.dart';

const _logAction = 'log';
const _snoozeAction = 'snooze';

/// Handles the Log and Snooze notification actions (spec 7.4).
///
/// * Log: adds one completion to every habit in the notification.
/// * Snooze: re-notifies 30 minutes later, at most twice, never into quiet
///   hours and never for habits whose target is already met.
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
  final decoded = ReminderPayload.decode(payload);
  if (decoded == null) return;

  final users = UserRepository(db, clock);
  final habitsRepo = HabitRepository(db, clock);
  final user = await users.ensureUser();
  final service = ReminderService(db: db, clock: clock, scheduler: scheduler);

  switch (actionId) {
    case _logAction:
      for (final id in decoded.habitIds) {
        final habit =
            await (db.select(db.habits)
                  ..where((h) => h.id.equals(id) & h.deletedAt.isNull()))
                .getSingleOrNull();
        if (habit == null) continue;
        await habitsRepo.log(
          habit: habit,
          dayCutoffMinutes: user.dayCutoffMinutes,
        );
      }
      await service.reschedule();

    case _snoozeAction:
      final habits =
          await (db.select(db.habits)
                ..where(
                  (h) => h.id.isIn(decoded.habitIds) & h.deletedAt.isNull(),
                )
                ..orderBy([(h) => OrderingTerm.asc(h.createdAt)]))
              .get();
      final met = await service.metToday(habits, habitsRepo, users.today(user));
      final now = clock.now().toLocal();
      final next = planSnooze(
        original: decoded.toPlanned(now),
        now: now,
        metToday: met,
        quietStart: user.quietHoursStart ?? defaultQuietStart,
        quietEnd: user.quietHoursEnd ?? defaultQuietEnd,
      );
      if (next == null) return;
      final text = reminderText(next);
      await scheduler.schedule(
        ScheduledNotification(
          id: snoozeIdBase + (now.millisecondsSinceEpoch % 50000),
          at: next.at,
          title: text.title,
          body: text.body,
          payload: ReminderPayload.fromPlanned(next).encode(),
        ),
      );

    default:
      // A plain tap opens the app; nothing to do.
      return;
  }
}
