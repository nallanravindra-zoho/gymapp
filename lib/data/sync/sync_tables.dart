import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tables.dart';
import 'remote_store.dart';

String _iso(DateTime d) => d.toUtc().toIso8601String();
DateTime _ts(Object? v) => DateTime.parse(v as String).toUtc();
DateTime? _tsOrNull(Object? v) => v == null ? null : _ts(v);
int _int(Object? v) => (v as num).toInt();
int? _intOrNull(Object? v) => v == null ? null : _int(v);
double? _realOrNull(Object? v) => v == null ? null : (v as num).toDouble();

/// One table's translation between local rows and server rows.
///
/// The local user id and the server (auth) user id differ, so every table
/// swaps `user_id` on the way in and out. Rows are matched by key, and a pulled
/// row only replaces a local one when it is strictly newer (last write wins).
abstract class SyncTable {
  const SyncTable();

  /// Server table name.
  String get name;

  /// Column that identifies a row on the server.
  String get keyColumn => 'id';

  /// Local rows changed at or after [since], in server shape.
  Future<List<Json>> localChanges(
    AppDatabase db,
    DateTime? since,
    String remoteUserId,
  );

  /// Writes a server row locally if it is newer. Returns whether it changed.
  Future<bool> applyRemote(AppDatabase db, Json row, String localUserId);
}

/// All user data that syncs. Streak state, weekly insights and the tips
/// library are derived or built in, so they stay local.
const syncTables = <SyncTable>[
  ProfilesSync(),
  CustomWorkoutTypesSync(),
  WorkoutsSync(),
  HabitsSync(),
  HabitLogsSync(),
  HabitSkipsSync(),
  HobbiesSync(),
  HobbyLogsSync(),
  BodyMeasurementsSync(),
  SleepTargetsSync(),
  SleepLogsSync(),
  RestDaysSync(),
  BadgesSync(),
  ScreenTimeDailySync(),
];

// ---------------------------------------------------------------------------

class ProfilesSync extends SyncTable {
  const ProfilesSync();
  @override
  String get name => 'profiles';

  @override
  Future<List<Json>> localChanges(
    AppDatabase db,
    DateTime? since,
    String remoteUserId,
  ) async {
    final q = db.select(db.users);
    if (since != null) q.where((u) => u.updatedAt.isBiggerOrEqualValue(since));
    return [
      // A profile nobody has edited is just the defaults. Sending it could
      // replace the real one on the server with a newer-looking blank.
      for (final u in (await q.get()).where((u) => u.updatedAt != u.createdAt))
        {
          'id': remoteUserId,
          'display_name': u.displayName,
          'avatar_url': u.avatarUrl,
          'timezone': u.timezone,
          'day_cutoff_minutes': u.dayCutoffMinutes,
          'quiet_hours_start': u.quietHoursStart,
          'quiet_hours_end': u.quietHoursEnd,
          'daily_reminder_cap': u.dailyReminderCap,
          'weekly_rest_days': u.weeklyRestDays,
          'freeze_enabled': u.freezeEnabled,
          'freeze_interval_days': u.freezeIntervalDays,
          'date_of_birth': u.dateOfBirth,
          'gender': u.gender,
          'height_cm': u.heightCm,
          'weight_kg': u.weightKg,
          'measurement_cadence': u.measurementCadence,
          'measurement_reminder_enabled': u.measurementReminderEnabled,
          'next_measurement_due': u.nextMeasurementDue,
          'reminder_sound': u.reminderSound,
          'habit_threshold': u.habitThreshold,
          'created_at': _iso(u.createdAt),
          'updated_at': _iso(u.updatedAt),
          'deleted_at': null,
        },
    ];
  }

  @override
  Future<bool> applyRemote(AppDatabase db, Json r, String localUserId) async {
    final local = await (db.select(
      db.users,
    )..where((u) => u.id.equals(localUserId))).getSingleOrNull();
    if (local == null) return false;
    final updated = _ts(r['updated_at']);
    // An untouched local profile is only defaults: the account's wins.
    final untouched = local.updatedAt == local.createdAt;
    if (!untouched && !updated.isAfter(local.updatedAt)) return false;
    await (db.update(db.users)..where((u) => u.id.equals(localUserId))).write(
      UsersCompanion(
        displayName: Value(r['display_name'] as String? ?? ''),
        avatarUrl: Value(r['avatar_url'] as String?),
        timezone: Value(r['timezone'] as String? ?? 'UTC'),
        dayCutoffMinutes: Value(_int(r['day_cutoff_minutes'])),
        quietHoursStart: Value(
          r['quiet_hours_start'] == null ? null : _int(r['quiet_hours_start']),
        ),
        quietHoursEnd: Value(
          r['quiet_hours_end'] == null ? null : _int(r['quiet_hours_end']),
        ),
        dailyReminderCap: Value(_int(r['daily_reminder_cap'])),
        weeklyRestDays: Value(_int(r['weekly_rest_days'])),
        freezeEnabled: Value(r['freeze_enabled'] as bool),
        freezeIntervalDays: Value(_int(r['freeze_interval_days'])),
        dateOfBirth: Value(r['date_of_birth'] as String?),
        gender: Value(r['gender'] as String?),
        heightCm: Value(_realOrNull(r['height_cm'])),
        weightKg: Value(_realOrNull(r['weight_kg'])),
        measurementCadence: Value(
          r['measurement_cadence'] as String? ?? 'monthly',
        ),
        measurementReminderEnabled: Value(
          r['measurement_reminder_enabled'] as bool? ?? true,
        ),
        nextMeasurementDue: Value(r['next_measurement_due'] as String?),
        reminderSound: Value(r['reminder_sound'] as String?),
        habitThreshold: Value(_intOrNull(r['habit_threshold']) ?? 1),
        updatedAt: Value(updated),
      ),
    );
    return true;
  }
}

