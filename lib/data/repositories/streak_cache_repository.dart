import 'package:drift/drift.dart';

import '../app_database.dart';

/// Stores computed streaks for fast first paint. Never the source of truth:
/// streaks are recomputed from logs (spec 7.2).
class StreakCacheRepository {
  StreakCacheRepository(this._db);

  final AppDatabase _db;

  Future<void> upsert({
    required String userId,
    required String scope,
    required int current,
    required int longest,
    required String? lastCountedDate,
    required bool freezeAvailable,
    required String? lastFreezeDate,
  }) => _db
      .into(_db.streakStates)
      .insertOnConflictUpdate(
        StreakStatesCompanion.insert(
          userId: userId,
          scope: scope,
          currentStreak: Value(current),
          longestStreak: Value(longest),
          lastCountedDate: Value(lastCountedDate),
          freezeAvailable: Value(freezeAvailable),
          // Holds the date a freeze was last applied.
          freezeLastGrantedOn: Value(lastFreezeDate),
        ),
      );

  Future<List<StreakState>> all(String userId) => (_db.select(
    _db.streakStates,
  )..where((s) => s.userId.equals(userId))).get();
}
