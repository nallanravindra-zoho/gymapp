import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/time/app_clock.dart';
import '../app_database.dart';

class ScreenTimeRepository {
  ScreenTimeRepository(this._db, this._clock);

  final AppDatabase _db;
  final AppClock _clock;

  /// One row per local date: re-reading usage stats overwrites that day.
  /// `shareInGroups` is left untouched on update (off by default).
  Future<void> upsertDay({
    required String userId,
    required String localDate,
    required int totalMinutes,
    String categoryMinutesJson = '{}',
    int lateEveningMinutes = 0,
  }) async {
    final now = _clock.now();
    final existing =
        await (_db.select(_db.screenTimeDaily)..where(
              (s) =>
                  s.userId.equals(userId) &
                  s.localDate.equals(localDate) &
                  s.deletedAt.isNull(),
            ))
            .getSingleOrNull();

    if (existing == null) {
      await _db
          .into(_db.screenTimeDaily)
          .insert(
            ScreenTimeDailyCompanion.insert(
              id: const Uuid().v4(),
              createdAt: now,
              updatedAt: now,
              userId: userId,
              localDate: localDate,
              totalMinutes: totalMinutes,
              categoryMinutes: Value(categoryMinutesJson),
              lateEveningMinutes: Value(lateEveningMinutes),
            ),
          );
      return;
    }
    await (_db.update(
      _db.screenTimeDaily,
    )..where((s) => s.id.equals(existing.id))).write(
      ScreenTimeDailyCompanion(
        totalMinutes: Value(totalMinutes),
        categoryMinutes: Value(categoryMinutesJson),
        lateEveningMinutes: Value(lateEveningMinutes),
        updatedAt: Value(now),
      ),
    );
  }

  /// Local dates in `[from, to]` that already have a row.
  Future<Set<String>> datesBetween(
    String userId,
    String from,
    String to,
  ) async {
    final rows =
        await (_db.select(_db.screenTimeDaily)..where(
              (s) =>
                  s.userId.equals(userId) &
                  s.deletedAt.isNull() &
                  s.localDate.isBiggerOrEqualValue(from) &
                  s.localDate.isSmallerOrEqualValue(to),
            ))
            .get();
    return {for (final r in rows) r.localDate};
  }

  Stream<List<ScreenTimeDailyData>> watchBetween(
    String userId,
    String from,
    String to,
  ) {
    return (_db.select(_db.screenTimeDaily)
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
