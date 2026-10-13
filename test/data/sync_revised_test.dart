import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/data/repositories/body_measurement_repository.dart';
import 'package:wellbeing/data/repositories/habit_repository.dart';
import 'package:wellbeing/data/repositories/hobby_repository.dart';
import 'package:wellbeing/data/repositories/screen_time_repository.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/data/repositories/workout_repository.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/sync/remote_store.dart';
import 'package:wellbeing/data/tables/tables.dart';

import 'sync_engine_test.dart' show Device, authUid, t;

void main() {
  late FakeRemoteStore remote;
  late Device a;
  late Device b;

  setUp(() async {
    remote = FakeRemoteStore();
    a = await Device.create(remote);
    b = await Device.create(remote);
  });

  tearDown(() async {
    await a.db.close();
    await b.db.close();
  });

  test('hobbies and hobby logs round-trip between devices', () async {
    final repo = HobbyRepository(a.db, FixedClock(t(0)));
    final id = await repo.addCustom(
      userId: a.user.id,
      name: 'Pottery',
      iconKey: 'art',
      goalPeriod: HobbyGoalPeriod.weekly,
      goalValue: 3,
      goalUnit: HobbyGoalUnit.sessions,
      reminderEnabled: true,
      reminderConfig: '{"frequency":"weekly"}',
    );
    final logId = await repo.addLog(
      userId: a.user.id,
      hobbyId: id,
      dayCutoffMinutes: 0,
      source: HobbyLogSource.timer,
      startedAt: t(0),
      endedAt: t(45),
      note: 'wheel',
    );
    await a.sync();
    expect(remote.rows('hobbies').single['user_id'], authUid);
    expect(remote.rows('hobby_logs').single['duration_minutes'], 45);
    await b.sync();

    final h = await HobbyRepository(b.db, FixedClock(t(0))).byId(id);
    expect(h!.name, 'Pottery');
    expect(h.goalPeriod, HobbyGoalPeriod.weekly);
    expect(h.goalValue, 3);
    expect(h.goalUnit, HobbyGoalUnit.sessions);
    expect(h.reminderEnabled, isTrue);
    expect(h.reminderConfig, '{"frequency":"weekly"}');
    expect(h.userId, b.user.id);
    final logs = await HobbyRepository(
      b.db,
      FixedClock(t(0)),
    ).logsForDate(b.user.id, '2026-05-13');
    expect(logs.single.id, logId);
    expect(logs.single.source, HobbyLogSource.timer);
    expect(logs.single.durationMinutes, 45);
    expect(logs.single.note, 'wheel');
    expect(logs.single.endedAt!.toUtc(), t(45));
  });

  test('built-in hobbies seeded on two devices are not duplicated', () async {
    final ra = HobbyRepository(a.db, FixedClock(t(0)));
    final rb = HobbyRepository(b.db, FixedClock(t(1)));
    await ra.ensureDefaults(a.user.id);
    await rb.ensureDefaults(b.user.id);
    final musicA = (await a.db.select(a.db.hobbies).get()).firstWhere(
      (h) => h.name == 'Music',
    );
    final musicB = (await b.db.select(b.db.hobbies).get()).firstWhere(
      (h) => h.name == 'Music',
    );
    // A log on each device against its own Music row.
    await ra.addLog(
      userId: a.user.id,
      hobbyId: musicA.id,
      dayCutoffMinutes: 0,
      source: HobbyLogSource.manual,
      startedAt: t(10),
      durationMinutes: 20,
    );
    await rb.addLog(
      userId: b.user.id,
      hobbyId: musicB.id,
      dayCutoffMinutes: 0,
      source: HobbyLogSource.manual,
      startedAt: t(20),
      durationMinutes: 30,
    );

    for (var i = 0; i < 3; i++) {
      await a.sync();
      await b.sync();
    }

    for (final d in [a, b]) {
      final repo = HobbyRepository(d.db, FixedClock(t(0)));
      final live = await d.db.select(d.db.hobbies).get();
      final names = live
          .where((h) => h.deletedAt == null)
          .map((h) => h.name)
          .toList();
      expect(names.length, 6, reason: 'six built-ins, no duplicates');
      expect(names.toSet().length, 6);
      final music = live.firstWhere(
        (h) => h.name == 'Music' && h.deletedAt == null,
      );
      final totals = await repo.totalsBetween(
        d.user.id,
        '2026-05-13',
        '2026-05-13',
        hobbyId: music.id,
      );
      expect(totals.minutes, 50, reason: 'both logs belong to the kept row');
    }
  });

  test('body measurements round-trip, partial values stay null', () async {
    final repo = BodyMeasurementRepository(a.db, FixedClock(t(0)));
    final full = await repo.add(
      userId: a.user.id,
      dayCutoffMinutes: 0,
      weightKg: 70,
      heightCm: 175,
      waistIn: 31.5,
      hipsIn: 38,
      chestIn: 36,
      armIn: 12,
      thighIn: 22,
      notes: 'morning',
    );
    final partial = await repo.add(
      userId: a.user.id,
      dayCutoffMinutes: 0,
      measuredAt: t(1440),
      waistIn: 31,
    );
    await a.sync();
    expect(remote.rows('body_measurements').length, 2);
    await b.sync();
    final brepo = BodyMeasurementRepository(b.db, FixedClock(t(0)));
    final f = (await brepo.byId(full))!;
    expect(f.weightKg, 70);
    expect(f.heightCm, 175);
    expect(f.bmi, closeTo(22.86, 0.01));
    expect(f.waistIn, 31.5);
    expect(f.hipsIn, 38);
    expect(f.chestIn, 36);
    expect(f.armIn, 12);
    expect(f.thighIn, 22);
    expect(f.notes, 'morning');
    final p = (await brepo.byId(partial))!;
    expect(p.waistIn, 31);
    expect(p.weightKg, isNull);
    expect(p.bmi, isNull);
    expect(p.localDate, '2026-05-14');
  });

  test('a deleted measurement disappears on the other device', () async {
    final repo = BodyMeasurementRepository(a.db, FixedClock(t(0)));
    final id = await repo.add(
      userId: a.user.id,
      dayCutoffMinutes: 0,
      weightKg: 70,
    );
    await a.sync();
    await b.sync();
    await BodyMeasurementRepository(a.db, FixedClock(t(60))).delete(id);
    await a.sync();
    await b.sync();
    expect(
      await BodyMeasurementRepository(b.db, FixedClock(t(0))).latest(b.user.id),
      isNull,
    );
  });

  test('habit skips round-trip and never become completions', () async {
    final habits = HabitRepository(a.db, FixedClock(t(0)));
    final habitId = await habits.create(
      userId: a.user.id,
      name: 'Water',
      kind: HabitKind.water,
    );
    final habit = (await habits.byId(habitId))!;
    final skipId = await habits.recordSkip(habit: habit, dayCutoffMinutes: 0);
    await a.sync();
    expect(remote.rows('habit_skips').single['habit_id'], habitId);
    expect(remote.rows('habit_logs'), isEmpty);
    await b.sync();
    final skips = await HabitRepository(
      b.db,
      FixedClock(t(0)),
    ).skipsForDate(b.user.id, '2026-05-13');
    expect(skips.single.id, skipId);
    expect(await b.db.select(b.db.habitLogs).get(), isEmpty);
  });

  test('every new habit kind syncs', () async {
    final habits = HabitRepository(a.db, FixedClock(t(0)));
    await habits.create(
      userId: a.user.id,
      name: 'Moisturize',
      kind: HabitKind.moisturize,
    );
    await habits.create(
      userId: a.user.id,
      name: 'Skin care',
      kind: HabitKind.skinCare,
    );
    await a.sync();
    await b.sync();
    final kinds = (await b.db.select(b.db.habits).get()).map((h) => h.kind);
    expect(kinds, containsAll([HabitKind.moisturize, HabitKind.skinCare]));
  });

  test('profile fields round-trip', () async {
    await UserRepository(a.db, FixedClock(t(5))).update(
      a.user.id,
      const UsersCompanion(
        displayName: Value('Divya'),
        dateOfBirth: Value('1990-04-02'),
        gender: Value('female'),
        heightCm: Value(165.5),
        weightKg: Value(60.25),
        measurementCadence: Value('biweekly'),
        measurementReminderEnabled: Value(false),
        nextMeasurementDue: Value('2026-05-27'),
        reminderSound: Value('content://sound/1'),
        habitThreshold: Value(3),
      ),
    );
    await a.sync();
    expect(remote.rows('profiles').single['date_of_birth'], '1990-04-02');
    await b.sync();
    final u = (await b.db.select(b.db.users).get()).single;
    expect(u.dateOfBirth, '1990-04-02');
    expect(u.gender, 'female');
    expect(u.heightCm, 165.5);
    expect(u.weightKg, 60.25);
    expect(u.measurementCadence, 'biweekly');
    expect(u.measurementReminderEnabled, isFalse);
    expect(u.nextMeasurementDue, '2026-05-27');
    expect(u.reminderSound, 'content://sound/1');
    expect(u.habitThreshold, 3);
  });

  test('workout metrics round-trip', () async {
    final id = await WorkoutRepository(a.db, FixedClock(t(0))).add(
      userId: a.user.id,
      dayCutoffMinutes: 0,
      workoutTypeId: 'builtin-run',
      startedAt: t(0),
      endedAt: t(30),
      source: WorkoutSource.timer,
      metrics: const WorkoutMetrics(
        caloriesEstimate: 280,
        steps: 4200,
        stepsSource: 'sensor',
        distanceKm: 4.5,
        avgSpeedKmh: 9.5,
        pausedSeconds: 120,
        activeSeconds: 1680,
        metricsNote: 'estimated',
      ),
    );
    await a.sync();
    await b.sync();
    final w = (await b.workouts()).singleWhere((w) => w.id == id);
    expect(w.caloriesEstimate, 280);
    expect(w.steps, 4200);
    expect(w.stepsSource, 'sensor');
    expect(w.distanceKm, 4.5);
    expect(w.avgSpeedKmh, 9.5);
    expect(w.pausedSeconds, 120);
    expect(w.activeSeconds, 1680);
    expect(w.metricsNote, 'estimated');
  });

  test('screen time source and target round-trip', () async {
    await ScreenTimeRepository(a.db, FixedClock(t(0))).upsertDay(
      userId: a.user.id,
      localDate: '2026-05-13',
      totalMinutes: 200,
      source: ScreenTimeSource.manual,
      targetMinutes: 180,
    );
    await a.sync();
    expect(remote.rows('screen_time_daily').single['source'], 'manual');
    await b.sync();
    final s = (await b.db.select(b.db.screenTimeDaily).get()).single;
    expect(s.source, ScreenTimeSource.manual);
    expect(s.targetMinutes, 180);
    expect(s.shareInGroups, isFalse);
  });

  test('the server shows an account only its own new-table rows', () async {
    var who = 'account-a';
    final server = FakeRemoteStore(accountId: () => who);
    for (final table in [
      'hobbies',
      'hobby_logs',
      'body_measurements',
      'habit_skips',
    ]) {
      final row = {
        'id': '$table-1',
        'user_id': 'account-a',
        'updated_at': t(0).toIso8601String(),
      };
      who = 'account-a';
      await server.upsert(table, 'id', [row]);
      who = 'account-b';
      expect((await server.fetchChanges(table, 0)).rows, isEmpty);
      expect(
        () => server.upsert(table, 'id', [
          {...row, 'id': '$table-2'},
        ]),
        throwsA(isA<StateError>()),
      );
    }
  });
}
