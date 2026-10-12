import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/builtin_workout_types.dart';

void main() {
  test('built-in types are seeded once and re-seeding is a no-op', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.seedBuiltinWorkoutTypes();
    await db.seedBuiltinWorkoutTypes();
    final rows = await db.select(db.workoutTypes).get();
    expect(rows.length, builtinWorkoutTypes.length);
    expect(rows.map((r) => r.name), containsAll(['Yoga', 'Walk', 'Run']));
  });

  test('a missing built-in type is added to an existing install', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.seedBuiltinWorkoutTypes();
    await (db.delete(
      db.workoutTypes,
    )..where((t) => t.id.equals('builtin-stability'))).go();
    await db.seedBuiltinWorkoutTypes();
    final ids = (await db.select(db.workoutTypes).get()).map((r) => r.id);
    expect(ids, contains('builtin-stability'));
  });

  test('Other stays stored (old workouts) but is retired from the picker', () {
    expect(retiredBuiltinTypeIds, contains('builtin-other'));
    expect(builtinWorkoutTypes.any((t) => t.id == 'builtin-other'), isTrue);
  });
}
