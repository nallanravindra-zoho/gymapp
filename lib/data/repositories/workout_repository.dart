import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/time/app_clock.dart';
import '../../core/time/local_date.dart';
import '../app_database.dart';
import '../tables/tables.dart';

/// Optional measurements saved with a workout (R3). Calories are always an
/// estimate; [stepsSource] is `sensor` or `estimate`; [metricsNote] is
/// `estimated` or `measured`.
class WorkoutMetrics {
  const WorkoutMetrics({
    this.caloriesEstimate,
    this.steps,
    this.stepsSource,
    this.distanceKm,
    this.avgSpeedKmh,
    this.pausedSeconds = 0,
    this.activeSeconds,
    this.metricsNote,
  });

  final int? caloriesEstimate;
  final int? steps;
  final String? stepsSource;
  final double? distanceKm;
  final double? avgSpeedKmh;
  final int pausedSeconds;
  final int? activeSeconds;
  final String? metricsNote;
}

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
    WorkoutMetrics? metrics,
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
            caloriesEstimate: Value(metrics?.caloriesEstimate),
            steps: Value(metrics?.steps),
            stepsSource: Value(metrics?.stepsSource),
            distanceKm: Value(metrics?.distanceKm),
            avgSpeedKmh: Value(metrics?.avgSpeedKmh),
            pausedSeconds: Value(metrics?.pausedSeconds ?? 0),
            activeSeconds: Value(metrics?.activeSeconds),
            metricsNote: Value(metrics?.metricsNote),
          ),
        );
    return id;
  }

  /// Replaces a workout's metrics (calories, steps, distance, speed, pauses).
  Future<void> setMetrics(String id, WorkoutMetrics metrics) =>
      (_db.update(_db.workouts)..where((w) => w.id.equals(id))).write(
        WorkoutsCompanion(
          caloriesEstimate: Value(metrics.caloriesEstimate),
          steps: Value(metrics.steps),
          stepsSource: Value(metrics.stepsSource),
          distanceKm: Value(metrics.distanceKm),
          avgSpeedKmh: Value(metrics.avgSpeedKmh),
          pausedSeconds: Value(metrics.pausedSeconds),
          activeSeconds: Value(metrics.activeSeconds),
          metricsNote: Value(metrics.metricsNote),
          updatedAt: Value(_clock.now()),
        ),
      );

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

  /// Live stream of every non-deleted workout, for streak computation.
  Stream<List<Workout>> watchAll(String userId) {
    return (_db.select(
      _db.workouts,
    )..where((w) => w.userId.equals(userId) & w.deletedAt.isNull())).watch();
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
