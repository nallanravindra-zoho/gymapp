import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/data/repositories/meditation_repository.dart';
import 'package:wellbeing/data/sync/remote_store.dart';

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

  test('a session is saved with the local date and its true length', () async {
    final repo = MeditationRepository(a.db, FixedClock(t(0)));
    await repo.add(
      userId: a.user.id,
      dayCutoffMinutes: 0,
      startedAt: DateTime.utc(2026, 5, 13, 9),
      plannedMinutes: 10,
      durationSeconds: 140,
      completed: false,
    );
    final rows = await repo
        .watchBetween(a.user.id, '2026-05-13', '2026-05-13')
        .first;
    expect(rows.single.plannedMinutes, 10);
    expect(rows.single.durationSeconds, 140);
    expect(rows.single.completed, isFalse);
    expect(rows.single.localDate, '2026-05-13');
  });

  test('a deleted session leaves the list', () async {
    final repo = MeditationRepository(a.db, FixedClock(t(0)));
    final id = await repo.add(
      userId: a.user.id,
      dayCutoffMinutes: 0,
      startedAt: t(0),
      plannedMinutes: 5,
      durationSeconds: 300,
      completed: true,
    );
    await repo.delete(id);
    expect(
      await repo.watchBetween(a.user.id, '2026-05-01', '2026-05-31').first,
      isEmpty,
    );
  });

  test('sessions round-trip between devices and deletes sync', () async {
    final repo = MeditationRepository(a.db, FixedClock(t(0)));
    final id = await repo.add(
      userId: a.user.id,
      dayCutoffMinutes: 0,
      startedAt: t(0),
      plannedMinutes: 15,
      durationSeconds: 900,
      completed: true,
    );
    await a.sync();
    final row = remote.rows('meditation_sessions').single;
    expect(row['user_id'], authUid);
    expect(row['planned_minutes'], 15);
    expect(row['completed'], isTrue);

    await b.sync();
    final seen = await MeditationRepository(
      b.db,
      FixedClock(t(0)),
    ).watchBetween(b.user.id, '2026-05-01', '2026-05-31').first;
    expect(seen.single.id, id);
    expect(seen.single.userId, b.user.id);
    expect(seen.single.durationSeconds, 900);

    await MeditationRepository(a.db, FixedClock(t(5))).delete(id);
    await a.sync();
    await b.sync();
    expect(
      await MeditationRepository(
        b.db,
        FixedClock(t(5)),
      ).watchBetween(b.user.id, '2026-05-01', '2026-05-31').first,
      isEmpty,
    );
  });

  test('the server shows an account only its own sessions', () async {
    var who = 'account-a';
    final server = FakeRemoteStore(accountId: () => who);
    await server.upsert('meditation_sessions', 'id', [
      {
        'id': 'm-1',
        'user_id': 'account-a',
        'updated_at': t(0).toIso8601String(),
      },
    ]);
    who = 'account-b';
    expect((await server.fetchChanges('meditation_sessions', 0)).rows, isEmpty);
  });
}
