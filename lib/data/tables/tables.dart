import 'package:drift/drift.dart';

import 'common.dart';

enum WorkoutIntensity { low, mid, high }

enum WorkoutSource { timer, manual }

/// Stored by name as text, so new kinds can be appended without a migration.
enum HabitKind { water, stand, stretch, custom, moisturize, skinCare }

enum HobbyGoalPeriod { daily, weekly }

enum HobbyGoalUnit { minutes, sessions }

enum HobbyLogSource { timer, manual }

/// `automatic` readings come from Android usage stats; `manual` is the
/// fallback when usage access is unavailable.
enum ScreenTimeSource { automatic, manual }

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

  // Profile (R10). Age is always calculated from [dateOfBirth], never stored.
  /// `yyyy-MM-dd`.
  TextColumn get dateOfBirth => text().nullable()();
  TextColumn get gender => text().nullable()();
  RealColumn get heightCm => real().nullable()();
  RealColumn get weightKg => real().nullable()();

  /// `weekly`, `biweekly`, `monthly` or `bimonthly`.
  TextColumn get measurementCadence =>
      text().withDefault(const Constant('monthly'))();
  BoolColumn get measurementReminderEnabled =>
      boolean().withDefault(const Constant(true))();

  /// Local date (`yyyy-MM-dd`) the next measurements are due.
  TextColumn get nextMeasurementDue => text().nullable()();

  /// Notification sound (a URI or key). Null means the phone's default.
  TextColumn get reminderSound => text().nullable()();

  /// How many active habits must meet their target in a day for the Healthy
  /// Habits icon in the Week calendar (R8).
  IntColumn get habitThreshold => integer().withDefault(const Constant(1))();
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

  // Metrics (R3). All optional; the estimate fields are labelled as such.
  /// Estimated, never measured, energy use. Null when inputs were missing.
  IntColumn get caloriesEstimate => integer().nullable()();
  IntColumn get steps => integer().nullable()();

  /// `sensor` or `estimate`; says where [steps] came from.
  TextColumn get stepsSource => text().nullable()();
  RealColumn get distanceKm => real().nullable()();

  /// Distance / active duration, excluding paused time.
  RealColumn get avgSpeedKmh => real().nullable()();

  /// Total time the timer was paused.
  IntColumn get pausedSeconds => integer().withDefault(const Constant(0))();

  /// Elapsed time minus paused time.
  IntColumn get activeSeconds => integer().nullable()();

  /// `estimated` or `measured` label for the metrics above.
  TextColumn get metricsNote => text().nullable()();
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

/// A reminder the person skipped. Kept apart from [HabitLogs] so a skip can
/// never count towards a target.
class HabitSkips extends Table with SyncColumns {
  TextColumn get habitId => text()();
  TextColumn get userId => text()();
  DateTimeColumn get skippedAt => dateTime()();
  IntColumn get tzOffsetMinutes => integer().withDefault(const Constant(0))();
  TextColumn get localDate => text()();
}

class Hobbies extends Table with SyncColumns {
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get iconKey => text()();
  BoolColumn get isBuiltin => boolean().withDefault(const Constant(false))();
  TextColumn get goalPeriod => textEnum<HobbyGoalPeriod>().nullable()();
  IntColumn get goalValue => integer().nullable()();
  TextColumn get goalUnit =>
      textEnum<HobbyGoalUnit>().withDefault(const Constant('minutes'))();
  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(false))();

  /// JSON: frequency (daily|weekly|biweekly|monthly), time, weekday, etc.
  TextColumn get reminderConfig => text().withDefault(const Constant('{}'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class HobbyLogs extends Table with SyncColumns {
  TextColumn get userId => text()();
  TextColumn get hobbyId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get durationMinutes => integer()();
  IntColumn get countOrSessions => integer().withDefault(const Constant(1))();
  TextColumn get source => textEnum<HobbyLogSource>()();
  IntColumn get tzOffsetMinutes => integer().withDefault(const Constant(0))();
  TextColumn get localDate => text()();
  TextColumn get note => text().nullable()();
}

/// Private body measurements (R10). Every value is optional so a partial
/// record is fine. Never shared with groups.
class BodyMeasurements extends Table with SyncColumns {
  TextColumn get userId => text()();
  DateTimeColumn get measuredAt => dateTime()();
  IntColumn get tzOffsetMinutes => integer().withDefault(const Constant(0))();
  TextColumn get localDate => text()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get heightCm => real().nullable()();
  RealColumn get bmi => real().nullable()();
  RealColumn get waistIn => real().nullable()();
  RealColumn get hipsIn => real().nullable()();
  RealColumn get chestIn => real().nullable()();
  RealColumn get armIn => real().nullable()();
  RealColumn get thighIn => real().nullable()();
  TextColumn get notes => text().nullable()();
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

  /// `automatic` (usage stats) or `manual` (fallback entry).
  TextColumn get source =>
      textEnum<ScreenTimeSource>().withDefault(const Constant('automatic'))();

  /// The daily limit in force when the day was recorded, in minutes.
  IntColumn get targetMinutes => integer().nullable()();
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