// ---------------------------------------------------------------------------

class CustomWorkoutTypesSync extends SyncTable {
  const CustomWorkoutTypesSync();
  @override
  String get name => 'workout_types';

  @override
  Future<List<Json>> localChanges(
    AppDatabase db,
    DateTime? since,
    String remoteUserId,
  ) async {
    final q = db.select(db.workoutTypes)
      ..where((t) => t.isBuiltin.equals(false));
    if (since != null) q.where((t) => t.updatedAt.isBiggerOrEqualValue(since));
    return [
      for (final t in await q.get())
        {
          'id': t.id,
          'user_id': remoteUserId,
          'name': t.name,
          'icon_key': t.iconKey,
          'created_at': _iso(t.createdAt),
          'updated_at': _iso(t.updatedAt),
          'deleted_at': t.deletedAt == null ? null : _iso(t.deletedAt!),
        },
    ];
  }

  @override
  Future<bool> applyRemote(AppDatabase db, Json r, String localUserId) async {
    final existing = await (db.select(
      db.workoutTypes,
    )..where((t) => t.id.equals(r['id'] as String))).getSingleOrNull();
    final updated = _ts(r['updated_at']);
    if (existing != null && !updated.isAfter(existing.updatedAt)) return false;
    await db
        .into(db.workoutTypes)
        .insertOnConflictUpdate(
          WorkoutTypesCompanion(
            id: Value(r['id'] as String),
            userId: Value(localUserId),
            name: Value(r['name'] as String),
            iconKey: Value(r['icon_key'] as String),
            isBuiltin: const Value(false),
            createdAt: Value(_ts(r['created_at'])),
            updatedAt: Value(updated),
            deletedAt: Value(_tsOrNull(r['deleted_at'])),
          ),
        );
    return true;
  }
}

// ---------------------------------------------------------------------------

class WorkoutsSync extends SyncTable {
  const WorkoutsSync();
  @override
  String get name => 'workouts';

  @override
  Future<List<Json>> localChanges(
    AppDatabase db,
    DateTime? since,
    String remoteUserId,
  ) async {
    final q = db.select(db.workouts);
    if (since != null) q.where((w) => w.updatedAt.isBiggerOrEqualValue(since));
    return [
      for (final w in await q.get())
        {
          'id': w.id,
          'user_id': remoteUserId,
          'workout_type_id': w.workoutTypeId,
          'started_at': _iso(w.startedAt),
          'ended_at': _iso(w.endedAt),
          'duration_minutes': w.durationMinutes,
          'intensity': w.intensity?.name,
          'note': w.note,
          'source': w.source.name,
          'tz_offset_minutes': w.tzOffsetMinutes,
          'local_date': w.localDate,
          'calories_estimate': w.caloriesEstimate,
          'steps': w.steps,
          'steps_source': w.stepsSource,
          'distance_km': w.distanceKm,
          'avg_speed_kmh': w.avgSpeedKmh,
          'paused_seconds': w.pausedSeconds,
          'active_seconds': w.activeSeconds,
          'metrics_note': w.metricsNote,
          'created_at': _iso(w.createdAt),
          'updated_at': _iso(w.updatedAt),
          'deleted_at': w.deletedAt == null ? null : _iso(w.deletedAt!),
        },
    ];
  }

