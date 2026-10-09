import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/repositories/screen_time_repository.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/features/screen_time/screen_time_logic.dart';
import 'package:wellbeing/features/screen_time/screen_time_sync.dart';
import 'package:wellbeing/features/screen_time/usage_source.dart';

ScreenTimeDailyData row(String date, int total, [String cats = '{}']) {
  final t = DateTime.utc(2026, 5, 13);
  return ScreenTimeDailyData(
    id: date,
    createdAt: t,
    updatedAt: t,
    deletedAt: null,
    userId: 'u',
    localDate: date,
    totalMinutes: total,
    categoryMinutes: cats,
    lateEveningMinutes: 0,
    shareInGroups: false,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DayUsage', () {
    test('late evening is use from 21:00 on', () {
      final hours = List<int>.filled(24, 0);
      hours[20] = 30; // not counted
      hours[21] = 10;
      hours[22] = 20;
      hours[23] = 5;
      expect(DayUsage(totalMinutes: 65, hours: hours).lateEveningMinutes, 35);
    });

    test('missing hour data means no late evening', () {
      expect(const DayUsage(totalMinutes: 60).lateEveningMinutes, 0);
    });

    test('parses the native map', () {
      final u = DayUsage.fromMap({
        'totalMinutes': 252,
        'categories': {'social': 92, 'video': 70},
        'hours': List<int>.filled(24, 1),
      });
      expect(u.totalMinutes, 252);
      expect(u.categories['social'], 92);
      expect(u.hours.length, 24);
    });

    test('tolerates an empty map', () {
      expect(DayUsage.fromMap(const {}).totalMinutes, 0);
    });
  });

  group('formatting and grouping', () {
    test('duration', () {
      expect(formatScreenTime(252), '4 h 12 min');
      expect(formatScreenTime(180), '3 h');
      expect(formatScreenTime(45), '45 min');
      expect(formatScreenTime(0), '0 min');
    });

    test('categories are sorted largest first, empty ones dropped', () {
      final r = row(
        '2026-05-13',
        200,
        '{"video":30,"social":90,"other":0,"browser":50}',
      );
      expect(categoriesOf(r).map((e) => e.key), ['social', 'browser', 'video']);
    });

    test('bad category JSON gives none', () {
      expect(categoriesOf(row('2026-05-13', 10, 'oops')), isEmpty);
    });

    test('percentages', () {
      expect(percentOf(92, 252), 37);
      expect(percentOf(5, 0), 0);
    });

    test('week summary averages only days with data', () {
      final s = summarizeScreenTime([
        row('2026-05-11', 240),
        row('2026-05-12', 0),
        row('2026-05-13', 120),
      ]);
      expect(s.totalMinutes, 360);
      expect(s.daysWithData, 2);
      expect(s.averageMinutes, 180);
      expect(summarizeScreenTime([]).averageMinutes, 0);
    });

    test('copy has no exclamation marks and no judgement words', () {
      for (final k in categoryOrder) {
        expect(categoryLabel(k).contains('!'), isFalse);
      }
      expect(goalLabel(300), 'Goal 5 h');
    });
  });

  group('Android channel', () {
    const channel = MethodChannel('wellbeing/usage');

    tearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    void mock(Future<Object?>? Function(MethodCall) handler) =>
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, handler);

    test('hasAccess and openSettings go through the channel', () async {
      final calls = <String>[];
      mock((c) async {
        calls.add(c.method);
        return c.method == 'hasAccess' ? true : null;
      });
      final source = AndroidUsageSource();
      expect(await source.hasAccess(), isTrue);
      await source.openSettings();
      expect(calls, ['hasAccess', 'openSettings']);
    });

    test('readDay sends the window and parses the result', () async {
      Map<Object?, Object?>? args;
      mock((c) async {
        args = c.arguments as Map<Object?, Object?>;
        return {
          'totalMinutes': 90,
          'categories': {'social': 60, 'other': 30},
          'hours': List<int>.filled(24, 0),
        };
      });
      final start = DateTime.utc(2026, 5, 13);
      final u = await AndroidUsageSource().readDay(
        start,
        start.add(const Duration(hours: 10)),
      );
      expect(args!['start'], start.millisecondsSinceEpoch);
      expect(
        args!['end'],
        start.add(const Duration(hours: 10)).millisecondsSinceEpoch,
      );
      expect(u.totalMinutes, 90);
    });

    test('a platform error means no access rather than a crash', () async {
      mock((c) async => throw PlatformException(code: 'x'));
      expect(await AndroidUsageSource().hasAccess(), isFalse);
    });

    test('a missing plugin means no access', () async {
      expect(await AndroidUsageSource().hasAccess(), isFalse);
    });
  });

  group('sync', () {
    late AppDatabase db;
    late FakeUsageSource source;
    // Wed 13 May 2026, 10:00 UTC.
    final clock = FixedClock(DateTime.utc(2026, 5, 13, 10));

    ScreenTimeSync make() {
      final repo = ScreenTimeRepository(db, clock);
      return ScreenTimeSync(
        source: source,
        clock: clock,
        users: UserRepository(db, clock),
        repo: repo,
        existingDates: repo.datesBetween,
      );
    }

    Future<List<ScreenTimeDailyData>> stored() =>
        db.select(db.screenTimeDaily).get();

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      source = FakeUsageSource(
        byDate: {
          '2026-05-13': const DayUsage(
            totalMinutes: 100,
            categories: {'social': 60, 'other': 40},
          ),
          '2026-05-12': const DayUsage(totalMinutes: 200),
        },
      );
    });

    tearDown(() => db.close());

    test('without access nothing is read or stored', () async {
      source.access = false;
      expect(await make().sync(), SyncOutcome.noAccess);
      expect(source.reads, isEmpty);
      expect(await stored(), isEmpty);
    });

    test('first sync reads the last 7 days and stores totals', () async {
      expect(await make().sync(), SyncOutcome.done);
      expect(source.reads.length, 7);
      final rows = await stored();
      expect(rows.length, 7);
      final today = rows.firstWhere((r) => r.localDate == '2026-05-13');
      expect(today.totalMinutes, 100);
      expect(categoriesOf(today).first.key, 'social');
      expect(today.shareInGroups, isFalse); // never shared by default
    });

    test('later syncs re-read only today', () async {
      await make().sync();
      source.reads.clear();
      source.byDate['2026-05-13'] = const DayUsage(totalMinutes: 130);
      await make().sync();

      expect(source.reads, ['2026-05-13']);
      final rows = await stored();
      expect(rows.length, 7); // no duplicates
      expect(
        rows.firstWhere((r) => r.localDate == '2026-05-13').totalMinutes,
        130,
      );
      expect(
        rows.firstWhere((r) => r.localDate == '2026-05-12').totalMinutes,
        200,
      );
    });

    test('a missing earlier day is filled in', () async {
      await make().sync();
      await (db.delete(
        db.screenTimeDaily,
      )..where((r) => r.localDate.equals('2026-05-10'))).go();
      source.reads.clear();
      await make().sync();
      expect(source.reads.toSet(), {'2026-05-13', '2026-05-10'});
    });

    test('today is read only up to now', () async {
      final seen = <DateTime>[];
      final spy = _SpySource(seen);
      final repo = ScreenTimeRepository(db, clock);
      await ScreenTimeSync(
        source: spy,
        clock: clock,
        users: UserRepository(db, clock),
        repo: repo,
        existingDates: repo.datesBetween,
      ).sync();
      final todayEnd = seen.last;
      expect(todayEnd, DateTime.utc(2026, 5, 13, 10).toLocal());
    });

    test('a failing read reports failure without throwing', () async {
      final repo = ScreenTimeRepository(db, clock);
      final out = await ScreenTimeSync(
        source: _ThrowingSource(),
        clock: clock,
        users: UserRepository(db, clock),
        repo: repo,
        existingDates: repo.datesBetween,
      ).sync();
      expect(out, SyncOutcome.failed);
    });
  });
}

class _SpySource extends FakeUsageSource {
  _SpySource(this.ends);
  final List<DateTime> ends;

  @override
  Future<DayUsage> readDay(DateTime start, DateTime end) {
    ends.add(end);
    return super.readDay(start, end);
  }
}

class _ThrowingSource extends FakeUsageSource {
  @override
  Future<DayUsage> readDay(DateTime start, DateTime end) =>
      throw PlatformException(code: 'usage_error');
}
