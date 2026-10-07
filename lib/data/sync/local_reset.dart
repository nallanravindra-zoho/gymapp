import 'package:drift/drift.dart';

import '../app_database.dart';

/// Clears everything that belongs to the previous account so a different one
/// can start clean: all synced records, cached streaks and insights, and the
/// profile settings. Built-in workout types and the tips library stay.
///
/// The user row itself is kept (so the app's ids stay valid) but returned to
/// its untouched state, which lets the new account's profile replace it.
Future<void> wipeLocalAccountData(AppDatabase db, String localUserId) {
  return db.transaction(() async {
    await db.delete(db.workouts).go();
    await db.delete(db.habitLogs).go();
    await db.delete(db.habits).go();
    await db.delete(db.sleepLogs).go();
    await db.delete(db.sleepTargets).go();
    await db.delete(db.restDays).go();
    await db.delete(db.badgesAwarded).go();
    await db.delete(db.screenTimeDaily).go();
    await db.delete(db.streakStates).go();
    await db.delete(db.weeklyInsights).go();
    await (db.delete(
      db.workoutTypes,
    )..where((t) => t.isBuiltin.equals(false))).go();

    final user = await (db.select(
      db.users,
    )..where((u) => u.id.equals(localUserId))).getSingleOrNull();
    if (user != null) {
      await (db.update(db.users)..where((u) => u.id.equals(localUserId))).write(
        UsersCompanion(
          displayName: const Value(''),
          avatarUrl: const Value(null),
          timezone: const Value('UTC'),
          dayCutoffMinutes: const Value(0),
          quietHoursStart: const Value(null),
          quietHoursEnd: const Value(null),
          dailyReminderCap: const Value(6),
          weeklyRestDays: const Value(2),
          freezeEnabled: const Value(true),
          freezeIntervalDays: const Value(7),
          // Untouched again: the new account's profile will replace it.
          updatedAt: Value(user.createdAt),
        ),
      );
    }
  });
}
