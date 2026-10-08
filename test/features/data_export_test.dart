import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/data/repositories/workout_repository.dart';
import 'package:wellbeing/data/tables/tables.dart';
import 'package:wellbeing/features/settings/data_export.dart';

final now = DateTime.utc(2026, 5, 13, 10);

void main() {
  group('CSV', () {
    test('plain values are left alone', () {
      expect(csvCell('Yoga'), 'Yoga');
      expect(csvCell(30), '30');
      expect(csvCell(null), '');
    });

    test('commas, quotes and line breaks are quoted', () {
      expect(csvCell('a,b'), '"a,b"');
      expect(csvCell('say "hi"'), '"say ""hi"""');
      expect(csvCell('two\nlines'), '"two\nlines"');
    });

    test('a note cannot run as a spreadsheet formula', () {
      expect(csvCell('=SUM(A1:A9)'), "'=SUM(A1:A9)");
      expect(csvCell('+1 later'), "'+1 later");
      expect(csvCell('@home'), "'@home");
      expect(csvCell('-rest'), "'-rest");
    });

    test('a real negative number is not changed', () {
      expect(csvCell(-5), '-5');
      expect(csvCell('-5'), '-5');
    });

    test('rows end with CRLF', () {
      expect(
        toCsv([
          ['a', 'b'],
          [1, 'x,y'],
        ]),
        'a,b\r\n1,"x,y"\r\n',
      );
    });
  });

  group('exports from the database', () {
    late AppDatabase db;
    late String userId;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      final clock = FixedClock(now);
      userId = (await UserRepository(db, clock).ensureUser()).id;
    });

    tearDown(() async => db.close());

    Future<String> addWorkout({
      String type = 'builtin-yoga',
      String? note,
      int minutes = 30,
      DateTime? at,
    }) async {
      final start = at ?? now;
      return WorkoutRepository(db, FixedClock(now)).add(
        userId: userId,
        dayCutoffMinutes: 0,
        workoutTypeId: type,
        startedAt: start,
        endedAt: start.add(Duration(minutes: minutes)),
        source: WorkoutSource.manual,
        note: note,
      );
    }

    test('the CSV lists workouts oldest first with type names', () async {
      await addWorkout(
        type: 'builtin-run',
        minutes: 20,
        at: now.add(const Duration(days: 1)),
      );
      await addWorkout(note: 'felt good, "easy"');
      final csv = (await buildWorkoutsCsv(db, now)).content.split('\r\n');
      expect(csv.first, 'date,type,started_at,ended_at,minutes,intensity,note');
      expect(csv[1], startsWith('2026-05-13,Yoga,2026-05-13T10:00:00.000Z'));
      expect(csv[1], endsWith(',30,,"felt good, ""easy"""'));
      expect(csv[2], startsWith('2026-05-14,Run,'));
      expect(csv[3], '');
    });

    test('deleted workouts are not exported', () async {
      final id = await addWorkout();
      await addWorkout(type: 'builtin-walk');
      await WorkoutRepository(db, FixedClock(now)).delete(id);
      final csv = (await buildWorkoutsCsv(db, now)).content;
      expect(csv, isNot(contains('Yoga')));
      expect(csv, contains('Walk'));
      final json = jsonDecode(
        (await buildJsonExport(db, now)).content,
      ) as Map<String, dynamic>;
      expect((json['workouts'] as List), hasLength(1));
    });

    test('the JSON holds the profile, entries and readable dates', () async {
      await UserRepository(
        db,
        FixedClock(now),
      ).update(userId, const UsersCompanion(displayName: const Value('Divya')));
      await addWorkout(note: 'morning');
      final export = await buildJsonExport(db, now);
      expect(export.fileName, 'wellbeing-data-2026-05-13.json');
      expect(export.mimeType, 'application/json');

      final json = jsonDecode(export.content) as Map<String, dynamic>;
      expect(json['app'], 'Well-Being Companion');
      expect(json['exportedAt'], '2026-05-13T10:00:00.000Z');
      expect((json['profile'] as Map)['displayName'], 'Divya');
      final w = (json['workouts'] as List).single as Map;
      expect(w['note'], 'morning');
      expect(w['durationMinutes'], 30);
      expect(w['startedAt'], '2026-05-13T10:00:00.000Z');
      for (final key in [
        'customWorkoutTypes',
        'habits',
        'habitLogs',
        'sleepTargets',
        'sleepLogs',
        'restDays',
        'badges',
        'screenTime',
      ]) {
        expect(json[key], isA<List>(), reason: key);
      }
    });

    test('built-in workout types are not exported as custom ones', () async {
      final json = jsonDecode(
        (await buildJsonExport(db, now)).content,
      ) as Map<String, dynamic>;
      expect(json['customWorkoutTypes'], isEmpty);
    });
  });
}
