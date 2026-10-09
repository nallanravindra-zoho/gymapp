import 'package:drift/drift.dart';

import 'common.dart';

enum WorkoutIntensity { low, mid, high }

enum WorkoutSource { timer, manual }

enum HabitKind { water, stand, stretch, custom }

enum StreakScope { overall, workoutType, habit }

/// The signed-in (or local) user. One row on this device.
class Users extends Table with SyncColumns {
  TextColumn get displayName => text().withDefault(const Constant(''))();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get timezone => text().withDefault(const Constant('UTC'))();
  IntColumn get dayCutoffMinutes => integer().withDefault(const Constant(0))();
  IntColumn get quietHoursStart => integer().nullable()();
  IntColumn get quietHoursEnd => integer().nullable()();
  IntColumn get dailyReminderCap => integer().withDefault(const Constant(6))();

  // Streak settings, all configurable (spec 7.2).
  IntColumn get weeklyRestDays => integer().withDefault(const Constant(2))();
  BoolColumn get freezeEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get freezeIntervalDays =>
      integer().withDefault(const Constant(7))();
}

class WorkoutTypes extends Table with SyncColumns {
  /// Null for built-in types.
  TextColumn get userId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get iconKey => text()();
  BoolColumn get isBuiltin => boolean().withDefault(const Constant(false))();
}

class Workouts extends Table with SyncColumns {
  TextColumn get userId => text()();
  TextColumn get workoutTypeId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime()();
  IntColumn get durationMinutes => integer()();
  TextColumn get intensity => textEnum<WorkoutIntensity>().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get source => textEnum<WorkoutSource>()();

  /// UTC offset at start time, so the local day can be re-derived.
  IntColumn get tzOffsetMinutes => integer().withDefault(const Constant(0))();
  TextColumn get localDate => text()();
}

class Habits extends Table with SyncColumns {
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get kind => textEnum<HabitKind>()();
  IntColumn get dailyTarget => integer().withDefault(const Constant(1))();
  BoolColumn get remindersEnabled =>
      boolean().withDefault(const Constant(false))();

  /// JSON: reminder times or interval, and active days.
  TextColumn get reminderConfig => text().withDefault(const Constant('{}'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class HabitLogs extends Table with SyncColumns {
  TextColumn get habitId => text()();
  TextColumn get userId => text()();
  DateTimeColumn get loggedAt => dateTime()();
  IntColumn get count => integer().withDefault(const Constant(1))();
  IntColumn get tzOffsetMinutes => integer().withDefault(const Constant(0))();
  TextColumn get localDate => text()();
}

class SleepTargets extends Table {
  TextColumn get userId => text()();
  IntColumn get bedtimeMinutes => integer()();
  IntColumn get wakeMinutes => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId};
}

class SleepLogs extends Table with SyncColumns {
  TextColumn get userId => text()();
  DateTimeColumn get bedtimeAt => dateTime()();
  DateTimeColumn get wakeAt => dateTime()();
  IntColumn get durationMinutes => integer()();
  IntColumn get tzOffsetMinutes => integer().withDefault(const Constant(0))();

  /// Date of waking.
  TextColumn get localDate => text()();
}

class RestDays extends Table with SyncColumns {
  TextColumn get userId => text()();
  TextColumn get localDate => text()();
}

/// Cached, always recomputable from logs (spec 7.2).
class StreakStates extends Table {
  TextColumn get userId => text()();

  /// `overall`, `workout_type:<id>` or `habit:<id>`.
  TextColumn get scope => text()();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();
  TextColumn get lastCountedDate => text().nullable()();
  BoolColumn get freezeAvailable =>
      boolean().withDefault(const Constant(true))();
  TextColumn get freezeLastGrantedOn => text().nullable()();

  @override
  Set<Column> get primaryKey => {userId, scope};
}

class BadgesAwarded extends Table with SyncColumns {
  TextColumn get userId => text()();
  TextColumn get badgeKey => text()();
  DateTimeColumn get awardedAt => dateTime()();
  TextColumn get context => text().withDefault(const Constant('{}'))();
}

/// Daily totals only. Per-app detail stays on the device; sharing is opt-in
/// and off by default (spec 8.1).
class ScreenTimeDaily extends Table with SyncColumns {
  TextColumn get userId => text()();
  TextColumn get localDate => text()();
  IntColumn get totalMinutes => integer()();

  /// JSON map of category -> minutes.
  TextColumn get categoryMinutes => text().withDefault(const Constant('{}'))();

  /// Minutes of use in the late-evening window, for the sleep insight.
  IntColumn get lateEveningMinutes =>
      integer().withDefault(const Constant(0))();
  BoolColumn get shareInGroups =>
      boolean().withDefault(const Constant(false))();
}

class WeeklyInsights extends Table with SyncColumns {
  TextColumn get userId => text()();
  TextColumn get weekStart => text()();
  TextColumn get insightKey => text()();
  TextColumn get params => text().withDefault(const Constant('{}'))();
  DateTimeColumn get generatedAt => dateTime()();
}

class TipsLibrary extends Table with SyncColumns {
  TextColumn get triggerKey => text()();
  TextColumn get body => text()();
  TextColumn get sourceLabel => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}