  @override
  Future<bool> applyRemote(AppDatabase db, Json r, String localUserId) async {
    final existing = await (db.select(
      db.workouts,
    )..where((w) => w.id.equals(r['id'] as String))).getSingleOrNull();
    final updated = _ts(r['updated_at']);
    if (existing != null && !updated.isAfter(existing.updatedAt)) return false;
    final intensity = r['intensity'] as String?;
    await db
        .into(db.workouts)
        .insertOnConflictUpdate(
          WorkoutsCompanion(
            id: Value(r['id'] as String),
            userId: Value(localUserId),
            workoutTypeId: Value(r['workout_type_id'] as String),
            startedAt: Value(_ts(r['started_at'])),
            endedAt: Value(_ts(r['ended_at'])),
            durationMinutes: Value(_int(r['duration_minutes'])),
            intensity: Value(
              intensity == null
                  ? null
                  : WorkoutIntensity.values.byName(intensity),
            ),
            note: Value(r['note'] as String?),
            source: Value(WorkoutSource.values.byName(r['source'] as String)),
            tzOffsetMinutes: Value(_int(r['tz_offset_minutes'])),
            localDate: Value(r['local_date'] as String),
            caloriesEstimate: Value(_intOrNull(r['calories_estimate'])),
            steps: Value(_intOrNull(r['steps'])),
            stepsSource: Value(r['steps_source'] as String?),
            distanceKm: Value(_realOrNull(r['distance_km'])),
            avgSpeedKmh: Value(_realOrNull(r['avg_speed_kmh'])),
            pausedSeconds: Value(_intOrNull(r['paused_seconds']) ?? 0),
            activeSeconds: Value(_intOrNull(r['active_seconds'])),
            metricsNote: Value(r['metrics_note'] as String?),
            createdAt: Value(_ts(r['created_at'])),
            updatedAt: Value(updated),
            deletedAt: Value(_tsOrNull(r['deleted_at'])),
          ),
        );
    return true;
  }
}

// ---------------------------------------------------------------------------

class HabitsSync extends SyncTable {
  const HabitsSync();
  @override
  String get name => 'habits';

  @override
  Future<List<Json>> localChanges(
    AppDatabase db,
    DateTime? since,
    String remoteUserId,
  ) async {
    final q = db.select(db.habits);
    if (since != null) q.where((h) => h.updatedAt.isBiggerOrEqualValue(since));
    return [
      for (final h in await q.get())
        {
          'id': h.id,
          'user_id': remoteUserId,
          'name': h.name,
          'kind': h.kind.name,
          'daily_target': h.dailyTarget,
          'reminders_enabled': h.remindersEnabled,
          'reminder_config': h.reminderConfig,
          'is_active': h.isActive,
          'created_at': _iso(h.createdAt),
          'updated_at': _iso(h.updatedAt),
          'deleted_at': h.deletedAt == null ? null : _iso(h.deletedAt!),
        },
    ];
  }

  @override
  Future<bool> applyRemote(AppDatabase db, Json r, String localUserId) async {
    final existing = await (db.select(
      db.habits,
    )..where((h) => h.id.equals(r['id'] as String))).getSingleOrNull();
    final updated = _ts(r['updated_at']);
    if (existing != null && !updated.isAfter(existing.updatedAt)) return false;
    await db
        .into(db.habits)
        .insertOnConflictUpdate(
          HabitsCompanion(
            id: Value(r['id'] as String),
            userId: Value(localUserId),
            name: Value(r['name'] as String),
            kind: Value(HabitKind.values.byName(r['kind'] as String)),
            dailyTarget: Value(_int(r['daily_target'])),
            remindersEnabled: Value(r['reminders_enabled'] as bool),
            reminderConfig: Value(r['reminder_config'] as String),
            isActive: Value(r['is_active'] as bool),
            createdAt: Value(_ts(r['created_at'])),
            updatedAt: Value(updated),
            deletedAt: Value(_tsOrNull(r['deleted_at'])),
          ),
        );
    return true;
  }
}

// ---------------------------------------------------------------------------

class HabitLogsSync extends SyncTable {
  const HabitLogsSync();
  @override
  String get name => 'habit_logs';

  @override
  Future<List<Json>> localChanges(
    AppDatabase db,
    DateTime? since,
    String remoteUserId,
  ) async {
    final q = db.select(db.habitLogs);
    if (since != null) q.where((l) => l.updatedAt.isBiggerOrEqualValue(since));
    return [
      for (final l in await q.get())
        {
          'id': l.id,
          'user_id': remoteUserId,
          'habit_id': l.habitId,
          'logged_at': _iso(l.loggedAt),
          'count': l.count,
          'tz_offset_minutes': l.tzOffsetMinutes,
          'local_date': l.localDate,
          'created_at': _iso(l.createdAt),
          'updated_at': _iso(l.updatedAt),
          'deleted_at': l.deletedAt == null ? null : _iso(l.deletedAt!),
        },
    ];
  }

  @override
  Future<bool> applyRemote(AppDatabase db, Json r, String localUserId) async {
    final existing = await (db.select(
      db.habitLogs,
    )..where((l) => l.id.equals(r['id'] as String))).getSingleOrNull();
    final updated = _ts(r['updated_at']);
    if (existing != null && !updated.isAfter(existing.updatedAt)) return false;
    await db
        .into(db.habitLogs)
        .insertOnConflictUpdate(
          HabitLogsCompanion(
            id: Value(r['id'] as String),
            habitId: Value(r['habit_id'] as String),
            userId: Value(localUserId),
            loggedAt: Value(_ts(r['logged_at'])),
            count: Value(_int(r['count'])),
            tzOffsetMinutes: Value(_int(r['tz_offset_minutes'])),
            localDate: Value(r['local_date'] as String),
            createdAt: Value(_ts(r['created_at'])),
            updatedAt: Value(updated),
            deletedAt: Value(_tsOrNull(r['deleted_at'])),
          ),
        );
    return true;
  }
}

