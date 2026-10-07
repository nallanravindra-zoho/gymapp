import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'builtin_workout_types.dart';
import 'tables/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    WorkoutTypes,
    Workouts,
    Habits,
    HabitLogs,
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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedBuiltins();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _seedBuiltins() async {
    final now = DateTime.now().toUtc();
    await batch((b) {
      b.insertAll(workoutTypes, [
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
