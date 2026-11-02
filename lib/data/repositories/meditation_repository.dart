import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/time/app_clock.dart';
import '../../core/time/local_date.dart';
import '../app_database.dart';

/// Time spent meditating. Sessions have no goal: the person chooses the
/// length each time, and what they did is simply recorded.
class MeditationRepository {
  MeditationRepository(this._db, this._clock);

  final AppDatabase _db;
  final AppClock _clock;

  /// Saves a session that started at [startedAt]. [durationSeconds] is the
  /// time actually spent; [completed] is true when the chosen length was
  /// reached.
  Future<String> add({
    required String userId,
    required int dayCutoffMinutes,
    required DateTime startedAt,
    required int plannedMinutes,
    required int durationSeconds,
    required bool completed,
  }) async {
    final now = _clock.now();
    final start = startedAt.toUtc();
    final offset = _clock.offsetAt(start);
    final id = const Uuid().v4();
    await _db
        .into(_db.meditationSessions)
        .insert(
          MeditationSessionsCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            userId: userId,
            startedAt: start,
            plannedMinutes: plannedMinutes,
            durationSeconds: durationSeconds,
            completed: Value(completed),
            tzOffsetMinutes: Value(offset),
            localDate: localDateOf(
              start,
              offsetMinutes: offset,
              cutoffMinutes: dayCutoffMinutes,
            ),
          ),
        );
    return id;
  }

  /// Soft delete, so the removal syncs.
  Future<void> delete(String id) {
    final now = _clock.now();
    return (_db.update(
      _db.meditationSessions,
    )..where((m) => m.id.equals(id))).write(
      MeditationSessionsCompanion(updatedAt: Value(now), deletedAt: Value(now)),
    );
  }

  /// Live sessions on or between the local dates [from] and [to].
  Stream<List<MeditationSession>> watchBetween(
    String userId,
    String from,
    String to,
  ) {
    return (_db.select(_db.meditationSessions)
          ..where(
            (m) =>
                m.userId.equals(userId) &
                m.deletedAt.isNull() &
                m.localDate.isBetweenValues(from, to),
          )
          ..orderBy([(m) => OrderingTerm.desc(m.startedAt)]))
        .watch();
  }
}