// ---------------------------------------------------------------------------

class SleepTargetsSync extends SyncTable {
  const SleepTargetsSync();
  @override
  String get name => 'sleep_targets';
  @override
  String get keyColumn => 'user_id';

  @override
  Future<List<Json>> localChanges(
    AppDatabase db,
    DateTime? since,
    String remoteUserId,
  ) async {
    final q = db.select(db.sleepTargets);
    if (since != null) q.where((t) => t.updatedAt.isBiggerOrEqualValue(since));
    return [
      for (final t in await q.get())
        {
          'user_id': remoteUserId,
          'bedtime_minutes': t.bedtimeMinutes,
          'wake_minutes': t.wakeMinutes,
          'updated_at': _iso(t.updatedAt),
        },
    ];
  }

  @override
  Future<bool> applyRemote(AppDatabase db, Json r, String localUserId) async {
    final existing = await (db.select(
      db.sleepTargets,
    )..where((t) => t.userId.equals(localUserId))).getSingleOrNull();
    final updated = _ts(r['updated_at']);
    if (existing != null && !updated.isAfter(existing.updatedAt)) return false;
    await db
        .into(db.sleepTargets)
        .insertOnConflictUpdate(
          SleepTargetsCompanion(
            userId: Value(localUserId),
            bedtimeMinutes: Value(_int(r['bedtime_minutes'])),
            wakeMinutes: Value(_int(r['wake_minutes'])),
            updatedAt: Value(updated),
          ),
        );
    return true;
  }
}

// ---------------------------------------------------------------------------

class SleepLogsSync extends SyncTable {
  const SleepLogsSync();
  @override
  String get name => 'sleep_logs';

  @override
  Future<List<Json>> localChanges(
    AppDatabase db,
    DateTime? since,
    String remoteUserId,
  ) async {
    final q = db.select(db.sleepLogs);
    if (since != null) q.where((l) => l.updatedAt.isBiggerOrEqualValue(since));
    return [
      for (final l in await q.get())
        {
          'id': l.id,
          'user_id': remoteUserId,
          'bedtime_at': _iso(l.bedtimeAt),
          'wake_at': _iso(l.wakeAt),
          'duration_minutes': l.durationMinutes,
          'tz_offset_minutes': l.tzOffsetMinutes,
          'local_date': l.localDate,
          'created_at': _iso(l.createdAt),
          'updated_at': _iso(l.updatedAt),
          'deleted_at': l.deletedAt == null ? null : _iso(l.deletedAt!),
        },
    ];
  }

  @override
  Future<bool> applyRemote(AppDatabase db, Json r, String localUserId) async {
    final updated = _ts(r['updated_at']);
    // One night per wake date. If another row already holds this date, the
    // newer of the two wins and the older is retired.
    final sameNight =
        await (db.select(db.sleepLogs)..where(
              (l) =>
                  l.userId.equals(localUserId) &
                  l.localDate.equals(r['local_date'] as String) &
                  l.deletedAt.isNull() &
                  l.id.equals(r['id'] as String).not(),
            ))
            .getSingleOrNull();
    if (sameNight != null && r['deleted_at'] == null) {
      if (!updated.isAfter(sameNight.updatedAt)) return false;
      await (db.update(
        db.sleepLogs,
      )..where((l) => l.id.equals(sameNight.id))).write(
        SleepLogsCompanion(
          deletedAt: Value(updated),
          updatedAt: Value(updated),
        ),
      );
    }
    final existing = await (db.select(
      db.sleepLogs,
    )..where((l) => l.id.equals(r['id'] as String))).getSingleOrNull();
    if (existing != null && !updated.isAfter(existing.updatedAt)) return false;
    await db
        .into(db.sleepLogs)
        .insertOnConflictUpdate(
          SleepLogsCompanion(
            id: Value(r['id'] as String),
            userId: Value(localUserId),
            bedtimeAt: Value(_ts(r['bedtime_at'])),
            wakeAt: Value(_ts(r['wake_at'])),
            durationMinutes: Value(_int(r['duration_minutes'])),
            tzOffsetMinutes: Value(_int(r['tz_offset_minutes'])),
            localDate: Value(r['local_date'] as String),
            createdAt: Value(_ts(r['created_at'])),
            updatedAt: Value(updated),
            deletedAt: Value(_tsOrNull(r['deleted_at'])),
          ),
        );
    return true;
  }
}

// ---------------------------------------------------------------------------

class RestDaysSync extends SyncTable {
  const RestDaysSync();
  @override
  String get name => 'rest_days';

