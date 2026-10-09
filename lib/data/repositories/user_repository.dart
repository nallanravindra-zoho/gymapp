import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/time/app_clock.dart';
import '../../core/time/local_date.dart';
import '../app_database.dart';

/// Owns the single local user row and everything derived from its settings.
class UserRepository {
  UserRepository(this._db, this._clock);

  final AppDatabase _db;
  final AppClock _clock;

  /// Returns the local user, creating it on first launch.
  ///
  /// The check and the insert run in one transaction. Several parts of the app
  /// ask for the user at startup, and without this each could find none and
  /// create its own.
  Future<User> ensureUser() {
    return _db.transaction(() async {
      final existing = await _firstUser().getSingleOrNull();
      if (existing != null) return existing;
      final now = _clock.now();
      final id = const Uuid().v4();
      await _db
          .into(_db.users)
          .insert(
            UsersCompanion.insert(id: id, createdAt: now, updatedAt: now),
          );
      return (_db.select(_db.users)..where((u) => u.id.equals(id))).getSingle();
    });
  }

  /// The earliest-created user, so every caller agrees on which one it is.
  SimpleSelectStatement<$UsersTable, User> _firstUser() => _db.select(_db.users)
    ..orderBy([
      (u) => OrderingTerm.asc(u.createdAt),
      (u) => OrderingTerm.asc(u.id),
    ])
    ..limit(1);

  Stream<User?> watchUser() => _firstUser().watchSingleOrNull();

  Future<void> update(String userId, UsersCompanion changes) =>
      (_db.update(_db.users)..where((u) => u.id.equals(userId))).write(
        changes.copyWith(updatedAt: Value(_clock.now())),
      );

  /// Local date for [instant] under this user's offset and day cutoff.
  String localDateFor(User user, DateTime instant) => localDateOf(
    instant,
    offsetMinutes: _clock.offsetAt(instant),
    cutoffMinutes: user.dayCutoffMinutes,
  );

  String today(User user) => localDateFor(user, _clock.now());
}
