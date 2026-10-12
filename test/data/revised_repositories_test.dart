import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/repositories/body_measurement_repository.dart';
import 'package:wellbeing/data/repositories/habit_repository.dart';
import 'package:wellbeing/data/repositories/hobby_repository.dart';
import 'package:wellbeing/data/repositories/screen_time_repository.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/data/repositories/workout_repository.dart';
import 'package:wellbeing/data/tables/tables.dart';

void main() {
  late AppDatabase db;
  late String userId;
  // 2026-05-13 10:00 UTC, phone at UTC+2 -> local date 2026-05-13.
  final clock = FixedClock(DateTime.utc(2026, 5, 13, 10), offsetMinutes: 120);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    userId = (await UserRepository(db, clock).ensureUser()).id;
  });
  tearDown(() => db.close());

  group('user profile fields', () {
    test('have the documented defaults and can be edited', () async {
      final repo = UserRepository(db, clock);
      final u = await repo.ensureUser();
      expect(u.dateOfBirth, isNull);
      expect(u.gender, isNull);
      expect(u.heightCm, isNull);
      expect(u.weightKg, isNull);
      expect(u.measurementCadence, 'monthly');
      expect(u.measurementReminderEnabled, isTrue);
      expect(u.nextMeasurementDue, isNull);
      expect(u.reminderSound, isNull);
      expect(u.habitThreshold, 1);
      await repo.update(
        userId,
        const UsersCompanion(
          dateOfBirth: Value('1990-01-31'),
          measurementCadence: Value('bimonthly'),
        ),
      );
      final e = await repo.ensureUser();
      expect(e.dateOfBirth, '1990-01-31');
      expect(e.measurementCadence, 'bimonthly');
    });
  });

  group('HobbyRepository', () {
    late HobbyRepository repo;
    setUp(() => repo = HobbyRepository(db, clock));

    test('ensureDefaults seeds the six built-ins once', () async {
      await repo.ensureDefaults(userId);
      await repo.ensureDefaults(userId);
      await Future.wait([
        repo.ensureDefaults(userId),
        repo.ensureDefaults(userId),
      ]);
      final list = await repo.watchActive(userId).first;
      expect(list.map((h) => h.name), [
        'Music',
        'Art',
        'Dance',
        'Learning',
        'Reading',
        'Writing',
      ]);
      expect(list.every((h) => h.isBuiltin && h.isActive), isTrue);
      expect(list.first.goalPeriod, isNull);
      expect(list.first.goalUnit, HobbyGoalUnit.minutes);
      expect(list.first.reminderEnabled, isFalse);
      expect(list.first.reminderConfig, '{}');
    });

    test('a deleted built-in is not brought back', () async {
      await repo.ensureDefaults(userId);
      final music = (await repo.watchActive(userId).first).first;
      await repo.delete(music.id);
      await repo.ensureDefaults(userId);
      final names = (await repo.watchActive(userId).first).map((h) => h.name);
      expect(names, isNot(contains('Music')));
      expect(names.length, 5);
    });

    test('add custom, edit goal and reminder, archive, unarchive', () async {
      final id = await repo.addCustom(userId: userId, name: 'Knitting');
      var h = (await repo.byId(id))!;
      expect(h.isBuiltin, isFalse);
      expect(h.iconKey, 'hobby');
      await repo.update(
        id,
        const HobbiesCompanion(
          goalPeriod: Value(HobbyGoalPeriod.daily),
          goalValue: Value(20),
          reminderEnabled: Value(true),
          reminderConfig: Value('{"frequency":"daily","minutes":1200}'),
        ),
      );
      h = (await repo.byId(id))!;
      expect(h.goalPeriod, HobbyGoalPeriod.daily);
      expect(h.goalValue, 20);
      expect(h.reminderEnabled, isTrue);

      await repo.archive(id);
      expect(await repo.watchActive(userId).first, isEmpty);
      expect((await repo.watchArchived(userId).first).single.id, id);
      await repo.unarchive(id);
      expect((await repo.watchActive(userId).first).single.id, id);

      await repo.delete(id);
      expect(await repo.byId(id), isNull);
      expect(await repo.watchActive(userId).first, isEmpty);
    });

    test('add, edit and delete logs; local date uses the offset', () async {
      final id = await repo.addCustom(userId: userId, name: 'Chess');
      // 23:30 UTC is 01:30 next day at +2.
      final logId = await repo.addLog(
        userId: userId,
        hobbyId: id,
        dayCutoffMinutes: 0,
        source: HobbyLogSource.manual,
        startedAt: DateTime.utc(2026, 5, 13, 23, 30),
        durationMinutes: 25,
        note: 'blitz',
      );
      expect((await repo.logsForDate(userId, '2026-05-14')).single.id, logId);
      expect(await repo.logsForDate(userId, '2026-05-13'), isEmpty);

      await repo.updateLog(
        id: logId,
        dayCutoffMinutes: 0,
        startedAt: DateTime.utc(2026, 5, 13, 12),
        durationMinutes: 40,
        countOrSessions: 2,
      );
      final l = (await repo.logsForDate(userId, '2026-05-13')).single;
      expect(l.durationMinutes, 40);
      expect(l.countOrSessions, 2);
      expect(l.note, 'blitz');

      await repo.deleteLog(logId);
      expect(await repo.logsForDate(userId, '2026-05-13'), isEmpty);
    });

    test('timer log derives duration from start and end', () async {
      final id = await repo.addCustom(userId: userId, name: 'Piano');
      await repo.addLog(
        userId: userId,
        hobbyId: id,
        dayCutoffMinutes: 0,
        source: HobbyLogSource.timer,
        startedAt: DateTime.utc(2026, 5, 13, 8),
        endedAt: DateTime.utc(2026, 5, 13, 8, 37),
      );
      final l = (await repo.logsForDate(userId, '2026-05-13')).single;
      expect(l.durationMinutes, 37);
      expect(l.source, HobbyLogSource.timer);
      expect(l.endedAt!.toUtc(), DateTime.utc(2026, 5, 13, 8, 37));
    });

    test('minutes and sessions in a date range, per hobby or all', () async {
      final a = await repo.addCustom(userId: userId, name: 'A');
      final b = await repo.addCustom(userId: userId, name: 'B');
      Future<void> log(String h, int day, int min, [int n = 1]) => repo.addLog(
        userId: userId,
        hobbyId: h,
        dayCutoffMinutes: 0,
        source: HobbyLogSource.manual,
        startedAt: DateTime.utc(2026, 5, day, 12),
        durationMinutes: min,
        countOrSessions: n,
      );
      await log(a, 11, 30);
      await log(a, 12, 20, 2);
      await log(b, 12, 10);
      await log(a, 20, 99); // outside the range
      expect(await repo.minutesBetween(userId, '2026-05-11', '2026-05-17'), 60);
      expect(await repo.sessionsBetween(userId, '2026-05-11', '2026-05-17'), 4);
      expect(
        await repo.minutesBetween(
          userId,
          '2026-05-11',
          '2026-05-17',
          hobbyId: a,
        ),
        50,
      );
      expect(
        await repo.sessionsBetween(
          userId,
          '2026-05-12',
          '2026-05-12',
          hobbyId: b,
        ),
        1,
      );
      final t = await repo.totalsBetween(userId, '2026-05-01', '2026-05-31');
      expect(t.minutes, 159);
      expect(
        (await repo.logsBetween(userId, '2026-05-11', '2026-05-12')).length,
        3,
      );
      expect((await repo.watchAllLogs(userId).first).length, 4);
    });
  });

  group('BodyMeasurementRepository', () {
    late BodyMeasurementRepository repo;
    setUp(() => repo = BodyMeasurementRepository(db, clock));

    test('BMI is weight / height squared, null without inputs', () {
      expect(calculateBmi(70, 175), closeTo(22.857, 0.001));
      expect(calculateBmi(null, 175), isNull);
      expect(calculateBmi(70, null), isNull);
      expect(calculateBmi(70, 0), isNull);
    });

    test('add computes BMI and allows partial records', () async {
      final full = await repo.add(
        userId: userId,
        dayCutoffMinutes: 0,
        weightKg: 80,
        heightCm: 180,
        waistIn: 33,
      );
      final partial = await repo.add(
        userId: userId,
        dayCutoffMinutes: 0,
        measuredAt: DateTime.utc(2026, 5, 20, 8),
        chestIn: 38,
      );
      final f = (await repo.byId(full))!;
      expect(f.bmi, closeTo(24.69, 0.01));
      expect(f.localDate, '2026-05-13');
      expect(f.tzOffsetMinutes, 120);
      final p = (await repo.byId(partial))!;
      expect(p.chestIn, 38);
      expect(p.weightKg, isNull);
      expect(p.bmi, isNull);
      expect(p.localDate, '2026-05-20');
    });

    test('an explicit BMI is kept', () async {
      final id = await repo.add(
        userId: userId,
        dayCutoffMinutes: 0,
        weightKg: 80,
        heightCm: 180,
        bmi: 25,
      );
      expect((await repo.byId(id))!.bmi, 25);
    });

    test('update recalculates BMI and re-derives the date', () async {
      final id = await repo.add(
        userId: userId,
        dayCutoffMinutes: 0,
        weightKg: 80,
        heightCm: 180,
      );
      await repo.update(
        id,
        const BodyMeasurementsCompanion(weightKg: Value(90), notes: Value('x')),
      );
      var m = (await repo.byId(id))!;
      expect(m.weightKg, 90);
      expect(m.bmi, closeTo(27.78, 0.01));
      expect(m.notes, 'x');
      await repo.update(
        id,
        BodyMeasurementsCompanion(
          measuredAt: Value(DateTime.utc(2026, 6, 1, 23)),
        ),
      );
      m = (await repo.byId(id))!;
      expect(m.localDate, '2026-06-02'); // 23:00 UTC is 01:00 at +2
    });

    test('delete hides a record from every query', () async {
      final id = await repo.add(
        userId: userId,
        dayCutoffMinutes: 0,
        weightKg: 70,
      );
      await repo.delete(id);
      expect(await repo.byId(id), isNull);
      expect(await repo.latest(userId), isNull);
      expect(await repo.allRecords(userId), isEmpty);
      expect(await repo.series(userId, MeasurementField.weightKg), isEmpty);
    });

    test('latest, latestWith, series and watchers', () async {
      await repo.add(
        userId: userId,
        dayCutoffMinutes: 0,
        measuredAt: DateTime.utc(2026, 4, 1, 8),
        weightKg: 72,
        waistIn: 32,
      );
      await repo.add(
        userId: userId,
        dayCutoffMinutes: 0,
        measuredAt: DateTime.utc(2026, 5, 1, 8),
        weightKg: 71,
      );
      await repo.add(
        userId: userId,
        dayCutoffMinutes: 0,
        measuredAt: DateTime.utc(2026, 5, 10, 8),
        hipsIn: 40,
      );
      final latest = (await repo.latest(userId))!;
      expect(latest.hipsIn, 40);
      expect(
        (await repo.latestWith(userId, MeasurementField.weightKg))!.weightKg,
        71,
      );
      expect(
        (await repo.latestWith(userId, MeasurementField.waistIn))!.waistIn,
        32,
      );
      expect(await repo.latestWith(userId, MeasurementField.armIn), isNull);

      final weights = await repo.series(userId, MeasurementField.weightKg);
      expect(weights.map((p) => p.value), [72, 71]);
      expect(weights.first.localDate, '2026-04-01');
      expect(
        weights.first.measuredAt.isBefore(weights.last.measuredAt),
        isTrue,
      );
      expect(
        (await repo.watchSeries(userId, MeasurementField.hipsIn).first).length,
        1,
      );
      final all = await repo.watchAll(userId).first;
      expect(all.length, 3);
      expect(all.first.hipsIn, 40); // newest first
    });
  });

  group('HabitRepository skips', () {
    late HabitRepository repo;
    late Habit water;
    setUp(() async {
      repo = HabitRepository(db, clock);
      final id = await repo.create(
        userId: userId,
        name: 'Water',
        kind: HabitKind.water,
        dailyTarget: 3,
      );
      water = (await repo.byId(id))!;
    });

    test('a skip is recorded apart from logs and never counts', () async {
      await repo.log(habit: water, dayCutoffMinutes: 0);
      await repo.recordSkip(habit: water, dayCutoffMinutes: 0);
      await repo.recordSkip(habit: water, dayCutoffMinutes: 0);
      expect(await repo.watchCount(water.id, '2026-05-13').first, 1);
      expect((await repo.watchCountsForDate(userId, '2026-05-13').first), {
        water.id: 1,
      });
      expect((await db.select(db.habitLogs).get()).length, 1);
      final skips = await repo.skipsForDate(userId, '2026-05-13');
      expect(skips.length, 2);
      expect(skips.first.tzOffsetMinutes, 120);
      expect((await repo.watchSkipCountsForDate(userId, '2026-05-13').first), {
        water.id: 2,
      });
    });

    test('skips are per date and per habit, and can be removed', () async {
      final otherId = await repo.create(
        userId: userId,
        name: 'Stretch',
        kind: HabitKind.stretch,
      );
      final other = (await repo.byId(otherId))!;
      final s1 = await repo.recordSkip(habit: water, dayCutoffMinutes: 0);
      await repo.recordSkip(habit: other, dayCutoffMinutes: 0);
      await repo.recordSkip(
        habit: water,
        dayCutoffMinutes: 0,
        at: DateTime.utc(2026, 5, 14, 9),
      );
      expect(
        (await repo.skipsForDate(
          userId,
          '2026-05-13',
          habitId: water.id,
        )).length,
        1,
      );
      expect((await repo.skipsForDate(userId, '2026-05-13')).length, 2);
      expect((await repo.skipsForDate(userId, '2026-05-14')).length, 1);
      await repo.deleteSkip(s1);
      expect(
        await repo.skipsForDate(userId, '2026-05-13', habitId: water.id),
        isEmpty,
      );
    });

    test('moisturize and skin care kinds are stored and read back', () async {
      final m = await repo.create(
        userId: userId,
        name: 'Moisturize',
        kind: HabitKind.moisturize,
      );
      final s = await repo.create(
        userId: userId,
        name: 'Skin care',
        kind: HabitKind.skinCare,
      );
      expect((await repo.byId(m))!.kind, HabitKind.moisturize);
      expect((await repo.byId(s))!.kind, HabitKind.skinCare);
    });
  });

  group('workout metrics and screen-time source', () {
    test('workout metrics default to none and can be saved', () async {
      final repo = WorkoutRepository(db, clock);
      final id = await repo.add(
        userId: userId,
        dayCutoffMinutes: 0,
        workoutTypeId: 'builtin-walk',
        startedAt: DateTime.utc(2026, 5, 13, 8),
        endedAt: DateTime.utc(2026, 5, 13, 8, 30),
        source: WorkoutSource.timer,
      );
      var w = (await repo.allLive(userId)).single;
      expect(w.caloriesEstimate, isNull);
      expect(w.steps, isNull);
      expect(w.pausedSeconds, 0);
      await repo.setMetrics(
        id,
        const WorkoutMetrics(
          caloriesEstimate: 120,
          steps: 3000,
          stepsSource: 'estimate',
          distanceKm: 2.2,
          avgSpeedKmh: 4.4,
          pausedSeconds: 60,
          activeSeconds: 1740,
          metricsNote: 'estimated',
        ),
      );
      w = (await repo.allLive(userId)).single;
      expect(w.caloriesEstimate, 120);
      expect(w.stepsSource, 'estimate');
      expect(w.distanceKm, 2.2);
      expect(w.activeSeconds, 1740);
      expect(w.metricsNote, 'estimated');
    });

    test(
      'screen time defaults to automatic; manual and target stick',
      () async {
        final repo = ScreenTimeRepository(db, clock);
        await repo.upsertDay(
          userId: userId,
          localDate: '2026-05-13',
          totalMinutes: 100,
        );
        var s = (await db.select(db.screenTimeDaily).get()).single;
        expect(s.source, ScreenTimeSource.automatic);
        expect(s.targetMinutes, isNull);
        await repo.upsertDay(
          userId: userId,
          localDate: '2026-05-13',
          totalMinutes: 130,
          source: ScreenTimeSource.manual,
          targetMinutes: 120,
        );
        // A later automatic refresh keeps the recorded target.
        await repo.upsertDay(
          userId: userId,
          localDate: '2026-05-13',
          totalMinutes: 140,
        );
        s = (await db.select(db.screenTimeDaily).get()).single;
        expect(s.totalMinutes, 140);
        expect(s.targetMinutes, 120);
        expect(s.source, ScreenTimeSource.automatic);
      },
    );
  });
}