  @override
  Future<List<Json>> localChanges(
    AppDatabase db,
    DateTime? since,
    String remoteUserId,
  ) async {
    final q = db.select(db.restDays);
    if (since != null) q.where((r) => r.updatedAt.isBiggerOrEqualValue(since));
    return [
      for (final r in await q.get())
        {
          'id': r.id,
          'user_id': remoteUserId,
          'local_date': r.localDate,
          'created_at': _iso(r.createdAt),
          'updated_at': _iso(r.updatedAt),
          'deleted_at': r.deletedAt == null ? null : _iso(r.deletedAt!),
        },
    ];
  }

  @override
  Future<bool> applyRemote(AppDatabase db, Json r, String localUserId) async {
    final existing = await (db.select(
      db.restDays,
    )..where((x) => x.id.equals(r['id'] as String))).getSingleOrNull();
    final updated = _ts(r['updated_at']);
    if (existing != null && !updated.isAfter(existing.updatedAt)) return false;
    // A date is a rest day once. A second row for the same date (from another
    // device) is skipped so it cannot count twice against the weekly limit.
    final sameDate =
        await (db.select(db.restDays)..where(
              (x) =>
                  x.userId.equals(localUserId) &
                  x.localDate.equals(r['local_date'] as String) &
                  x.deletedAt.isNull() &
                  x.id.equals(r['id'] as String).not(),
            ))
            .getSingleOrNull();
    if (sameDate != null && r['deleted_at'] == null) return false;
    await db
        .into(db.restDays)
        .insertOnConflictUpdate(
          RestDaysCompanion(
            id: Value(r['id'] as String),
            userId: Value(localUserId),
            localDate: Value(r['local_date'] as String),
            createdAt: Value(_ts(r['created_at'])),
            updatedAt: Value(updated),
            deletedAt: Value(_tsOrNull(r['deleted_at'])),
          ),
        );
    return true;
  }
}

// ---------------------------------------------------------------------------

class BadgesSync extends SyncTable {
  const BadgesSync();
  @override
  String get name => 'badges_awarded';

  @override
  Future<List<Json>> localChanges(
    AppDatabase db,
    DateTime? since,
    String remoteUserId,
  ) async {
    final q = db.select(db.badgesAwarded);
    if (since != null) q.where((b) => b.updatedAt.isBiggerOrEqualValue(since));
    return [
      for (final b in await q.get())
        {
          'id': b.id,
          'user_id': remoteUserId,
          'badge_key': b.badgeKey,
          'awarded_at': _iso(b.awardedAt),
          'context': b.context,
          'created_at': _iso(b.createdAt),
          'updated_at': _iso(b.updatedAt),
          'deleted_at': b.deletedAt == null ? null : _iso(b.deletedAt!),
        },
    ];
  }

  @override
  Future<bool> applyRemote(AppDatabase db, Json r, String localUserId) async {
    final existing = await (db.select(
      db.badgesAwarded,
    )..where((b) => b.id.equals(r['id'] as String))).getSingleOrNull();
    final updated = _ts(r['updated_at']);
    if (existing != null && !updated.isAfter(existing.updatedAt)) return false;
    // A badge is awarded once: if this device already holds the same badge
    // under a different row, keep the earlier one rather than duplicating it.
    final sameBadge =
        await (db.select(db.badgesAwarded)..where(
              (b) =>
                  b.userId.equals(localUserId) &
                  b.badgeKey.equals(r['badge_key'] as String) &
                  b.deletedAt.isNull() &
                  b.id.equals(r['id'] as String).not(),
            ))
            .getSingleOrNull();
    if (sameBadge != null && r['deleted_at'] == null) return false;
    await db
        .into(db.badgesAwarded)
        .insertOnConflictUpdate(
          BadgesAwardedCompanion(
            id: Value(r['id'] as String),
            userId: Value(localUserId),
            badgeKey: Value(r['badge_key'] as String),
            awardedAt: Value(_ts(r['awarded_at'])),
            context: Value(r['context'] as String),
            createdAt: Value(_ts(r['created_at'])),
            updatedAt: Value(updated),
            deletedAt: Value(_tsOrNull(r['deleted_at'])),
          ),
        );
    return true;
  }
}

// ---------------------------------------------------------------------------

class ScreenTimeDailySync extends SyncTable {
  const ScreenTimeDailySync();
  @override
  String get name => 'screen_time_daily';

  @override
  Future<List<Json>> localChanges(
    AppDatabase db,
    DateTime? since,
    String remoteUserId,
  ) async {
    final q = db.select(db.screenTimeDaily);
    if (since != null) q.where((s) => s.updatedAt.isBiggerOrEqualValue(since));
    return [
      for (final s in await q.get())
        {
          'id': s.id,
          'user_id': remoteUserId,
          'local_date': s.localDate,
          'total_minutes': s.totalMinutes,
          'category_minutes': s.categoryMinutes,
          'late_evening_minutes': s.lateEveningMinutes,
          'share_in_groups': s.shareInGroups,
          'source': s.source.name,
          'target_minutes': s.targetMinutes,
          'created_at': _iso(s.createdAt),
          'updated_at': _iso(s.updatedAt),
          'deleted_at': s.deletedAt == null ? null : _iso(s.deletedAt!),
        },
    ];
  }

