import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/providers.dart';
import 'package:wellbeing/data/repositories/habit_repository.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/data/repositories/workout_repository.dart';
import 'package:wellbeing/data/sync/remote_store.dart';
import 'package:wellbeing/data/sync/sync_state.dart';
import 'package:wellbeing/data/tables/tables.dart';
import 'package:wellbeing/features/account/auth_service.dart';
import 'package:wellbeing/features/account/sync_providers.dart';

final t0 = DateTime.utc(2026, 5, 13, 8);
DateTime t(int minutes) => t0.add(Duration(minutes: minutes));

const accountA = AccountUser(
  id: 'account-a',
  email: 'a@example.com',
  displayName: 'A',
);
const accountB = AccountUser(
  id: 'account-b',
  email: 'b@example.com',
  displayName: 'B',
);

class Rig {
  Rig({AccountUser? signedIn})
    : db = AppDatabase(NativeDatabase.memory()),
      auth = FakeAuthService(signedIn: signedIn),
      state = MemorySyncStateStore() {
    // Like the real server, show each account only its own rows.
    remote = FakeRemoteStore(accountId: () => auth.currentUser?.id);
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(FixedClock(t(0))),
        authServiceProvider.overrideWithValue(auth),
        remoteStoreProvider.overrideWithValue(remote),
        syncStateProvider.overrideWithValue(state),
      ],
    );
  }

  final AppDatabase db;
  final FakeAuthService auth;
  late final FakeRemoteStore remote;
  final MemorySyncStateStore state;
  late final ProviderContainer container;

  SyncController get controller =>
      container.read(syncControllerProvider.notifier);
  SyncStatus get status => container.read(syncControllerProvider);

  Future<User> get user => UserRepository(db, FixedClock(t(0))).ensureUser();

  Future<void> addWorkout(int minute, {String? note}) async {
    final u = await user;
    await WorkoutRepository(db, FixedClock(t(minute))).add(
      userId: u.id,
      dayCutoffMinutes: 0,
      workoutTypeId: 'builtin-yoga',
      startedAt: t(minute),
      endedAt: t(minute + 30),
      source: WorkoutSource.manual,
      note: note,
    );
  }

  Future<List<Workout>> workouts() async => (await db.select(db.workouts).get())
      .where((w) => w.deletedAt == null)
      .toList();

  Future<void> dispose() async {
    container.dispose();
    await db.close();
  }
}

