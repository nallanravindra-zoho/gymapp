import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/time/app_clock.dart';
import '../../core/time/local_date.dart';
import '../app_database.dart';

enum RestDayResult { recorded, alreadyRecorded, limitReached }

class RestDayRepository {
  RestDayRepository(this._db, this._clock);

  final AppDatabase _db;
  final AppClock _clock;

  /// Marks [localDate] as a rest day unless the Mon-Sun week already holds
  /// [weeklyLimit] of them (spec 7.2).
  Future<RestDayResult> mark({
    required String userId,
    required String localDate,
    required int weeklyLimit,
  }) async {
    final live = await _liveBetween(
      userId,
      weekStartOf(localDate),
      shiftLocalDate(weekStartOf(localDate), 6),
    );
    if (live.any((r) => r.localDate == localDate)) {
      return RestDayResult.alreadyRecorded;
    }
    if (live.length >= weeklyLimit) return RestDayResult.limitReached;

    final now = _clock.now();
    await _db
        .into(_db.restDays)
        .insert(
          RestDaysCompanion.insert(
            id: const Uuid().v4(),
            createdAt: now,
            updatedAt: now,
            userId: userId,
            localDate: localDate,
          ),
        );
    return RestDayResult.recorded;
  }

  Future<void> unmark(String userId, String localDate) =>
      (_db.update(_db.restDays)..where(
            (r) =>
                r.userId.equals(userId) &
                r.localDate.equals(localDate) &
                r.deletedAt.isNull(),
          ))
          .write(
            RestDaysCompanion(
              deletedAt: Value(_clock.now()),
              updatedAt: Value(_clock.now()),
            ),
          );

  Stream<List<RestDay>> watchBetween(String userId, String from, String to) {
    return (_db.select(_db.restDays)..where(
          (r) =>
              r.userId.equals(userId) &
              r.deletedAt.isNull() &
              r.localDate.isBiggerOrEqualValue(from) &
              r.localDate.isSmallerOrEqualValue(to),
        ))
        .watch();
  }

  Future<List<RestDay>> all(String userId) => (_db.select(
    _db.restDays,
  )..where((r) => r.userId.equals(userId) & r.deletedAt.isNull())).get();

  Future<List<RestDay>> _liveBetween(String userId, String from, String to) =>
      (_db.select(_db.restDays)..where(
            (r) =>
                r.userId.equals(userId) &
                r.deletedAt.isNull() &
                r.localDate.isBiggerOrEqualValue(from) &
                r.localDate.isSmallerOrEqualValue(to),
          ))
          .get();
}
