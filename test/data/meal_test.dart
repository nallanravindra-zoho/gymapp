import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/data/repositories/meal_repository.dart';
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

  test('a meal keeps its values and local date', () async {
    final repo = MealRepository(a.db, FixedClock(t(0), offsetMinutes: 120));
    await repo.add(
      userId: a.user.id,
      dayCutoffMinutes: 0,
      name: ' Dal, cooked ',
      servings: 1.5,
      calories: 270,
      proteinG: 18,
      carbsG: 45,
      fatG: 1.5,
      source: 'listed',
      // 23:30 UTC is 01:30 the next day at +2.
      loggedAt: DateTime.utc(2026, 5, 13, 23, 30),
    );
    final rows = await repo
        .watchBetween(a.user.id, '2026-05-14', '2026-05-14')
        .first;
    expect(rows.single.name, 'Dal, cooked');
    expect(rows.single.servings, 1.5);
    expect(rows.single.calories, 270);
    expect(rows.single.source, 'listed');
    expect(
      await repo.watchBetween(a.user.id, '2026-05-13', '2026-05-13').first,
      isEmpty,
    );
  });

  test('values are optional and a deleted meal leaves the list', () async {
    final repo = MealRepository(a.db, FixedClock(t(0)));
    final id = await repo.add(
      userId: a.user.id,
      dayCutoffMinutes: 0,
      name: 'Soup',
    );
    final row =
        (await repo.watchBetween(a.user.id, '2026-05-01', '2026-05-31').first)
            .single;
    expect(row.calories, isNull);
    expect(row.servings, 1);
    expect(row.source, 'entered');
    await repo.delete(id);
    expect(
      await repo.watchBetween(a.user.id, '2026-05-01', '2026-05-31').first,
      isEmpty,
    );
  });

  test('meals round-trip between devices and deletes sync', () async {
    final repo = MealRepository(a.db, FixedClock(t(0)));
    final id = await repo.add(
      userId: a.user.id,
      dayCutoffMinutes: 0,
      name: 'Idli',
      servings: 3,
      calories: 120,
      proteinG: 6,
      source: 'listed',
    );
    await a.sync();
    final row = remote.rows('meal_logs').single;
    expect(row['user_id'], authUid);
    expect(row['servings'], 3);
    expect(row['protein_g'], 6);
    expect(row['carbs_g'], isNull);

    await b.sync();
    final seen = await MealRepository(
      b.db,
      FixedClock(t(0)),
    ).watchBetween(b.user.id, '2026-05-01', '2026-05-31').first;
    expect(seen.single.id, id);
    expect(seen.single.userId, b.user.id);
    expect(seen.single.calories, 120);
    expect(seen.single.carbsG, isNull);

    await MealRepository(a.db, FixedClock(t(5))).delete(id);
    await a.sync();
    await b.sync();
    expect(
      await MealRepository(
        b.db,
        FixedClock(t(5)),
      ).watchBetween(b.user.id, '2026-05-01', '2026-05-31').first,
      isEmpty,
    );
  });

  test('the server shows an account only its own meals', () async {
    var who = 'account-a';
    final server = FakeRemoteStore(accountId: () => who);
    await server.upsert('meal_logs', 'id', [
      {
        'id': 'm-1',
        'user_id': 'account-a',
        'updated_at': t(0).toIso8601String(),
      },
    ]);
    who = 'account-b';
    expect((await server.fetchChanges('meal_logs', 0)).rows, isEmpty);
  });
}