  @override
  Future<bool> applyRemote(AppDatabase db, Json r, String localUserId) async {
    // One row per day. Two devices may each have created a row for the same
    // date with different ids; keep the newer one and retire the other.
    final sameDay =
        await (db.select(db.screenTimeDaily)..where(
              (s) =>
                  s.userId.equals(localUserId) &
                  s.localDate.equals(r['local_date'] as String) &
                  s.deletedAt.isNull() &
                  s.id.equals(r['id'] as String).not(),
            ))
            .getSingleOrNull();
    final updated = _ts(r['updated_at']);
    if (sameDay != null && r['deleted_at'] == null) {
      if (!updated.isAfter(sameDay.updatedAt)) return false;
      await (db.update(
        db.screenTimeDaily,
      )..where((s) => s.id.equals(sameDay.id))).write(
        ScreenTimeDailyCompanion(
          deletedAt: Value(updated),
          updatedAt: Value(updated),
        ),
      );
    }
    final existing = await (db.select(
      db.screenTimeDaily,
    )..where((s) => s.id.equals(r['id'] as String))).getSingleOrNull();
    if (existing != null && !updated.isAfter(existing.updatedAt)) return false;
    await db
        .into(db.screenTimeDaily)
        .insertOnConflictUpdate(
          ScreenTimeDailyCompanion(
            id: Value(r['id'] as String),
            userId: Value(localUserId),
            localDate: Value(r['local_date'] as String),
            totalMinutes: Value(_int(r['total_minutes'])),
            categoryMinutes: Value(r['category_minutes'] as String),
            lateEveningMinutes: Value(_int(r['late_evening_minutes'])),
            shareInGroups: Value(r['share_in_groups'] as bool),
            source: Value(
              ScreenTimeSource.values.byName(
                r['source'] as String? ?? 'automatic',
              ),
            ),
            targetMinutes: Value(_intOrNull(r['target_minutes'])),
            createdAt: Value(_ts(r['created_at'])),
            updatedAt: Value(updated),
            deletedAt: Value(_tsOrNull(r['deleted_at'])),
          ),
        );
    return true;
  }
}

// ---------------------------------------------------------------------------

class HabitSkipsSync extends SyncTable {
  const HabitSkipsSync();
  @override
  String get name => 'habit_skips';

  @override
  Future<List<Json>> localChanges(
    AppDatabase db,
    DateTime? since,
    String remoteUserId,
  ) async {
    final q = db.select(db.habitSkips);
    if (since != null) q.where((x) => x.updatedAt.isBiggerOrEqualValue(since));
    return [
      for (final k in await q.get())
        {
          'id': k.id,
          'user_id': remoteUserId,
          'habit_id': k.habitId,
          'skipped_at': _iso(k.skippedAt),
          'tz_offset_minutes': k.tzOffsetMinutes,
          'local_date': k.localDate,
          'created_at': _iso(k.createdAt),
          'updated_at': _iso(k.updatedAt),
          'deleted_at': k.deletedAt == null ? null : _iso(k.deletedAt!),
        },
    ];
  }

  @override
  Future<bool> applyRemote(AppDatabase db, Json r, String localUserId) async {
    final existing = await (db.select(
      db.habitSkips,
    )..where((x) => x.id.equals(r['id'] as String))).getSingleOrNull();
    final updated = _ts(r['updated_at']);
    if (existing != null && !updated.isAfter(existing.updatedAt)) return false;
    await db
        .into(db.habitSkips)
        .insertOnConflictUpdate(
          HabitSkipsCompanion(
            id: Value(r['id'] as String),
            userId: Value(localUserId),
            habitId: Value(r['habit_id'] as String),
            skippedAt: Value(_ts(r['skipped_at'])),
            tzOffsetMinutes: Value(_int(r['tz_offset_minutes'])),
            localDate: Value(r['local_date'] as String),
            createdAt: Value(_ts(r['created_at'])),
            updatedAt: Value(updated),
            deletedAt: Value(_tsOrNull(r['deleted_at'])),
          ),
        );
    return true;
  }
}

// ---------------------------------------------------------------------------

class HobbiesSync extends SyncTable {
  const HobbiesSync();
  @override
  String get name => 'hobbies';

  @override
  Future<List<Json>> localChanges(
    AppDatabase db,
    DateTime? since,
    String remoteUserId,
  ) async {
    final q = db.select(db.hobbies);
    if (since != null) q.where((x) => x.updatedAt.isBiggerOrEqualValue(since));
    return [
      for (final h in await q.get())
        {
          'id': h.id,
          'user_id': remoteUserId,
          'name': h.name,
          'icon_key': h.iconKey,
          'is_builtin': h.isBuiltin,
          'goal_period': h.goalPeriod?.name,
          'goal_value': h.goalValue,
          'goal_unit': h.goalUnit.name,
          'reminder_enabled': h.reminderEnabled,
          'reminder_config': h.reminderConfig,
          'is_active': h.isActive,
          'created_at': _iso(h.createdAt),
          'updated_at': _iso(h.updatedAt),
          'deleted_at': h.deletedAt == null ? null : _iso(h.deletedAt!),
        },
    ];
  }

