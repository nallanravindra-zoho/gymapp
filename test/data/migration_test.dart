import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/seed_tips.dart';
import 'package:wellbeing/data/tables/tables.dart';

/// The v1 shape of the tables the v2 upgrade touches, as installed phones
/// have them.
void _createV1(dynamic raw) {
  raw.execute('''
CREATE TABLE users (
  id TEXT NOT NULL PRIMARY KEY, created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL, deleted_at INTEGER,
  display_name TEXT NOT NULL DEFAULT '', avatar_url TEXT,
  timezone TEXT NOT NULL DEFAULT 'UTC',
  day_cutoff_minutes INTEGER NOT NULL DEFAULT 0,
  quiet_hours_start INTEGER, quiet_hours_end INTEGER,
  daily_reminder_cap INTEGER NOT NULL DEFAULT 6,
  weekly_rest_days INTEGER NOT NULL DEFAULT 2,
  freeze_enabled INTEGER NOT NULL DEFAULT 1 CHECK (freeze_enabled IN (0, 1)),
  freeze_interval_days INTEGER NOT NULL DEFAULT 7
);
CREATE TABLE workout_types (
  id TEXT NOT NULL PRIMARY KEY, created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL, deleted_at INTEGER,
  user_id TEXT, name TEXT NOT NULL, icon_key TEXT NOT NULL,
  is_builtin INTEGER NOT NULL DEFAULT 0 CHECK (is_builtin IN (0, 1))
);
CREATE TABLE workouts (
  id TEXT NOT NULL PRIMARY KEY, created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL, deleted_at INTEGER,
  user_id TEXT NOT NULL, workout_type_id TEXT NOT NULL,
  started_at INTEGER NOT NULL, ended_at INTEGER NOT NULL,
  duration_minutes INTEGER NOT NULL, intensity TEXT, note TEXT,
  source TEXT NOT NULL, tz_offset_minutes INTEGER NOT NULL DEFAULT 0,
  local_date TEXT NOT NULL
);
CREATE TABLE screen_time_daily (
  id TEXT NOT NULL PRIMARY KEY, created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL, deleted_at INTEGER,
  user_id TEXT NOT NULL, local_date TEXT NOT NULL,
  total_minutes INTEGER NOT NULL,
  category_minutes TEXT NOT NULL DEFAULT '{}',
  late_evening_minutes INTEGER NOT NULL DEFAULT 0,
  share_in_groups INTEGER NOT NULL DEFAULT 0 CHECK (share_in_groups IN (0, 1))
);
CREATE TABLE tips_library (
  id TEXT NOT NULL PRIMARY KEY, created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL, deleted_at INTEGER,
  trigger_key TEXT NOT NULL, body TEXT NOT NULL, source_label TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1))
);
INSERT INTO users (id, created_at, updated_at, display_name)
  VALUES ('u1', 1700000000, 1700000100, 'Asha');
INSERT INTO workouts (id, created_at, updated_at, user_id, workout_type_id,
  started_at, ended_at, duration_minutes, source, local_date)
  VALUES ('w1', 1700000000, 1700000000, 'u1', 'builtin-yoga', 1700000000,
  1700001800, 30, 'manual', '2023-11-14');
INSERT INTO screen_time_daily (id, created_at, updated_at, user_id,
  local_date, total_minutes) VALUES ('s1', 1700000000, 1700000000, 'u1',
  '2023-11-14', 90);
PRAGMA user_version = 1;
''');
}

void main() {
  test('a v1 database upgrades to v2 keeping its data', () async {
    final db = AppDatabase(NativeDatabase.memory(setup: _createV1));
    addTearDown(db.close);

    // Old rows survive and the new columns have their defaults.
    final u = await db.select(db.users).getSingle();
    expect(u.displayName, 'Asha');
    expect(u.dateOfBirth, isNull);
    expect(u.gender, isNull);
    expect(u.heightCm, isNull);
    expect(u.weightKg, isNull);
    expect(u.measurementCadence, 'monthly');
    expect(u.measurementReminderEnabled, isTrue);
    expect(u.nextMeasurementDue, isNull);
    expect(u.reminderSound, isNull);
    expect(u.habitThreshold, 1);

    final w = await db.select(db.workouts).getSingle();
    expect(w.durationMinutes, 30);
    expect(w.caloriesEstimate, isNull);
    expect(w.steps, isNull);
    expect(w.stepsSource, isNull);
    expect(w.distanceKm, isNull);
    expect(w.avgSpeedKmh, isNull);
    expect(w.pausedSeconds, 0);
    expect(w.activeSeconds, isNull);
    expect(w.metricsNote, isNull);

    final s = await db.select(db.screenTimeDaily).getSingle();
    expect(s.totalMinutes, 90);
    expect(s.source, ScreenTimeSource.automatic);
    expect(s.targetMinutes, isNull);
    expect(s.shareInGroups, isFalse);

    // The new tables exist and are usable.
    expect(await db.select(db.hobbies).get(), isEmpty);
    expect(await db.select(db.hobbyLogs).get(), isEmpty);
    expect(await db.select(db.bodyMeasurements).get(), isEmpty);
    expect(await db.select(db.habitSkips).get(), isEmpty);

    // Tips are still seeded on open.
    expect((await db.select(db.tipsLibrary).get()).length, seedTips.length);

    final version = await db
        .customSelect('PRAGMA user_version')
        .map((r) => r.read<int>('user_version'))
        .getSingle();
    expect(version, 2);
  });

  test('a fresh database is created at v2 with every table', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect(db.schemaVersion, 2);
    expect(await db.select(db.hobbies).get(), isEmpty);
    expect(await db.select(db.bodyMeasurements).get(), isEmpty);
    expect((await db.select(db.workoutTypes).get()), isNotEmpty);
  });
}
