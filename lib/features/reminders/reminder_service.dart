import 'package:drift/drift.dart' show BooleanExpressionOperators, OrderingTerm;

import '../../core/time/app_clock.dart';
import '../../data/app_database.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../habits/reminder_config.dart';
import 'notification_scheduler.dart';
import 'reminder_planner.dart';

/// Rebuilds the scheduled reminders from the database. Safe to call as often
/// as needed: it replaces the planned set each time.
class ReminderService {
  ReminderService({
    required this.db,
    required this.clock,
    required this.scheduler,
  });

  final AppDatabase db;
  final AppClock clock;
  final NotificationScheduler scheduler;

  Future<void> reschedule() async {
    final users = UserRepository(db, clock);
    final habitsRepo = HabitRepository(db, clock);
    final user = await users.ensureUser();

    await scheduler.cancelPlanned();
    if (!await scheduler.hasPermission()) return;

    final habits =
        await (db.select(db.habits)
              ..where(
                (h) =>
                    h.userId.equals(user.id) &
                    h.deletedAt.isNull() &
                    h.isActive.equals(true),
              )
              ..orderBy([(h) => OrderingTerm.asc(h.createdAt)]))
            .get();

    final today = users.today(user);
    final met = await metToday(habits, habitsRepo, today);

    // Snoozes for habits that have since met their target no longer fire.
    for (final p in await scheduler.pending()) {
      if (p.id < snoozeIdBase) continue;
      final payload = ReminderPayload.decode(p.payload);
      if (payload == null || payload.habitIds.every(met.contains)) {
        await scheduler.cancel(p.id);
      }
    }

    final inputs = <HabitReminderInput>[];
    for (var i = 0; i < habits.length; i++) {
      final h = habits[i];
      if (!h.remindersEnabled) continue;
      inputs.add(
        HabitReminderInput(
          id: h.id,
          name: h.name,
          kind: h.kind.name,
          priority: i,
          config: ReminderConfig.fromJson(h.reminderConfig),
        ),
      );
    }

    final planned = planReminders(
      habits: inputs,
      now: clock.now().toLocal(),
      metToday: met,
      quietStart: user.quietHoursStart ?? defaultQuietStart,
      quietEnd: user.quietHoursEnd ?? defaultQuietEnd,
      cap: user.dailyReminderCap,
    );

    for (var i = 0; i < planned.length; i++) {
      final r = planned[i];
      final text = reminderText(r);
      await scheduler.schedule(
        ScheduledNotification(
          id: plannedIdBase + i,
          at: r.at,
          title: text.title,
          body: text.body,
          payload: ReminderPayload.fromPlanned(r).encode(),
        ),
      );
    }
  }

  /// Ids of habits whose daily target is already met on [localDate].
  Future<Set<String>> metToday(
    List<Habit> habits,
    HabitRepository repo,
    String localDate,
  ) async {
    final met = <String>{};
    for (final h in habits) {
      final logs = await repo.logsBetween(h.id, localDate, localDate);
      final total = logs.fold<int>(0, (s, l) => s + l.count);
      if (total >= h.dailyTarget) met.add(h.id);
    }
    return met;
  }
}
