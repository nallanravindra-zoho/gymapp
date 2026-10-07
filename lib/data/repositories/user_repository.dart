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
  Future<User> ensureUser() async {
    final existing = await (_db.select(_db.users)..limit(1)).getSingleOrNull();
    if (existing != null) return existing;
    final now = _clock.now();
    final id = const Uuid().v4();
    await _db
        .into(_db.users)
        .insert(UsersCompanion.insert(id: id, createdAt: now, updatedAt: now));
    return (_db.select(_db.users)..where((u) => u.id.equals(id))).getSingle();
  }

  Stream<User?> watchUser() =>
      (_db.select(_db.users)..limit(1)).watchSingleOrNull();

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
