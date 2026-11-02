import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/time/app_clock.dart';
import '../../core/time/local_date.dart';
import '../app_database.dart';

/// Foods and meals logged by hand. Values are always estimates.
class MealRepository {
  MealRepository(this._db, this._clock);

  final AppDatabase _db;
  final AppClock _clock;

  /// Saves a meal. Calories and macronutrients are optional; [source] is
  /// `listed` (from the built-in food list) or `entered` (typed by the
  /// person).
  Future<String> add({
    required String userId,
    required int dayCutoffMinutes,
    required String name,
    double servings = 1,
    int? calories,
    double? proteinG,
    double? carbsG,
    double? fatG,
    String source = 'entered',
    DateTime? loggedAt,
  }) async {
    final now = _clock.now();
    final at = (loggedAt ?? now).toUtc();
    final offset = _clock.offsetAt(at);
    final id = const Uuid().v4();
    await _db
        .into(_db.mealLogs)
        .insert(
          MealLogsCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            userId: userId,
            name: name.trim(),
            servings: Value(servings),
            calories: Value(calories),
            proteinG: Value(proteinG),
            carbsG: Value(carbsG),
            fatG: Value(fatG),
            source: Value(source),
            loggedAt: at,
            tzOffsetMinutes: Value(offset),
            localDate: localDateOf(
              at,
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
    return (_db.update(_db.mealLogs)..where((m) => m.id.equals(id))).write(
      MealLogsCompanion(updatedAt: Value(now), deletedAt: Value(now)),
    );
  }

  /// Live meals on or between the local dates [from] and [to], newest first.
  Stream<List<MealLog>> watchBetween(String userId, String from, String to) {
    return (_db.select(_db.mealLogs)
          ..where(
            (m) =>
                m.userId.equals(userId) &
                m.deletedAt.isNull() &
                m.localDate.isBetweenValues(from, to),
          )
          ..orderBy([(m) => OrderingTerm.desc(m.loggedAt)]))
        .watch();
  }
}
