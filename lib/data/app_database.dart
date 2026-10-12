import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'builtin_workout_types.dart';
import 'seed_tips.dart';
import 'tables/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    WorkoutTypes,
    Workouts,
    Habits,
    HabitLogs,
    HabitSkips,
    Hobbies,
    HobbyLogs,
    BodyMeasurements,
    SleepTargets,
    SleepLogs,
    RestDays,
    StreakStates,
    BadgesAwarded,
    ScreenTimeDaily,
    WeeklyInsights,
    TipsLibrary,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'wellbeing'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedBuiltins();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) await _upgradeToV2(m);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      // Adds any tips this version ships that the database lacks, so
      // existing installs receive new tips too.
      await seedTipsLibrary();
      // Adds any built-in workout types this version ships that the database
      // lacks; existing rows (and the retired "Other") are left untouched.
      await seedBuiltinWorkoutTypes();
    },
  );

  /// v1 -> v2: revised requirements (profile, workout metrics, hobbies, body
  /// measurements, habit skips, screen-time source). Existing rows keep their
  /// data; every new column is nullable or has a default.
  Future<void> _upgradeToV2(Migrator m) async {
    await m.addColumn(users, users.dateOfBirth);
    await m.addColumn(users, users.gender);
    await m.addColumn(users, users.heightCm);
    await m.addColumn(users, users.weightKg);
    await m.addColumn(users, users.measurementCadence);
    await m.addColumn(users, users.measurementReminderEnabled);
    await m.addColumn(users, users.nextMeasurementDue);
    await m.addColumn(users, users.reminderSound);
    await m.addColumn(users, users.habitThreshold);

    await m.addColumn(workouts, workouts.caloriesEstimate);
    await m.addColumn(workouts, workouts.steps);
    await m.addColumn(workouts, workouts.stepsSource);
    await m.addColumn(workouts, workouts.distanceKm);
    await m.addColumn(workouts, workouts.avgSpeedKmh);
    await m.addColumn(workouts, workouts.pausedSeconds);
    await m.addColumn(workouts, workouts.activeSeconds);
    await m.addColumn(workouts, workouts.metricsNote);

    await m.addColumn(screenTimeDaily, screenTimeDaily.source);
    await m.addColumn(screenTimeDaily, screenTimeDaily.targetMinutes);

    await m.createTable(habitSkips);
    await m.createTable(hobbies);
    await m.createTable(hobbyLogs);
    await m.createTable(bodyMeasurements);
  }

  /// Inserts the curated tips that are missing. Tips are matched by id, so
  /// running this repeatedly never duplicates or overwrites anything.
  Future<void> seedTipsLibrary() async {
    final now = DateTime.now().toUtc();
    await batch((b) {
      b.insertAll(tipsLibrary, [
        for (final t in seedTips)
          TipsLibraryCompanion.insert(
            id: t.id,
            createdAt: now,
            updatedAt: now,
            triggerKey: t.triggerKey,
            body: t.text,
            sourceLabel: seedTipSource,
          ),
      ], mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> _seedBuiltins() => seedBuiltinWorkoutTypes();

  /// Idempotent: types are matched by their fixed ids.
  Future<void> seedBuiltinWorkoutTypes() async {
    final now = DateTime.now().toUtc();
    await batch((b) {
      b.insertAll(workoutTypes, mode: InsertMode.insertOrIgnore, [
        for (final t in builtinWorkoutTypes)
          WorkoutTypesCompanion.insert(
            id: t.id,
            createdAt: now,
            updatedAt: now,
            name: t.name,
            iconKey: t.iconKey,
            isBuiltin: const Value(true),
          ),
      ]);
    });
  }
}
