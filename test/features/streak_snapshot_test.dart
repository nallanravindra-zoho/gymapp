import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/tables/tables.dart';
import 'package:wellbeing/features/streaks/streak_snapshot.dart';

Workout w(String type, String date, int minutes) {
  final t = DateTime.utc(2026, 5, 11, 9);
  return Workout(
    id: '$type$date$minutes',
    createdAt: t,
    updatedAt: t,
    deletedAt: null,
    userId: 'u',
    workoutTypeId: type,
    startedAt: t,
    endedAt: t.add(Duration(minutes: minutes)),
    durationMinutes: minutes,
    intensity: null,
    note: null,
    source: WorkoutSource.manual,
    tzOffsetMinutes: 0,
    localDate: date,
  );
}

StreakSnapshot snap(List<Workout> ws, {Set<String> rest = const {}}) =>
    buildSnapshot(
      workouts: ws,
      restDates: rest,
      today: '2026-05-13',
      freezeEnabled: false,
      freezeIntervalDays: 7,
    );

void main() {
  test('overall counts any workout; per-type counts only that type', () {
    final s = snap([
      w('yoga', '2026-05-11', 30),
      w('run', '2026-05-12', 30),
      w('yoga', '2026-05-13', 30),
    ]);
    expect(s.overall.current, 3);
    expect(s.byType['yoga']!.current, 1); // not on the 12th
    // Yesterday counted and today is still open, so the run streak is alive.
    expect(s.byType['run']!.current, 1);
  });

  test('rest days bridge the overall streak but not per-type streaks', () {
    final s = snap(
      [w('yoga', '2026-05-11', 30), w('yoga', '2026-05-13', 30)],
      rest: {'2026-05-12'},
    );
    expect(s.overall.current, 2);
    expect(s.byType['yoga']!.current, 1);
  });

  test('best week minutes uses Monday to Sunday weeks', () {
    final s = snap([
      w('yoga', '2026-05-10', 100), // Sunday of the previous week
      w('yoga', '2026-05-11', 30), // this week
      w('run', '2026-05-12', 45),
    ]);
    expect(s.bestWeekMinutes, 100); // previous week's 100 beats 75
    final s2 = snap([
      w('yoga', '2026-05-09', 60),
      w('yoga', '2026-05-11', 30),
      w('run', '2026-05-12', 45),
    ]);
    expect(s2.bestWeekMinutes, 75);
  });

  test('empty logs', () {
    final s = snap([]);
    expect(s.overall.current, 0);
    expect(s.bestWeekMinutes, 0);
    expect(s.byType, isEmpty);
  });
}
