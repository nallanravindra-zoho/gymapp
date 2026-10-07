import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wellbeing/data/sync/supabase_remote_store.dart';

const _key = 'sb_publishable_TestKeyForUnitTests';

String _b64(Object o) =>
    base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');

/// A well-formed (unsigned) token that expires far in the future.
final _jwt = [
  _b64({'alg': 'HS256', 'typ': 'JWT'}),
  _b64({
    'sub': 'account-1',
    'aud': 'authenticated',
    'role': 'authenticated',
    'exp': 4102444800,
  }),
  'signature',
].join('.');

final _sessionJson = jsonEncode({
  'access_token': _jwt,
  'refresh_token': 'refresh',
  'token_type': 'bearer',
  'expires_in': 3600,
  'expires_at': 4102444800,
  'user': {
    'id': 'account-1',
    'aud': 'authenticated',
    'app_metadata': <String, Object>{},
    'user_metadata': <String, Object>{},
    'created_at': '2026-05-13T08:00:00Z',
  },
});

/// A Supabase client whose network is replaced by [handler], so requests can
/// be inspected and responses scripted.
({SupabaseRemoteStore store, List<http.Request> seen}) make(
  http.Response Function(http.Request) handler,
) {
  final seen = <http.Request>[];
  final client = SupabaseClient(
    'https://example.supabase.co',
    _key,
    httpClient: MockClient((req) async {
      seen.add(req);
      final r = handler(req);
      // Real responses know their request; the library relies on that.
      return http.Response(
        r.body,
        r.statusCode,
        headers: r.headers,
        request: req,
      );
    }),
  );
  return (store: SupabaseRemoteStore(client), seen: seen);
}

http.Response json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);

