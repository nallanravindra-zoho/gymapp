import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/tables/tables.dart';
import 'package:wellbeing/features/workouts/workout_detail_screen.dart';
import 'package:wellbeing/features/workouts/workout_manage_screen.dart';

BuildContext _ctx(WidgetTester tester) =>
    tester.element(find.byType(Scaffold).first);

Future<void> openDetail(WidgetTester tester, String id) async {
  openWorkoutDetail(_ctx(tester), id);
  await tester.pumpAndSettle();
}

Future<void> openManage(WidgetTester tester) async {
  openWorkoutManage(_ctx(tester));
  await tester.pumpAndSettle();
}

/// Inserts a workout directly, with the fixed test user.
Future<String> insertWorkout(
  AppDatabase db, {
  required String userId,
  required String typeId,
  String id = 'w1',
  int minutes = 30,
  int? calories,
  int? steps,
  String? stepsSource,
  double? distanceKm,
  double? speed,
  int paused = 0,
  String? metricsNote,
  String? note,
}) async {
  final start = DateTime.utc(2026, 5, 13, 8);
  await db
      .into(db.workouts)
      .insert(
        WorkoutsCompanion.insert(
          id: id,
          createdAt: start,
          updatedAt: start,
          userId: userId,
          workoutTypeId: typeId,
          startedAt: start,
          endedAt: start.add(Duration(minutes: minutes)),
          durationMinutes: minutes,
          source: WorkoutSource.timer,
          localDate: '2026-05-13',
          caloriesEstimate: Value(calories),
          steps: Value(steps),
          stepsSource: Value(stepsSource),
          distanceKm: Value(distanceKm),
          avgSpeedKmh: Value(speed),
          pausedSeconds: Value(paused),
          metricsNote: Value(metricsNote),
          note: Value(note),
        ),
      );
  return id;
}