  @override
  Future<bool> applyRemote(AppDatabase db, Json r, String localUserId) async {
    final existing = await (db.select(
      db.hobbies,
    )..where((x) => x.id.equals(r['id'] as String))).getSingleOrNull();
    final updated = _ts(r['updated_at']);
    if (existing != null && !updated.isAfter(existing.updatedAt)) return false;
    // Each device seeds the built-in hobbies on first use, so two devices
    // hold different rows for "Music". Keep the row with the smaller id on
    // both sides; the other is retired and its logs move to the kept one.
    if (r['is_builtin'] == true && r['deleted_at'] == null) {
      final twin =
          await (db.select(db.hobbies)..where(
                (h) =>
                    h.userId.equals(localUserId) &
                    h.isBuiltin.equals(true) &
                    h.name.equals(r['name'] as String) &
                    h.deletedAt.isNull() &
                    h.id.equals(r['id'] as String).not(),
              ))
              .getSingleOrNull();
      if (twin != null) {
        if (twin.id.compareTo(r['id'] as String) < 0) {
          // The local row is the one to keep. Remember the remote row as
          // retired so its logs can be pointed at the kept one.
          await db
              .into(db.hobbies)
              .insertOnConflictUpdate(
                HobbiesCompanion(
                  id: Value(r['id'] as String),
                  userId: Value(localUserId),
                  name: Value(r['name'] as String),
                  iconKey: Value(r['icon_key'] as String),
                  isBuiltin: const Value(true),
                  createdAt: Value(_ts(r['created_at'])),
                  updatedAt: Value(updated),
                  deletedAt: Value(updated),
                ),
              );
          return true;
        }
        final stamp = updated.isAfter(twin.updatedAt)
            ? updated
            : twin.updatedAt.add(const Duration(seconds: 1));
        await (db.update(db.hobbies)..where((h) => h.id.equals(twin.id))).write(
          HobbiesCompanion(deletedAt: Value(stamp), updatedAt: Value(stamp)),
        );
        final logs = await (db.select(
          db.hobbyLogs,
        )..where((l) => l.hobbyId.equals(twin.id))).get();
        for (final l in logs) {
          await (db.update(
            db.hobbyLogs,
          )..where((x) => x.id.equals(l.id))).write(
            HobbyLogsCompanion(
              hobbyId: Value(r['id'] as String),
              updatedAt: Value(
                stamp.isAfter(l.updatedAt)
                    ? stamp
                    : l.updatedAt.add(const Duration(seconds: 1)),
              ),
            ),
          );
        }
      }
    }
    await db
        .into(db.hobbies)
        .insertOnConflictUpdate(
          HobbiesCompanion(
            id: Value(r['id'] as String),
            userId: Value(localUserId),
            name: Value(r['name'] as String),
            iconKey: Value(r['icon_key'] as String),
            isBuiltin: Value(r['is_builtin'] as bool),
            goalPeriod: Value(
              r['goal_period'] == null
                  ? null
                  : HobbyGoalPeriod.values.byName(r['goal_period'] as String),
            ),
            goalValue: Value(_intOrNull(r['goal_value'])),
            goalUnit: Value(
              HobbyGoalUnit.values.byName(r['goal_unit'] as String),
            ),
            reminderEnabled: Value(r['reminder_enabled'] as bool),
            reminderConfig: Value(r['reminder_config'] as String),
            isActive: Value(r['is_active'] as bool),
            createdAt: Value(_ts(r['created_at'])),
            updatedAt: Value(updated),
            deletedAt: Value(_tsOrNull(r['deleted_at'])),
          ),
        );
    return true;
  }
}

// ---------------------------------------------------------------------------

class HobbyLogsSync extends SyncTable {
  const HobbyLogsSync();
  @override
  String get name => 'hobby_logs';

  @override
  Future<List<Json>> localChanges(
    AppDatabase db,
    DateTime? since,
    String remoteUserId,
  ) async {
    final q = db.select(db.hobbyLogs);
    if (since != null) q.where((x) => x.updatedAt.isBiggerOrEqualValue(since));
    return [
      for (final l in await q.get())
        {
          'id': l.id,
          'user_id': remoteUserId,
          'hobby_id': l.hobbyId,
          'started_at': _iso(l.startedAt),
          'ended_at': l.endedAt == null ? null : _iso(l.endedAt!),
          'duration_minutes': l.durationMinutes,
          'count_or_sessions': l.countOrSessions,
          'source': l.source.name,
          'tz_offset_minutes': l.tzOffsetMinutes,
          'local_date': l.localDate,
          'note': l.note,
          'created_at': _iso(l.createdAt),
          'updated_at': _iso(l.updatedAt),
          'deleted_at': l.deletedAt == null ? null : _iso(l.deletedAt!),
        },
    ];
  }

