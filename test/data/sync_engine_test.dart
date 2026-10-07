import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/repositories/badge_repository.dart';
import 'package:wellbeing/data/repositories/habit_repository.dart';
import 'package:wellbeing/data/repositories/rest_day_repository.dart';
import 'package:wellbeing/data/repositories/screen_time_repository.dart';
import 'package:wellbeing/data/repositories/sleep_repository.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/data/repositories/workout_repository.dart';
import 'package:wellbeing/data/sync/remote_store.dart';
import 'package:wellbeing/data/sync/sync_engine.dart';
import 'package:wellbeing/data/sync/sync_state.dart';
import 'package:wellbeing/data/sync/sync_tables.dart';
import 'package:wellbeing/data/tables/tables.dart';

const authUid = 'auth-user-1';

/// One phone: its own database, its own local user id, its own sync state.
class Device {
  Device._(this.db, this.user, this.engine);

  final AppDatabase db;
  final User user;
  final SyncEngine engine;

  static Future<Device> create(
    RemoteStore remote, {
    int chunkSize = 200,
    int pageSize = 500,
    int createdAtMinute = 0,
  }) async {
    final db = AppDatabase(NativeDatabase.memory());
    final user = await UserRepository(
      db,
      FixedClock(t(createdAtMinute)),
    ).ensureUser();
    final engine = SyncEngine(
      db: db,
      remote: remote,
      state: MemorySyncStateStore(),
      chunkSize: chunkSize,
      pageSize: pageSize,
    );
    return Device._(db, user, engine);
  }

  Future<SyncReport> sync() =>
      engine.run(remoteUserId: authUid, localUserId: user.id);

  Future<String> addWorkout(
    DateTime at, {
    String type = 'builtin-yoga',
    String? note,
    int minutes = 30,
  }) {
    return WorkoutRepository(db, FixedClock(at)).add(
      userId: user.id,
      dayCutoffMinutes: 0,
      workoutTypeId: type,
      startedAt: at,
      endedAt: at.add(Duration(minutes: minutes)),
      source: WorkoutSource.manual,
      note: note,
    );
  }

  Future<List<Workout>> workouts({bool includeDeleted = false}) async {
    final all = await db.select(db.workouts).get();
    return includeDeleted
        ? all
        : all.where((w) => w.deletedAt == null).toList();
  }
}

