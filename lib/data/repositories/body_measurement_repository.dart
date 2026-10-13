import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/time/app_clock.dart';
import '../../core/time/local_date.dart';
import '../app_database.dart';

/// BMI = weight_kg / (height_m * height_m). Null when an input is missing or
/// not positive. A screening figure only (R10).
double? calculateBmi(double? weightKg, double? heightCm) {
  if (weightKg == null || heightCm == null) return null;
  if (weightKg <= 0 || heightCm <= 0) return null;
  final m = heightCm / 100;
  return weightKg / (m * m);
}

/// One chartable value of a body measurement record.
enum MeasurementField {
  weightKg,
  bmi,
  waistIn,
  hipsIn,
  chestIn,
  armIn,
  thighIn,
}

class MeasurementPoint {
  const MeasurementPoint({
    required this.measuredAt,
    required this.localDate,
    required this.value,
    required this.id,
  });
  final String id;
  final DateTime measuredAt;
  final String localDate;
  final double value;
}

extension MeasurementFieldRead on BodyMeasurement {
  double? valueOf(MeasurementField f) => switch (f) {
    MeasurementField.weightKg => weightKg,
    MeasurementField.bmi => bmi,
    MeasurementField.waistIn => waistIn,
    MeasurementField.hipsIn => hipsIn,
    MeasurementField.chestIn => chestIn,
    MeasurementField.armIn => armIn,
    MeasurementField.thighIn => thighIn,
  };
}

class BodyMeasurementRepository {
  BodyMeasurementRepository(this._db, this._clock);

  final AppDatabase _db;
  final AppClock _clock;

  /// Saves a record. Every value is optional (partial records are fine). BMI
  /// is calculated from weight and height when both are given and [bmi] is
  /// not.
  Future<String> add({
    required String userId,
    required int dayCutoffMinutes,
    DateTime? measuredAt,
    double? weightKg,
    double? heightCm,
    double? bmi,
    double? waistIn,
    double? hipsIn,
    double? chestIn,
    double? armIn,
    double? thighIn,
    String? notes,
  }) async {
    final now = _clock.now();
    final at = (measuredAt ?? now).toUtc();
    final offset = _clock.offsetAt(at);
    final id = const Uuid().v4();
    await _db
        .into(_db.bodyMeasurements)
        .insert(
          BodyMeasurementsCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            userId: userId,
            measuredAt: at,
            tzOffsetMinutes: Value(offset),
            localDate: localDateOf(
              at,
              offsetMinutes: offset,
              cutoffMinutes: dayCutoffMinutes,
            ),
            weightKg: Value(weightKg),
            heightCm: Value(heightCm),
            bmi: Value(bmi ?? calculateBmi(weightKg, heightCm)),
            waistIn: Value(waistIn),
            hipsIn: Value(hipsIn),
            chestIn: Value(chestIn),
            armIn: Value(armIn),
            thighIn: Value(thighIn),
            notes: Value(notes),
          ),
        );
    return id;
  }

  /// Edits a record. [changes] may set any value; when weight or height
  /// change and no BMI is given, BMI is recalculated from the merged values.
  Future<void> update(
    String id,
    BodyMeasurementsCompanion changes, {
    int dayCutoffMinutes = 0,
  }) async {
    final current = await (_db.select(
      _db.bodyMeasurements,
    )..where((m) => m.id.equals(id))).getSingle();
    var next = changes;
    if (!changes.bmi.present &&
        (changes.weightKg.present || changes.heightCm.present)) {
      final w = changes.weightKg.present
          ? changes.weightKg.value
          : current.weightKg;
      final h = changes.heightCm.present
          ? changes.heightCm.value
          : current.heightCm;
      next = next.copyWith(bmi: Value(calculateBmi(w, h)));
    }
    if (changes.measuredAt.present) {
      final at = changes.measuredAt.value.toUtc();
      final offset = _clock.offsetAt(at);
      next = next.copyWith(
        measuredAt: Value(at),
        tzOffsetMinutes: Value(offset),
        localDate: Value(
          localDateOf(
            at,
            offsetMinutes: offset,
            cutoffMinutes: dayCutoffMinutes,
          ),
        ),
      );
    }
    await (_db.update(_db.bodyMeasurements)..where((m) => m.id.equals(id)))
        .write(next.copyWith(updatedAt: Value(_clock.now())));
  }

  /// Soft-deletes a record (it syncs as deleted).
  Future<void> delete(String id) =>
      (_db.update(_db.bodyMeasurements)..where((m) => m.id.equals(id))).write(
        BodyMeasurementsCompanion(
          deletedAt: Value(_clock.now()),
          updatedAt: Value(_clock.now()),
        ),
      );

  Future<BodyMeasurement?> byId(String id) => (_db.select(
    _db.bodyMeasurements,
  )..where((m) => m.id.equals(id) & m.deletedAt.isNull())).getSingleOrNull();

  SimpleSelectStatement<$BodyMeasurementsTable, BodyMeasurement> _live(
    String userId,
  ) =>
      _db.select(_db.bodyMeasurements)
        ..where((m) => m.userId.equals(userId) & m.deletedAt.isNull());

  /// The most recent record, or null.
  Future<BodyMeasurement?> latest(String userId) =>
      (_live(userId)
            ..orderBy([(m) => OrderingTerm.desc(m.measuredAt)])
            ..limit(1))
          .getSingleOrNull();

  /// The most recent record that has a value for [field], or null.
  Future<BodyMeasurement?> latestWith(
    String userId,
    MeasurementField field,
  ) async {
    final all = await allRecords(userId);
    for (final m in all.reversed) {
      if (m.valueOf(field) != null) return m;
    }
    return null;
  }

  /// Every live record, oldest first.
  Future<List<BodyMeasurement>> allRecords(String userId) =>
      (_live(userId)..orderBy([(m) => OrderingTerm.asc(m.measuredAt)])).get();

  /// Live stream of every record, newest first (for the history list).
  Stream<List<BodyMeasurement>> watchAll(String userId) => (_live(
    userId,
  )..orderBy([(m) => OrderingTerm.desc(m.measuredAt)])).watch();

  /// Values of one field over time, oldest first. Records without a value
  /// for the field are skipped.
  Future<List<MeasurementPoint>> series(
    String userId,
    MeasurementField field,
  ) async => _points(await allRecords(userId), field);

  Stream<List<MeasurementPoint>> watchSeries(
    String userId,
    MeasurementField field,
  ) => (_live(userId)..orderBy([(m) => OrderingTerm.asc(m.measuredAt)]))
      .watch()
      .map((rows) => _points(rows, field));

  List<MeasurementPoint> _points(
    List<BodyMeasurement> rows,
    MeasurementField field,
  ) => [
    for (final m in rows)
      if (m.valueOf(field) != null)
        MeasurementPoint(
          id: m.id,
          measuredAt: m.measuredAt,
          localDate: m.localDate,
          value: m.valueOf(field)!,
        ),
  ];
}
