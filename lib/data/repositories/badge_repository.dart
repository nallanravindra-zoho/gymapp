import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/time/app_clock.dart';
import '../app_database.dart';

/// Deterministic row id for a badge (UUID v5), identical on every device.
String badgeRowId(String userId, String badgeKey) =>
    const Uuid().v5(Namespace.url.value, 'wellbeing-badge:$userId:$badgeKey');

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

  /// Badge key -> when it was first awarded (earliest if rows ever repeat).
  Stream<Map<String, DateTime>> watchAwardedDates(String userId) {
    return (_db.select(_db.badgesAwarded)
          ..where((b) => b.userId.equals(userId) & b.deletedAt.isNull()))
        .watch()
        .map((rows) {
          final out = <String, DateTime>{};
          for (final r in rows) {
            final prev = out[r.badgeKey];
            if (prev == null || r.awardedAt.isBefore(prev)) {
              out[r.badgeKey] = r.awardedAt;
            }
          }
          return out;
        });
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
      // The id is derived from user and key, so two devices that award the
      // same badge produce the same row and sync merges them into one.
      await _db
          .into(_db.badgesAwarded)
          .insertOnConflictUpdate(
            BadgesAwardedCompanion.insert(
              id: badgeRowId(userId, badgeKey),
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