/// A fixed point in time, [minutes] after 2026-05-13 08:00 UTC.
DateTime t(int minutes) =>
    DateTime.utc(2026, 5, 13, 8).add(Duration(minutes: minutes));

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

  group('push', () {
    test('sends local rows under the account id, not the local id', () async {
      final id = await a.addWorkout(t(0), note: 'morning');
      final report = await a.sync();

      expect(report.ok, isTrue);
      final rows = remote.rows('workouts');
      expect(rows.length, 1);
      expect(rows.single['id'], id);
      expect(rows.single['user_id'], authUid);
      expect(rows.single['user_id'], isNot(a.user.id));
      expect(rows.single['note'], 'morning');
      expect(rows.single['source'], 'manual');
    });

    test('built-in workout types are not sent; custom ones are', () async {
      await WorkoutRepository(
        a.db,
        FixedClock(t(0)),
      ).addCustomType(userId: a.user.id, name: 'Climbing');
      await a.sync();
      final rows = remote.rows('workout_types');
      expect(rows.length, 1);
      expect(rows.single['name'], 'Climbing');
    });

    test('sends nothing when nothing changed, and never duplicates', () async {
      await a.addWorkout(t(0));
      await a.sync();
      final seqAfterFirst = remote.rows('workouts').single['sync_seq'];

      await a.sync();
      await a.sync();
      expect(remote.rows('workouts').length, 1);
      // The server ignored the re-sent boundary row: nothing moved.
      expect(remote.rows('workouts').single['sync_seq'], seqAfterFirst);
    });

    test('large pushes are sent in chunks', () async {
      final small = await Device.create(remote, chunkSize: 2);
      for (var i = 0; i < 5; i++) {
        await small.addWorkout(t(i * 60));
      }
      remote.upsertCalls = 0;
      await small.sync();
      final workoutCalls = remote.upsertCalls;
      expect(remote.rows('workouts').length, 5);
      expect(workoutCalls, greaterThanOrEqualTo(3));
      await small.db.close();
    });
  });

  group('two devices', () {
    test('a workout logged on A appears on B once', () async {
      final id = await a.addWorkout(t(0), note: 'from A');
      await a.sync();
      final report = await b.sync();

      expect(report.pulled, greaterThanOrEqualTo(1));
      final got = await b.workouts();
      expect(got.length, 1);
      expect(got.single.id, id);
      expect(got.single.note, 'from A');
      expect(got.single.userId, b.user.id); // mapped to B's local user

      await b.sync();
      await a.sync();
      expect((await b.workouts()).length, 1);
      expect((await a.workouts()).length, 1);
    });

    test('changes flow both ways', () async {
      await a.addWorkout(t(0), note: 'A');
      await b.addWorkout(t(10), note: 'B', type: 'builtin-run');
      await a.sync();
      await b.sync();
      await a.sync();

      expect((await a.workouts()).map((w) => w.note).toSet(), {'A', 'B'});
      expect((await b.workouts()).map((w) => w.note).toSet(), {'A', 'B'});
    });

    test('the newest edit wins on both devices', () async {
      final id = await a.addWorkout(t(0), note: 'original');
      await a.sync();
      await b.sync();

      // A edits at t=60, B edits the same workout later at t=120.
      await WorkoutRepository(
        a.db,
        FixedClock(t(60)),
      ).update(id: id, dayCutoffMinutes: 0, note: 'edit by A');
      await WorkoutRepository(
        b.db,
        FixedClock(t(120)),
      ).update(id: id, dayCutoffMinutes: 0, note: 'edit by B');

      await a.sync(); // pushes A's older edit
      await b.sync(); // pushes B's newer edit, pulls A's (ignored)
      await a.sync(); // pulls B's

      expect((await a.workouts()).single.note, 'edit by B');
      expect((await b.workouts()).single.note, 'edit by B');
      expect(remote.rows('workouts').single['note'], 'edit by B');
    });

    test('an older server row never overwrites a newer local edit', () async {
      final id = await b.addWorkout(t(0), note: 'original');
      await WorkoutRepository(
        b.db,
        FixedClock(t(200)),
      ).update(id: id, dayCutoffMinutes: 0, note: 'newest');

      // A server copy from earlier than B's edit arrives.
      final stale = {
        ...(await const WorkoutsSync().localChanges(
          b.db,
          null,
          authUid,
        )).single,
        'note': 'stale server copy',
        'updated_at': t(60).toIso8601String(),
      };
      final applied = await const WorkoutsSync().applyRemote(
        b.db,
        stale,
        b.user.id,
      );

      expect(applied, isFalse);
      expect((await b.workouts()).single.note, 'newest');
    });

    test('an equal timestamp is not re-applied', () async {
      await b.addWorkout(t(0), note: 'mine');
      final same = {
        ...(await const WorkoutsSync().localChanges(
          b.db,
          null,
          authUid,
        )).single,
        'note': 'different',
      };
      expect(
        await const WorkoutsSync().applyRemote(b.db, same, b.user.id),
        isFalse,
      );
      expect((await b.workouts()).single.note, 'mine');
    });

    test('a delete on one device removes it on the other', () async {
      final id = await a.addWorkout(t(0));
      await a.sync();
      await b.sync();
      expect((await b.workouts()).length, 1);

      await WorkoutRepository(a.db, FixedClock(t(30))).delete(id);
      await a.sync();
      await b.sync();

      expect(await b.workouts(), isEmpty);
      final raw = await b.workouts(includeDeleted: true);
      expect(raw.single.deletedAt, isNotNull); // soft delete, row kept
    });

    test('a device that was offline for a long time catches up', () async {
      for (var i = 0; i < 7; i++) {
        await a.addWorkout(t(i * 60));
        await a.sync();
      }
      await b.sync();
      expect((await b.workouts()).length, 7);
    });
  });

  group('offline', () {
    test('a failed sync keeps local data and reports the error', () async {
      await a.addWorkout(t(0));
      remote.failWith = Exception('no network');
      final report = await a.sync();

      expect(report.ok, isFalse);
      expect((await a.workouts()).length, 1);
      expect(remote.rows('workouts'), isEmpty);
    });

    test('the next sync sends everything that was missed, once', () async {
      await a.addWorkout(t(0));
      remote.failWith = Exception('no network');
      await a.sync();
      await a.addWorkout(t(60));

      remote.failWith = null;
      final report = await a.sync();
      expect(report.ok, isTrue);
      expect(remote.rows('workouts').length, 2);

      await a.sync();
      expect(remote.rows('workouts').length, 2);
    });

    test(
      'a sync that drops part-way resumes without loss or repeats',
      () async {
        // An edited profile is sent; an untouched default one is not.
        await UserRepository(
          a.db,
          FixedClock(t(5)),
        ).update(a.user.id, const UsersCompanion(displayName: Value('Divya')));
        await a.addWorkout(t(0));
        await a.addWorkout(t(60), type: 'builtin-run');
        // Profile and others succeed; the workouts table fails.
        remote
          ..failWith = Exception('connection dropped')
          ..failOnlyTable = 'workouts';
        final first = await a.sync();
        expect(first.ok, isFalse);
        expect(remote.rows('workouts'), isEmpty);
        expect(
          remote.rows('profiles').length,
          1,
        ); // earlier tables did go through

        // More work while still failing, then the connection returns.
        await a.addWorkout(t(120), type: 'builtin-walk');
        remote.failWith = null;
        final second = await a.sync();
        expect(second.ok, isTrue);
        expect(remote.rows('workouts').length, 3);

        await b.sync();
        expect((await b.workouts()).length, 3);
      },
    );

    test('a failed pull does not lose the server rows', () async {
      await a.addWorkout(t(0));
      await a.sync();

      remote.failWith = Exception('timeout');
      expect((await b.sync()).ok, isFalse);
      expect(await b.workouts(), isEmpty);

      remote.failWith = null;
      await b.sync();
      expect((await b.workouts()).length, 1);
    });

    test('pulling in small pages gets every row', () async {
      for (var i = 0; i < 7; i++) {
        await a.addWorkout(t(i * 60));
      }
      await a.sync();
      final small = await Device.create(remote, pageSize: 3);
      await small.sync();
      expect((await small.workouts()).length, 7);
      await small.db.close();
    });
  });

  group('other data', () {
    test('profile and streak settings follow the account', () async {
      await UserRepository(a.db, FixedClock(t(10))).update(
        a.user.id,
        const UsersCompanion(
          displayName: Value('Divya'),
          weeklyRestDays: Value(3),
          freezeEnabled: Value(false),
        ),
      );
      await a.sync();
      await b.sync();

      final u = await UserRepository(b.db, FixedClock(t(0))).ensureUser();
      expect(u.id, b.user.id);
      expect(u.displayName, 'Divya');
      expect(u.weeklyRestDays, 3);
      expect(u.freezeEnabled, isFalse);
    });

    test(
      'a brand-new phone gets the account profile, not blank defaults',
      () async {
        await UserRepository(a.db, FixedClock(t(10))).update(
          a.user.id,
          const UsersCompanion(
            displayName: Value('Divya'),
            weeklyRestDays: Value(3),
          ),
        );
        await a.sync();

        // Installed long after the profile was last edited, so its default
        // profile looks "newer" by timestamp.
        final fresh = await Device.create(remote, createdAtMinute: 5000);
        await fresh.sync();

        final u = await UserRepository(fresh.db, FixedClock(t(0))).ensureUser();
        expect(u.displayName, 'Divya');
        expect(u.weeklyRestDays, 3);

        // And it did not overwrite the account's profile on the way.
        final server = remote.rows('profiles').single;
        expect(server['display_name'], 'Divya');
        expect(server['weekly_rest_days'], 3);
        await fresh.db.close();
      },
    );

    test('an untouched profile is never sent', () async {
      await a.sync();
      expect(remote.rows('profiles'), isEmpty);
    });

    test('an edited profile still follows last write wins', () async {
      await UserRepository(
        a.db,
        FixedClock(t(10)),
      ).update(a.user.id, const UsersCompanion(displayName: Value('Old')));
      await a.sync();
      await b.sync();
      await UserRepository(
        b.db,
        FixedClock(t(60)),
      ).update(b.user.id, const UsersCompanion(displayName: Value('Newer')));
      await b.sync();
      await a.sync();
      expect(
        (await UserRepository(a.db, FixedClock(t(0))).ensureUser()).displayName,
        'Newer',
      );
    });

    test('sleep targets and logs sync', () async {
      final sa = SleepRepository(a.db, FixedClock(t(0)));
      await sa.setTarget(
        userId: a.user.id,
        bedtimeMinutes: 1350,
        wakeMinutes: 390,
      );
      await sa.log(
        userId: a.user.id,
        dayCutoffMinutes: 0,
        bedtimeAt: DateTime.utc(2026, 5, 12, 22, 30),
        wakeAt: DateTime.utc(2026, 5, 13, 6, 30),
      );
      await a.sync();
      await b.sync();

      final target = await b.db.select(b.db.sleepTargets).getSingle();
      expect(target.bedtimeMinutes, 1350);
      expect(target.userId, b.user.id);
      final logs = await b.db.select(b.db.sleepLogs).get();
      expect(logs.single.durationMinutes, 480);
    });

    test('the same night logged on two devices becomes one night', () async {
      final bedA = DateTime.utc(2026, 5, 12, 22, 30);
      final wake = DateTime.utc(2026, 5, 13, 6, 30);
      await SleepRepository(a.db, FixedClock(t(0))).log(
        userId: a.user.id,
        dayCutoffMinutes: 0,
        bedtimeAt: bedA,
        wakeAt: wake,
      );
      await SleepRepository(b.db, FixedClock(t(30))).log(
        userId: b.user.id,
        dayCutoffMinutes: 0,
        bedtimeAt: bedA.add(const Duration(minutes: 15)),
        wakeAt: wake,
      );

      await a.sync();
      await b.sync();
      await a.sync();

      for (final d in [a, b]) {
        final live = (await d.db.select(d.db.sleepLogs).get()).where(
          (l) => l.deletedAt == null,
        );
        expect(live.length, 1, reason: 'one live night per device');
        expect(live.single.durationMinutes, 465); // the later (B) entry
      }
    });

    test('habits and their logs sync', () async {
      final ha = HabitRepository(a.db, FixedClock(t(0)));
      final id = await ha.create(
        userId: a.user.id,
        name: 'Water',
        kind: HabitKind.water,
        dailyTarget: 6,
      );
      final habit = (await ha.byId(id))!;
      await ha.log(habit: habit, dayCutoffMinutes: 0, count: 2);
      await a.sync();
      await b.sync();

      final hb = HabitRepository(b.db, FixedClock(t(0)));
      expect((await hb.byId(id))!.dailyTarget, 6);
      final logs = await hb.logsBetween(id, '2026-05-13', '2026-05-13');
      expect(logs.single.count, 2);
    });

    test('rest days: one per date even if both devices marked it', () async {
      await RestDayRepository(
        a.db,
        FixedClock(t(0)),
      ).mark(userId: a.user.id, localDate: '2026-05-14', weeklyLimit: 2);
      await RestDayRepository(
        b.db,
        FixedClock(t(5)),
      ).mark(userId: b.user.id, localDate: '2026-05-14', weeklyLimit: 2);
      await a.sync();
      await b.sync();
      await a.sync();

      for (final d in [a, b]) {
        final live = (await d.db.select(d.db.restDays).get()).where(
          (r) => r.deletedAt == null,
        );
        expect(live.length, 1);
      }
    });

    test('the same badge earned on two devices is held once', () async {
      await BadgeRepository(
        a.db,
        FixedClock(t(0)),
      ).award(a.user.id, 'streak_overall_7');
      await BadgeRepository(
        b.db,
        FixedClock(t(5)),
      ).award(b.user.id, 'streak_overall_7');
      await a.sync();
      await b.sync();
      await a.sync();

      for (final d in [a, b]) {
        final keys = await BadgeRepository(
          d.db,
          FixedClock(t(0)),
        ).awardedKeys(d.user.id);
        expect(keys, {'streak_overall_7'});
        final live = (await d.db.select(d.db.badgesAwarded).get()).where(
          (x) => x.deletedAt == null,
        );
        expect(live.length, 1);
      }
    });

    test('screen time is one row per day and stays unshared', () async {
      await ScreenTimeRepository(a.db, FixedClock(t(0))).upsertDay(
        userId: a.user.id,
        localDate: '2026-05-13',
        totalMinutes: 100,
      );
      await ScreenTimeRepository(b.db, FixedClock(t(60))).upsertDay(
        userId: b.user.id,
        localDate: '2026-05-13',
        totalMinutes: 140,
      );
      await a.sync();
      await b.sync();
      await a.sync();

      for (final d in [a, b]) {
        final live = (await d.db.select(d.db.screenTimeDaily).get()).where(
          (x) => x.deletedAt == null,
        );
        expect(live.length, 1);
        expect(live.single.totalMinutes, 140);
        expect(live.single.shareInGroups, isFalse);
      }
      expect(
        remote
            .rows('screen_time_daily')
            .every((r) => r['share_in_groups'] == false),
        isTrue,
      );
    });
  });

  group('the server only shows an account its own rows', () {
    test('one account cannot read or write another\'s data', () async {
      var who = 'account-a';
      final server = FakeRemoteStore(accountId: () => who);
      final row = {
        'id': 'w1',
        'user_id': 'account-a',
        'updated_at': t(0).toIso8601String(),
      };
      await server.upsert('workouts', 'id', [row]);

      who = 'account-b';
      expect((await server.fetchChanges('workouts', 0)).rows, isEmpty);
      expect(
        () => server.upsert('workouts', 'id', [
          {...row, 'id': 'w2'},
        ]),
        throwsA(isA<StateError>()),
      );

      who = 'account-a';
      expect((await server.fetchChanges('workouts', 0)).rows.length, 1);
    });
  });

  test('cached streaks and insights never leave the device', () async {
    await a.addWorkout(t(0));
    await a.sync();
    for (final table in ['streak_states', 'weekly_insights', 'tips_library']) {
      expect(remote.rows(table), isEmpty);
    }
  });
}
