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

  /// Why the last attempt to schedule failed, or null if it did not. Shown on
  /// the Reminders screen so a problem is not silent.
  String? lastError;

  /// Works out which reminders should exist right now, from the stored
  /// habits and today's progress.
  Future<_Plan> _plan() async {
    final users = UserRepository(db, clock);
    final habitsRepo = HabitRepository(db, clock);
    final user = await users.ensureUser();

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

    final met = await metToday(habits, habitsRepo, users.today(user));

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

    final quietStart = user.quietHoursStart ?? defaultQuietStart;
    final quietEnd = user.quietHoursEnd ?? defaultQuietEnd;
    final planned = planReminders(
      habits: inputs,
      now: clock.now().toLocal(),
      metToday: met,
      quietStart: quietStart,
      quietEnd: quietEnd,
      cap: user.dailyReminderCap,
    );
    return _Plan(
      planned: planned,
      met: met,
      enabledHabits: inputs.length,
      quietStart: quietStart,
      quietEnd: quietEnd,
    );
  }

  Future<void> reschedule() async {
    await scheduler.cancelPlanned();
    if (!await scheduler.hasPermission()) return;

    final plan = await _plan();

    // Snoozes for habits that have since met their target no longer fire.
    // The test reminder is not tied to a habit and is left alone.
    for (final p in await scheduler.pending()) {
      if (p.id < snoozeIdBase || p.id == testNotificationId) continue;
      final payload = ReminderPayload.decode(p.payload);
      if (payload == null || payload.habitIds.every(plan.met.contains)) {
        await scheduler.cancel(p.id);
      }
    }

    try {
      for (var i = 0; i < plan.planned.length; i++) {
        final r = plan.planned[i];
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
      lastError = null;
    } catch (e) {
      lastError = _short(e);
    }
  }

  /// What the Reminders screen shows: the next reminders, and whether they
  /// are really set up on this phone.
  Future<UpcomingReminders> upcoming({int limit = 10}) async {
    final plan = await _plan();
    final permitted = await scheduler.hasPermission();
    final diagnostics = await scheduler.diagnose();
    final onPhone = [
      for (final p in await scheduler.pending())
        if (p.id >= plannedIdBase && p.id < snoozeIdBase) p,
    ].length;
    return UpcomingReminders(
      next: plan.planned.take(limit).toList(),
      totalPlanned: plan.planned.length,
      permitted: permitted,
      scheduledOnPhone: onPhone,
      enabledHabits: plan.enabledHabits,
      quietStart: plan.quietStart,
      quietEnd: plan.quietEnd,
      diagnostics: diagnostics,
      problem: lastError,
    );
  }

  /// Sends a test reminder, either now or after [delay], through the same
  /// path real reminders use, then asks the phone whether it took it.
  Future<TestResult> sendTest({Duration delay = Duration.zero}) async {
    if (!await scheduler.hasPermission()) {
      return const TestResult.noPermission();
    }
    final at = clock.now().toLocal().add(delay);
    final test = ScheduledNotification(
      id: testNotificationId,
      at: at,
      title: 'Test reminder.',
      body: 'Notifications are working.',
      // No habits: the Log and Snooze buttons do nothing for a test.
      payload: const ReminderPayload(
        habitIds: [],
        habitNames: [],
        kinds: [],
        priority: 0,
        snoozeCount: 0,
      ).encode(),
    );
    try {
      if (delay == Duration.zero) {
        await scheduler.show(test);
        final d = await scheduler.diagnose();
        return TestResult(at: at, confirmed: d.shownIds.contains(test.id));
      }
      await scheduler.schedule(test);
      final registered = (await scheduler.pending()).any(
        (p) => p.id == test.id,
      );
      return TestResult(at: at, confirmed: registered);
    } catch (e) {
      return TestResult.failed(_short(e));
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

class _Plan {
  const _Plan({
    required this.planned,
    required this.met,
    required this.enabledHabits,
    required this.quietStart,
    required this.quietEnd,
  });

  final List<PlannedReminder> planned;
  final Set<String> met;
  final int enabledHabits;
  final int quietStart;
  final int quietEnd;
}

String _short(Object e) {
  final text = e.toString().replaceAll(RegExp(r'\s+'), ' ');
  return text.length > 140 ? '${text.substring(0, 140)}...' : text;
}

/// What happened when a test reminder was sent.
class TestResult {
  const TestResult({required this.at, required this.confirmed})
    : error = null,
      noPermissionGiven = false;

  const TestResult.noPermission()
    : at = null,
      confirmed = false,
      error = null,
      noPermissionGiven = true;

  const TestResult.failed(this.error)
    : at = null,
      confirmed = false,
      noPermissionGiven = false;

  /// When it should appear.
  final DateTime? at;

  /// For a test shown now: the phone lists it as showing. For a scheduled
  /// test: the phone has the alarm registered.
  final bool confirmed;

  final String? error;
  final bool noPermissionGiven;
}

/// A snapshot for the Reminders screen.
class UpcomingReminders {
  const UpcomingReminders({
    required this.next,
    required this.totalPlanned,
    required this.permitted,
    required this.scheduledOnPhone,
    required this.enabledHabits,
    required this.quietStart,
    required this.quietEnd,
    required this.diagnostics,
    required this.problem,
  });

  /// The next reminders in time order.
  final List<PlannedReminder> next;

  /// How many are planned for the coming week.
  final int totalPlanned;

  final bool permitted;

  /// How many of them the phone actually has scheduled right now.
  final int scheduledOnPhone;

  /// Habits with reminders switched on.
  final int enabledHabits;

  /// Quiet hours, as minutes after midnight.
  final int quietStart;
  final int quietEnd;

  /// What the phone says about this app's notifications.
  final NotificationDiagnostics diagnostics;

  /// Why the last scheduling attempt failed, if it did.
  final String? problem;
}
