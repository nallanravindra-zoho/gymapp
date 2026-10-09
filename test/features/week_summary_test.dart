import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/tables/tables.dart';
import 'package:wellbeing/features/week/week_summary.dart';

Workout w(String type, String date, int minutes, {int hour = 9}) {
  final t = DateTime.utc(2026, 5, 11, hour);
  return Workout(
    id: '$type$date$hour',
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

void main() {
  test('empty week', () {
    final s = summarizeWeek(const []);
    expect(s.isEmpty, isTrue);
    expect(s.activeMinutes, 0);
    expect(s.activeDays, 0);
  });

  test('totals minutes, distinct days and per-type counts', () {
    final s = summarizeWeek([
      w('yoga', '2026-05-11', 30),
      w('yoga', '2026-05-11', 20, hour: 18), // same day, second workout
      w('run', '2026-05-13', 45),
    ]);
    expect(s.activeMinutes, 95);
    expect(s.activeDays, 2);
    expect(s.countByType, {'yoga': 2, 'run': 1});
  });

  test('weekDates lists Monday to Sunday', () {
    final d = weekDates('2026-05-11');
    expect(d.first, '2026-05-11');
    expect(d.last, '2026-05-17');
    expect(d.length, 7);
  });

  test('groupByDate orders each day by start time', () {
    final g = groupByDate([
      w('run', '2026-05-11', 10, hour: 18),
      w('yoga', '2026-05-11', 10, hour: 7),
    ]);
    expect(g['2026-05-11']!.map((x) => x.workoutTypeId), ['yoga', 'run']);
  });
}