void main() {
  group('upsert', () {
    test('posts rows to the table, merging on the key column', () async {
      final m = make((_) => json([]));
      await m.store.upsert('workouts', 'id', [
        {'id': 'a', 'note': 'one', 'updated_at': '2026-05-13T08:00:00.000Z'},
        {'id': 'b', 'note': null, 'updated_at': '2026-05-13T09:00:00.000Z'},
      ]);

      final r = m.seen.single;
      expect(r.method, 'POST');
      expect(r.url.path, '/rest/v1/workouts');
      expect(r.url.queryParameters['on_conflict'], 'id');
      expect(r.headers['Prefer'], contains('resolution=merge-duplicates'));
      final body = jsonDecode(r.body) as List;
      expect(body.length, 2);
      expect(body.first['id'], 'a');
      expect(body.last['note'], isNull);
    });

    test('uses the right key column for tables keyed by user', () async {
      final m = make((_) => json([]));
      await m.store.upsert('sleep_targets', 'user_id', [
        {
          'user_id': 'u',
          'bedtime_minutes': 1350,
          'updated_at': '2026-05-13T08:00:00.000Z',
        },
      ]);
      expect(m.seen.single.url.queryParameters['on_conflict'], 'user_id');
      expect(m.seen.single.url.path, '/rest/v1/sleep_targets');
    });

    test(
      'a signed-in request carries the user\'s own token, plus the key',
      () async {
        final seen = <http.Request>[];
        final client = SupabaseClient(
          'https://example.supabase.co',
          _key,
          httpClient: MockClient((req) async {
            seen.add(req);
            return http.Response(
              '[]',
              200,
              headers: {'content-type': 'application/json'},
              request: req,
            );
          }),
        );
        await client.auth.recoverSession(_sessionJson);
        expect(client.auth.currentUser?.id, 'account-1');

        await SupabaseRemoteStore(client).upsert('habits', 'id', [
          {'id': 'h', 'updated_at': '2026-05-13T08:00:00.000Z'},
        ]);

        final r = seen.single;
        expect(r.headers['Authorization'], 'Bearer $_jwt');
        expect(r.headers['apikey'], _key);
      },
    );

    test('the key itself is sent as the apikey header', () async {
      final m = make((_) => json([]));
      await m.store.upsert('habits', 'id', [
        {'id': 'h', 'updated_at': '2026-05-13T08:00:00.000Z'},
      ]);
      expect(m.seen.single.headers['apikey'], _key);
    });

    test('an empty list makes no request', () async {
      final m = make((_) => json([]));
      await m.store.upsert('workouts', 'id', []);
      expect(m.seen, isEmpty);
    });

    test('a server error is raised, so the sync reports failure', () async {
      final m = make((_) => json({'message': 'boom'}, 500));
      expect(
        m.store.upsert('workouts', 'id', [
          {'id': 'a', 'updated_at': '2026-05-13T08:00:00.000Z'},
        ]),
        throwsA(isA<PostgrestException>()),
      );
    });

    test('a row-level security refusal is raised', () async {
      final m = make(
        (_) => json({
          'code': '42501',
          'message': 'new row violates row-level security policy',
        }, 403),
      );
      expect(
        m.store.upsert('workouts', 'id', [
          {'id': 'a', 'updated_at': '2026-05-13T08:00:00.000Z'},
        ]),
        throwsA(isA<PostgrestException>()),
      );
    });
  });

  group('fetchChanges', () {
    test('asks for rows after the cursor, oldest change first', () async {
      final m = make((_) => json([]));
      await m.store.fetchChanges('workouts', 41, limit: 200);

      final r = m.seen.single;
      expect(r.method, 'GET');
      expect(r.url.path, '/rest/v1/workouts');
      expect(r.url.queryParameters['sync_seq'], 'gt.41');
      expect(r.url.queryParameters['order'], startsWith('sync_seq.asc'));
      expect(r.url.queryParameters['limit'], '200');
      expect(r.headers['apikey'], _key);
    });

    test('returns rows and moves the cursor to the last sync_seq', () async {
      final m = make(
        (_) => json([
          {'id': 'a', 'sync_seq': 42, 'note': 'x'},
          {'id': 'b', 'sync_seq': 47, 'note': null},
        ]),
      );
      final page = await m.store.fetchChanges('workouts', 41, limit: 500);
      expect(page.rows.length, 2);
      expect(page.rows.first['id'], 'a');
      expect(page.cursor, 47);
      expect(page.hasMore, isFalse);
    });

    test('a full page means there may be more', () async {
      final m = make(
        (_) => json([
          {'id': 'a', 'sync_seq': 1},
          {'id': 'b', 'sync_seq': 2},
        ]),
      );
      final page = await m.store.fetchChanges('workouts', 0, limit: 2);
      expect(page.hasMore, isTrue);
      expect(page.cursor, 2);
    });

    test('no rows keeps the cursor where it was', () async {
      final m = make((_) => json([]));
      final page = await m.store.fetchChanges('workouts', 99);
      expect(page.rows, isEmpty);
      expect(page.cursor, 99);
      expect(page.hasMore, isFalse);
    });

    test('a failure is raised', () async {
      final m = make((_) => json({'message': 'down'}, 503));
      expect(
        m.store.fetchChanges('workouts', 0),
        throwsA(isA<PostgrestException>()),
      );
    });

    test('server rows can be applied by the sync tables', () async {
      // The server's timestamp format (with an offset) must parse.
      final m = make(
        (_) => json([
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'user_id': 'u',
            'workout_type_id': 'builtin-yoga',
            'started_at': '2026-05-13T08:00:00+00:00',
            'ended_at': '2026-05-13T08:30:00+00:00',
            'duration_minutes': 30,
            'intensity': null,
            'note': null,
            'source': 'manual',
            'tz_offset_minutes': 0,
            'local_date': '2026-05-13',
            'created_at': '2026-05-13T08:31:00.123456+00:00',
            'updated_at': '2026-05-13T08:31:00.123456+00:00',
            'deleted_at': null,
            'sync_seq': 7,
          },
        ]),
      );
      final page = await m.store.fetchChanges('workouts', 0);
      final row = page.rows.single;
      expect(DateTime.parse(row['updated_at'] as String).isUtc, isTrue);
      expect(row['sync_seq'], 7);
    });
  });
}
