import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/body_measurement_repository.dart';
import '../streaks/streak_providers.dart';
import '../week/week_providers.dart';
import 'metrics_logic.dart';

/// Every body measurement record, newest first. Private to the person.
final measurementsProvider = StreamProvider<List<BodyMeasurement>>((
  ref,
) async* {
  final user = await ref.watch(currentUserProvider.future);
  yield* ref.watch(bodyMeasurementRepositoryProvider).watchAll(user.id);
});

/// One chartable series, oldest first.
final measurementSeriesProvider =
    StreamProvider.family<List<MeasurementPoint>, MeasurementField>((
      ref,
      field,
    ) async* {
      final user = await ref.watch(currentUserProvider.future);
      yield* ref
          .watch(bodyMeasurementRepositoryProvider)
          .watchSeries(user.id, field);
    });

/// The person's age today, from their date of birth (null without one).
final userAgeProvider = Provider<int?>((ref) {
  final user = ref.watch(userStreamProvider).value;
  final today = ref.watch(todayDateProvider).value;
  if (user == null || today == null) return null;
  return ageOn(user.dateOfBirth, today);
});

/// The heads-up for measurement day. The Today screen shows it through
/// `MeasurementsBanner`.
final measurementNoticeProvider = Provider<MeasurementNotice>((ref) {
  final user = ref.watch(userStreamProvider).value;
  final today = ref.watch(todayDateProvider).value;
  if (user == null || today == null) return MeasurementNotice.none;
  return measurementNotice(
    enabled: user.measurementReminderEnabled,
    due: user.nextMeasurementDue,
    today: today,
  );
});

/// The latest BMI: from the newest record that has one, else from the
/// profile height and weight.
final latestBmiProvider = Provider<double?>((ref) {
  final rows = ref.watch(measurementsProvider).value ?? const [];
  for (final m in rows) {
    if (m.bmi != null) return m.bmi;
  }
  final u = ref.watch(userStreamProvider).value;
  return calculateBmi(u?.weightKg, u?.heightCm);
});

/// Writes that keep the profile and the next-due date in step with records.
class MetricsActions {
  MetricsActions(this._ref);
  final Ref _ref;

  Future<void> _afterChange() async {
    final user = await _ref.read(currentUserProvider.future);
    final repo = _ref.read(bodyMeasurementRepositoryProvider);
    final latest = await repo.latest(user.id);
    final fresh = await _ref.read(userRepositoryProvider).watchUser().first;
    if (fresh == null) return;
    final cadence = MeasurementCadence.parse(fresh.measurementCadence);
    String? due = fresh.nextMeasurementDue;
    if (latest != null) due = nextMeasurementDue(latest.localDate, cadence);
    final w = await repo.latestWith(user.id, MeasurementField.weightKg);
    await _ref
        .read(userRepositoryProvider)
        .update(
          user.id,
          UsersCompanion(
            nextMeasurementDue: Value(due),
            weightKg: w?.weightKg != null
                ? Value(w!.weightKg)
                : const Value.absent(),
          ),
        );
  }

  Future<void> add({
    required DateTime at,
    double? weightKg,
    double? heightCm,
    double? waistIn,
    double? hipsIn,
    double? chestIn,
    double? armIn,
    double? thighIn,
    String? notes,
  }) async {
    final user = await _ref.read(currentUserProvider.future);
    await _ref
        .read(bodyMeasurementRepositoryProvider)
        .add(
          userId: user.id,
          dayCutoffMinutes: user.dayCutoffMinutes,
          measuredAt: at,
          weightKg: weightKg,
          heightCm: heightCm,
          waistIn: waistIn,
          hipsIn: hipsIn,
          chestIn: chestIn,
          armIn: armIn,
          thighIn: thighIn,
          notes: notes,
        );
    if (heightCm != null) {
      await _ref
          .read(userRepositoryProvider)
          .update(user.id, UsersCompanion(heightCm: Value(heightCm)));
    }
    await _afterChange();
  }

  Future<void> edit(
    String id, {
    required DateTime at,
    double? weightKg,
    double? heightCm,
    double? waistIn,
    double? hipsIn,
    double? chestIn,
    double? armIn,
    double? thighIn,
    String? notes,
  }) async {
    final user = await _ref.read(currentUserProvider.future);
    await _ref
        .read(bodyMeasurementRepositoryProvider)
        .update(
          id,
          BodyMeasurementsCompanion(
            measuredAt: Value(at),
            weightKg: Value(weightKg),
            heightCm: Value(heightCm),
            waistIn: Value(waistIn),
            hipsIn: Value(hipsIn),
            chestIn: Value(chestIn),
            armIn: Value(armIn),
            thighIn: Value(thighIn),
            notes: Value(notes),
            // Recalculated from the new weight and height.
            bmi: Value(calculateBmi(weightKg, heightCm)),
          ),
          dayCutoffMinutes: user.dayCutoffMinutes,
        );
    if (heightCm != null) {
      await _ref
          .read(userRepositoryProvider)
          .update(user.id, UsersCompanion(heightCm: Value(heightCm)));
    }
    await _afterChange();
  }

  Future<void> delete(String id) async {
    await _ref.read(bodyMeasurementRepositoryProvider).delete(id);
    await _afterChange();
  }

  /// Changes how often measurements are due and recomputes the next date.
  Future<void> setCadence(MeasurementCadence c) async {
    final user = await _ref.read(currentUserProvider.future);
    final repo = _ref.read(bodyMeasurementRepositoryProvider);
    final latest = await repo.latest(user.id);
    final today = _ref.read(userRepositoryProvider).today(user);
    await _ref
        .read(userRepositoryProvider)
        .update(
          user.id,
          UsersCompanion(
            measurementCadence: Value(c.key),
            nextMeasurementDue: Value(
              nextMeasurementDue(latest?.localDate ?? today, c),
            ),
          ),
        );
  }
}

final metricsActionsProvider = Provider(MetricsActions.new);
