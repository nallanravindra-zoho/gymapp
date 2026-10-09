import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/time/app_clock.dart';
import '../app_database.dart';

class BadgeRepository {
  BadgeRepository(this._db, this._clock);

  final AppDatabase _db;
  final AppClock _clock;

  Future<Set<String>> awardedKeys(String userId) async {
    final rows = await (_db.select(
      _db.badgesAwarded,
    )..where((b) => b.userId.equals(userId) & b.deletedAt.isNull())).get();
    return {for (final r in rows) r.badgeKey};
  }

  Stream<Set<String>> watchAwardedKeys(String userId) {
    return (_db.select(_db.badgesAwarded)
          ..where((b) => b.userId.equals(userId) & b.deletedAt.isNull()))
        .watch()
        .map((rows) => {for (final r in rows) r.badgeKey});
  }

  /// Awards [badgeKey] once. Returns false if it was already awarded.
  Future<bool> award(String userId, String badgeKey, {String context = '{}'}) {
    return _db.transaction(() async {
      final existing =
          await (_db.select(_db.badgesAwarded)..where(
                (b) =>
                    b.userId.equals(userId) &
                    b.badgeKey.equals(badgeKey) &
                    b.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (existing != null) return false;
      final now = _clock.now();
      await _db
          .into(_db.badgesAwarded)
          .insert(
            BadgesAwardedCompanion.insert(
              id: const Uuid().v4(),
              createdAt: now,
              updatedAt: now,
              userId: userId,
              badgeKey: badgeKey,
              awardedAt: now,
              context: Value(context),
            ),
          );
      return true;
    });
  }
}
