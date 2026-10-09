import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/time/app_clock.dart';
import '../../core/time/local_date.dart';
import '../app_database.dart';

class SleepRepository {
  SleepRepository(this._db, this._clock);

  final AppDatabase _db;
  final AppClock _clock;

  Stream<SleepTarget?> watchTarget(String userId) => (_db.select(
    _db.sleepTargets,
  )..where((t) => t.userId.equals(userId))).watchSingleOrNull();

  Future<void> setTarget({
    required String userId,
    required int bedtimeMinutes,
    required int wakeMinutes,
  }) => _db
      .into(_db.sleepTargets)
      .insertOnConflictUpdate(
        SleepTargetsCompanion.insert(
          userId: userId,
          bedtimeMinutes: bedtimeMinutes,
          wakeMinutes: wakeMinutes,
          updatedAt: _clock.now(),
        ),
      );

  /// One log per wake date: logging again for the same date replaces it.
  Future<String> log({
    required String userId,
    required int dayCutoffMinutes,
    required DateTime bedtimeAt,
    required DateTime wakeAt,
  }) async {
    final wake = wakeAt.toUtc();
    final offset = _clock.offsetAt(wake);
    final date = localDateOf(
      wake,
      offsetMinutes: offset,
      cutoffMinutes: dayCutoffMinutes,
    );
    final now = _clock.now();

    final existing =
        await (_db.select(_db.sleepLogs)..where(
              (s) =>
                  s.userId.equals(userId) &
                  s.localDate.equals(date) &
                  s.deletedAt.isNull(),
            ))
            .getSingleOrNull();

    final minutes = wake.difference(bedtimeAt.toUtc()).inMinutes;
    if (existing != null) {
      await (_db.update(
        _db.sleepLogs,
      )..where((s) => s.id.equals(existing.id))).write(
        SleepLogsCompanion(
          bedtimeAt: Value(bedtimeAt.toUtc()),
          wakeAt: Value(wake),
          durationMinutes: Value(minutes < 0 ? 0 : minutes),
          tzOffsetMinutes: Value(offset),
          updatedAt: Value(now),
        ),
      );
      return existing.id;
    }

    final id = const Uuid().v4();
    await _db
        .into(_db.sleepLogs)
        .insert(
          SleepLogsCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            userId: userId,
            bedtimeAt: bedtimeAt.toUtc(),
            wakeAt: wake,
            durationMinutes: minutes < 0 ? 0 : minutes,
            tzOffsetMinutes: Value(offset),
            localDate: date,
          ),
        );
    return id;
  }

  Future<void> delete(String id) =>
      (_db.update(_db.sleepLogs)..where((s) => s.id.equals(id))).write(
        SleepLogsCompanion(
          deletedAt: Value(_clock.now()),
          updatedAt: Value(_clock.now()),
        ),
      );

  Stream<List<SleepLog>> watchBetween(String userId, String from, String to) {
    return (_db.select(_db.sleepLogs)
          ..where(
            (s) =>
                s.userId.equals(userId) &
                s.deletedAt.isNull() &
                s.localDate.isBiggerOrEqualValue(from) &
                s.localDate.isSmallerOrEqualValue(to),
          )
          ..orderBy([(s) => OrderingTerm.asc(s.localDate)]))
        .watch();
  }
}