  @override
  Future<bool> applyRemote(AppDatabase db, Json r, String localUserId) async {
    final existing = await (db.select(
      db.hobbyLogs,
    )..where((x) => x.id.equals(r['id'] as String))).getSingleOrNull();
    final updated = _ts(r['updated_at']);
    if (existing != null && !updated.isAfter(existing.updatedAt)) return false;
    // A log written against a built-in hobby this device retired in favour
    // of its twin belongs to the twin.
    var hobbyId = r['hobby_id'] as String;
    final target = await (db.select(
      db.hobbies,
    )..where((h) => h.id.equals(hobbyId))).getSingleOrNull();
    if (target != null && target.isBuiltin && target.deletedAt != null) {
      final kept =
          await (db.select(db.hobbies)..where(
                (h) =>
                    h.userId.equals(localUserId) &
                    h.isBuiltin.equals(true) &
                    h.name.equals(target.name) &
                    h.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (kept != null) hobbyId = kept.id;
    }
    await db
        .into(db.hobbyLogs)
        .insertOnConflictUpdate(
          HobbyLogsCompanion(
            id: Value(r['id'] as String),
            userId: Value(localUserId),
            hobbyId: Value(hobbyId),
            startedAt: Value(_ts(r['started_at'])),
            endedAt: Value(_tsOrNull(r['ended_at'])),
            durationMinutes: Value(_int(r['duration_minutes'])),
            countOrSessions: Value(_int(r['count_or_sessions'])),
            source: Value(HobbyLogSource.values.byName(r['source'] as String)),
            tzOffsetMinutes: Value(_int(r['tz_offset_minutes'])),
            localDate: Value(r['local_date'] as String),
            note: Value(r['note'] as String?),
            createdAt: Value(_ts(r['created_at'])),
            updatedAt: Value(updated),
            deletedAt: Value(_tsOrNull(r['deleted_at'])),
          ),
        );
    return true;
  }
}

// ---------------------------------------------------------------------------

class BodyMeasurementsSync extends SyncTable {
  const BodyMeasurementsSync();
  @override
  String get name => 'body_measurements';

  @override
  Future<List<Json>> localChanges(
    AppDatabase db,
    DateTime? since,
    String remoteUserId,
  ) async {
    final q = db.select(db.bodyMeasurements);
    if (since != null) q.where((x) => x.updatedAt.isBiggerOrEqualValue(since));
    return [
      for (final m in await q.get())
        {
          'id': m.id,
          'user_id': remoteUserId,
          'measured_at': _iso(m.measuredAt),
          'tz_offset_minutes': m.tzOffsetMinutes,
          'local_date': m.localDate,
          'weight_kg': m.weightKg,
          'height_cm': m.heightCm,
          'bmi': m.bmi,
          'waist_in': m.waistIn,
          'hips_in': m.hipsIn,
          'chest_in': m.chestIn,
          'arm_in': m.armIn,
          'thigh_in': m.thighIn,
          'notes': m.notes,
          'created_at': _iso(m.createdAt),
          'updated_at': _iso(m.updatedAt),
          'deleted_at': m.deletedAt == null ? null : _iso(m.deletedAt!),
        },
    ];
  }

  @override
  Future<bool> applyRemote(AppDatabase db, Json r, String localUserId) async {
    final existing = await (db.select(
      db.bodyMeasurements,
    )..where((x) => x.id.equals(r['id'] as String))).getSingleOrNull();
    final updated = _ts(r['updated_at']);
    if (existing != null && !updated.isAfter(existing.updatedAt)) return false;
    await db
        .into(db.bodyMeasurements)
        .insertOnConflictUpdate(
          BodyMeasurementsCompanion(
            id: Value(r['id'] as String),
            userId: Value(localUserId),
            measuredAt: Value(_ts(r['measured_at'])),
            tzOffsetMinutes: Value(_int(r['tz_offset_minutes'])),
            localDate: Value(r['local_date'] as String),
            weightKg: Value(_realOrNull(r['weight_kg'])),
            heightCm: Value(_realOrNull(r['height_cm'])),
            bmi: Value(_realOrNull(r['bmi'])),
            waistIn: Value(_realOrNull(r['waist_in'])),
            hipsIn: Value(_realOrNull(r['hips_in'])),
            chestIn: Value(_realOrNull(r['chest_in'])),
            armIn: Value(_realOrNull(r['arm_in'])),
            thighIn: Value(_realOrNull(r['thigh_in'])),
            notes: Value(r['notes'] as String?),
            createdAt: Value(_ts(r['created_at'])),
            updatedAt: Value(updated),
            deletedAt: Value(_tsOrNull(r['deleted_at'])),
          ),
        );
    return true;
  }
}
