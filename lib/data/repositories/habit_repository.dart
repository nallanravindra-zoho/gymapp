import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/time/app_clock.dart';
import '../../core/time/local_date.dart';
import '../app_database.dart';
import '../tables/tables.dart';

class HabitRepository {
  HabitRepository(this._db, this._clock);

  final AppDatabase _db;
  final AppClock _clock;

  Future<String> create({
    required String userId,
    required String name,
    required HabitKind kind,
    int dailyTarget = 1,
    bool remindersEnabled = false,
    String reminderConfig = '{}',
  }) async {
    final now = _clock.now();
    final id = const Uuid().v4();
    await _db
        .into(_db.habits)
        .insert(
          HabitsCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            userId: userId,
            name: name,
            kind: kind,
            dailyTarget: Value(dailyTarget),
            remindersEnabled: Value(remindersEnabled),
            reminderConfig: Value(reminderConfig),
          ),
        );
    return id;
  }

  Future<void> update(String id, HabitsCompanion changes) =>
      (_db.update(_db.habits)..where((h) => h.id.equals(id))).write(
        changes.copyWith(updatedAt: Value(_clock.now())),
      );

  Future<void> delete(String id) =>
      update(id, HabitsCompanion(deletedAt: Value(_clock.now())));

  Stream<List<Habit>> watchActive(String userId) {
    return (_db.select(_db.habits)
          ..where(
            (h) =>
                h.userId.equals(userId) &
                h.deletedAt.isNull() &
                h.isActive.equals(true),
          )
          ..orderBy([(h) => OrderingTerm.asc(h.createdAt)]))
        .watch();
  }

  /// Records [count] completions now. Returns the new log id.
  Future<String> log({
    required Habit habit,
    required int dayCutoffMinutes,
    int count = 1,
    DateTime? at,
  }) async {
    final when = (at ?? _clock.now()).toUtc();
    final offset = _clock.offsetAt(when);
    final id = const Uuid().v4();
    await _db
        .into(_db.habitLogs)
        .insert(
          HabitLogsCompanion.insert(
            id: id,
            createdAt: _clock.now(),
            updatedAt: _clock.now(),
            habitId: habit.id,
            userId: habit.userId,
            loggedAt: when,
            count: Value(count),
            tzOffsetMinutes: Value(offset),
            localDate: localDateOf(
              when,
              offsetMinutes: offset,
              cutoffMinutes: dayCutoffMinutes,
            ),
          ),
        );
    return id;
  }

  Future<void> deleteLog(String id) =>
      (_db.update(_db.habitLogs)..where((l) => l.id.equals(id))).write(
        HabitLogsCompanion(
          deletedAt: Value(_clock.now()),
          updatedAt: Value(_clock.now()),
        ),
      );

  /// Total completions for a habit on a local date.
  Stream<int> watchCount(String habitId, String localDate) {
    final sum = _db.habitLogs.count.sum();
    final q = _db.selectOnly(_db.habitLogs)
      ..addColumns([sum])
      ..where(
        _db.habitLogs.habitId.equals(habitId) &
            _db.habitLogs.localDate.equals(localDate) &
            _db.habitLogs.deletedAt.isNull(),
      );
    return q.watchSingle().map((r) => r.read(sum) ?? 0);
  }

  Future<List<HabitLog>> logsBetween(String habitId, String from, String to) {
    return (_db.select(_db.habitLogs)..where(
          (l) =>
              l.habitId.equals(habitId) &
              l.deletedAt.isNull() &
              l.localDate.isBiggerOrEqualValue(from) &
              l.localDate.isSmallerOrEqualValue(to),
        ))
        .get();
  }
}
