import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/repositories/habit_repository.dart';
import 'package:wellbeing/data/repositories/hobby_repository.dart';
import 'package:wellbeing/data/repositories/screen_time_repository.dart';
import 'package:wellbeing/data/repositories/sleep_repository.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/data/repositories/workout_repository.dart';
import 'package:wellbeing/data/tables/tables.dart';

import '../test_helpers.dart';

/// Writes one achieved entry per category for the UTC date `2026-05-[day]`
/// (the test clock runs in UTC): a workout, a habit that reaches its target,
/// a hobby with a daily goal met, a night of 10 hours ending that morning,
/// and 60 minutes of screen time. Use with a screen-time target of 120.
Future<void> seedFullDay(AppDatabase db, {int day = 12}) async {
  final clock = FixedClock(testNow);
  final user = await UserRepository(db, clock).ensureUser();
  final at = DateTime.utc(2026, 5, day, 8);

  await WorkoutRepository(db, clock).add(
    userId: user.id,
    dayCutoffMinutes: 0,
    workoutTypeId: 'builtin-yoga',
    startedAt: at,
    endedAt: at.add(const Duration(minutes: 30)),
    source: WorkoutSource.manual,
  );

  final habits = HabitRepository(db, clock);
  final habitId = await habits.create(
    userId: user.id,
    name: 'Water',
    kind: HabitKind.water,
    dailyTarget: 1,
  );
  final habit = (await db.select(db.habits).get()).firstWhere(
    (h) => h.id == habitId,
  );
  await habits.log(habit: habit, dayCutoffMinutes: 0, at: at);

  final hobbies = HobbyRepository(db, clock);
  final hobbyId = await hobbies.addCustom(
    userId: user.id,
    name: 'Painting',
    goalPeriod: HobbyGoalPeriod.daily,
    goalValue: 10,
  );
  await hobbies.addLog(
    userId: user.id,
    hobbyId: hobbyId,
    dayCutoffMinutes: 0,
    source: HobbyLogSource.manual,
    startedAt: at,
    durationMinutes: 20,
  );

  await SleepRepository(db, clock).log(
    userId: user.id,
    dayCutoffMinutes: 0,
    bedtimeAt: DateTime.utc(2026, 5, day - 1, 21),
    wakeAt: DateTime.utc(2026, 5, day, 7),
  );

  await ScreenTimeRepository(db, clock).upsertDay(
    userId: user.id,
    localDate: '2026-05-${day.toString().padLeft(2, '0')}',
    totalMinutes: 60,
  );
}
