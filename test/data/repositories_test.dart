import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/builtin_workout_types.dart';
import 'package:wellbeing/data/repositories/habit_repository.dart';
import 'package:wellbeing/data/repositories/rest_day_repository.dart';
import 'package:wellbeing/data/repositories/screen_time_repository.dart';
import 'package:wellbeing/data/repositories/sleep_repository.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/data/repositories/workout_repository.dart';
import 'package:wellbeing/data/tables/tables.dart';

void main() {
  late AppDatabase db;
  late String userId;
  final clock = FixedClock(DateTime.utc(2026, 5, 13, 10), offsetMinutes: 120);
  late WorkoutRepository workouts;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final user = await UserRepository(db, clock).ensureUser();
    userId = user.id;
    workouts = WorkoutRepository(db, clock);
  });

  tearDown(() => db.close());

  group('user', () {
    test('ensureUser is idempotent and has spec defaults', () async {
      final repo = UserRepository(db, clock);
      final a = await repo.ensureUser();
      final b = await repo.ensureUser();
      expect(a.id, b.id);
      expect(a.weeklyRestDays, 2);
      expect(a.dailyReminderCap, 6);
      expect(a.freezeEnabled, isTrue);
      expect(a.freezeIntervalDays, 7);
    });

    test('streak settings are configurable', () async {
      final repo = UserRepository(db, clock);
      await repo.update(
        userId,
        const UsersCompanion(
          weeklyRestDays: Value(3),
          freezeEnabled: Value(false),
        ),
      );
      final u = await repo.ensureUser();
      expect(u.weeklyRestDays, 3);
      expect(u.freezeEnabled, isFalse);
    });
  });

  group('workouts', () {
    test('built-in types are seeded', () async {
      final types = await workouts.watchTypes(userId).first;
      expect(types.length, builtinWorkoutTypes.length);
      expect(types.every((t) => t.isBuiltin), isTrue);
    });

    test('add derives duration and local date', () async {
      final id = await workouts.add(
        userId: userId,
        dayCutoffMinutes: 0,
        workoutTypeId: 'builtin-yoga',
        startedAt: DateTime.utc(2026, 5, 12, 22, 30),
        endedAt: DateTime.utc(2026, 5, 12, 23, 5),
        source: WorkoutSource.manual,
      );
      final w = (await workouts.allLive(userId)).single;
      expect(w.id, id);
      expect(w.durationMinutes, 35);
      expect(w.localDate, '2026-05-13'); // 22:30 UTC is 00:30 in UTC+2
      expect(w.intensity, isNull);
    });

    test('edit recomputes duration and date; delete is soft', () async {
      final id = await workouts.add(
        userId: userId,
        dayCutoffMinutes: 0,
        workoutTypeId: 'builtin-run',
        startedAt: DateTime.utc(2026, 5, 13, 8),
        endedAt: DateTime.utc(2026, 5, 13, 8, 30),
        source: WorkoutSource.timer,
        intensity: WorkoutIntensity.mid,
      );
      await workouts.update(
        id: id,
        dayCutoffMinutes: 0,
        endedAt: DateTime.utc(2026, 5, 13, 9),
        clearIntensity: true,
      );
      var w = (await workouts.allLive(userId)).single;
      expect(w.durationMinutes, 60);
      expect(w.intensity, isNull);

      await workouts.delete(id);
      expect(await workouts.allLive(userId), isEmpty);
      final raw = await db.select(db.workouts).get();
      expect(raw.single.deletedAt, isNotNull);
    });

    test('watchBetween is inclusive and excludes deleted rows', () async {
      Future<String> add(DateTime d) => workouts.add(
        userId: userId,
        dayCutoffMinutes: 0,
        workoutTypeId: 'builtin-walk',
        startedAt: d,
        endedAt: d.add(const Duration(minutes: 20)),
        source: WorkoutSource.manual,
      );
      await add(DateTime.utc(2026, 5, 11, 10));
      final mid = await add(DateTime.utc(2026, 5, 13, 10));
      await add(DateTime.utc(2026, 5, 18, 10));
      await workouts.delete(mid);

      final list = await workouts
          .watchBetween(userId, '2026-05-11', '2026-05-17')
          .first;
      expect(list.map((w) => w.localDate), ['2026-05-11']);
    });

    test('custom types are visible only to their owner', () async {
      await workouts.addCustomType(userId: userId, name: 'Climbing');
      final mine = await workouts.watchTypes(userId).first;
      final other = await workouts.watchTypes('someone-else').first;
      expect(mine.length, other.length + 1);
    });
  });

  group('habits', () {
    test('logs accumulate per local date', () async {
      final repo = HabitRepository(db, clock);
      final id = await repo.create(
        userId: userId,
        name: 'Water',
        kind: HabitKind.water,
        dailyTarget: 8,
      );
      final habit = (await repo.watchActive(userId).first).single;
      expect(habit.id, id);
      expect(habit.remindersEnabled, isFalse); // off by default (7.4)

      await repo.log(habit: habit, dayCutoffMinutes: 0);
      await repo.log(habit: habit, dayCutoffMinutes: 0, count: 2);
      expect(await repo.watchCount(id, '2026-05-13').first, 3);
      expect(await repo.watchCount(id, '2026-05-12').first, 0);
    });

    test('deleted logs no longer count', () async {
      final repo = HabitRepository(db, clock);
      final id = await repo.create(
        userId: userId,
        name: 'Stand',
        kind: HabitKind.stand,
      );
      final habit = (await repo.watchActive(userId).first).single;
      final logId = await repo.log(habit: habit, dayCutoffMinutes: 0);
      await repo.deleteLog(logId);
      expect(await repo.watchCount(id, '2026-05-13').first, 0);
    });
  });

  group('sleep', () {
    test('logging twice for one wake date replaces the entry', () async {
      final repo = SleepRepository(db, clock);
      await repo.log(
        userId: userId,
        dayCutoffMinutes: 0,
        bedtimeAt: DateTime.utc(2026, 5, 12, 20, 45),
        wakeAt: DateTime.utc(2026, 5, 13, 4, 35),
      );
      await repo.log(
        userId: userId,
        dayCutoffMinutes: 0,
        bedtimeAt: DateTime.utc(2026, 5, 12, 21),
        wakeAt: DateTime.utc(2026, 5, 13, 5),
      );
      final logs = await repo
          .watchBetween(userId, '2026-05-13', '2026-05-13')
          .first;
      expect(logs.single.durationMinutes, 480);
    });

    test('target upsert keeps one row', () async {
      final repo = SleepRepository(db, clock);
      await repo.setTarget(
        userId: userId,
        bedtimeMinutes: 1320,
        wakeMinutes: 390,
      );
      await repo.setTarget(
        userId: userId,
        bedtimeMinutes: 1380,
        wakeMinutes: 420,
      );
      final t = await repo.watchTarget(userId).first;
      expect(t!.bedtimeMinutes, 1380);
    });
  });

  group('rest days', () {
    test('limit applies per Mon-Sun week', () async {
      final repo = RestDayRepository(db, clock);
      Future<RestDayResult> mark(String d) =>
          repo.mark(userId: userId, localDate: d, weeklyLimit: 2);

      expect(await mark('2026-05-11'), RestDayResult.recorded);
      expect(await mark('2026-05-11'), RestDayResult.alreadyRecorded);
      expect(await mark('2026-05-12'), RestDayResult.recorded);
      expect(await mark('2026-05-13'), RestDayResult.limitReached);
      // Next week is independent.
      expect(await mark('2026-05-18'), RestDayResult.recorded);

      await repo.unmark(userId, '2026-05-12');
      expect(await mark('2026-05-13'), RestDayResult.recorded);
    });
  });

  group('screen time', () {
    test('upsert overwrites the day and keeps sharing off', () async {
      final repo = ScreenTimeRepository(db, clock);
      await repo.upsertDay(
        userId: userId,
        localDate: '2026-05-13',
        totalMinutes: 200,
      );
      await repo.upsertDay(
        userId: userId,
        localDate: '2026-05-13',
        totalMinutes: 252,
      );
      final rows = await repo
          .watchBetween(userId, '2026-05-13', '2026-05-13')
          .first;
      expect(rows.single.totalMinutes, 252);
      expect(rows.single.shareInGroups, isFalse);
    });
  });
}