void main() {
  late Rig rig;

  tearDown(() => rig.dispose());

  group('signed out', () {
    test('does nothing and contacts no server', () async {
      rig = Rig();
      await rig.addWorkout(0);
      await rig.controller.syncNow();

      expect(rig.remote.upsertCalls, 0);
      expect(rig.status.lastSyncedAt, isNull);
      expect(await rig.state.accountId(), isNull);
    });
  });

  group('signed in', () {
    test('sends local data and records success and the account', () async {
      rig = Rig(signedIn: accountA);
      await rig.addWorkout(0, note: 'before sign-in');
      await rig.controller.syncNow();

      expect(rig.status.syncing, isFalse);
      expect(rig.status.lastFailed, isFalse);
      expect(rig.status.lastSyncedAt, isNotNull);
      expect(rig.remote.rows('workouts').single['user_id'], 'account-a');
      expect(rig.remote.rows('workouts').single['note'], 'before sign-in');
      expect(await rig.state.accountId(), 'account-a');
    });

    test('brings the account\'s data onto a fresh phone', () async {
      // Another phone already uploaded.
      final first = Rig(signedIn: accountA);
      await first.addWorkout(0, note: 'from phone one');
      await first.controller.syncNow();

      rig = Rig(signedIn: accountA);
      // Share the same server.
      final shared = first.remote;
      final second = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(rig.db),
          clockProvider.overrideWithValue(FixedClock(t(0))),
          authServiceProvider.overrideWithValue(rig.auth),
          remoteStoreProvider.overrideWithValue(shared),
          syncStateProvider.overrideWithValue(rig.state),
        ],
      );
      await second.read(syncControllerProvider.notifier).syncNow();

      expect((await rig.workouts()).single.note, 'from phone one');
      second.dispose();
      await first.dispose();
    });

    test('a failed sync is reported and the next one recovers', () async {
      rig = Rig(signedIn: accountA);
      await rig.addWorkout(0);
      rig.remote.failWith = Exception('no network');
      await rig.controller.syncNow();

      expect(rig.status.lastFailed, isTrue);
      expect(rig.status.syncing, isFalse);
      expect(rig.status.lastSyncedAt, isNull);
      expect((await rig.workouts()).length, 1); // local data untouched

      rig.remote.failWith = null;
      await rig.controller.syncNow();
      expect(rig.status.lastFailed, isFalse);
      expect(rig.status.lastSyncedAt, isNotNull);
      expect(rig.remote.rows('workouts').length, 1);
    });

    test('a failure keeps the earlier last-synced time', () async {
      rig = Rig(signedIn: accountA);
      await rig.controller.syncNow();
      final when = rig.status.lastSyncedAt;
      expect(when, isNotNull);

      rig.remote.failWith = Exception('down');
      await rig.controller.syncNow();
      expect(rig.status.lastFailed, isTrue);
      expect(rig.status.lastSyncedAt, when);
    });

    test('overlapping requests run once', () async {
      rig = Rig(signedIn: accountA);
      await rig.addWorkout(0);
      await Future.wait([
        rig.controller.syncNow(),
        rig.controller.syncNow(),
        rig.controller.syncNow(),
      ]);
      // One pass over ten tables; a second overlapping pass would double it.
      final calls = rig.remote.upsertCalls;
      await rig.controller.syncNow();
      final secondPass = rig.remote.upsertCalls - calls;
      expect(calls, lessThanOrEqualTo(secondPass + 2));
      expect(rig.remote.rows('workouts').length, 1);
    });
  });

  group('a different account', () {
    Future<void> signInAsBWithOldData() async {
      rig = Rig(signedIn: accountA);
      await rig.addWorkout(0, note: 'belongs to A');
      await rig.controller.syncNow();
      expect(rig.remote.rows('workouts').length, 1);
      await rig.auth.signOut();
      rig.auth.signInAs = accountB;
      await rig.auth.signInWithGoogle();
    }

    test('is not merged: nothing moves until the person decides', () async {
      await signInAsBWithOldData();
      final before = rig.remote.rows('workouts').length;
      await rig.controller.syncNow();

      expect(rig.status.accountConflict, isTrue);
      expect(rig.remote.rows('workouts').length, before);
      expect(rig.remote.rows('workouts').single['user_id'], 'account-a');
      expect((await rig.workouts()).single.note, 'belongs to A'); // still here
    });

    test(
      'replacing erases this phone\'s data and starts from the account',
      () async {
        await signInAsBWithOldData();
        // Account B already has its own data on the server.
        await rig.remote.upsert('workouts', 'id', [
          {
            'id': '99999999-9999-4999-8999-999999999999',
            'user_id': 'account-b',
            'workout_type_id': 'builtin-run',
            'started_at': t(500).toIso8601String(),
            'ended_at': t(530).toIso8601String(),
            'duration_minutes': 30,
            'intensity': null,
            'note': 'belongs to B',
            'source': 'manual',
            'tz_offset_minutes': 0,
            'local_date': '2026-05-13',
            'created_at': t(530).toIso8601String(),
            'updated_at': t(530).toIso8601String(),
            'deleted_at': null,
          },
        ]);

        await rig.controller.syncNow();
        expect(rig.status.accountConflict, isTrue);
        await rig.controller.replaceLocalData();

        expect(rig.status.accountConflict, isFalse);
        expect(rig.status.lastFailed, isFalse);
        final mine = await rig.workouts();
        expect(mine.map((w) => w.note), ['belongs to B']);
        expect(await rig.state.accountId(), 'account-b');
        // A's data on the server is untouched.
        expect(
          rig.remote
              .rows('workouts')
              .where((r) => r['user_id'] == 'account-a')
              .length,
          1,
        );
        // Built-in workout types survive the wipe.
        expect(
          (await rig.db.select(rig.db.workoutTypes).get())
              .where((x) => x.isBuiltin)
              .length,
          12,
        );
      },
    );

    test('signing back in as the same account needs no decision', () async {
      rig = Rig(signedIn: accountA);
      await rig.controller.syncNow();
      await rig.auth.signOut();
      rig.auth.signInAs = accountA;
      await rig.auth.signInWithGoogle();
      await rig.controller.syncNow();
      expect(rig.status.accountConflict, isFalse);
      expect(rig.status.lastFailed, isFalse);
    });
  });

  group('wiping local data', () {
    test('clears records and resets the profile, keeping built-ins', () async {
      rig = Rig();
      final u = await rig.user;
      await rig.addWorkout(0);
      final habits = HabitRepository(rig.db, FixedClock(t(0)));
      await habits.create(
        userId: u.id,
        name: 'Water',
        kind: HabitKind.water,
        dailyTarget: 6,
      );
      await UserRepository(rig.db, FixedClock(t(30))).update(
        u.id,
        const UsersCompanion(
          displayName: Value('Old name'),
          weeklyRestDays: Value(4),
        ),
      );
      await WorkoutRepository(
        rig.db,
        FixedClock(t(0)),
      ).addCustomType(userId: u.id, name: 'Climbing');

      final auth = FakeAuthService(signedIn: accountA);
      final c = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(rig.db),
          clockProvider.overrideWithValue(FixedClock(t(0))),
          authServiceProvider.overrideWithValue(auth),
          remoteStoreProvider.overrideWithValue(FakeRemoteStore()),
          syncStateProvider.overrideWithValue(MemorySyncStateStore()),
        ],
      );
      await c.read(syncControllerProvider.notifier).replaceLocalData();
      c.dispose();

      expect(await rig.workouts(), isEmpty);
      expect(await rig.db.select(rig.db.habits).get(), isEmpty);
      final types = await rig.db.select(rig.db.workoutTypes).get();
      expect(types.every((x) => x.isBuiltin), isTrue);
      final after = await rig.user;
      expect(after.id, u.id); // same row, so the app's ids stay valid
      expect(after.displayName, '');
      expect(after.weeklyRestDays, 2);
      expect(after.updatedAt, after.createdAt); // untouched again
    });
  });
}
