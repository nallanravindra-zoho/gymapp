import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/time/app_clock.dart';
import '../../core/time/local_date.dart';
import '../app_database.dart';
import '../tables/tables.dart';

class WorkoutRepository {
  WorkoutRepository(this._db, this._clock);

  final AppDatabase _db;
  final AppClock _clock;

  Stream<List<WorkoutType>> watchTypes(String userId) {
    return (_db.select(_db.workoutTypes)
          ..where(
            (t) =>
                t.deletedAt.isNull() &
                (t.isBuiltin.equals(true) | t.userId.equals(userId)),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<WorkoutType> addCustomType({
    required String userId,
    required String name,
    String iconKey = 'other',
  }) async {
    final now = _clock.now();
    final id = const Uuid().v4();
    await _db
        .into(_db.workoutTypes)
        .insert(
          WorkoutTypesCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            userId: Value(userId),
            name: name,
            iconKey: iconKey,
          ),
        );
    return (_db.select(
      _db.workoutTypes,
    )..where((t) => t.id.equals(id))).getSingle();
  }

  /// Saves a workout. Duration and local date are derived here so every
  /// caller (timer, manual entry, edit) gets the same result.
  Future<String> add({
    required String userId,
    required int dayCutoffMinutes,
    required String workoutTypeId,
    required DateTime startedAt,
    required DateTime endedAt,
    required WorkoutSource source,
    WorkoutIntensity? intensity,
    String? note,
  }) async {
    final now = _clock.now();
    final id = const Uuid().v4();
    final offset = _clock.offsetAt(startedAt);
    await _db
        .into(_db.workouts)
        .insert(
          WorkoutsCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            userId: userId,
            workoutTypeId: workoutTypeId,
            startedAt: startedAt.toUtc(),
            endedAt: endedAt.toUtc(),
            durationMinutes: _minutes(startedAt, endedAt),
            intensity: Value(intensity),
            note: Value(note),
            source: source,
            tzOffsetMinutes: Value(offset),
            localDate: localDateOf(
              startedAt,
              offsetMinutes: offset,
              cutoffMinutes: dayCutoffMinutes,
            ),
          ),
        );
    return id;
  }

  Future<void> update({
    required String id,
    required int dayCutoffMinutes,
    String? workoutTypeId,
    DateTime? startedAt,
    DateTime? endedAt,
    WorkoutIntensity? intensity,
    bool clearIntensity = false,
    String? note,
  }) async {
    final current = await (_db.select(
      _db.workouts,
    )..where((w) => w.id.equals(id))).getSingle();
    final start = (startedAt ?? current.startedAt).toUtc();
    final end = (endedAt ?? current.endedAt).toUtc();
    final offset = startedAt != null
        ? _clock.offsetAt(start)
        : current.tzOffsetMinutes;
    await (_db.update(_db.workouts)..where((w) => w.id.equals(id))).write(
      WorkoutsCompanion(
        workoutTypeId: workoutTypeId == null
            ? const Value.absent()
            : Value(workoutTypeId),
        startedAt: Value(start),
        endedAt: Value(end),
        durationMinutes: Value(_minutes(start, end)),
        intensity: clearIntensity
            ? const Value(null)
            : intensity == null
            ? const Value.absent()
            : Value(intensity),
        note: note == null ? const Value.absent() : Value(note),
        tzOffsetMinutes: Value(offset),
        localDate: Value(
          localDateOf(
            start,
            offsetMinutes: offset,
            cutoffMinutes: dayCutoffMinutes,
          ),
        ),
        updatedAt: Value(_clock.now()),
      ),
    );
  }

  Future<void> delete(String id) =>
      (_db.update(_db.workouts)..where((w) => w.id.equals(id))).write(
        WorkoutsCompanion(
          deletedAt: Value(_clock.now()),
          updatedAt: Value(_clock.now()),
        ),
      );

  /// Live workouts with local dates in [from, to] inclusive.
  Stream<List<Workout>> watchBetween(String userId, String from, String to) {
    return (_db.select(_db.workouts)
          ..where(
            (w) =>
                w.userId.equals(userId) &
                w.deletedAt.isNull() &
                w.localDate.isBiggerOrEqualValue(from) &
                w.localDate.isSmallerOrEqualValue(to),
          )
          ..orderBy([(w) => OrderingTerm.asc(w.startedAt)]))
        .watch();
  }

  Future<List<Workout>> allLive(String userId) {
    return (_db.select(
      _db.workouts,
    )..where((w) => w.userId.equals(userId) & w.deletedAt.isNull())).get();
  }

  int _minutes(DateTime start, DateTime end) {
    final m = end.difference(start).inMinutes;
    return m < 0 ? 0 : m;
  }
}
