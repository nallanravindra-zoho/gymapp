// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('UTC'),
  );
  static const VerificationMeta _dayCutoffMinutesMeta = const VerificationMeta(
    'dayCutoffMinutes',
  );
  @override
  late final GeneratedColumn<int> dayCutoffMinutes = GeneratedColumn<int>(
    'day_cutoff_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _quietHoursStartMeta = const VerificationMeta(
    'quietHoursStart',
  );
  @override
  late final GeneratedColumn<int> quietHoursStart = GeneratedColumn<int>(
    'quiet_hours_start',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quietHoursEndMeta = const VerificationMeta(
    'quietHoursEnd',
  );
  @override
  late final GeneratedColumn<int> quietHoursEnd = GeneratedColumn<int>(
    'quiet_hours_end',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dailyReminderCapMeta = const VerificationMeta(
    'dailyReminderCap',
  );
  @override
  late final GeneratedColumn<int> dailyReminderCap = GeneratedColumn<int>(
    'daily_reminder_cap',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(6),
  );
  static const VerificationMeta _weeklyRestDaysMeta = const VerificationMeta(
    'weeklyRestDays',
  );
  @override
  late final GeneratedColumn<int> weeklyRestDays = GeneratedColumn<int>(
    'weekly_rest_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _freezeEnabledMeta = const VerificationMeta(
    'freezeEnabled',
  );
  @override
  late final GeneratedColumn<bool> freezeEnabled = GeneratedColumn<bool>(
    'freeze_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("freeze_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _freezeIntervalDaysMeta =
      const VerificationMeta('freezeIntervalDays');
  @override
  late final GeneratedColumn<int> freezeIntervalDays = GeneratedColumn<int>(
    'freeze_interval_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7),
  );
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<String> dateOfBirth = GeneratedColumn<String>(
    'date_of_birth',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _measurementCadenceMeta =
      const VerificationMeta('measurementCadence');
  @override
  late final GeneratedColumn<String> measurementCadence =
      GeneratedColumn<String>(
        'measurement_cadence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('monthly'),
      );
  static const VerificationMeta _measurementReminderEnabledMeta =
      const VerificationMeta('measurementReminderEnabled');
  @override
  late final GeneratedColumn<bool> measurementReminderEnabled =
      GeneratedColumn<bool>(
        'measurement_reminder_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("measurement_reminder_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _nextMeasurementDueMeta =
      const VerificationMeta('nextMeasurementDue');
  @override
  late final GeneratedColumn<String> nextMeasurementDue =
      GeneratedColumn<String>(
        'next_measurement_due',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _reminderSoundMeta = const VerificationMeta(
    'reminderSound',
  );
  @override
  late final GeneratedColumn<String> reminderSound = GeneratedColumn<String>(
    'reminder_sound',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _habitThresholdMeta = const VerificationMeta(
    'habitThreshold',
  );
  @override
  late final GeneratedColumn<int> habitThreshold = GeneratedColumn<int>(
    'habit_threshold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    displayName,
    avatarUrl,
    timezone,
    dayCutoffMinutes,
    quietHoursStart,
    quietHoursEnd,
    dailyReminderCap,
    weeklyRestDays,
    freezeEnabled,
    freezeIntervalDays,
    dateOfBirth,
    gender,
    heightCm,
    weightKg,
    measurementCadence,
    measurementReminderEnabled,
    nextMeasurementDue,
    reminderSound,
    habitThreshold,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('day_cutoff_minutes')) {
      context.handle(
        _dayCutoffMinutesMeta,
        dayCutoffMinutes.isAcceptableOrUnknown(
          data['day_cutoff_minutes']!,
          _dayCutoffMinutesMeta,
        ),
      );
    }
    if (data.containsKey('quiet_hours_start')) {
      context.handle(
        _quietHoursStartMeta,
        quietHoursStart.isAcceptableOrUnknown(
          data['quiet_hours_start']!,
          _quietHoursStartMeta,
        ),
      );
    }
    if (data.containsKey('quiet_hours_end')) {
      context.handle(
        _quietHoursEndMeta,
        quietHoursEnd.isAcceptableOrUnknown(
          data['quiet_hours_end']!,
          _quietHoursEndMeta,
        ),
      );
    }
    if (data.containsKey('daily_reminder_cap')) {
      context.handle(
        _dailyReminderCapMeta,
        dailyReminderCap.isAcceptableOrUnknown(
          data['daily_reminder_cap']!,
          _dailyReminderCapMeta,
        ),
      );
    }
    if (data.containsKey('weekly_rest_days')) {
      context.handle(
        _weeklyRestDaysMeta,
        weeklyRestDays.isAcceptableOrUnknown(
          data['weekly_rest_days']!,
          _weeklyRestDaysMeta,
        ),
      );
    }
    if (data.containsKey('freeze_enabled')) {
      context.handle(
        _freezeEnabledMeta,
        freezeEnabled.isAcceptableOrUnknown(
          data['freeze_enabled']!,
          _freezeEnabledMeta,
        ),
      );
    }
    if (data.containsKey('freeze_interval_days')) {
      context.handle(
        _freezeIntervalDaysMeta,
        freezeIntervalDays.isAcceptableOrUnknown(
          data['freeze_interval_days']!,
          _freezeIntervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
        _dateOfBirthMeta,
        dateOfBirth.isAcceptableOrUnknown(
          data['date_of_birth']!,
          _dateOfBirthMeta,
        ),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('measurement_cadence')) {
      context.handle(
        _measurementCadenceMeta,
        measurementCadence.isAcceptableOrUnknown(
          data['measurement_cadence']!,
          _measurementCadenceMeta,
        ),
      );
    }
    if (data.containsKey('measurement_reminder_enabled')) {
      context.handle(
        _measurementReminderEnabledMeta,
        measurementReminderEnabled.isAcceptableOrUnknown(
          data['measurement_reminder_enabled']!,
          _measurementReminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('next_measurement_due')) {
      context.handle(
        _nextMeasurementDueMeta,
        nextMeasurementDue.isAcceptableOrUnknown(
          data['next_measurement_due']!,
          _nextMeasurementDueMeta,
        ),
      );
    }
    if (data.containsKey('reminder_sound')) {
      context.handle(
        _reminderSoundMeta,
        reminderSound.isAcceptableOrUnknown(
          data['reminder_sound']!,
          _reminderSoundMeta,
        ),
      );
    }
    if (data.containsKey('habit_threshold')) {
      context.handle(
        _habitThresholdMeta,
        habitThreshold.isAcceptableOrUnknown(
          data['habit_threshold']!,
          _habitThresholdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      dayCutoffMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_cutoff_minutes'],
      )!,
      quietHoursStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quiet_hours_start'],
      ),
      quietHoursEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quiet_hours_end'],
      ),
      dailyReminderCap: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_reminder_cap'],
      )!,
      weeklyRestDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekly_rest_days'],
      )!,
      freezeEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}freeze_enabled'],
      )!,
      freezeIntervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}freeze_interval_days'],
      )!,
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_of_birth'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      measurementCadence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}measurement_cadence'],
      )!,
      measurementReminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}measurement_reminder_enabled'],
      )!,
      nextMeasurementDue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_measurement_due'],
      ),
      reminderSound: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_sound'],
      ),
      habitThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}habit_threshold'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String displayName;
  final String? avatarUrl;
  final String timezone;
  final int dayCutoffMinutes;
  final int? quietHoursStart;
  final int? quietHoursEnd;
  final int dailyReminderCap;
  final int weeklyRestDays;
  final bool freezeEnabled;
  final int freezeIntervalDays;

  /// `yyyy-MM-dd`.
  final String? dateOfBirth;
  final String? gender;
  final double? heightCm;
  final double? weightKg;

  /// `weekly`, `biweekly`, `monthly` or `bimonthly`.
  final String measurementCadence;
  final bool measurementReminderEnabled;

  /// Local date (`yyyy-MM-dd`) the next measurements are due.
  final String? nextMeasurementDue;

  /// Notification sound (a URI or key). Null means the phone's default.
  final String? reminderSound;

  /// How many active habits must meet their target in a day for the Healthy
  /// Habits icon in the Week calendar (R8).
  final int habitThreshold;
  const User({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.displayName,
    this.avatarUrl,
    required this.timezone,
    required this.dayCutoffMinutes,
    this.quietHoursStart,
    this.quietHoursEnd,
    required this.dailyReminderCap,
    required this.weeklyRestDays,
    required this.freezeEnabled,
    required this.freezeIntervalDays,
    this.dateOfBirth,
    this.gender,
    this.heightCm,
    this.weightKg,
    required this.measurementCadence,
    required this.measurementReminderEnabled,
    this.nextMeasurementDue,
    this.reminderSound,
    required this.habitThreshold,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['timezone'] = Variable<String>(timezone);
    map['day_cutoff_minutes'] = Variable<int>(dayCutoffMinutes);
    if (!nullToAbsent || quietHoursStart != null) {
      map['quiet_hours_start'] = Variable<int>(quietHoursStart);
    }
    if (!nullToAbsent || quietHoursEnd != null) {
      map['quiet_hours_end'] = Variable<int>(quietHoursEnd);
    }
    map['daily_reminder_cap'] = Variable<int>(dailyReminderCap);
    map['weekly_rest_days'] = Variable<int>(weeklyRestDays);
    map['freeze_enabled'] = Variable<bool>(freezeEnabled);
    map['freeze_interval_days'] = Variable<int>(freezeIntervalDays);
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<String>(dateOfBirth);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    map['measurement_cadence'] = Variable<String>(measurementCadence);
    map['measurement_reminder_enabled'] = Variable<bool>(
      measurementReminderEnabled,
    );
    if (!nullToAbsent || nextMeasurementDue != null) {
      map['next_measurement_due'] = Variable<String>(nextMeasurementDue);
    }
    if (!nullToAbsent || reminderSound != null) {
      map['reminder_sound'] = Variable<String>(reminderSound);
    }
    map['habit_threshold'] = Variable<int>(habitThreshold);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      displayName: Value(displayName),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      timezone: Value(timezone),
      dayCutoffMinutes: Value(dayCutoffMinutes),
      quietHoursStart: quietHoursStart == null && nullToAbsent
          ? const Value.absent()
          : Value(quietHoursStart),
      quietHoursEnd: quietHoursEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(quietHoursEnd),
      dailyReminderCap: Value(dailyReminderCap),
      weeklyRestDays: Value(weeklyRestDays),
      freezeEnabled: Value(freezeEnabled),
      freezeIntervalDays: Value(freezeIntervalDays),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      measurementCadence: Value(measurementCadence),
      measurementReminderEnabled: Value(measurementReminderEnabled),
      nextMeasurementDue: nextMeasurementDue == null && nullToAbsent
          ? const Value.absent()
          : Value(nextMeasurementDue),
      reminderSound: reminderSound == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderSound),
      habitThreshold: Value(habitThreshold),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      displayName: serializer.fromJson<String>(json['displayName']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      timezone: serializer.fromJson<String>(json['timezone']),
      dayCutoffMinutes: serializer.fromJson<int>(json['dayCutoffMinutes']),
      quietHoursStart: serializer.fromJson<int?>(json['quietHoursStart']),
      quietHoursEnd: serializer.fromJson<int?>(json['quietHoursEnd']),
      dailyReminderCap: serializer.fromJson<int>(json['dailyReminderCap']),
      weeklyRestDays: serializer.fromJson<int>(json['weeklyRestDays']),
      freezeEnabled: serializer.fromJson<bool>(json['freezeEnabled']),
      freezeIntervalDays: serializer.fromJson<int>(json['freezeIntervalDays']),
      dateOfBirth: serializer.fromJson<String?>(json['dateOfBirth']),
      gender: serializer.fromJson<String?>(json['gender']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      measurementCadence: serializer.fromJson<String>(
        json['measurementCadence'],
      ),
      measurementReminderEnabled: serializer.fromJson<bool>(
        json['measurementReminderEnabled'],
      ),
      nextMeasurementDue: serializer.fromJson<String?>(
        json['nextMeasurementDue'],
      ),
      reminderSound: serializer.fromJson<String?>(json['reminderSound']),
      habitThreshold: serializer.fromJson<int>(json['habitThreshold']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'displayName': serializer.toJson<String>(displayName),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'timezone': serializer.toJson<String>(timezone),
      'dayCutoffMinutes': serializer.toJson<int>(dayCutoffMinutes),
      'quietHoursStart': serializer.toJson<int?>(quietHoursStart),
      'quietHoursEnd': serializer.toJson<int?>(quietHoursEnd),
      'dailyReminderCap': serializer.toJson<int>(dailyReminderCap),
      'weeklyRestDays': serializer.toJson<int>(weeklyRestDays),
      'freezeEnabled': serializer.toJson<bool>(freezeEnabled),
      'freezeIntervalDays': serializer.toJson<int>(freezeIntervalDays),
      'dateOfBirth': serializer.toJson<String?>(dateOfBirth),
      'gender': serializer.toJson<String?>(gender),
      'heightCm': serializer.toJson<double?>(heightCm),
      'weightKg': serializer.toJson<double?>(weightKg),
      'measurementCadence': serializer.toJson<String>(measurementCadence),
      'measurementReminderEnabled': serializer.toJson<bool>(
        measurementReminderEnabled,
      ),
      'nextMeasurementDue': serializer.toJson<String?>(nextMeasurementDue),
      'reminderSound': serializer.toJson<String?>(reminderSound),
      'habitThreshold': serializer.toJson<int>(habitThreshold),
    };
  }

  User copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? displayName,
    Value<String?> avatarUrl = const Value.absent(),
    String? timezone,
    int? dayCutoffMinutes,
    Value<int?> quietHoursStart = const Value.absent(),
    Value<int?> quietHoursEnd = const Value.absent(),
    int? dailyReminderCap,
    int? weeklyRestDays,
    bool? freezeEnabled,
    int? freezeIntervalDays,
    Value<String?> dateOfBirth = const Value.absent(),
    Value<String?> gender = const Value.absent(),
    Value<double?> heightCm = const Value.absent(),
    Value<double?> weightKg = const Value.absent(),
    String? measurementCadence,
    bool? measurementReminderEnabled,
    Value<String?> nextMeasurementDue = const Value.absent(),
    Value<String?> reminderSound = const Value.absent(),
    int? habitThreshold,
  }) => User(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    displayName: displayName ?? this.displayName,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    timezone: timezone ?? this.timezone,
    dayCutoffMinutes: dayCutoffMinutes ?? this.dayCutoffMinutes,
    quietHoursStart: quietHoursStart.present
        ? quietHoursStart.value
        : this.quietHoursStart,
    quietHoursEnd: quietHoursEnd.present
        ? quietHoursEnd.value
        : this.quietHoursEnd,
    dailyReminderCap: dailyReminderCap ?? this.dailyReminderCap,
    weeklyRestDays: weeklyRestDays ?? this.weeklyRestDays,
    freezeEnabled: freezeEnabled ?? this.freezeEnabled,
    freezeIntervalDays: freezeIntervalDays ?? this.freezeIntervalDays,
    dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
    gender: gender.present ? gender.value : this.gender,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    measurementCadence: measurementCadence ?? this.measurementCadence,
    measurementReminderEnabled:
        measurementReminderEnabled ?? this.measurementReminderEnabled,
    nextMeasurementDue: nextMeasurementDue.present
        ? nextMeasurementDue.value
        : this.nextMeasurementDue,
    reminderSound: reminderSound.present
        ? reminderSound.value
        : this.reminderSound,
    habitThreshold: habitThreshold ?? this.habitThreshold,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      dayCutoffMinutes: data.dayCutoffMinutes.present
          ? data.dayCutoffMinutes.value
          : this.dayCutoffMinutes,
      quietHoursStart: data.quietHoursStart.present
          ? data.quietHoursStart.value
          : this.quietHoursStart,
      quietHoursEnd: data.quietHoursEnd.present
          ? data.quietHoursEnd.value
          : this.quietHoursEnd,
      dailyReminderCap: data.dailyReminderCap.present
          ? data.dailyReminderCap.value
          : this.dailyReminderCap,
      weeklyRestDays: data.weeklyRestDays.present
          ? data.weeklyRestDays.value
          : this.weeklyRestDays,
      freezeEnabled: data.freezeEnabled.present
          ? data.freezeEnabled.value
          : this.freezeEnabled,
      freezeIntervalDays: data.freezeIntervalDays.present
          ? data.freezeIntervalDays.value
          : this.freezeIntervalDays,
      dateOfBirth: data.dateOfBirth.present
          ? data.dateOfBirth.value
          : this.dateOfBirth,
      gender: data.gender.present ? data.gender.value : this.gender,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      measurementCadence: data.measurementCadence.present
          ? data.measurementCadence.value
          : this.measurementCadence,
      measurementReminderEnabled: data.measurementReminderEnabled.present
          ? data.measurementReminderEnabled.value
          : this.measurementReminderEnabled,
      nextMeasurementDue: data.nextMeasurementDue.present
          ? data.nextMeasurementDue.value
          : this.nextMeasurementDue,
      reminderSound: data.reminderSound.present
          ? data.reminderSound.value
          : this.reminderSound,
      habitThreshold: data.habitThreshold.present
          ? data.habitThreshold.value
          : this.habitThreshold,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('timezone: $timezone, ')
          ..write('dayCutoffMinutes: $dayCutoffMinutes, ')
          ..write('quietHoursStart: $quietHoursStart, ')
          ..write('quietHoursEnd: $quietHoursEnd, ')
          ..write('dailyReminderCap: $dailyReminderCap, ')
          ..write('weeklyRestDays: $weeklyRestDays, ')
          ..write('freezeEnabled: $freezeEnabled, ')
          ..write('freezeIntervalDays: $freezeIntervalDays, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('gender: $gender, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('measurementCadence: $measurementCadence, ')
          ..write('measurementReminderEnabled: $measurementReminderEnabled, ')
          ..write('nextMeasurementDue: $nextMeasurementDue, ')
          ..write('reminderSound: $reminderSound, ')
          ..write('habitThreshold: $habitThreshold')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    updatedAt,
    deletedAt,
    displayName,
    avatarUrl,
    timezone,
    dayCutoffMinutes,
    quietHoursStart,
    quietHoursEnd,
    dailyReminderCap,
    weeklyRestDays,
    freezeEnabled,
    freezeIntervalDays,
    dateOfBirth,
    gender,
    heightCm,
    weightKg,
    measurementCadence,
    measurementReminderEnabled,
    nextMeasurementDue,
    reminderSound,
    habitThreshold,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.displayName == this.displayName &&
          other.avatarUrl == this.avatarUrl &&
          other.timezone == this.timezone &&
          other.dayCutoffMinutes == this.dayCutoffMinutes &&
          other.quietHoursStart == this.quietHoursStart &&
          other.quietHoursEnd == this.quietHoursEnd &&
          other.dailyReminderCap == this.dailyReminderCap &&
          other.weeklyRestDays == this.weeklyRestDays &&
          other.freezeEnabled == this.freezeEnabled &&
          other.freezeIntervalDays == this.freezeIntervalDays &&
          other.dateOfBirth == this.dateOfBirth &&
          other.gender == this.gender &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.measurementCadence == this.measurementCadence &&
          other.measurementReminderEnabled == this.measurementReminderEnabled &&
          other.nextMeasurementDue == this.nextMeasurementDue &&
          other.reminderSound == this.reminderSound &&
          other.habitThreshold == this.habitThreshold);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> displayName;
  final Value<String?> avatarUrl;
  final Value<String> timezone;
  final Value<int> dayCutoffMinutes;
  final Value<int?> quietHoursStart;
  final Value<int?> quietHoursEnd;
  final Value<int> dailyReminderCap;
  final Value<int> weeklyRestDays;
  final Value<bool> freezeEnabled;
  final Value<int> freezeIntervalDays;
  final Value<String?> dateOfBirth;
  final Value<String?> gender;
  final Value<double?> heightCm;
  final Value<double?> weightKg;
  final Value<String> measurementCadence;
  final Value<bool> measurementReminderEnabled;
  final Value<String?> nextMeasurementDue;
  final Value<String?> reminderSound;
  final Value<int> habitThreshold;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.timezone = const Value.absent(),
    this.dayCutoffMinutes = const Value.absent(),
    this.quietHoursStart = const Value.absent(),
    this.quietHoursEnd = const Value.absent(),
    this.dailyReminderCap = const Value.absent(),
    this.weeklyRestDays = const Value.absent(),
    this.freezeEnabled = const Value.absent(),
    this.freezeIntervalDays = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.gender = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.measurementCadence = const Value.absent(),
    this.measurementReminderEnabled = const Value.absent(),
    this.nextMeasurementDue = const Value.absent(),
    this.reminderSound = const Value.absent(),
    this.habitThreshold = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.timezone = const Value.absent(),
    this.dayCutoffMinutes = const Value.absent(),
    this.quietHoursStart = const Value.absent(),
    this.quietHoursEnd = const Value.absent(),
    this.dailyReminderCap = const Value.absent(),
    this.weeklyRestDays = const Value.absent(),
    this.freezeEnabled = const Value.absent(),
    this.freezeIntervalDays = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.gender = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.measurementCadence = const Value.absent(),
    this.measurementReminderEnabled = const Value.absent(),
    this.nextMeasurementDue = const Value.absent(),
    this.reminderSound = const Value.absent(),
    this.habitThreshold = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? displayName,
    Expression<String>? avatarUrl,
    Expression<String>? timezone,
    Expression<int>? dayCutoffMinutes,
    Expression<int>? quietHoursStart,
    Expression<int>? quietHoursEnd,
    Expression<int>? dailyReminderCap,
    Expression<int>? weeklyRestDays,
    Expression<bool>? freezeEnabled,
    Expression<int>? freezeIntervalDays,
    Expression<String>? dateOfBirth,
    Expression<String>? gender,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<String>? measurementCadence,
    Expression<bool>? measurementReminderEnabled,
    Expression<String>? nextMeasurementDue,
    Expression<String>? reminderSound,
    Expression<int>? habitThreshold,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (displayName != null) 'display_name': displayName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (timezone != null) 'timezone': timezone,
      if (dayCutoffMinutes != null) 'day_cutoff_minutes': dayCutoffMinutes,
      if (quietHoursStart != null) 'quiet_hours_start': quietHoursStart,
      if (quietHoursEnd != null) 'quiet_hours_end': quietHoursEnd,
      if (dailyReminderCap != null) 'daily_reminder_cap': dailyReminderCap,
      if (weeklyRestDays != null) 'weekly_rest_days': weeklyRestDays,
      if (freezeEnabled != null) 'freeze_enabled': freezeEnabled,
      if (freezeIntervalDays != null)
        'freeze_interval_days': freezeIntervalDays,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (measurementCadence != null) 'measurement_cadence': measurementCadence,
      if (measurementReminderEnabled != null)
        'measurement_reminder_enabled': measurementReminderEnabled,
      if (nextMeasurementDue != null)
        'next_measurement_due': nextMeasurementDue,
      if (reminderSound != null) 'reminder_sound': reminderSound,
      if (habitThreshold != null) 'habit_threshold': habitThreshold,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? displayName,
    Value<String?>? avatarUrl,
    Value<String>? timezone,
    Value<int>? dayCutoffMinutes,
    Value<int?>? quietHoursStart,
    Value<int?>? quietHoursEnd,
    Value<int>? dailyReminderCap,
    Value<int>? weeklyRestDays,
    Value<bool>? freezeEnabled,
    Value<int>? freezeIntervalDays,
    Value<String?>? dateOfBirth,
    Value<String?>? gender,
    Value<double?>? heightCm,
    Value<double?>? weightKg,
    Value<String>? measurementCadence,
    Value<bool>? measurementReminderEnabled,
    Value<String?>? nextMeasurementDue,
    Value<String?>? reminderSound,
    Value<int>? habitThreshold,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      timezone: timezone ?? this.timezone,
      dayCutoffMinutes: dayCutoffMinutes ?? this.dayCutoffMinutes,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      dailyReminderCap: dailyReminderCap ?? this.dailyReminderCap,
      weeklyRestDays: weeklyRestDays ?? this.weeklyRestDays,
      freezeEnabled: freezeEnabled ?? this.freezeEnabled,
      freezeIntervalDays: freezeIntervalDays ?? this.freezeIntervalDays,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      measurementCadence: measurementCadence ?? this.measurementCadence,
      measurementReminderEnabled:
          measurementReminderEnabled ?? this.measurementReminderEnabled,
      nextMeasurementDue: nextMeasurementDue ?? this.nextMeasurementDue,
      reminderSound: reminderSound ?? this.reminderSound,
      habitThreshold: habitThreshold ?? this.habitThreshold,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (dayCutoffMinutes.present) {
      map['day_cutoff_minutes'] = Variable<int>(dayCutoffMinutes.value);
    }
    if (quietHoursStart.present) {
      map['quiet_hours_start'] = Variable<int>(quietHoursStart.value);
    }
    if (quietHoursEnd.present) {
      map['quiet_hours_end'] = Variable<int>(quietHoursEnd.value);
    }
    if (dailyReminderCap.present) {
      map['daily_reminder_cap'] = Variable<int>(dailyReminderCap.value);
    }
    if (weeklyRestDays.present) {
      map['weekly_rest_days'] = Variable<int>(weeklyRestDays.value);
    }
    if (freezeEnabled.present) {
      map['freeze_enabled'] = Variable<bool>(freezeEnabled.value);
    }
    if (freezeIntervalDays.present) {
      map['freeze_interval_days'] = Variable<int>(freezeIntervalDays.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<String>(dateOfBirth.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (measurementCadence.present) {
      map['measurement_cadence'] = Variable<String>(measurementCadence.value);
    }
    if (measurementReminderEnabled.present) {
      map['measurement_reminder_enabled'] = Variable<bool>(
        measurementReminderEnabled.value,
      );
    }
    if (nextMeasurementDue.present) {
      map['next_measurement_due'] = Variable<String>(nextMeasurementDue.value);
    }
    if (reminderSound.present) {
      map['reminder_sound'] = Variable<String>(reminderSound.value);
    }
    if (habitThreshold.present) {
      map['habit_threshold'] = Variable<int>(habitThreshold.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('timezone: $timezone, ')
          ..write('dayCutoffMinutes: $dayCutoffMinutes, ')
          ..write('quietHoursStart: $quietHoursStart, ')
          ..write('quietHoursEnd: $quietHoursEnd, ')
          ..write('dailyReminderCap: $dailyReminderCap, ')
          ..write('weeklyRestDays: $weeklyRestDays, ')
          ..write('freezeEnabled: $freezeEnabled, ')
          ..write('freezeIntervalDays: $freezeIntervalDays, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('gender: $gender, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('measurementCadence: $measurementCadence, ')
          ..write('measurementReminderEnabled: $measurementReminderEnabled, ')
          ..write('nextMeasurementDue: $nextMeasurementDue, ')
          ..write('reminderSound: $reminderSound, ')
          ..write('habitThreshold: $habitThreshold, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutTypesTable extends WorkoutTypes
    with TableInfo<$WorkoutTypesTable, WorkoutType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isBuiltinMeta = const VerificationMeta(
    'isBuiltin',
  );
  @override
  late final GeneratedColumn<bool> isBuiltin = GeneratedColumn<bool>(
    'is_builtin',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_builtin" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    name,
    iconKey,
    isBuiltin,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_iconKeyMeta);
    }
    if (data.containsKey('is_builtin')) {
      context.handle(
        _isBuiltinMeta,
        isBuiltin.isAcceptableOrUnknown(data['is_builtin']!, _isBuiltinMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      isBuiltin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_builtin'],
      )!,
    );
  }

  @override
  $WorkoutTypesTable createAlias(String alias) {
    return $WorkoutTypesTable(attachedDatabase, alias);
  }
}

class WorkoutType extends DataClass implements Insertable<WorkoutType> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// Null for built-in types.
  final String? userId;
  final String name;
  final String iconKey;
  final bool isBuiltin;
  const WorkoutType({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.userId,
    required this.name,
    required this.iconKey,
    required this.isBuiltin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['name'] = Variable<String>(name);
    map['icon_key'] = Variable<String>(iconKey);
    map['is_builtin'] = Variable<bool>(isBuiltin);
    return map;
  }

  WorkoutTypesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutTypesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      name: Value(name),
      iconKey: Value(iconKey),
      isBuiltin: Value(isBuiltin),
    );
  }

  factory WorkoutType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutType(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      userId: serializer.fromJson<String?>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      isBuiltin: serializer.fromJson<bool>(json['isBuiltin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'userId': serializer.toJson<String?>(userId),
      'name': serializer.toJson<String>(name),
      'iconKey': serializer.toJson<String>(iconKey),
      'isBuiltin': serializer.toJson<bool>(isBuiltin),
    };
  }

  WorkoutType copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> userId = const Value.absent(),
    String? name,
    String? iconKey,
    bool? isBuiltin,
  }) => WorkoutType(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    userId: userId.present ? userId.value : this.userId,
    name: name ?? this.name,
    iconKey: iconKey ?? this.iconKey,
    isBuiltin: isBuiltin ?? this.isBuiltin,
  );
  WorkoutType copyWithCompanion(WorkoutTypesCompanion data) {
    return WorkoutType(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      isBuiltin: data.isBuiltin.present ? data.isBuiltin.value : this.isBuiltin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutType(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('isBuiltin: $isBuiltin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    name,
    iconKey,
    isBuiltin,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutType &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.iconKey == this.iconKey &&
          other.isBuiltin == this.isBuiltin);
}

class WorkoutTypesCompanion extends UpdateCompanion<WorkoutType> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> userId;
  final Value<String> name;
  final Value<String> iconKey;
  final Value<bool> isBuiltin;
  final Value<int> rowid;
  const WorkoutTypesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutTypesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.userId = const Value.absent(),
    required String name,
    required String iconKey,
    this.isBuiltin = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       iconKey = Value(iconKey);
  static Insertable<WorkoutType> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? iconKey,
    Expression<bool>? isBuiltin,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (iconKey != null) 'icon_key': iconKey,
      if (isBuiltin != null) 'is_builtin': isBuiltin,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutTypesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? userId,
    Value<String>? name,
    Value<String>? iconKey,
    Value<bool>? isBuiltin,
    Value<int>? rowid,
  }) {
    return WorkoutTypesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      isBuiltin: isBuiltin ?? this.isBuiltin,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (isBuiltin.present) {
      map['is_builtin'] = Variable<bool>(isBuiltin.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutTypesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutsTable extends Workouts with TableInfo<$WorkoutsTable, Workout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workoutTypeIdMeta = const VerificationMeta(
    'workoutTypeId',
  );
  @override
  late final GeneratedColumn<String> workoutTypeId = GeneratedColumn<String>(
    'workout_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WorkoutIntensity?, String>
  intensity = GeneratedColumn<String>(
    'intensity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<WorkoutIntensity?>($WorkoutsTable.$converterintensityn);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WorkoutSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<WorkoutSource>($WorkoutsTable.$convertersource);
  static const VerificationMeta _tzOffsetMinutesMeta = const VerificationMeta(
    'tzOffsetMinutes',
  );
  @override
  late final GeneratedColumn<int> tzOffsetMinutes = GeneratedColumn<int>(
    'tz_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesEstimateMeta = const VerificationMeta(
    'caloriesEstimate',
  );
  @override
  late final GeneratedColumn<int> caloriesEstimate = GeneratedColumn<int>(
    'calories_estimate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<int> steps = GeneratedColumn<int>(
    'steps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stepsSourceMeta = const VerificationMeta(
    'stepsSource',
  );
  @override
  late final GeneratedColumn<String> stepsSource = GeneratedColumn<String>(
    'steps_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceKmMeta = const VerificationMeta(
    'distanceKm',
  );
  @override
  late final GeneratedColumn<double> distanceKm = GeneratedColumn<double>(
    'distance_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avgSpeedKmhMeta = const VerificationMeta(
    'avgSpeedKmh',
  );
  @override
  late final GeneratedColumn<double> avgSpeedKmh = GeneratedColumn<double>(
    'avg_speed_kmh',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pausedSecondsMeta = const VerificationMeta(
    'pausedSeconds',
  );
  @override
  late final GeneratedColumn<int> pausedSeconds = GeneratedColumn<int>(
    'paused_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _activeSecondsMeta = const VerificationMeta(
    'activeSeconds',
  );
  @override
  late final GeneratedColumn<int> activeSeconds = GeneratedColumn<int>(
    'active_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metricsNoteMeta = const VerificationMeta(
    'metricsNote',
  );
  @override
  late final GeneratedColumn<String> metricsNote = GeneratedColumn<String>(
    'metrics_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    workoutTypeId,
    startedAt,
    endedAt,
    durationMinutes,
    intensity,
    note,
    source,
    tzOffsetMinutes,
    localDate,
    caloriesEstimate,
    steps,
    stepsSource,
    distanceKm,
    avgSpeedKmh,
    pausedSeconds,
    activeSeconds,
    metricsNote,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Workout> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('workout_type_id')) {
      context.handle(
        _workoutTypeIdMeta,
        workoutTypeId.isAcceptableOrUnknown(
          data['workout_type_id']!,
          _workoutTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutTypeIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('tz_offset_minutes')) {
      context.handle(
        _tzOffsetMinutesMeta,
        tzOffsetMinutes.isAcceptableOrUnknown(
          data['tz_offset_minutes']!,
          _tzOffsetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('calories_estimate')) {
      context.handle(
        _caloriesEstimateMeta,
        caloriesEstimate.isAcceptableOrUnknown(
          data['calories_estimate']!,
          _caloriesEstimateMeta,
        ),
      );
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    }
    if (data.containsKey('steps_source')) {
      context.handle(
        _stepsSourceMeta,
        stepsSource.isAcceptableOrUnknown(
          data['steps_source']!,
          _stepsSourceMeta,
        ),
      );
    }
    if (data.containsKey('distance_km')) {
      context.handle(
        _distanceKmMeta,
        distanceKm.isAcceptableOrUnknown(data['distance_km']!, _distanceKmMeta),
      );
    }
    if (data.containsKey('avg_speed_kmh')) {
      context.handle(
        _avgSpeedKmhMeta,
        avgSpeedKmh.isAcceptableOrUnknown(
          data['avg_speed_kmh']!,
          _avgSpeedKmhMeta,
        ),
      );
    }
    if (data.containsKey('paused_seconds')) {
      context.handle(
        _pausedSecondsMeta,
        pausedSeconds.isAcceptableOrUnknown(
          data['paused_seconds']!,
          _pausedSecondsMeta,
        ),
      );
    }
    if (data.containsKey('active_seconds')) {
      context.handle(
        _activeSecondsMeta,
        activeSeconds.isAcceptableOrUnknown(
          data['active_seconds']!,
          _activeSecondsMeta,
        ),
      );
    }
    if (data.containsKey('metrics_note')) {
      context.handle(
        _metricsNoteMeta,
        metricsNote.isAcceptableOrUnknown(
          data['metrics_note']!,
          _metricsNoteMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Workout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workout(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      workoutTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_type_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      intensity: $WorkoutsTable.$converterintensityn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}intensity'],
        ),
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      source: $WorkoutsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      tzOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tz_offset_minutes'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      caloriesEstimate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories_estimate'],
      ),
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}steps'],
      ),
      stepsSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}steps_source'],
      ),
      distanceKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_km'],
      ),
      avgSpeedKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_speed_kmh'],
      ),
      pausedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paused_seconds'],
      )!,
      activeSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_seconds'],
      ),
      metricsNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metrics_note'],
      ),
    );
  }

  @override
  $WorkoutsTable createAlias(String alias) {
    return $WorkoutsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<WorkoutIntensity, String, String>
  $converterintensity = const EnumNameConverter<WorkoutIntensity>(
    WorkoutIntensity.values,
  );
  static JsonTypeConverter2<WorkoutIntensity?, String?, String?>
  $converterintensityn = JsonTypeConverter2.asNullable($converterintensity);
  static JsonTypeConverter2<WorkoutSource, String, String> $convertersource =
      const EnumNameConverter<WorkoutSource>(WorkoutSource.values);
}

class Workout extends DataClass implements Insertable<Workout> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String userId;
  final String workoutTypeId;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationMinutes;
  final WorkoutIntensity? intensity;
  final String? note;
  final WorkoutSource source;

  /// UTC offset at start time, so the local day can be re-derived.
  final int tzOffsetMinutes;
  final String localDate;

  /// Estimated, never measured, energy use. Null when inputs were missing.
  final int? caloriesEstimate;
  final int? steps;

  /// `sensor` or `estimate`; says where [steps] came from.
  final String? stepsSource;
  final double? distanceKm;

  /// Distance / active duration, excluding paused time.
  final double? avgSpeedKmh;

  /// Total time the timer was paused.
  final int pausedSeconds;

  /// Elapsed time minus paused time.
  final int? activeSeconds;

  /// `estimated` or `measured` label for the metrics above.
  final String? metricsNote;
  const Workout({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.userId,
    required this.workoutTypeId,
    required this.startedAt,
    required this.endedAt,
    required this.durationMinutes,
    this.intensity,
    this.note,
    required this.source,
    required this.tzOffsetMinutes,
    required this.localDate,
    this.caloriesEstimate,
    this.steps,
    this.stepsSource,
    this.distanceKm,
    this.avgSpeedKmh,
    required this.pausedSeconds,
    this.activeSeconds,
    this.metricsNote,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['user_id'] = Variable<String>(userId);
    map['workout_type_id'] = Variable<String>(workoutTypeId);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['ended_at'] = Variable<DateTime>(endedAt);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    if (!nullToAbsent || intensity != null) {
      map['intensity'] = Variable<String>(
        $WorkoutsTable.$converterintensityn.toSql(intensity),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    {
      map['source'] = Variable<String>(
        $WorkoutsTable.$convertersource.toSql(source),
      );
    }
    map['tz_offset_minutes'] = Variable<int>(tzOffsetMinutes);
    map['local_date'] = Variable<String>(localDate);
    if (!nullToAbsent || caloriesEstimate != null) {
      map['calories_estimate'] = Variable<int>(caloriesEstimate);
    }
    if (!nullToAbsent || steps != null) {
      map['steps'] = Variable<int>(steps);
    }
    if (!nullToAbsent || stepsSource != null) {
      map['steps_source'] = Variable<String>(stepsSource);
    }
    if (!nullToAbsent || distanceKm != null) {
      map['distance_km'] = Variable<double>(distanceKm);
    }
    if (!nullToAbsent || avgSpeedKmh != null) {
      map['avg_speed_kmh'] = Variable<double>(avgSpeedKmh);
    }
    map['paused_seconds'] = Variable<int>(pausedSeconds);
    if (!nullToAbsent || activeSeconds != null) {
      map['active_seconds'] = Variable<int>(activeSeconds);
    }
    if (!nullToAbsent || metricsNote != null) {
      map['metrics_note'] = Variable<String>(metricsNote);
    }
    return map;
  }

  WorkoutsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      userId: Value(userId),
      workoutTypeId: Value(workoutTypeId),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
      durationMinutes: Value(durationMinutes),
      intensity: intensity == null && nullToAbsent
          ? const Value.absent()
          : Value(intensity),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      source: Value(source),
      tzOffsetMinutes: Value(tzOffsetMinutes),
      localDate: Value(localDate),
      caloriesEstimate: caloriesEstimate == null && nullToAbsent
          ? const Value.absent()
          : Value(caloriesEstimate),
      steps: steps == null && nullToAbsent
          ? const Value.absent()
          : Value(steps),
      stepsSource: stepsSource == null && nullToAbsent
          ? const Value.absent()
          : Value(stepsSource),
      distanceKm: distanceKm == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceKm),
      avgSpeedKmh: avgSpeedKmh == null && nullToAbsent
          ? const Value.absent()
          : Value(avgSpeedKmh),
      pausedSeconds: Value(pausedSeconds),
      activeSeconds: activeSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(activeSeconds),
      metricsNote: metricsNote == null && nullToAbsent
          ? const Value.absent()
          : Value(metricsNote),
    );
  }

  factory Workout.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workout(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      userId: serializer.fromJson<String>(json['userId']),
      workoutTypeId: serializer.fromJson<String>(json['workoutTypeId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime>(json['endedAt']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      intensity: $WorkoutsTable.$converterintensityn.fromJson(
        serializer.fromJson<String?>(json['intensity']),
      ),
      note: serializer.fromJson<String?>(json['note']),
      source: $WorkoutsTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      tzOffsetMinutes: serializer.fromJson<int>(json['tzOffsetMinutes']),
      localDate: serializer.fromJson<String>(json['localDate']),
      caloriesEstimate: serializer.fromJson<int?>(json['caloriesEstimate']),
      steps: serializer.fromJson<int?>(json['steps']),
      stepsSource: serializer.fromJson<String?>(json['stepsSource']),
      distanceKm: serializer.fromJson<double?>(json['distanceKm']),
      avgSpeedKmh: serializer.fromJson<double?>(json['avgSpeedKmh']),
      pausedSeconds: serializer.fromJson<int>(json['pausedSeconds']),
      activeSeconds: serializer.fromJson<int?>(json['activeSeconds']),
      metricsNote: serializer.fromJson<String?>(json['metricsNote']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'userId': serializer.toJson<String>(userId),
      'workoutTypeId': serializer.toJson<String>(workoutTypeId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime>(endedAt),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'intensity': serializer.toJson<String?>(
        $WorkoutsTable.$converterintensityn.toJson(intensity),
      ),
      'note': serializer.toJson<String?>(note),
      'source': serializer.toJson<String>(
        $WorkoutsTable.$convertersource.toJson(source),
      ),
      'tzOffsetMinutes': serializer.toJson<int>(tzOffsetMinutes),
      'localDate': serializer.toJson<String>(localDate),
      'caloriesEstimate': serializer.toJson<int?>(caloriesEstimate),
      'steps': serializer.toJson<int?>(steps),
      'stepsSource': serializer.toJson<String?>(stepsSource),
      'distanceKm': serializer.toJson<double?>(distanceKm),
      'avgSpeedKmh': serializer.toJson<double?>(avgSpeedKmh),
      'pausedSeconds': serializer.toJson<int>(pausedSeconds),
      'activeSeconds': serializer.toJson<int?>(activeSeconds),
      'metricsNote': serializer.toJson<String?>(metricsNote),
    };
  }

  Workout copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? userId,
    String? workoutTypeId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationMinutes,
    Value<WorkoutIntensity?> intensity = const Value.absent(),
    Value<String?> note = const Value.absent(),
    WorkoutSource? source,
    int? tzOffsetMinutes,
    String? localDate,
    Value<int?> caloriesEstimate = const Value.absent(),
    Value<int?> steps = const Value.absent(),
    Value<String?> stepsSource = const Value.absent(),
    Value<double?> distanceKm = const Value.absent(),
    Value<double?> avgSpeedKmh = const Value.absent(),
    int? pausedSeconds,
    Value<int?> activeSeconds = const Value.absent(),
    Value<String?> metricsNote = const Value.absent(),
  }) => Workout(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    userId: userId ?? this.userId,
    workoutTypeId: workoutTypeId ?? this.workoutTypeId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    intensity: intensity.present ? intensity.value : this.intensity,
    note: note.present ? note.value : this.note,
    source: source ?? this.source,
    tzOffsetMinutes: tzOffsetMinutes ?? this.tzOffsetMinutes,
    localDate: localDate ?? this.localDate,
    caloriesEstimate: caloriesEstimate.present
        ? caloriesEstimate.value
        : this.caloriesEstimate,
    steps: steps.present ? steps.value : this.steps,
    stepsSource: stepsSource.present ? stepsSource.value : this.stepsSource,
    distanceKm: distanceKm.present ? distanceKm.value : this.distanceKm,
    avgSpeedKmh: avgSpeedKmh.present ? avgSpeedKmh.value : this.avgSpeedKmh,
    pausedSeconds: pausedSeconds ?? this.pausedSeconds,
    activeSeconds: activeSeconds.present
        ? activeSeconds.value
        : this.activeSeconds,
    metricsNote: metricsNote.present ? metricsNote.value : this.metricsNote,
  );
  Workout copyWithCompanion(WorkoutsCompanion data) {
    return Workout(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      userId: data.userId.present ? data.userId.value : this.userId,
      workoutTypeId: data.workoutTypeId.present
          ? data.workoutTypeId.value
          : this.workoutTypeId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      intensity: data.intensity.present ? data.intensity.value : this.intensity,
      note: data.note.present ? data.note.value : this.note,
      source: data.source.present ? data.source.value : this.source,
      tzOffsetMinutes: data.tzOffsetMinutes.present
          ? data.tzOffsetMinutes.value
          : this.tzOffsetMinutes,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      caloriesEstimate: data.caloriesEstimate.present
          ? data.caloriesEstimate.value
          : this.caloriesEstimate,
      steps: data.steps.present ? data.steps.value : this.steps,
      stepsSource: data.stepsSource.present
          ? data.stepsSource.value
          : this.stepsSource,
      distanceKm: data.distanceKm.present
          ? data.distanceKm.value
          : this.distanceKm,
      avgSpeedKmh: data.avgSpeedKmh.present
          ? data.avgSpeedKmh.value
          : this.avgSpeedKmh,
      pausedSeconds: data.pausedSeconds.present
          ? data.pausedSeconds.value
          : this.pausedSeconds,
      activeSeconds: data.activeSeconds.present
          ? data.activeSeconds.value
          : this.activeSeconds,
      metricsNote: data.metricsNote.present
          ? data.metricsNote.value
          : this.metricsNote,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Workout(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('workoutTypeId: $workoutTypeId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('intensity: $intensity, ')
          ..write('note: $note, ')
          ..write('source: $source, ')
          ..write('tzOffsetMinutes: $tzOffsetMinutes, ')
          ..write('localDate: $localDate, ')
          ..write('caloriesEstimate: $caloriesEstimate, ')
          ..write('steps: $steps, ')
          ..write('stepsSource: $stepsSource, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('avgSpeedKmh: $avgSpeedKmh, ')
          ..write('pausedSeconds: $pausedSeconds, ')
          ..write('activeSeconds: $activeSeconds, ')
          ..write('metricsNote: $metricsNote')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    workoutTypeId,
    startedAt,
    endedAt,
    durationMinutes,
    intensity,
    note,
    source,
    tzOffsetMinutes,
    localDate,
    caloriesEstimate,
    steps,
    stepsSource,
    distanceKm,
    avgSpeedKmh,
    pausedSeconds,
    activeSeconds,
    metricsNote,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workout &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.userId == this.userId &&
          other.workoutTypeId == this.workoutTypeId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationMinutes == this.durationMinutes &&
          other.intensity == this.intensity &&
          other.note == this.note &&
          other.source == this.source &&
          other.tzOffsetMinutes == this.tzOffsetMinutes &&
          other.localDate == this.localDate &&
          other.caloriesEstimate == this.caloriesEstimate &&
          other.steps == this.steps &&
          other.stepsSource == this.stepsSource &&
          other.distanceKm == this.distanceKm &&
          other.avgSpeedKmh == this.avgSpeedKmh &&
          other.pausedSeconds == this.pausedSeconds &&
          other.activeSeconds == this.activeSeconds &&
          other.metricsNote == this.metricsNote);
}

class WorkoutsCompanion extends UpdateCompanion<Workout> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> userId;
  final Value<String> workoutTypeId;
  final Value<DateTime> startedAt;
  final Value<DateTime> endedAt;
  final Value<int> durationMinutes;
  final Value<WorkoutIntensity?> intensity;
  final Value<String?> note;
  final Value<WorkoutSource> source;
  final Value<int> tzOffsetMinutes;
  final Value<String> localDate;
  final Value<int?> caloriesEstimate;
  final Value<int?> steps;
  final Value<String?> stepsSource;
  final Value<double?> distanceKm;
  final Value<double?> avgSpeedKmh;
  final Value<int> pausedSeconds;
  final Value<int?> activeSeconds;
  final Value<String?> metricsNote;
  final Value<int> rowid;
  const WorkoutsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.workoutTypeId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.intensity = const Value.absent(),
    this.note = const Value.absent(),
    this.source = const Value.absent(),
    this.tzOffsetMinutes = const Value.absent(),
    this.localDate = const Value.absent(),
    this.caloriesEstimate = const Value.absent(),
    this.steps = const Value.absent(),
    this.stepsSource = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.avgSpeedKmh = const Value.absent(),
    this.pausedSeconds = const Value.absent(),
    this.activeSeconds = const Value.absent(),
    this.metricsNote = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String userId,
    required String workoutTypeId,
    required DateTime startedAt,
    required DateTime endedAt,
    required int durationMinutes,
    this.intensity = const Value.absent(),
    this.note = const Value.absent(),
    required WorkoutSource source,
    this.tzOffsetMinutes = const Value.absent(),
    required String localDate,
    this.caloriesEstimate = const Value.absent(),
    this.steps = const Value.absent(),
    this.stepsSource = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.avgSpeedKmh = const Value.absent(),
    this.pausedSeconds = const Value.absent(),
    this.activeSeconds = const Value.absent(),
    this.metricsNote = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       userId = Value(userId),
       workoutTypeId = Value(workoutTypeId),
       startedAt = Value(startedAt),
       endedAt = Value(endedAt),
       durationMinutes = Value(durationMinutes),
       source = Value(source),
       localDate = Value(localDate);
  static Insertable<Workout> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? userId,
    Expression<String>? workoutTypeId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? durationMinutes,
    Expression<String>? intensity,
    Expression<String>? note,
    Expression<String>? source,
    Expression<int>? tzOffsetMinutes,
    Expression<String>? localDate,
    Expression<int>? caloriesEstimate,
    Expression<int>? steps,
    Expression<String>? stepsSource,
    Expression<double>? distanceKm,
    Expression<double>? avgSpeedKmh,
    Expression<int>? pausedSeconds,
    Expression<int>? activeSeconds,
    Expression<String>? metricsNote,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (userId != null) 'user_id': userId,
      if (workoutTypeId != null) 'workout_type_id': workoutTypeId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (intensity != null) 'intensity': intensity,
      if (note != null) 'note': note,
      if (source != null) 'source': source,
      if (tzOffsetMinutes != null) 'tz_offset_minutes': tzOffsetMinutes,
      if (localDate != null) 'local_date': localDate,
      if (caloriesEstimate != null) 'calories_estimate': caloriesEstimate,
      if (steps != null) 'steps': steps,
      if (stepsSource != null) 'steps_source': stepsSource,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (avgSpeedKmh != null) 'avg_speed_kmh': avgSpeedKmh,
      if (pausedSeconds != null) 'paused_seconds': pausedSeconds,
      if (activeSeconds != null) 'active_seconds': activeSeconds,
      if (metricsNote != null) 'metrics_note': metricsNote,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? userId,
    Value<String>? workoutTypeId,
    Value<DateTime>? startedAt,
    Value<DateTime>? endedAt,
    Value<int>? durationMinutes,
    Value<WorkoutIntensity?>? intensity,
    Value<String?>? note,
    Value<WorkoutSource>? source,
    Value<int>? tzOffsetMinutes,
    Value<String>? localDate,
    Value<int?>? caloriesEstimate,
    Value<int?>? steps,
    Value<String?>? stepsSource,
    Value<double?>? distanceKm,
    Value<double?>? avgSpeedKmh,
    Value<int>? pausedSeconds,
    Value<int?>? activeSeconds,
    Value<String?>? metricsNote,
    Value<int>? rowid,
  }) {
    return WorkoutsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      userId: userId ?? this.userId,
      workoutTypeId: workoutTypeId ?? this.workoutTypeId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      intensity: intensity ?? this.intensity,
      note: note ?? this.note,
      source: source ?? this.source,
      tzOffsetMinutes: tzOffsetMinutes ?? this.tzOffsetMinutes,
      localDate: localDate ?? this.localDate,
      caloriesEstimate: caloriesEstimate ?? this.caloriesEstimate,
      steps: steps ?? this.steps,
      stepsSource: stepsSource ?? this.stepsSource,
      distanceKm: distanceKm ?? this.distanceKm,
      avgSpeedKmh: avgSpeedKmh ?? this.avgSpeedKmh,
      pausedSeconds: pausedSeconds ?? this.pausedSeconds,
      activeSeconds: activeSeconds ?? this.activeSeconds,
      metricsNote: metricsNote ?? this.metricsNote,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (workoutTypeId.present) {
      map['workout_type_id'] = Variable<String>(workoutTypeId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (intensity.present) {
      map['intensity'] = Variable<String>(
        $WorkoutsTable.$converterintensityn.toSql(intensity.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $WorkoutsTable.$convertersource.toSql(source.value),
      );
    }
    if (tzOffsetMinutes.present) {
      map['tz_offset_minutes'] = Variable<int>(tzOffsetMinutes.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (caloriesEstimate.present) {
      map['calories_estimate'] = Variable<int>(caloriesEstimate.value);
    }
    if (steps.present) {
      map['steps'] = Variable<int>(steps.value);
    }
    if (stepsSource.present) {
      map['steps_source'] = Variable<String>(stepsSource.value);
    }
    if (distanceKm.present) {
      map['distance_km'] = Variable<double>(distanceKm.value);
    }
    if (avgSpeedKmh.present) {
      map['avg_speed_kmh'] = Variable<double>(avgSpeedKmh.value);
    }
    if (pausedSeconds.present) {
      map['paused_seconds'] = Variable<int>(pausedSeconds.value);
    }
    if (activeSeconds.present) {
      map['active_seconds'] = Variable<int>(activeSeconds.value);
    }
    if (metricsNote.present) {
      map['metrics_note'] = Variable<String>(metricsNote.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('workoutTypeId: $workoutTypeId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('intensity: $intensity, ')
          ..write('note: $note, ')
          ..write('source: $source, ')
          ..write('tzOffsetMinutes: $tzOffsetMinutes, ')
          ..write('localDate: $localDate, ')
          ..write('caloriesEstimate: $caloriesEstimate, ')
          ..write('steps: $steps, ')
          ..write('stepsSource: $stepsSource, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('avgSpeedKmh: $avgSpeedKmh, ')
          ..write('pausedSeconds: $pausedSeconds, ')
          ..write('activeSeconds: $activeSeconds, ')
          ..write('metricsNote: $metricsNote, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<HabitKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<HabitKind>($HabitsTable.$converterkind);
  static const VerificationMeta _dailyTargetMeta = const VerificationMeta(
    'dailyTarget',
  );
  @override
  late final GeneratedColumn<int> dailyTarget = GeneratedColumn<int>(
    'daily_target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _remindersEnabledMeta = const VerificationMeta(
    'remindersEnabled',
  );
  @override
  late final GeneratedColumn<bool> remindersEnabled = GeneratedColumn<bool>(
    'reminders_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminders_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reminderConfigMeta = const VerificationMeta(
    'reminderConfig',
  );
  @override
  late final GeneratedColumn<String> reminderConfig = GeneratedColumn<String>(
    'reminder_config',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    name,
    kind,
    dailyTarget,
    remindersEnabled,
    reminderConfig,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Habit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('daily_target')) {
      context.handle(
        _dailyTargetMeta,
        dailyTarget.isAcceptableOrUnknown(
          data['daily_target']!,
          _dailyTargetMeta,
        ),
      );
    }
    if (data.containsKey('reminders_enabled')) {
      context.handle(
        _remindersEnabledMeta,
        remindersEnabled.isAcceptableOrUnknown(
          data['reminders_enabled']!,
          _remindersEnabledMeta,
        ),
      );
    }
    if (data.containsKey('reminder_config')) {
      context.handle(
        _reminderConfigMeta,
        reminderConfig.isAcceptableOrUnknown(
          data['reminder_config']!,
          _reminderConfigMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: $HabitsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      dailyTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_target'],
      )!,
      remindersEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminders_enabled'],
      )!,
      reminderConfig: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_config'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<HabitKind, String, String> $converterkind =
      const EnumNameConverter<HabitKind>(HabitKind.values);
}

class Habit extends DataClass implements Insertable<Habit> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String userId;
  final String name;
  final HabitKind kind;
  final int dailyTarget;
  final bool remindersEnabled;

  /// JSON: reminder times or interval, and active days.
  final String reminderConfig;
  final bool isActive;
  const Habit({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.userId,
    required this.name,
    required this.kind,
    required this.dailyTarget,
    required this.remindersEnabled,
    required this.reminderConfig,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    {
      map['kind'] = Variable<String>($HabitsTable.$converterkind.toSql(kind));
    }
    map['daily_target'] = Variable<int>(dailyTarget);
    map['reminders_enabled'] = Variable<bool>(remindersEnabled);
    map['reminder_config'] = Variable<String>(reminderConfig);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      userId: Value(userId),
      name: Value(name),
      kind: Value(kind),
      dailyTarget: Value(dailyTarget),
      remindersEnabled: Value(remindersEnabled),
      reminderConfig: Value(reminderConfig),
      isActive: Value(isActive),
    );
  }

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habit(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      kind: $HabitsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      dailyTarget: serializer.fromJson<int>(json['dailyTarget']),
      remindersEnabled: serializer.fromJson<bool>(json['remindersEnabled']),
      reminderConfig: serializer.fromJson<String>(json['reminderConfig']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(
        $HabitsTable.$converterkind.toJson(kind),
      ),
      'dailyTarget': serializer.toJson<int>(dailyTarget),
      'remindersEnabled': serializer.toJson<bool>(remindersEnabled),
      'reminderConfig': serializer.toJson<String>(reminderConfig),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Habit copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? userId,
    String? name,
    HabitKind? kind,
    int? dailyTarget,
    bool? remindersEnabled,
    String? reminderConfig,
    bool? isActive,
  }) => Habit(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    dailyTarget: dailyTarget ?? this.dailyTarget,
    remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    reminderConfig: reminderConfig ?? this.reminderConfig,
    isActive: isActive ?? this.isActive,
  );
  Habit copyWithCompanion(HabitsCompanion data) {
    return Habit(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      dailyTarget: data.dailyTarget.present
          ? data.dailyTarget.value
          : this.dailyTarget,
      remindersEnabled: data.remindersEnabled.present
          ? data.remindersEnabled.value
          : this.remindersEnabled,
      reminderConfig: data.reminderConfig.present
          ? data.reminderConfig.value
          : this.reminderConfig,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('dailyTarget: $dailyTarget, ')
          ..write('remindersEnabled: $remindersEnabled, ')
          ..write('reminderConfig: $reminderConfig, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    name,
    kind,
    dailyTarget,
    remindersEnabled,
    reminderConfig,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habit &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.dailyTarget == this.dailyTarget &&
          other.remindersEnabled == this.remindersEnabled &&
          other.reminderConfig == this.reminderConfig &&
          other.isActive == this.isActive);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> userId;
  final Value<String> name;
  final Value<HabitKind> kind;
  final Value<int> dailyTarget;
  final Value<bool> remindersEnabled;
  final Value<String> reminderConfig;
  final Value<bool> isActive;
  final Value<int> rowid;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.dailyTarget = const Value.absent(),
    this.remindersEnabled = const Value.absent(),
    this.reminderConfig = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String userId,
    required String name,
    required HabitKind kind,
    this.dailyTarget = const Value.absent(),
    this.remindersEnabled = const Value.absent(),
    this.reminderConfig = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       userId = Value(userId),
       name = Value(name),
       kind = Value(kind);
  static Insertable<Habit> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<int>? dailyTarget,
    Expression<bool>? remindersEnabled,
    Expression<String>? reminderConfig,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (dailyTarget != null) 'daily_target': dailyTarget,
      if (remindersEnabled != null) 'reminders_enabled': remindersEnabled,
      if (reminderConfig != null) 'reminder_config': reminderConfig,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? userId,
    Value<String>? name,
    Value<HabitKind>? kind,
    Value<int>? dailyTarget,
    Value<bool>? remindersEnabled,
    Value<String>? reminderConfig,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderConfig: reminderConfig ?? this.reminderConfig,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $HabitsTable.$converterkind.toSql(kind.value),
      );
    }
    if (dailyTarget.present) {
      map['daily_target'] = Variable<int>(dailyTarget.value);
    }
    if (remindersEnabled.present) {
      map['reminders_enabled'] = Variable<bool>(remindersEnabled.value);
    }
    if (reminderConfig.present) {
      map['reminder_config'] = Variable<String>(reminderConfig.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('dailyTarget: $dailyTarget, ')
          ..write('remindersEnabled: $remindersEnabled, ')
          ..write('reminderConfig: $reminderConfig, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitLogsTable extends HabitLogs
    with TableInfo<$HabitLogsTable, HabitLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _tzOffsetMinutesMeta = const VerificationMeta(
    'tzOffsetMinutes',
  );
  @override
  late final GeneratedColumn<int> tzOffsetMinutes = GeneratedColumn<int>(
    'tz_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    habitId,
    userId,
    loggedAt,
    count,
    tzOffsetMinutes,
    localDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    if (data.containsKey('tz_offset_minutes')) {
      context.handle(
        _tzOffsetMinutesMeta,
        tzOffsetMinutes.isAcceptableOrUnknown(
          data['tz_offset_minutes']!,
          _tzOffsetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_at'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      tzOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tz_offset_minutes'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
    );
  }

  @override
  $HabitLogsTable createAlias(String alias) {
    return $HabitLogsTable(attachedDatabase, alias);
  }
}

class HabitLog extends DataClass implements Insertable<HabitLog> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String habitId;
  final String userId;
  final DateTime loggedAt;
  final int count;
  final int tzOffsetMinutes;
  final String localDate;
  const HabitLog({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.habitId,
    required this.userId,
    required this.loggedAt,
    required this.count,
    required this.tzOffsetMinutes,
    required this.localDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['habit_id'] = Variable<String>(habitId);
    map['user_id'] = Variable<String>(userId);
    map['logged_at'] = Variable<DateTime>(loggedAt);
    map['count'] = Variable<int>(count);
    map['tz_offset_minutes'] = Variable<int>(tzOffsetMinutes);
    map['local_date'] = Variable<String>(localDate);
    return map;
  }

  HabitLogsCompanion toCompanion(bool nullToAbsent) {
    return HabitLogsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      habitId: Value(habitId),
      userId: Value(userId),
      loggedAt: Value(loggedAt),
      count: Value(count),
      tzOffsetMinutes: Value(tzOffsetMinutes),
      localDate: Value(localDate),
    );
  }

  factory HabitLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitLog(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      habitId: serializer.fromJson<String>(json['habitId']),
      userId: serializer.fromJson<String>(json['userId']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
      count: serializer.fromJson<int>(json['count']),
      tzOffsetMinutes: serializer.fromJson<int>(json['tzOffsetMinutes']),
      localDate: serializer.fromJson<String>(json['localDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'habitId': serializer.toJson<String>(habitId),
      'userId': serializer.toJson<String>(userId),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
      'count': serializer.toJson<int>(count),
      'tzOffsetMinutes': serializer.toJson<int>(tzOffsetMinutes),
      'localDate': serializer.toJson<String>(localDate),
    };
  }

  HabitLog copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? habitId,
    String? userId,
    DateTime? loggedAt,
    int? count,
    int? tzOffsetMinutes,
    String? localDate,
  }) => HabitLog(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    habitId: habitId ?? this.habitId,
    userId: userId ?? this.userId,
    loggedAt: loggedAt ?? this.loggedAt,
    count: count ?? this.count,
    tzOffsetMinutes: tzOffsetMinutes ?? this.tzOffsetMinutes,
    localDate: localDate ?? this.localDate,
  );
  HabitLog copyWithCompanion(HabitLogsCompanion data) {
    return HabitLog(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      userId: data.userId.present ? data.userId.value : this.userId,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      count: data.count.present ? data.count.value : this.count,
      tzOffsetMinutes: data.tzOffsetMinutes.present
          ? data.tzOffsetMinutes.value
          : this.tzOffsetMinutes,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitLog(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('habitId: $habitId, ')
          ..write('userId: $userId, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('count: $count, ')
          ..write('tzOffsetMinutes: $tzOffsetMinutes, ')
          ..write('localDate: $localDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    habitId,
    userId,
    loggedAt,
    count,
    tzOffsetMinutes,
    localDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitLog &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.habitId == this.habitId &&
          other.userId == this.userId &&
          other.loggedAt == this.loggedAt &&
          other.count == this.count &&
          other.tzOffsetMinutes == this.tzOffsetMinutes &&
          other.localDate == this.localDate);
}

class HabitLogsCompanion extends UpdateCompanion<HabitLog> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> habitId;
  final Value<String> userId;
  final Value<DateTime> loggedAt;
  final Value<int> count;
  final Value<int> tzOffsetMinutes;
  final Value<String> localDate;
  final Value<int> rowid;
  const HabitLogsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.habitId = const Value.absent(),
    this.userId = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.count = const Value.absent(),
    this.tzOffsetMinutes = const Value.absent(),
    this.localDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitLogsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String habitId,
    required String userId,
    required DateTime loggedAt,
    this.count = const Value.absent(),
    this.tzOffsetMinutes = const Value.absent(),
    required String localDate,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       habitId = Value(habitId),
       userId = Value(userId),
       loggedAt = Value(loggedAt),
       localDate = Value(localDate);
  static Insertable<HabitLog> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? habitId,
    Expression<String>? userId,
    Expression<DateTime>? loggedAt,
    Expression<int>? count,
    Expression<int>? tzOffsetMinutes,
    Expression<String>? localDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (habitId != null) 'habit_id': habitId,
      if (userId != null) 'user_id': userId,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (count != null) 'count': count,
      if (tzOffsetMinutes != null) 'tz_offset_minutes': tzOffsetMinutes,
      if (localDate != null) 'local_date': localDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitLogsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? habitId,
    Value<String>? userId,
    Value<DateTime>? loggedAt,
    Value<int>? count,
    Value<int>? tzOffsetMinutes,
    Value<String>? localDate,
    Value<int>? rowid,
  }) {
    return HabitLogsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      loggedAt: loggedAt ?? this.loggedAt,
      count: count ?? this.count,
      tzOffsetMinutes: tzOffsetMinutes ?? this.tzOffsetMinutes,
      localDate: localDate ?? this.localDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (tzOffsetMinutes.present) {
      map['tz_offset_minutes'] = Variable<int>(tzOffsetMinutes.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitLogsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('habitId: $habitId, ')
          ..write('userId: $userId, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('count: $count, ')
          ..write('tzOffsetMinutes: $tzOffsetMinutes, ')
          ..write('localDate: $localDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitSkipsTable extends HabitSkips
    with TableInfo<$HabitSkipsTable, HabitSkip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitSkipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skippedAtMeta = const VerificationMeta(
    'skippedAt',
  );
  @override
  late final GeneratedColumn<DateTime> skippedAt = GeneratedColumn<DateTime>(
    'skipped_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tzOffsetMinutesMeta = const VerificationMeta(
    'tzOffsetMinutes',
  );
  @override
  late final GeneratedColumn<int> tzOffsetMinutes = GeneratedColumn<int>(
    'tz_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    habitId,
    userId,
    skippedAt,
    tzOffsetMinutes,
    localDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_skips';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitSkip> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('skipped_at')) {
      context.handle(
        _skippedAtMeta,
        skippedAt.isAcceptableOrUnknown(data['skipped_at']!, _skippedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_skippedAtMeta);
    }
    if (data.containsKey('tz_offset_minutes')) {
      context.handle(
        _tzOffsetMinutesMeta,
        tzOffsetMinutes.isAcceptableOrUnknown(
          data['tz_offset_minutes']!,
          _tzOffsetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitSkip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitSkip(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      skippedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}skipped_at'],
      )!,
      tzOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tz_offset_minutes'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
    );
  }

  @override
  $HabitSkipsTable createAlias(String alias) {
    return $HabitSkipsTable(attachedDatabase, alias);
  }
}

class HabitSkip extends DataClass implements Insertable<HabitSkip> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String habitId;
  final String userId;
  final DateTime skippedAt;
  final int tzOffsetMinutes;
  final String localDate;
  const HabitSkip({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.habitId,
    required this.userId,
    required this.skippedAt,
    required this.tzOffsetMinutes,
    required this.localDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['habit_id'] = Variable<String>(habitId);
    map['user_id'] = Variable<String>(userId);
    map['skipped_at'] = Variable<DateTime>(skippedAt);
    map['tz_offset_minutes'] = Variable<int>(tzOffsetMinutes);
    map['local_date'] = Variable<String>(localDate);
    return map;
  }

  HabitSkipsCompanion toCompanion(bool nullToAbsent) {
    return HabitSkipsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      habitId: Value(habitId),
      userId: Value(userId),
      skippedAt: Value(skippedAt),
      tzOffsetMinutes: Value(tzOffsetMinutes),
      localDate: Value(localDate),
    );
  }

  factory HabitSkip.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitSkip(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      habitId: serializer.fromJson<String>(json['habitId']),
      userId: serializer.fromJson<String>(json['userId']),
      skippedAt: serializer.fromJson<DateTime>(json['skippedAt']),
      tzOffsetMinutes: serializer.fromJson<int>(json['tzOffsetMinutes']),
      localDate: serializer.fromJson<String>(json['localDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'habitId': serializer.toJson<String>(habitId),
      'userId': serializer.toJson<String>(userId),
      'skippedAt': serializer.toJson<DateTime>(skippedAt),
      'tzOffsetMinutes': serializer.toJson<int>(tzOffsetMinutes),
      'localDate': serializer.toJson<String>(localDate),
    };
  }

  HabitSkip copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? habitId,
    String? userId,
    DateTime? skippedAt,
    int? tzOffsetMinutes,
    String? localDate,
  }) => HabitSkip(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    habitId: habitId ?? this.habitId,
    userId: userId ?? this.userId,
    skippedAt: skippedAt ?? this.skippedAt,
    tzOffsetMinutes: tzOffsetMinutes ?? this.tzOffsetMinutes,
    localDate: localDate ?? this.localDate,
  );
  HabitSkip copyWithCompanion(HabitSkipsCompanion data) {
    return HabitSkip(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      userId: data.userId.present ? data.userId.value : this.userId,
      skippedAt: data.skippedAt.present ? data.skippedAt.value : this.skippedAt,
      tzOffsetMinutes: data.tzOffsetMinutes.present
          ? data.tzOffsetMinutes.value
          : this.tzOffsetMinutes,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitSkip(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('habitId: $habitId, ')
          ..write('userId: $userId, ')
          ..write('skippedAt: $skippedAt, ')
          ..write('tzOffsetMinutes: $tzOffsetMinutes, ')
          ..write('localDate: $localDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    habitId,
    userId,
    skippedAt,
    tzOffsetMinutes,
    localDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitSkip &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.habitId == this.habitId &&
          other.userId == this.userId &&
          other.skippedAt == this.skippedAt &&
          other.tzOffsetMinutes == this.tzOffsetMinutes &&
          other.localDate == this.localDate);
}

class HabitSkipsCompanion extends UpdateCompanion<HabitSkip> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> habitId;
  final Value<String> userId;
  final Value<DateTime> skippedAt;
  final Value<int> tzOffsetMinutes;
  final Value<String> localDate;
  final Value<int> rowid;
  const HabitSkipsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.habitId = const Value.absent(),
    this.userId = const Value.absent(),
    this.skippedAt = const Value.absent(),
    this.tzOffsetMinutes = const Value.absent(),
    this.localDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitSkipsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String habitId,
    required String userId,
    required DateTime skippedAt,
    this.tzOffsetMinutes = const Value.absent(),
    required String localDate,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       habitId = Value(habitId),
       userId = Value(userId),
       skippedAt = Value(skippedAt),
       localDate = Value(localDate);
  static Insertable<HabitSkip> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? habitId,
    Expression<String>? userId,
    Expression<DateTime>? skippedAt,
    Expression<int>? tzOffsetMinutes,
    Expression<String>? localDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (habitId != null) 'habit_id': habitId,
      if (userId != null) 'user_id': userId,
      if (skippedAt != null) 'skipped_at': skippedAt,
      if (tzOffsetMinutes != null) 'tz_offset_minutes': tzOffsetMinutes,
      if (localDate != null) 'local_date': localDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitSkipsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? habitId,
    Value<String>? userId,
    Value<DateTime>? skippedAt,
    Value<int>? tzOffsetMinutes,
    Value<String>? localDate,
    Value<int>? rowid,
  }) {
    return HabitSkipsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      skippedAt: skippedAt ?? this.skippedAt,
      tzOffsetMinutes: tzOffsetMinutes ?? this.tzOffsetMinutes,
      localDate: localDate ?? this.localDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (skippedAt.present) {
      map['skipped_at'] = Variable<DateTime>(skippedAt.value);
    }
    if (tzOffsetMinutes.present) {
      map['tz_offset_minutes'] = Variable<int>(tzOffsetMinutes.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitSkipsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('habitId: $habitId, ')
          ..write('userId: $userId, ')
          ..write('skippedAt: $skippedAt, ')
          ..write('tzOffsetMinutes: $tzOffsetMinutes, ')
          ..write('localDate: $localDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HobbiesTable extends Hobbies with TableInfo<$HobbiesTable, Hobby> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HobbiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isBuiltinMeta = const VerificationMeta(
    'isBuiltin',
  );
  @override
  late final GeneratedColumn<bool> isBuiltin = GeneratedColumn<bool>(
    'is_builtin',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_builtin" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<HobbyGoalPeriod?, String>
  goalPeriod = GeneratedColumn<String>(
    'goal_period',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<HobbyGoalPeriod?>($HobbiesTable.$convertergoalPeriodn);
  static const VerificationMeta _goalValueMeta = const VerificationMeta(
    'goalValue',
  );
  @override
  late final GeneratedColumn<int> goalValue = GeneratedColumn<int>(
    'goal_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<HobbyGoalUnit, String> goalUnit =
      GeneratedColumn<String>(
        'goal_unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('minutes'),
      ).withConverter<HobbyGoalUnit>($HobbiesTable.$convertergoalUnit);
  static const VerificationMeta _reminderEnabledMeta = const VerificationMeta(
    'reminderEnabled',
  );
  @override
  late final GeneratedColumn<bool> reminderEnabled = GeneratedColumn<bool>(
    'reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reminderConfigMeta = const VerificationMeta(
    'reminderConfig',
  );
  @override
  late final GeneratedColumn<String> reminderConfig = GeneratedColumn<String>(
    'reminder_config',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    name,
    iconKey,
    isBuiltin,
    goalPeriod,
    goalValue,
    goalUnit,
    reminderEnabled,
    reminderConfig,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hobbies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Hobby> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_iconKeyMeta);
    }
    if (data.containsKey('is_builtin')) {
      context.handle(
        _isBuiltinMeta,
        isBuiltin.isAcceptableOrUnknown(data['is_builtin']!, _isBuiltinMeta),
      );
    }
    if (data.containsKey('goal_value')) {
      context.handle(
        _goalValueMeta,
        goalValue.isAcceptableOrUnknown(data['goal_value']!, _goalValueMeta),
      );
    }
    if (data.containsKey('reminder_enabled')) {
      context.handle(
        _reminderEnabledMeta,
        reminderEnabled.isAcceptableOrUnknown(
          data['reminder_enabled']!,
          _reminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('reminder_config')) {
      context.handle(
        _reminderConfigMeta,
        reminderConfig.isAcceptableOrUnknown(
          data['reminder_config']!,
          _reminderConfigMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Hobby map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Hobby(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      isBuiltin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_builtin'],
      )!,
      goalPeriod: $HobbiesTable.$convertergoalPeriodn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}goal_period'],
        ),
      ),
      goalValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal_value'],
      ),
      goalUnit: $HobbiesTable.$convertergoalUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}goal_unit'],
        )!,
      ),
      reminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_enabled'],
      )!,
      reminderConfig: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_config'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $HobbiesTable createAlias(String alias) {
    return $HobbiesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<HobbyGoalPeriod, String, String>
  $convertergoalPeriod = const EnumNameConverter<HobbyGoalPeriod>(
    HobbyGoalPeriod.values,
  );
  static JsonTypeConverter2<HobbyGoalPeriod?, String?, String?>
  $convertergoalPeriodn = JsonTypeConverter2.asNullable($convertergoalPeriod);
  static JsonTypeConverter2<HobbyGoalUnit, String, String> $convertergoalUnit =
      const EnumNameConverter<HobbyGoalUnit>(HobbyGoalUnit.values);
}

class Hobby extends DataClass implements Insertable<Hobby> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String userId;
  final String name;
  final String iconKey;
  final bool isBuiltin;
  final HobbyGoalPeriod? goalPeriod;
  final int? goalValue;
  final HobbyGoalUnit goalUnit;
  final bool reminderEnabled;

  /// JSON: frequency (daily|weekly|biweekly|monthly), time, weekday, etc.
  final String reminderConfig;
  final bool isActive;
  const Hobby({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.userId,
    required this.name,
    required this.iconKey,
    required this.isBuiltin,
    this.goalPeriod,
    this.goalValue,
    required this.goalUnit,
    required this.reminderEnabled,
    required this.reminderConfig,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['icon_key'] = Variable<String>(iconKey);
    map['is_builtin'] = Variable<bool>(isBuiltin);
    if (!nullToAbsent || goalPeriod != null) {
      map['goal_period'] = Variable<String>(
        $HobbiesTable.$convertergoalPeriodn.toSql(goalPeriod),
      );
    }
    if (!nullToAbsent || goalValue != null) {
      map['goal_value'] = Variable<int>(goalValue);
    }
    {
      map['goal_unit'] = Variable<String>(
        $HobbiesTable.$convertergoalUnit.toSql(goalUnit),
      );
    }
    map['reminder_enabled'] = Variable<bool>(reminderEnabled);
    map['reminder_config'] = Variable<String>(reminderConfig);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  HobbiesCompanion toCompanion(bool nullToAbsent) {
    return HobbiesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      userId: Value(userId),
      name: Value(name),
      iconKey: Value(iconKey),
      isBuiltin: Value(isBuiltin),
      goalPeriod: goalPeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(goalPeriod),
      goalValue: goalValue == null && nullToAbsent
          ? const Value.absent()
          : Value(goalValue),
      goalUnit: Value(goalUnit),
      reminderEnabled: Value(reminderEnabled),
      reminderConfig: Value(reminderConfig),
      isActive: Value(isActive),
    );
  }

  factory Hobby.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Hobby(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      isBuiltin: serializer.fromJson<bool>(json['isBuiltin']),
      goalPeriod: $HobbiesTable.$convertergoalPeriodn.fromJson(
        serializer.fromJson<String?>(json['goalPeriod']),
      ),
      goalValue: serializer.fromJson<int?>(json['goalValue']),
      goalUnit: $HobbiesTable.$convertergoalUnit.fromJson(
        serializer.fromJson<String>(json['goalUnit']),
      ),
      reminderEnabled: serializer.fromJson<bool>(json['reminderEnabled']),
      reminderConfig: serializer.fromJson<String>(json['reminderConfig']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'iconKey': serializer.toJson<String>(iconKey),
      'isBuiltin': serializer.toJson<bool>(isBuiltin),
      'goalPeriod': serializer.toJson<String?>(
        $HobbiesTable.$convertergoalPeriodn.toJson(goalPeriod),
      ),
      'goalValue': serializer.toJson<int?>(goalValue),
      'goalUnit': serializer.toJson<String>(
        $HobbiesTable.$convertergoalUnit.toJson(goalUnit),
      ),
      'reminderEnabled': serializer.toJson<bool>(reminderEnabled),
      'reminderConfig': serializer.toJson<String>(reminderConfig),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Hobby copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? userId,
    String? name,
    String? iconKey,
    bool? isBuiltin,
    Value<HobbyGoalPeriod?> goalPeriod = const Value.absent(),
    Value<int?> goalValue = const Value.absent(),
    HobbyGoalUnit? goalUnit,
    bool? reminderEnabled,
    String? reminderConfig,
    bool? isActive,
  }) => Hobby(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    iconKey: iconKey ?? this.iconKey,
    isBuiltin: isBuiltin ?? this.isBuiltin,
    goalPeriod: goalPeriod.present ? goalPeriod.value : this.goalPeriod,
    goalValue: goalValue.present ? goalValue.value : this.goalValue,
    goalUnit: goalUnit ?? this.goalUnit,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    reminderConfig: reminderConfig ?? this.reminderConfig,
    isActive: isActive ?? this.isActive,
  );
  Hobby copyWithCompanion(HobbiesCompanion data) {
    return Hobby(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      isBuiltin: data.isBuiltin.present ? data.isBuiltin.value : this.isBuiltin,
      goalPeriod: data.goalPeriod.present
          ? data.goalPeriod.value
          : this.goalPeriod,
      goalValue: data.goalValue.present ? data.goalValue.value : this.goalValue,
      goalUnit: data.goalUnit.present ? data.goalUnit.value : this.goalUnit,
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      reminderConfig: data.reminderConfig.present
          ? data.reminderConfig.value
          : this.reminderConfig,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Hobby(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('goalPeriod: $goalPeriod, ')
          ..write('goalValue: $goalValue, ')
          ..write('goalUnit: $goalUnit, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderConfig: $reminderConfig, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    name,
    iconKey,
    isBuiltin,
    goalPeriod,
    goalValue,
    goalUnit,
    reminderEnabled,
    reminderConfig,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Hobby &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.iconKey == this.iconKey &&
          other.isBuiltin == this.isBuiltin &&
          other.goalPeriod == this.goalPeriod &&
          other.goalValue == this.goalValue &&
          other.goalUnit == this.goalUnit &&
          other.reminderEnabled == this.reminderEnabled &&
          other.reminderConfig == this.reminderConfig &&
          other.isActive == this.isActive);
}

class HobbiesCompanion extends UpdateCompanion<Hobby> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> userId;
  final Value<String> name;
  final Value<String> iconKey;
  final Value<bool> isBuiltin;
  final Value<HobbyGoalPeriod?> goalPeriod;
  final Value<int?> goalValue;
  final Value<HobbyGoalUnit> goalUnit;
  final Value<bool> reminderEnabled;
  final Value<String> reminderConfig;
  final Value<bool> isActive;
  final Value<int> rowid;
  const HobbiesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.goalPeriod = const Value.absent(),
    this.goalValue = const Value.absent(),
    this.goalUnit = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderConfig = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HobbiesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String userId,
    required String name,
    required String iconKey,
    this.isBuiltin = const Value.absent(),
    this.goalPeriod = const Value.absent(),
    this.goalValue = const Value.absent(),
    this.goalUnit = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderConfig = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       userId = Value(userId),
       name = Value(name),
       iconKey = Value(iconKey);
  static Insertable<Hobby> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? iconKey,
    Expression<bool>? isBuiltin,
    Expression<String>? goalPeriod,
    Expression<int>? goalValue,
    Expression<String>? goalUnit,
    Expression<bool>? reminderEnabled,
    Expression<String>? reminderConfig,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (iconKey != null) 'icon_key': iconKey,
      if (isBuiltin != null) 'is_builtin': isBuiltin,
      if (goalPeriod != null) 'goal_period': goalPeriod,
      if (goalValue != null) 'goal_value': goalValue,
      if (goalUnit != null) 'goal_unit': goalUnit,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (reminderConfig != null) 'reminder_config': reminderConfig,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HobbiesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? userId,
    Value<String>? name,
    Value<String>? iconKey,
    Value<bool>? isBuiltin,
    Value<HobbyGoalPeriod?>? goalPeriod,
    Value<int?>? goalValue,
    Value<HobbyGoalUnit>? goalUnit,
    Value<bool>? reminderEnabled,
    Value<String>? reminderConfig,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return HobbiesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      isBuiltin: isBuiltin ?? this.isBuiltin,
      goalPeriod: goalPeriod ?? this.goalPeriod,
      goalValue: goalValue ?? this.goalValue,
      goalUnit: goalUnit ?? this.goalUnit,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderConfig: reminderConfig ?? this.reminderConfig,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (isBuiltin.present) {
      map['is_builtin'] = Variable<bool>(isBuiltin.value);
    }
    if (goalPeriod.present) {
      map['goal_period'] = Variable<String>(
        $HobbiesTable.$convertergoalPeriodn.toSql(goalPeriod.value),
      );
    }
    if (goalValue.present) {
      map['goal_value'] = Variable<int>(goalValue.value);
    }
    if (goalUnit.present) {
      map['goal_unit'] = Variable<String>(
        $HobbiesTable.$convertergoalUnit.toSql(goalUnit.value),
      );
    }
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<bool>(reminderEnabled.value);
    }
    if (reminderConfig.present) {
      map['reminder_config'] = Variable<String>(reminderConfig.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HobbiesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('goalPeriod: $goalPeriod, ')
          ..write('goalValue: $goalValue, ')
          ..write('goalUnit: $goalUnit, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderConfig: $reminderConfig, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HobbyLogsTable extends HobbyLogs
    with TableInfo<$HobbyLogsTable, HobbyLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HobbyLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hobbyIdMeta = const VerificationMeta(
    'hobbyId',
  );
  @override
  late final GeneratedColumn<String> hobbyId = GeneratedColumn<String>(
    'hobby_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countOrSessionsMeta = const VerificationMeta(
    'countOrSessions',
  );
  @override
  late final GeneratedColumn<int> countOrSessions = GeneratedColumn<int>(
    'count_or_sessions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  late final GeneratedColumnWithTypeConverter<HobbyLogSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<HobbyLogSource>($HobbyLogsTable.$convertersource);
  static const VerificationMeta _tzOffsetMinutesMeta = const VerificationMeta(
    'tzOffsetMinutes',
  );
  @override
  late final GeneratedColumn<int> tzOffsetMinutes = GeneratedColumn<int>(
    'tz_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    hobbyId,
    startedAt,
    endedAt,
    durationMinutes,
    countOrSessions,
    source,
    tzOffsetMinutes,
    localDate,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hobby_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<HobbyLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('hobby_id')) {
      context.handle(
        _hobbyIdMeta,
        hobbyId.isAcceptableOrUnknown(data['hobby_id']!, _hobbyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_hobbyIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('count_or_sessions')) {
      context.handle(
        _countOrSessionsMeta,
        countOrSessions.isAcceptableOrUnknown(
          data['count_or_sessions']!,
          _countOrSessionsMeta,
        ),
      );
    }
    if (data.containsKey('tz_offset_minutes')) {
      context.handle(
        _tzOffsetMinutesMeta,
        tzOffsetMinutes.isAcceptableOrUnknown(
          data['tz_offset_minutes']!,
          _tzOffsetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HobbyLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HobbyLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      hobbyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hobby_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      countOrSessions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count_or_sessions'],
      )!,
      source: $HobbyLogsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      tzOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tz_offset_minutes'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $HobbyLogsTable createAlias(String alias) {
    return $HobbyLogsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<HobbyLogSource, String, String> $convertersource =
      const EnumNameConverter<HobbyLogSource>(HobbyLogSource.values);
}

class HobbyLog extends DataClass implements Insertable<HobbyLog> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String userId;
  final String hobbyId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationMinutes;
  final int countOrSessions;
  final HobbyLogSource source;
  final int tzOffsetMinutes;
  final String localDate;
  final String? note;
  const HobbyLog({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.userId,
    required this.hobbyId,
    required this.startedAt,
    this.endedAt,
    required this.durationMinutes,
    required this.countOrSessions,
    required this.source,
    required this.tzOffsetMinutes,
    required this.localDate,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['user_id'] = Variable<String>(userId);
    map['hobby_id'] = Variable<String>(hobbyId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['count_or_sessions'] = Variable<int>(countOrSessions);
    {
      map['source'] = Variable<String>(
        $HobbyLogsTable.$convertersource.toSql(source),
      );
    }
    map['tz_offset_minutes'] = Variable<int>(tzOffsetMinutes);
    map['local_date'] = Variable<String>(localDate);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  HobbyLogsCompanion toCompanion(bool nullToAbsent) {
    return HobbyLogsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      userId: Value(userId),
      hobbyId: Value(hobbyId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      durationMinutes: Value(durationMinutes),
      countOrSessions: Value(countOrSessions),
      source: Value(source),
      tzOffsetMinutes: Value(tzOffsetMinutes),
      localDate: Value(localDate),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory HobbyLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HobbyLog(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      userId: serializer.fromJson<String>(json['userId']),
      hobbyId: serializer.fromJson<String>(json['hobbyId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      countOrSessions: serializer.fromJson<int>(json['countOrSessions']),
      source: $HobbyLogsTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      tzOffsetMinutes: serializer.fromJson<int>(json['tzOffsetMinutes']),
      localDate: serializer.fromJson<String>(json['localDate']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'userId': serializer.toJson<String>(userId),
      'hobbyId': serializer.toJson<String>(hobbyId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'countOrSessions': serializer.toJson<int>(countOrSessions),
      'source': serializer.toJson<String>(
        $HobbyLogsTable.$convertersource.toJson(source),
      ),
      'tzOffsetMinutes': serializer.toJson<int>(tzOffsetMinutes),
      'localDate': serializer.toJson<String>(localDate),
      'note': serializer.toJson<String?>(note),
    };
  }

  HobbyLog copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? userId,
    String? hobbyId,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    int? durationMinutes,
    int? countOrSessions,
    HobbyLogSource? source,
    int? tzOffsetMinutes,
    String? localDate,
    Value<String?> note = const Value.absent(),
  }) => HobbyLog(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    userId: userId ?? this.userId,
    hobbyId: hobbyId ?? this.hobbyId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    countOrSessions: countOrSessions ?? this.countOrSessions,
    source: source ?? this.source,
    tzOffsetMinutes: tzOffsetMinutes ?? this.tzOffsetMinutes,
    localDate: localDate ?? this.localDate,
    note: note.present ? note.value : this.note,
  );
  HobbyLog copyWithCompanion(HobbyLogsCompanion data) {
    return HobbyLog(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      userId: data.userId.present ? data.userId.value : this.userId,
      hobbyId: data.hobbyId.present ? data.hobbyId.value : this.hobbyId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      countOrSessions: data.countOrSessions.present
          ? data.countOrSessions.value
          : this.countOrSessions,
      source: data.source.present ? data.source.value : this.source,
      tzOffsetMinutes: data.tzOffsetMinutes.present
          ? data.tzOffsetMinutes.value
          : this.tzOffsetMinutes,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HobbyLog(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('hobbyId: $hobbyId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('countOrSessions: $countOrSessions, ')
          ..write('source: $source, ')
          ..write('tzOffsetMinutes: $tzOffsetMinutes, ')
          ..write('localDate: $localDate, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    hobbyId,
    startedAt,
    endedAt,
    durationMinutes,
    countOrSessions,
    source,
    tzOffsetMinutes,
    localDate,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HobbyLog &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.userId == this.userId &&
          other.hobbyId == this.hobbyId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationMinutes == this.durationMinutes &&
          other.countOrSessions == this.countOrSessions &&
          other.source == this.source &&
          other.tzOffsetMinutes == this.tzOffsetMinutes &&
          other.localDate == this.localDate &&
          other.note == this.note);
}

class HobbyLogsCompanion extends UpdateCompanion<HobbyLog> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> userId;
  final Value<String> hobbyId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> durationMinutes;
  final Value<int> countOrSessions;
  final Value<HobbyLogSource> source;
  final Value<int> tzOffsetMinutes;
  final Value<String> localDate;
  final Value<String?> note;
  final Value<int> rowid;
  const HobbyLogsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.hobbyId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.countOrSessions = const Value.absent(),
    this.source = const Value.absent(),
    this.tzOffsetMinutes = const Value.absent(),
    this.localDate = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HobbyLogsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String userId,
    required String hobbyId,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    required int durationMinutes,
    this.countOrSessions = const Value.absent(),
    required HobbyLogSource source,
    this.tzOffsetMinutes = const Value.absent(),
    required String localDate,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       userId = Value(userId),
       hobbyId = Value(hobbyId),
       startedAt = Value(startedAt),
       durationMinutes = Value(durationMinutes),
       source = Value(source),
       localDate = Value(localDate);
  static Insertable<HobbyLog> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? userId,
    Expression<String>? hobbyId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? durationMinutes,
    Expression<int>? countOrSessions,
    Expression<String>? source,
    Expression<int>? tzOffsetMinutes,
    Expression<String>? localDate,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (userId != null) 'user_id': userId,
      if (hobbyId != null) 'hobby_id': hobbyId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (countOrSessions != null) 'count_or_sessions': countOrSessions,
      if (source != null) 'source': source,
      if (tzOffsetMinutes != null) 'tz_offset_minutes': tzOffsetMinutes,
      if (localDate != null) 'local_date': localDate,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HobbyLogsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? userId,
    Value<String>? hobbyId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? durationMinutes,
    Value<int>? countOrSessions,
    Value<HobbyLogSource>? source,
    Value<int>? tzOffsetMinutes,
    Value<String>? localDate,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return HobbyLogsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      userId: userId ?? this.userId,
      hobbyId: hobbyId ?? this.hobbyId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      countOrSessions: countOrSessions ?? this.countOrSessions,
      source: source ?? this.source,
      tzOffsetMinutes: tzOffsetMinutes ?? this.tzOffsetMinutes,
      localDate: localDate ?? this.localDate,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (hobbyId.present) {
      map['hobby_id'] = Variable<String>(hobbyId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (countOrSessions.present) {
      map['count_or_sessions'] = Variable<int>(countOrSessions.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $HobbyLogsTable.$convertersource.toSql(source.value),
      );
    }
    if (tzOffsetMinutes.present) {
      map['tz_offset_minutes'] = Variable<int>(tzOffsetMinutes.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HobbyLogsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('hobbyId: $hobbyId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('countOrSessions: $countOrSessions, ')
          ..write('source: $source, ')
          ..write('tzOffsetMinutes: $tzOffsetMinutes, ')
          ..write('localDate: $localDate, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BodyMeasurementsTable extends BodyMeasurements
    with TableInfo<$BodyMeasurementsTable, BodyMeasurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyMeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _measuredAtMeta = const VerificationMeta(
    'measuredAt',
  );
  @override
  late final GeneratedColumn<DateTime> measuredAt = GeneratedColumn<DateTime>(
    'measured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tzOffsetMinutesMeta = const VerificationMeta(
    'tzOffsetMinutes',
  );
  @override
  late final GeneratedColumn<int> tzOffsetMinutes = GeneratedColumn<int>(
    'tz_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bmiMeta = const VerificationMeta('bmi');
  @override
  late final GeneratedColumn<double> bmi = GeneratedColumn<double>(
    'bmi',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waistInMeta = const VerificationMeta(
    'waistIn',
  );
  @override
  late final GeneratedColumn<double> waistIn = GeneratedColumn<double>(
    'waist_in',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hipsInMeta = const VerificationMeta('hipsIn');
  @override
  late final GeneratedColumn<double> hipsIn = GeneratedColumn<double>(
    'hips_in',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chestInMeta = const VerificationMeta(
    'chestIn',
  );
  @override
  late final GeneratedColumn<double> chestIn = GeneratedColumn<double>(
    'chest_in',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _armInMeta = const VerificationMeta('armIn');
  @override
  late final GeneratedColumn<double> armIn = GeneratedColumn<double>(
    'arm_in',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thighInMeta = const VerificationMeta(
    'thighIn',
  );
  @override
  late final GeneratedColumn<double> thighIn = GeneratedColumn<double>(
    'thigh_in',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    measuredAt,
    tzOffsetMinutes,
    localDate,
    weightKg,
    heightCm,
    bmi,
    waistIn,
    hipsIn,
    chestIn,
    armIn,
    thighIn,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_measurements';
  @override
  VerificationContext validateIntegrity(
    Insertable<BodyMeasurement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('measured_at')) {
      context.handle(
        _measuredAtMeta,
        measuredAt.isAcceptableOrUnknown(data['measured_at']!, _measuredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_measuredAtMeta);
    }
    if (data.containsKey('tz_offset_minutes')) {
      context.handle(
        _tzOffsetMinutesMeta,
        tzOffsetMinutes.isAcceptableOrUnknown(
          data['tz_offset_minutes']!,
          _tzOffsetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('bmi')) {
      context.handle(
        _bmiMeta,
        bmi.isAcceptableOrUnknown(data['bmi']!, _bmiMeta),
      );
    }
    if (data.containsKey('waist_in')) {
      context.handle(
        _waistInMeta,
        waistIn.isAcceptableOrUnknown(data['waist_in']!, _waistInMeta),
      );
    }
    if (data.containsKey('hips_in')) {
      context.handle(
        _hipsInMeta,
        hipsIn.isAcceptableOrUnknown(data['hips_in']!, _hipsInMeta),
      );
    }
    if (data.containsKey('chest_in')) {
      context.handle(
        _chestInMeta,
        chestIn.isAcceptableOrUnknown(data['chest_in']!, _chestInMeta),
      );
    }
    if (data.containsKey('arm_in')) {
      context.handle(
        _armInMeta,
        armIn.isAcceptableOrUnknown(data['arm_in']!, _armInMeta),
      );
    }
    if (data.containsKey('thigh_in')) {
      context.handle(
        _thighInMeta,
        thighIn.isAcceptableOrUnknown(data['thigh_in']!, _thighInMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BodyMeasurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyMeasurement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      measuredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}measured_at'],
      )!,
      tzOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tz_offset_minutes'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      ),
      bmi: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bmi'],
      ),
      waistIn: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}waist_in'],
      ),
      hipsIn: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hips_in'],
      ),
      chestIn: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}chest_in'],
      ),
      armIn: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}arm_in'],
      ),
      thighIn: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}thigh_in'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $BodyMeasurementsTable createAlias(String alias) {
    return $BodyMeasurementsTable(attachedDatabase, alias);
  }
}

class BodyMeasurement extends DataClass implements Insertable<BodyMeasurement> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String userId;
  final DateTime measuredAt;
  final int tzOffsetMinutes;
  final String localDate;
  final double? weightKg;
  final double? heightCm;
  final double? bmi;
  final double? waistIn;
  final double? hipsIn;
  final double? chestIn;
  final double? armIn;
  final double? thighIn;
  final String? notes;
  const BodyMeasurement({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.userId,
    required this.measuredAt,
    required this.tzOffsetMinutes,
    required this.localDate,
    this.weightKg,
    this.heightCm,
    this.bmi,
    this.waistIn,
    this.hipsIn,
    this.chestIn,
    this.armIn,
    this.thighIn,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['user_id'] = Variable<String>(userId);
    map['measured_at'] = Variable<DateTime>(measuredAt);
    map['tz_offset_minutes'] = Variable<int>(tzOffsetMinutes);
    map['local_date'] = Variable<String>(localDate);
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || bmi != null) {
      map['bmi'] = Variable<double>(bmi);
    }
    if (!nullToAbsent || waistIn != null) {
      map['waist_in'] = Variable<double>(waistIn);
    }
    if (!nullToAbsent || hipsIn != null) {
      map['hips_in'] = Variable<double>(hipsIn);
    }
    if (!nullToAbsent || chestIn != null) {
      map['chest_in'] = Variable<double>(chestIn);
    }
    if (!nullToAbsent || armIn != null) {
      map['arm_in'] = Variable<double>(armIn);
    }
    if (!nullToAbsent || thighIn != null) {
      map['thigh_in'] = Variable<double>(thighIn);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  BodyMeasurementsCompanion toCompanion(bool nullToAbsent) {
    return BodyMeasurementsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      userId: Value(userId),
      measuredAt: Value(measuredAt),
      tzOffsetMinutes: Value(tzOffsetMinutes),
      localDate: Value(localDate),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      bmi: bmi == null && nullToAbsent ? const Value.absent() : Value(bmi),
      waistIn: waistIn == null && nullToAbsent
          ? const Value.absent()
          : Value(waistIn),
      hipsIn: hipsIn == null && nullToAbsent
          ? const Value.absent()
          : Value(hipsIn),
      chestIn: chestIn == null && nullToAbsent
          ? const Value.absent()
          : Value(chestIn),
      armIn: armIn == null && nullToAbsent
          ? const Value.absent()
          : Value(armIn),
      thighIn: thighIn == null && nullToAbsent
          ? const Value.absent()
          : Value(thighIn),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory BodyMeasurement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyMeasurement(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      userId: serializer.fromJson<String>(json['userId']),
      measuredAt: serializer.fromJson<DateTime>(json['measuredAt']),
      tzOffsetMinutes: serializer.fromJson<int>(json['tzOffsetMinutes']),
      localDate: serializer.fromJson<String>(json['localDate']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      bmi: serializer.fromJson<double?>(json['bmi']),
      waistIn: serializer.fromJson<double?>(json['waistIn']),
      hipsIn: serializer.fromJson<double?>(json['hipsIn']),
      chestIn: serializer.fromJson<double?>(json['chestIn']),
      armIn: serializer.fromJson<double?>(json['armIn']),
      thighIn: serializer.fromJson<double?>(json['thighIn']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'userId': serializer.toJson<String>(userId),
      'measuredAt': serializer.toJson<DateTime>(measuredAt),
      'tzOffsetMinutes': serializer.toJson<int>(tzOffsetMinutes),
      'localDate': serializer.toJson<String>(localDate),
      'weightKg': serializer.toJson<double?>(weightKg),
      'heightCm': serializer.toJson<double?>(heightCm),
      'bmi': serializer.toJson<double?>(bmi),
      'waistIn': serializer.toJson<double?>(waistIn),
      'hipsIn': serializer.toJson<double?>(hipsIn),
      'chestIn': serializer.toJson<double?>(chestIn),
      'armIn': serializer.toJson<double?>(armIn),
      'thighIn': serializer.toJson<double?>(thighIn),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  BodyMeasurement copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? userId,
    DateTime? measuredAt,
    int? tzOffsetMinutes,
    String? localDate,
    Value<double?> weightKg = const Value.absent(),
    Value<double?> heightCm = const Value.absent(),
    Value<double?> bmi = const Value.absent(),
    Value<double?> waistIn = const Value.absent(),
    Value<double?> hipsIn = const Value.absent(),
    Value<double?> chestIn = const Value.absent(),
    Value<double?> armIn = const Value.absent(),
    Value<double?> thighIn = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => BodyMeasurement(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    userId: userId ?? this.userId,
    measuredAt: measuredAt ?? this.measuredAt,
    tzOffsetMinutes: tzOffsetMinutes ?? this.tzOffsetMinutes,
    localDate: localDate ?? this.localDate,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    bmi: bmi.present ? bmi.value : this.bmi,
    waistIn: waistIn.present ? waistIn.value : this.waistIn,
    hipsIn: hipsIn.present ? hipsIn.value : this.hipsIn,
    chestIn: chestIn.present ? chestIn.value : this.chestIn,
    armIn: armIn.present ? armIn.value : this.armIn,
    thighIn: thighIn.present ? thighIn.value : this.thighIn,
    notes: notes.present ? notes.value : this.notes,
  );
  BodyMeasurement copyWithCompanion(BodyMeasurementsCompanion data) {
    return BodyMeasurement(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      userId: data.userId.present ? data.userId.value : this.userId,
      measuredAt: data.measuredAt.present
          ? data.measuredAt.value
          : this.measuredAt,
      tzOffsetMinutes: data.tzOffsetMinutes.present
          ? data.tzOffsetMinutes.value
          : this.tzOffsetMinutes,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      bmi: data.bmi.present ? data.bmi.value : this.bmi,
      waistIn: data.waistIn.present ? data.waistIn.value : this.waistIn,
      hipsIn: data.hipsIn.present ? data.hipsIn.value : this.hipsIn,
      chestIn: data.chestIn.present ? data.chestIn.value : this.chestIn,
      armIn: data.armIn.present ? data.armIn.value : this.armIn,
      thighIn: data.thighIn.present ? data.thighIn.value : this.thighIn,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurement(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('tzOffsetMinutes: $tzOffsetMinutes, ')
          ..write('localDate: $localDate, ')
          ..write('weightKg: $weightKg, ')
          ..write('heightCm: $heightCm, ')
          ..write('bmi: $bmi, ')
          ..write('waistIn: $waistIn, ')
          ..write('hipsIn: $hipsIn, ')
          ..write('chestIn: $chestIn, ')
          ..write('armIn: $armIn, ')
          ..write('thighIn: $thighIn, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    measuredAt,
    tzOffsetMinutes,
    localDate,
    weightKg,
    heightCm,
    bmi,
    waistIn,
    hipsIn,
    chestIn,
    armIn,
    thighIn,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyMeasurement &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.userId == this.userId &&
          other.measuredAt == this.measuredAt &&
          other.tzOffsetMinutes == this.tzOffsetMinutes &&
          other.localDate == this.localDate &&
          other.weightKg == this.weightKg &&
          other.heightCm == this.heightCm &&
          other.bmi == this.bmi &&
          other.waistIn == this.waistIn &&
          other.hipsIn == this.hipsIn &&
          other.chestIn == this.chestIn &&
          other.armIn == this.armIn &&
          other.thighIn == this.thighIn &&
          other.notes == this.notes);
}

class BodyMeasurementsCompanion extends UpdateCompanion<BodyMeasurement> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> userId;
  final Value<DateTime> measuredAt;
  final Value<int> tzOffsetMinutes;
  final Value<String> localDate;
  final Value<double?> weightKg;
  final Value<double?> heightCm;
  final Value<double?> bmi;
  final Value<double?> waistIn;
  final Value<double?> hipsIn;
  final Value<double?> chestIn;
  final Value<double?> armIn;
  final Value<double?> thighIn;
  final Value<String?> notes;
  final Value<int> rowid;
  const BodyMeasurementsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.measuredAt = const Value.absent(),
    this.tzOffsetMinutes = const Value.absent(),
    this.localDate = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.bmi = const Value.absent(),
    this.waistIn = const Value.absent(),
    this.hipsIn = const Value.absent(),
    this.chestIn = const Value.absent(),
    this.armIn = const Value.absent(),
    this.thighIn = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BodyMeasurementsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String userId,
    required DateTime measuredAt,
    this.tzOffsetMinutes = const Value.absent(),
    required String localDate,
    this.weightKg = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.bmi = const Value.absent(),
    this.waistIn = const Value.absent(),
    this.hipsIn = const Value.absent(),
    this.chestIn = const Value.absent(),
    this.armIn = const Value.absent(),
    this.thighIn = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       userId = Value(userId),
       measuredAt = Value(measuredAt),
       localDate = Value(localDate);
  static Insertable<BodyMeasurement> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? userId,
    Expression<DateTime>? measuredAt,
    Expression<int>? tzOffsetMinutes,
    Expression<String>? localDate,
    Expression<double>? weightKg,
    Expression<double>? heightCm,
    Expression<double>? bmi,
    Expression<double>? waistIn,
    Expression<double>? hipsIn,
    Expression<double>? chestIn,
    Expression<double>? armIn,
    Expression<double>? thighIn,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (userId != null) 'user_id': userId,
      if (measuredAt != null) 'measured_at': measuredAt,
      if (tzOffsetMinutes != null) 'tz_offset_minutes': tzOffsetMinutes,
      if (localDate != null) 'local_date': localDate,
      if (weightKg != null) 'weight_kg': weightKg,
      if (heightCm != null) 'height_cm': heightCm,
      if (bmi != null) 'bmi': bmi,
      if (waistIn != null) 'waist_in': waistIn,
      if (hipsIn != null) 'hips_in': hipsIn,
      if (chestIn != null) 'chest_in': chestIn,
      if (armIn != null) 'arm_in': armIn,
      if (thighIn != null) 'thigh_in': thighIn,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BodyMeasurementsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? userId,
    Value<DateTime>? measuredAt,
    Value<int>? tzOffsetMinutes,
    Value<String>? localDate,
    Value<double?>? weightKg,
    Value<double?>? heightCm,
    Value<double?>? bmi,
    Value<double?>? waistIn,
    Value<double?>? hipsIn,
    Value<double?>? chestIn,
    Value<double?>? armIn,
    Value<double?>? thighIn,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return BodyMeasurementsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      userId: userId ?? this.userId,
      measuredAt: measuredAt ?? this.measuredAt,
      tzOffsetMinutes: tzOffsetMinutes ?? this.tzOffsetMinutes,
      localDate: localDate ?? this.localDate,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      bmi: bmi ?? this.bmi,
      waistIn: waistIn ?? this.waistIn,
      hipsIn: hipsIn ?? this.hipsIn,
      chestIn: chestIn ?? this.chestIn,
      armIn: armIn ?? this.armIn,
      thighIn: thighIn ?? this.thighIn,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (measuredAt.present) {
      map['measured_at'] = Variable<DateTime>(measuredAt.value);
    }
    if (tzOffsetMinutes.present) {
      map['tz_offset_minutes'] = Variable<int>(tzOffsetMinutes.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (bmi.present) {
      map['bmi'] = Variable<double>(bmi.value);
    }
    if (waistIn.present) {
      map['waist_in'] = Variable<double>(waistIn.value);
    }
    if (hipsIn.present) {
      map['hips_in'] = Variable<double>(hipsIn.value);
    }
    if (chestIn.present) {
      map['chest_in'] = Variable<double>(chestIn.value);
    }
    if (armIn.present) {
      map['arm_in'] = Variable<double>(armIn.value);
    }
    if (thighIn.present) {
      map['thigh_in'] = Variable<double>(thighIn.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('tzOffsetMinutes: $tzOffsetMinutes, ')
          ..write('localDate: $localDate, ')
          ..write('weightKg: $weightKg, ')
          ..write('heightCm: $heightCm, ')
          ..write('bmi: $bmi, ')
          ..write('waistIn: $waistIn, ')
          ..write('hipsIn: $hipsIn, ')
          ..write('chestIn: $chestIn, ')
          ..write('armIn: $armIn, ')
          ..write('thighIn: $thighIn, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SleepTargetsTable extends SleepTargets
    with TableInfo<$SleepTargetsTable, SleepTarget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SleepTargetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bedtimeMinutesMeta = const VerificationMeta(
    'bedtimeMinutes',
  );
  @override
  late final GeneratedColumn<int> bedtimeMinutes = GeneratedColumn<int>(
    'bedtime_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wakeMinutesMeta = const VerificationMeta(
    'wakeMinutes',
  );
  @override
  late final GeneratedColumn<int> wakeMinutes = GeneratedColumn<int>(
    'wake_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    bedtimeMinutes,
    wakeMinutes,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sleep_targets';
  @override
  VerificationContext validateIntegrity(
    Insertable<SleepTarget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('bedtime_minutes')) {
      context.handle(
        _bedtimeMinutesMeta,
        bedtimeMinutes.isAcceptableOrUnknown(
          data['bedtime_minutes']!,
          _bedtimeMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bedtimeMinutesMeta);
    }
    if (data.containsKey('wake_minutes')) {
      context.handle(
        _wakeMinutesMeta,
        wakeMinutes.isAcceptableOrUnknown(
          data['wake_minutes']!,
          _wakeMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wakeMinutesMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  SleepTarget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SleepTarget(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      bedtimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bedtime_minutes'],
      )!,
      wakeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wake_minutes'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SleepTargetsTable createAlias(String alias) {
    return $SleepTargetsTable(attachedDatabase, alias);
  }
}

class SleepTarget extends DataClass implements Insertable<SleepTarget> {
  final String userId;
  final int bedtimeMinutes;
  final int wakeMinutes;
  final DateTime updatedAt;
  const SleepTarget({
    required this.userId,
    required this.bedtimeMinutes,
    required this.wakeMinutes,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['bedtime_minutes'] = Variable<int>(bedtimeMinutes);
    map['wake_minutes'] = Variable<int>(wakeMinutes);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SleepTargetsCompanion toCompanion(bool nullToAbsent) {
    return SleepTargetsCompanion(
      userId: Value(userId),
      bedtimeMinutes: Value(bedtimeMinutes),
      wakeMinutes: Value(wakeMinutes),
      updatedAt: Value(updatedAt),
    );
  }

  factory SleepTarget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SleepTarget(
      userId: serializer.fromJson<String>(json['userId']),
      bedtimeMinutes: serializer.fromJson<int>(json['bedtimeMinutes']),
      wakeMinutes: serializer.fromJson<int>(json['wakeMinutes']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'bedtimeMinutes': serializer.toJson<int>(bedtimeMinutes),
      'wakeMinutes': serializer.toJson<int>(wakeMinutes),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SleepTarget copyWith({
    String? userId,
    int? bedtimeMinutes,
    int? wakeMinutes,
    DateTime? updatedAt,
  }) => SleepTarget(
    userId: userId ?? this.userId,
    bedtimeMinutes: bedtimeMinutes ?? this.bedtimeMinutes,
    wakeMinutes: wakeMinutes ?? this.wakeMinutes,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SleepTarget copyWithCompanion(SleepTargetsCompanion data) {
    return SleepTarget(
      userId: data.userId.present ? data.userId.value : this.userId,
      bedtimeMinutes: data.bedtimeMinutes.present
          ? data.bedtimeMinutes.value
          : this.bedtimeMinutes,
      wakeMinutes: data.wakeMinutes.present
          ? data.wakeMinutes.value
          : this.wakeMinutes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SleepTarget(')
          ..write('userId: $userId, ')
          ..write('bedtimeMinutes: $bedtimeMinutes, ')
          ..write('wakeMinutes: $wakeMinutes, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userId, bedtimeMinutes, wakeMinutes, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SleepTarget &&
          other.userId == this.userId &&
          other.bedtimeMinutes == this.bedtimeMinutes &&
          other.wakeMinutes == this.wakeMinutes &&
          other.updatedAt == this.updatedAt);
}

class SleepTargetsCompanion extends UpdateCompanion<SleepTarget> {
  final Value<String> userId;
  final Value<int> bedtimeMinutes;
  final Value<int> wakeMinutes;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SleepTargetsCompanion({
    this.userId = const Value.absent(),
    this.bedtimeMinutes = const Value.absent(),
    this.wakeMinutes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SleepTargetsCompanion.insert({
    required String userId,
    required int bedtimeMinutes,
    required int wakeMinutes,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       bedtimeMinutes = Value(bedtimeMinutes),
       wakeMinutes = Value(wakeMinutes),
       updatedAt = Value(updatedAt);
  static Insertable<SleepTarget> custom({
    Expression<String>? userId,
    Expression<int>? bedtimeMinutes,
    Expression<int>? wakeMinutes,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (bedtimeMinutes != null) 'bedtime_minutes': bedtimeMinutes,
      if (wakeMinutes != null) 'wake_minutes': wakeMinutes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SleepTargetsCompanion copyWith({
    Value<String>? userId,
    Value<int>? bedtimeMinutes,
    Value<int>? wakeMinutes,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SleepTargetsCompanion(
      userId: userId ?? this.userId,
      bedtimeMinutes: bedtimeMinutes ?? this.bedtimeMinutes,
      wakeMinutes: wakeMinutes ?? this.wakeMinutes,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (bedtimeMinutes.present) {
      map['bedtime_minutes'] = Variable<int>(bedtimeMinutes.value);
    }
    if (wakeMinutes.present) {
      map['wake_minutes'] = Variable<int>(wakeMinutes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SleepTargetsCompanion(')
          ..write('userId: $userId, ')
          ..write('bedtimeMinutes: $bedtimeMinutes, ')
          ..write('wakeMinutes: $wakeMinutes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SleepLogsTable extends SleepLogs
    with TableInfo<$SleepLogsTable, SleepLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SleepLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bedtimeAtMeta = const VerificationMeta(
    'bedtimeAt',
  );
  @override
  late final GeneratedColumn<DateTime> bedtimeAt = GeneratedColumn<DateTime>(
    'bedtime_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wakeAtMeta = const VerificationMeta('wakeAt');
  @override
  late final GeneratedColumn<DateTime> wakeAt = GeneratedColumn<DateTime>(
    'wake_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tzOffsetMinutesMeta = const VerificationMeta(
    'tzOffsetMinutes',
  );
  @override
  late final GeneratedColumn<int> tzOffsetMinutes = GeneratedColumn<int>(
    'tz_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    bedtimeAt,
    wakeAt,
    durationMinutes,
    tzOffsetMinutes,
    localDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sleep_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SleepLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('bedtime_at')) {
      context.handle(
        _bedtimeAtMeta,
        bedtimeAt.isAcceptableOrUnknown(data['bedtime_at']!, _bedtimeAtMeta),
      );
    } else if (isInserting) {
      context.missing(_bedtimeAtMeta);
    }
    if (data.containsKey('wake_at')) {
      context.handle(
        _wakeAtMeta,
        wakeAt.isAcceptableOrUnknown(data['wake_at']!, _wakeAtMeta),
      );
    } else if (isInserting) {
      context.missing(_wakeAtMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('tz_offset_minutes')) {
      context.handle(
        _tzOffsetMinutesMeta,
        tzOffsetMinutes.isAcceptableOrUnknown(
          data['tz_offset_minutes']!,
          _tzOffsetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SleepLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SleepLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      bedtimeAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}bedtime_at'],
      )!,
      wakeAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}wake_at'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      tzOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tz_offset_minutes'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
    );
  }

  @override
  $SleepLogsTable createAlias(String alias) {
    return $SleepLogsTable(attachedDatabase, alias);
  }
}

class SleepLog extends DataClass implements Insertable<SleepLog> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String userId;
  final DateTime bedtimeAt;
  final DateTime wakeAt;
  final int durationMinutes;
  final int tzOffsetMinutes;

  /// Date of waking.
  final String localDate;
  const SleepLog({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.userId,
    required this.bedtimeAt,
    required this.wakeAt,
    required this.durationMinutes,
    required this.tzOffsetMinutes,
    required this.localDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['user_id'] = Variable<String>(userId);
    map['bedtime_at'] = Variable<DateTime>(bedtimeAt);
    map['wake_at'] = Variable<DateTime>(wakeAt);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['tz_offset_minutes'] = Variable<int>(tzOffsetMinutes);
    map['local_date'] = Variable<String>(localDate);
    return map;
  }

  SleepLogsCompanion toCompanion(bool nullToAbsent) {
    return SleepLogsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      userId: Value(userId),
      bedtimeAt: Value(bedtimeAt),
      wakeAt: Value(wakeAt),
      durationMinutes: Value(durationMinutes),
      tzOffsetMinutes: Value(tzOffsetMinutes),
      localDate: Value(localDate),
    );
  }

  factory SleepLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SleepLog(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      userId: serializer.fromJson<String>(json['userId']),
      bedtimeAt: serializer.fromJson<DateTime>(json['bedtimeAt']),
      wakeAt: serializer.fromJson<DateTime>(json['wakeAt']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      tzOffsetMinutes: serializer.fromJson<int>(json['tzOffsetMinutes']),
      localDate: serializer.fromJson<String>(json['localDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'userId': serializer.toJson<String>(userId),
      'bedtimeAt': serializer.toJson<DateTime>(bedtimeAt),
      'wakeAt': serializer.toJson<DateTime>(wakeAt),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'tzOffsetMinutes': serializer.toJson<int>(tzOffsetMinutes),
      'localDate': serializer.toJson<String>(localDate),
    };
  }

  SleepLog copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? userId,
    DateTime? bedtimeAt,
    DateTime? wakeAt,
    int? durationMinutes,
    int? tzOffsetMinutes,
    String? localDate,
  }) => SleepLog(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    userId: userId ?? this.userId,
    bedtimeAt: bedtimeAt ?? this.bedtimeAt,
    wakeAt: wakeAt ?? this.wakeAt,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    tzOffsetMinutes: tzOffsetMinutes ?? this.tzOffsetMinutes,
    localDate: localDate ?? this.localDate,
  );
  SleepLog copyWithCompanion(SleepLogsCompanion data) {
    return SleepLog(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      userId: data.userId.present ? data.userId.value : this.userId,
      bedtimeAt: data.bedtimeAt.present ? data.bedtimeAt.value : this.bedtimeAt,
      wakeAt: data.wakeAt.present ? data.wakeAt.value : this.wakeAt,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      tzOffsetMinutes: data.tzOffsetMinutes.present
          ? data.tzOffsetMinutes.value
          : this.tzOffsetMinutes,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SleepLog(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('bedtimeAt: $bedtimeAt, ')
          ..write('wakeAt: $wakeAt, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('tzOffsetMinutes: $tzOffsetMinutes, ')
          ..write('localDate: $localDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    bedtimeAt,
    wakeAt,
    durationMinutes,
    tzOffsetMinutes,
    localDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SleepLog &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.userId == this.userId &&
          other.bedtimeAt == this.bedtimeAt &&
          other.wakeAt == this.wakeAt &&
          other.durationMinutes == this.durationMinutes &&
          other.tzOffsetMinutes == this.tzOffsetMinutes &&
          other.localDate == this.localDate);
}

class SleepLogsCompanion extends UpdateCompanion<SleepLog> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> userId;
  final Value<DateTime> bedtimeAt;
  final Value<DateTime> wakeAt;
  final Value<int> durationMinutes;
  final Value<int> tzOffsetMinutes;
  final Value<String> localDate;
  final Value<int> rowid;
  const SleepLogsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.bedtimeAt = const Value.absent(),
    this.wakeAt = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.tzOffsetMinutes = const Value.absent(),
    this.localDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SleepLogsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String userId,
    required DateTime bedtimeAt,
    required DateTime wakeAt,
    required int durationMinutes,
    this.tzOffsetMinutes = const Value.absent(),
    required String localDate,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       userId = Value(userId),
       bedtimeAt = Value(bedtimeAt),
       wakeAt = Value(wakeAt),
       durationMinutes = Value(durationMinutes),
       localDate = Value(localDate);
  static Insertable<SleepLog> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? userId,
    Expression<DateTime>? bedtimeAt,
    Expression<DateTime>? wakeAt,
    Expression<int>? durationMinutes,
    Expression<int>? tzOffsetMinutes,
    Expression<String>? localDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (userId != null) 'user_id': userId,
      if (bedtimeAt != null) 'bedtime_at': bedtimeAt,
      if (wakeAt != null) 'wake_at': wakeAt,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (tzOffsetMinutes != null) 'tz_offset_minutes': tzOffsetMinutes,
      if (localDate != null) 'local_date': localDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SleepLogsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? userId,
    Value<DateTime>? bedtimeAt,
    Value<DateTime>? wakeAt,
    Value<int>? durationMinutes,
    Value<int>? tzOffsetMinutes,
    Value<String>? localDate,
    Value<int>? rowid,
  }) {
    return SleepLogsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      userId: userId ?? this.userId,
      bedtimeAt: bedtimeAt ?? this.bedtimeAt,
      wakeAt: wakeAt ?? this.wakeAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      tzOffsetMinutes: tzOffsetMinutes ?? this.tzOffsetMinutes,
      localDate: localDate ?? this.localDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (bedtimeAt.present) {
      map['bedtime_at'] = Variable<DateTime>(bedtimeAt.value);
    }
    if (wakeAt.present) {
      map['wake_at'] = Variable<DateTime>(wakeAt.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (tzOffsetMinutes.present) {
      map['tz_offset_minutes'] = Variable<int>(tzOffsetMinutes.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SleepLogsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('bedtimeAt: $bedtimeAt, ')
          ..write('wakeAt: $wakeAt, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('tzOffsetMinutes: $tzOffsetMinutes, ')
          ..write('localDate: $localDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RestDaysTable extends RestDays with TableInfo<$RestDaysTable, RestDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RestDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    localDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rest_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<RestDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RestDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RestDay(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
    );
  }

  @override
  $RestDaysTable createAlias(String alias) {
    return $RestDaysTable(attachedDatabase, alias);
  }
}

class RestDay extends DataClass implements Insertable<RestDay> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String userId;
  final String localDate;
  const RestDay({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.userId,
    required this.localDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['user_id'] = Variable<String>(userId);
    map['local_date'] = Variable<String>(localDate);
    return map;
  }

  RestDaysCompanion toCompanion(bool nullToAbsent) {
    return RestDaysCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      userId: Value(userId),
      localDate: Value(localDate),
    );
  }

  factory RestDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RestDay(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      userId: serializer.fromJson<String>(json['userId']),
      localDate: serializer.fromJson<String>(json['localDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'userId': serializer.toJson<String>(userId),
      'localDate': serializer.toJson<String>(localDate),
    };
  }

  RestDay copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? userId,
    String? localDate,
  }) => RestDay(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    userId: userId ?? this.userId,
    localDate: localDate ?? this.localDate,
  );
  RestDay copyWithCompanion(RestDaysCompanion data) {
    return RestDay(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      userId: data.userId.present ? data.userId.value : this.userId,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RestDay(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('localDate: $localDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, deletedAt, userId, localDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RestDay &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.userId == this.userId &&
          other.localDate == this.localDate);
}

class RestDaysCompanion extends UpdateCompanion<RestDay> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> userId;
  final Value<String> localDate;
  final Value<int> rowid;
  const RestDaysCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.localDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RestDaysCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String userId,
    required String localDate,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       userId = Value(userId),
       localDate = Value(localDate);
  static Insertable<RestDay> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? userId,
    Expression<String>? localDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (userId != null) 'user_id': userId,
      if (localDate != null) 'local_date': localDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RestDaysCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? userId,
    Value<String>? localDate,
    Value<int>? rowid,
  }) {
    return RestDaysCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      userId: userId ?? this.userId,
      localDate: localDate ?? this.localDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RestDaysCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('localDate: $localDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StreakStatesTable extends StreakStates
    with TableInfo<$StreakStatesTable, StreakState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StreakStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentStreakMeta = const VerificationMeta(
    'currentStreak',
  );
  @override
  late final GeneratedColumn<int> currentStreak = GeneratedColumn<int>(
    'current_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _longestStreakMeta = const VerificationMeta(
    'longestStreak',
  );
  @override
  late final GeneratedColumn<int> longestStreak = GeneratedColumn<int>(
    'longest_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastCountedDateMeta = const VerificationMeta(
    'lastCountedDate',
  );
  @override
  late final GeneratedColumn<String> lastCountedDate = GeneratedColumn<String>(
    'last_counted_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _freezeAvailableMeta = const VerificationMeta(
    'freezeAvailable',
  );
  @override
  late final GeneratedColumn<bool> freezeAvailable = GeneratedColumn<bool>(
    'freeze_available',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("freeze_available" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _freezeLastGrantedOnMeta =
      const VerificationMeta('freezeLastGrantedOn');
  @override
  late final GeneratedColumn<String> freezeLastGrantedOn =
      GeneratedColumn<String>(
        'freeze_last_granted_on',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    scope,
    currentStreak,
    longestStreak,
    lastCountedDate,
    freezeAvailable,
    freezeLastGrantedOn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'streak_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<StreakState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('current_streak')) {
      context.handle(
        _currentStreakMeta,
        currentStreak.isAcceptableOrUnknown(
          data['current_streak']!,
          _currentStreakMeta,
        ),
      );
    }
    if (data.containsKey('longest_streak')) {
      context.handle(
        _longestStreakMeta,
        longestStreak.isAcceptableOrUnknown(
          data['longest_streak']!,
          _longestStreakMeta,
        ),
      );
    }
    if (data.containsKey('last_counted_date')) {
      context.handle(
        _lastCountedDateMeta,
        lastCountedDate.isAcceptableOrUnknown(
          data['last_counted_date']!,
          _lastCountedDateMeta,
        ),
      );
    }
    if (data.containsKey('freeze_available')) {
      context.handle(
        _freezeAvailableMeta,
        freezeAvailable.isAcceptableOrUnknown(
          data['freeze_available']!,
          _freezeAvailableMeta,
        ),
      );
    }
    if (data.containsKey('freeze_last_granted_on')) {
      context.handle(
        _freezeLastGrantedOnMeta,
        freezeLastGrantedOn.isAcceptableOrUnknown(
          data['freeze_last_granted_on']!,
          _freezeLastGrantedOnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, scope};
  @override
  StreakState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StreakState(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      currentStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_streak'],
      )!,
      longestStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}longest_streak'],
      )!,
      lastCountedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_counted_date'],
      ),
      freezeAvailable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}freeze_available'],
      )!,
      freezeLastGrantedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}freeze_last_granted_on'],
      ),
    );
  }

  @override
  $StreakStatesTable createAlias(String alias) {
    return $StreakStatesTable(attachedDatabase, alias);
  }
}

class StreakState extends DataClass implements Insertable<StreakState> {
  final String userId;

  /// `overall`, `workout_type:<id>` or `habit:<id>`.
  final String scope;
  final int currentStreak;
  final int longestStreak;
  final String? lastCountedDate;
  final bool freezeAvailable;
  final String? freezeLastGrantedOn;
  const StreakState({
    required this.userId,
    required this.scope,
    required this.currentStreak,
    required this.longestStreak,
    this.lastCountedDate,
    required this.freezeAvailable,
    this.freezeLastGrantedOn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['scope'] = Variable<String>(scope);
    map['current_streak'] = Variable<int>(currentStreak);
    map['longest_streak'] = Variable<int>(longestStreak);
    if (!nullToAbsent || lastCountedDate != null) {
      map['last_counted_date'] = Variable<String>(lastCountedDate);
    }
    map['freeze_available'] = Variable<bool>(freezeAvailable);
    if (!nullToAbsent || freezeLastGrantedOn != null) {
      map['freeze_last_granted_on'] = Variable<String>(freezeLastGrantedOn);
    }
    return map;
  }

  StreakStatesCompanion toCompanion(bool nullToAbsent) {
    return StreakStatesCompanion(
      userId: Value(userId),
      scope: Value(scope),
      currentStreak: Value(currentStreak),
      longestStreak: Value(longestStreak),
      lastCountedDate: lastCountedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCountedDate),
      freezeAvailable: Value(freezeAvailable),
      freezeLastGrantedOn: freezeLastGrantedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(freezeLastGrantedOn),
    );
  }

  factory StreakState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StreakState(
      userId: serializer.fromJson<String>(json['userId']),
      scope: serializer.fromJson<String>(json['scope']),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
      longestStreak: serializer.fromJson<int>(json['longestStreak']),
      lastCountedDate: serializer.fromJson<String?>(json['lastCountedDate']),
      freezeAvailable: serializer.fromJson<bool>(json['freezeAvailable']),
      freezeLastGrantedOn: serializer.fromJson<String?>(
        json['freezeLastGrantedOn'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'scope': serializer.toJson<String>(scope),
      'currentStreak': serializer.toJson<int>(currentStreak),
      'longestStreak': serializer.toJson<int>(longestStreak),
      'lastCountedDate': serializer.toJson<String?>(lastCountedDate),
      'freezeAvailable': serializer.toJson<bool>(freezeAvailable),
      'freezeLastGrantedOn': serializer.toJson<String?>(freezeLastGrantedOn),
    };
  }

  StreakState copyWith({
    String? userId,
    String? scope,
    int? currentStreak,
    int? longestStreak,
    Value<String?> lastCountedDate = const Value.absent(),
    bool? freezeAvailable,
    Value<String?> freezeLastGrantedOn = const Value.absent(),
  }) => StreakState(
    userId: userId ?? this.userId,
    scope: scope ?? this.scope,
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    lastCountedDate: lastCountedDate.present
        ? lastCountedDate.value
        : this.lastCountedDate,
    freezeAvailable: freezeAvailable ?? this.freezeAvailable,
    freezeLastGrantedOn: freezeLastGrantedOn.present
        ? freezeLastGrantedOn.value
        : this.freezeLastGrantedOn,
  );
  StreakState copyWithCompanion(StreakStatesCompanion data) {
    return StreakState(
      userId: data.userId.present ? data.userId.value : this.userId,
      scope: data.scope.present ? data.scope.value : this.scope,
      currentStreak: data.currentStreak.present
          ? data.currentStreak.value
          : this.currentStreak,
      longestStreak: data.longestStreak.present
          ? data.longestStreak.value
          : this.longestStreak,
      lastCountedDate: data.lastCountedDate.present
          ? data.lastCountedDate.value
          : this.lastCountedDate,
      freezeAvailable: data.freezeAvailable.present
          ? data.freezeAvailable.value
          : this.freezeAvailable,
      freezeLastGrantedOn: data.freezeLastGrantedOn.present
          ? data.freezeLastGrantedOn.value
          : this.freezeLastGrantedOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StreakState(')
          ..write('userId: $userId, ')
          ..write('scope: $scope, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('lastCountedDate: $lastCountedDate, ')
          ..write('freezeAvailable: $freezeAvailable, ')
          ..write('freezeLastGrantedOn: $freezeLastGrantedOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    scope,
    currentStreak,
    longestStreak,
    lastCountedDate,
    freezeAvailable,
    freezeLastGrantedOn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StreakState &&
          other.userId == this.userId &&
          other.scope == this.scope &&
          other.currentStreak == this.currentStreak &&
          other.longestStreak == this.longestStreak &&
          other.lastCountedDate == this.lastCountedDate &&
          other.freezeAvailable == this.freezeAvailable &&
          other.freezeLastGrantedOn == this.freezeLastGrantedOn);
}

class StreakStatesCompanion extends UpdateCompanion<StreakState> {
  final Value<String> userId;
  final Value<String> scope;
  final Value<int> currentStreak;
  final Value<int> longestStreak;
  final Value<String?> lastCountedDate;
  final Value<bool> freezeAvailable;
  final Value<String?> freezeLastGrantedOn;
  final Value<int> rowid;
  const StreakStatesCompanion({
    this.userId = const Value.absent(),
    this.scope = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.lastCountedDate = const Value.absent(),
    this.freezeAvailable = const Value.absent(),
    this.freezeLastGrantedOn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StreakStatesCompanion.insert({
    required String userId,
    required String scope,
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.lastCountedDate = const Value.absent(),
    this.freezeAvailable = const Value.absent(),
    this.freezeLastGrantedOn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       scope = Value(scope);
  static Insertable<StreakState> custom({
    Expression<String>? userId,
    Expression<String>? scope,
    Expression<int>? currentStreak,
    Expression<int>? longestStreak,
    Expression<String>? lastCountedDate,
    Expression<bool>? freezeAvailable,
    Expression<String>? freezeLastGrantedOn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (scope != null) 'scope': scope,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (longestStreak != null) 'longest_streak': longestStreak,
      if (lastCountedDate != null) 'last_counted_date': lastCountedDate,
      if (freezeAvailable != null) 'freeze_available': freezeAvailable,
      if (freezeLastGrantedOn != null)
        'freeze_last_granted_on': freezeLastGrantedOn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StreakStatesCompanion copyWith({
    Value<String>? userId,
    Value<String>? scope,
    Value<int>? currentStreak,
    Value<int>? longestStreak,
    Value<String?>? lastCountedDate,
    Value<bool>? freezeAvailable,
    Value<String?>? freezeLastGrantedOn,
    Value<int>? rowid,
  }) {
    return StreakStatesCompanion(
      userId: userId ?? this.userId,
      scope: scope ?? this.scope,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCountedDate: lastCountedDate ?? this.lastCountedDate,
      freezeAvailable: freezeAvailable ?? this.freezeAvailable,
      freezeLastGrantedOn: freezeLastGrantedOn ?? this.freezeLastGrantedOn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    if (longestStreak.present) {
      map['longest_streak'] = Variable<int>(longestStreak.value);
    }
    if (lastCountedDate.present) {
      map['last_counted_date'] = Variable<String>(lastCountedDate.value);
    }
    if (freezeAvailable.present) {
      map['freeze_available'] = Variable<bool>(freezeAvailable.value);
    }
    if (freezeLastGrantedOn.present) {
      map['freeze_last_granted_on'] = Variable<String>(
        freezeLastGrantedOn.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StreakStatesCompanion(')
          ..write('userId: $userId, ')
          ..write('scope: $scope, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('lastCountedDate: $lastCountedDate, ')
          ..write('freezeAvailable: $freezeAvailable, ')
          ..write('freezeLastGrantedOn: $freezeLastGrantedOn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BadgesAwardedTable extends BadgesAwarded
    with TableInfo<$BadgesAwardedTable, BadgesAwardedData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BadgesAwardedTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _badgeKeyMeta = const VerificationMeta(
    'badgeKey',
  );
  @override
  late final GeneratedColumn<String> badgeKey = GeneratedColumn<String>(
    'badge_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _awardedAtMeta = const VerificationMeta(
    'awardedAt',
  );
  @override
  late final GeneratedColumn<DateTime> awardedAt = GeneratedColumn<DateTime>(
    'awarded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextMeta = const VerificationMeta(
    'context',
  );
  @override
  late final GeneratedColumn<String> context = GeneratedColumn<String>(
    'context',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    badgeKey,
    awardedAt,
    context,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'badges_awarded';
  @override
  VerificationContext validateIntegrity(
    Insertable<BadgesAwardedData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('badge_key')) {
      context.handle(
        _badgeKeyMeta,
        badgeKey.isAcceptableOrUnknown(data['badge_key']!, _badgeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_badgeKeyMeta);
    }
    if (data.containsKey('awarded_at')) {
      context.handle(
        _awardedAtMeta,
        awardedAt.isAcceptableOrUnknown(data['awarded_at']!, _awardedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_awardedAtMeta);
    }
    if (data.containsKey('context')) {
      context.handle(
        _contextMeta,
        this.context.isAcceptableOrUnknown(data['context']!, _contextMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BadgesAwardedData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BadgesAwardedData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      badgeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}badge_key'],
      )!,
      awardedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}awarded_at'],
      )!,
      context: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context'],
      )!,
    );
  }

  @override
  $BadgesAwardedTable createAlias(String alias) {
    return $BadgesAwardedTable(attachedDatabase, alias);
  }
}

class BadgesAwardedData extends DataClass
    implements Insertable<BadgesAwardedData> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String userId;
  final String badgeKey;
  final DateTime awardedAt;
  final String context;
  const BadgesAwardedData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.userId,
    required this.badgeKey,
    required this.awardedAt,
    required this.context,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['user_id'] = Variable<String>(userId);
    map['badge_key'] = Variable<String>(badgeKey);
    map['awarded_at'] = Variable<DateTime>(awardedAt);
    map['context'] = Variable<String>(context);
    return map;
  }

  BadgesAwardedCompanion toCompanion(bool nullToAbsent) {
    return BadgesAwardedCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      userId: Value(userId),
      badgeKey: Value(badgeKey),
      awardedAt: Value(awardedAt),
      context: Value(context),
    );
  }

  factory BadgesAwardedData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BadgesAwardedData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      userId: serializer.fromJson<String>(json['userId']),
      badgeKey: serializer.fromJson<String>(json['badgeKey']),
      awardedAt: serializer.fromJson<DateTime>(json['awardedAt']),
      context: serializer.fromJson<String>(json['context']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'userId': serializer.toJson<String>(userId),
      'badgeKey': serializer.toJson<String>(badgeKey),
      'awardedAt': serializer.toJson<DateTime>(awardedAt),
      'context': serializer.toJson<String>(context),
    };
  }

  BadgesAwardedData copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? userId,
    String? badgeKey,
    DateTime? awardedAt,
    String? context,
  }) => BadgesAwardedData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    userId: userId ?? this.userId,
    badgeKey: badgeKey ?? this.badgeKey,
    awardedAt: awardedAt ?? this.awardedAt,
    context: context ?? this.context,
  );
  BadgesAwardedData copyWithCompanion(BadgesAwardedCompanion data) {
    return BadgesAwardedData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      userId: data.userId.present ? data.userId.value : this.userId,
      badgeKey: data.badgeKey.present ? data.badgeKey.value : this.badgeKey,
      awardedAt: data.awardedAt.present ? data.awardedAt.value : this.awardedAt,
      context: data.context.present ? data.context.value : this.context,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BadgesAwardedData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('badgeKey: $badgeKey, ')
          ..write('awardedAt: $awardedAt, ')
          ..write('context: $context')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    badgeKey,
    awardedAt,
    context,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BadgesAwardedData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.userId == this.userId &&
          other.badgeKey == this.badgeKey &&
          other.awardedAt == this.awardedAt &&
          other.context == this.context);
}

class BadgesAwardedCompanion extends UpdateCompanion<BadgesAwardedData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> userId;
  final Value<String> badgeKey;
  final Value<DateTime> awardedAt;
  final Value<String> context;
  final Value<int> rowid;
  const BadgesAwardedCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.badgeKey = const Value.absent(),
    this.awardedAt = const Value.absent(),
    this.context = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BadgesAwardedCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String userId,
    required String badgeKey,
    required DateTime awardedAt,
    this.context = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       userId = Value(userId),
       badgeKey = Value(badgeKey),
       awardedAt = Value(awardedAt);
  static Insertable<BadgesAwardedData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? userId,
    Expression<String>? badgeKey,
    Expression<DateTime>? awardedAt,
    Expression<String>? context,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (userId != null) 'user_id': userId,
      if (badgeKey != null) 'badge_key': badgeKey,
      if (awardedAt != null) 'awarded_at': awardedAt,
      if (context != null) 'context': context,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BadgesAwardedCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? userId,
    Value<String>? badgeKey,
    Value<DateTime>? awardedAt,
    Value<String>? context,
    Value<int>? rowid,
  }) {
    return BadgesAwardedCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      userId: userId ?? this.userId,
      badgeKey: badgeKey ?? this.badgeKey,
      awardedAt: awardedAt ?? this.awardedAt,
      context: context ?? this.context,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (badgeKey.present) {
      map['badge_key'] = Variable<String>(badgeKey.value);
    }
    if (awardedAt.present) {
      map['awarded_at'] = Variable<DateTime>(awardedAt.value);
    }
    if (context.present) {
      map['context'] = Variable<String>(context.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BadgesAwardedCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('badgeKey: $badgeKey, ')
          ..write('awardedAt: $awardedAt, ')
          ..write('context: $context, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScreenTimeDailyTable extends ScreenTimeDaily
    with TableInfo<$ScreenTimeDailyTable, ScreenTimeDailyData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScreenTimeDailyTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMinutesMeta = const VerificationMeta(
    'totalMinutes',
  );
  @override
  late final GeneratedColumn<int> totalMinutes = GeneratedColumn<int>(
    'total_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMinutesMeta = const VerificationMeta(
    'categoryMinutes',
  );
  @override
  late final GeneratedColumn<String> categoryMinutes = GeneratedColumn<String>(
    'category_minutes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _lateEveningMinutesMeta =
      const VerificationMeta('lateEveningMinutes');
  @override
  late final GeneratedColumn<int> lateEveningMinutes = GeneratedColumn<int>(
    'late_evening_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _shareInGroupsMeta = const VerificationMeta(
    'shareInGroups',
  );
  @override
  late final GeneratedColumn<bool> shareInGroups = GeneratedColumn<bool>(
    'share_in_groups',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("share_in_groups" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ScreenTimeSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('automatic'),
      ).withConverter<ScreenTimeSource>($ScreenTimeDailyTable.$convertersource);
  static const VerificationMeta _targetMinutesMeta = const VerificationMeta(
    'targetMinutes',
  );
  @override
  late final GeneratedColumn<int> targetMinutes = GeneratedColumn<int>(
    'target_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    localDate,
    totalMinutes,
    categoryMinutes,
    lateEveningMinutes,
    shareInGroups,
    source,
    targetMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'screen_time_daily';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScreenTimeDailyData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('total_minutes')) {
      context.handle(
        _totalMinutesMeta,
        totalMinutes.isAcceptableOrUnknown(
          data['total_minutes']!,
          _totalMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalMinutesMeta);
    }
    if (data.containsKey('category_minutes')) {
      context.handle(
        _categoryMinutesMeta,
        categoryMinutes.isAcceptableOrUnknown(
          data['category_minutes']!,
          _categoryMinutesMeta,
        ),
      );
    }
    if (data.containsKey('late_evening_minutes')) {
      context.handle(
        _lateEveningMinutesMeta,
        lateEveningMinutes.isAcceptableOrUnknown(
          data['late_evening_minutes']!,
          _lateEveningMinutesMeta,
        ),
      );
    }
    if (data.containsKey('share_in_groups')) {
      context.handle(
        _shareInGroupsMeta,
        shareInGroups.isAcceptableOrUnknown(
          data['share_in_groups']!,
          _shareInGroupsMeta,
        ),
      );
    }
    if (data.containsKey('target_minutes')) {
      context.handle(
        _targetMinutesMeta,
        targetMinutes.isAcceptableOrUnknown(
          data['target_minutes']!,
          _targetMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScreenTimeDailyData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScreenTimeDailyData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      totalMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_minutes'],
      )!,
      categoryMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_minutes'],
      )!,
      lateEveningMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}late_evening_minutes'],
      )!,
      shareInGroups: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}share_in_groups'],
      )!,
      source: $ScreenTimeDailyTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      targetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_minutes'],
      ),
    );
  }

  @override
  $ScreenTimeDailyTable createAlias(String alias) {
    return $ScreenTimeDailyTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ScreenTimeSource, String, String> $convertersource =
      const EnumNameConverter<ScreenTimeSource>(ScreenTimeSource.values);
}

class ScreenTimeDailyData extends DataClass
    implements Insertable<ScreenTimeDailyData> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String userId;
  final String localDate;
  final int totalMinutes;

  /// JSON map of category -> minutes.
  final String categoryMinutes;

  /// Minutes of use in the late-evening window, for the sleep insight.
  final int lateEveningMinutes;
  final bool shareInGroups;

  /// `automatic` (usage stats) or `manual` (fallback entry).
  final ScreenTimeSource source;

  /// The daily limit in force when the day was recorded, in minutes.
  final int? targetMinutes;
  const ScreenTimeDailyData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.userId,
    required this.localDate,
    required this.totalMinutes,
    required this.categoryMinutes,
    required this.lateEveningMinutes,
    required this.shareInGroups,
    required this.source,
    this.targetMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['user_id'] = Variable<String>(userId);
    map['local_date'] = Variable<String>(localDate);
    map['total_minutes'] = Variable<int>(totalMinutes);
    map['category_minutes'] = Variable<String>(categoryMinutes);
    map['late_evening_minutes'] = Variable<int>(lateEveningMinutes);
    map['share_in_groups'] = Variable<bool>(shareInGroups);
    {
      map['source'] = Variable<String>(
        $ScreenTimeDailyTable.$convertersource.toSql(source),
      );
    }
    if (!nullToAbsent || targetMinutes != null) {
      map['target_minutes'] = Variable<int>(targetMinutes);
    }
    return map;
  }

  ScreenTimeDailyCompanion toCompanion(bool nullToAbsent) {
    return ScreenTimeDailyCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      userId: Value(userId),
      localDate: Value(localDate),
      totalMinutes: Value(totalMinutes),
      categoryMinutes: Value(categoryMinutes),
      lateEveningMinutes: Value(lateEveningMinutes),
      shareInGroups: Value(shareInGroups),
      source: Value(source),
      targetMinutes: targetMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(targetMinutes),
    );
  }

  factory ScreenTimeDailyData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScreenTimeDailyData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      userId: serializer.fromJson<String>(json['userId']),
      localDate: serializer.fromJson<String>(json['localDate']),
      totalMinutes: serializer.fromJson<int>(json['totalMinutes']),
      categoryMinutes: serializer.fromJson<String>(json['categoryMinutes']),
      lateEveningMinutes: serializer.fromJson<int>(json['lateEveningMinutes']),
      shareInGroups: serializer.fromJson<bool>(json['shareInGroups']),
      source: $ScreenTimeDailyTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      targetMinutes: serializer.fromJson<int?>(json['targetMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'userId': serializer.toJson<String>(userId),
      'localDate': serializer.toJson<String>(localDate),
      'totalMinutes': serializer.toJson<int>(totalMinutes),
      'categoryMinutes': serializer.toJson<String>(categoryMinutes),
      'lateEveningMinutes': serializer.toJson<int>(lateEveningMinutes),
      'shareInGroups': serializer.toJson<bool>(shareInGroups),
      'source': serializer.toJson<String>(
        $ScreenTimeDailyTable.$convertersource.toJson(source),
      ),
      'targetMinutes': serializer.toJson<int?>(targetMinutes),
    };
  }

  ScreenTimeDailyData copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? userId,
    String? localDate,
    int? totalMinutes,
    String? categoryMinutes,
    int? lateEveningMinutes,
    bool? shareInGroups,
    ScreenTimeSource? source,
    Value<int?> targetMinutes = const Value.absent(),
  }) => ScreenTimeDailyData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    userId: userId ?? this.userId,
    localDate: localDate ?? this.localDate,
    totalMinutes: totalMinutes ?? this.totalMinutes,
    categoryMinutes: categoryMinutes ?? this.categoryMinutes,
    lateEveningMinutes: lateEveningMinutes ?? this.lateEveningMinutes,
    shareInGroups: shareInGroups ?? this.shareInGroups,
    source: source ?? this.source,
    targetMinutes: targetMinutes.present
        ? targetMinutes.value
        : this.targetMinutes,
  );
  ScreenTimeDailyData copyWithCompanion(ScreenTimeDailyCompanion data) {
    return ScreenTimeDailyData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      userId: data.userId.present ? data.userId.value : this.userId,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      totalMinutes: data.totalMinutes.present
          ? data.totalMinutes.value
          : this.totalMinutes,
      categoryMinutes: data.categoryMinutes.present
          ? data.categoryMinutes.value
          : this.categoryMinutes,
      lateEveningMinutes: data.lateEveningMinutes.present
          ? data.lateEveningMinutes.value
          : this.lateEveningMinutes,
      shareInGroups: data.shareInGroups.present
          ? data.shareInGroups.value
          : this.shareInGroups,
      source: data.source.present ? data.source.value : this.source,
      targetMinutes: data.targetMinutes.present
          ? data.targetMinutes.value
          : this.targetMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScreenTimeDailyData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('localDate: $localDate, ')
          ..write('totalMinutes: $totalMinutes, ')
          ..write('categoryMinutes: $categoryMinutes, ')
          ..write('lateEveningMinutes: $lateEveningMinutes, ')
          ..write('shareInGroups: $shareInGroups, ')
          ..write('source: $source, ')
          ..write('targetMinutes: $targetMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    localDate,
    totalMinutes,
    categoryMinutes,
    lateEveningMinutes,
    shareInGroups,
    source,
    targetMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScreenTimeDailyData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.userId == this.userId &&
          other.localDate == this.localDate &&
          other.totalMinutes == this.totalMinutes &&
          other.categoryMinutes == this.categoryMinutes &&
          other.lateEveningMinutes == this.lateEveningMinutes &&
          other.shareInGroups == this.shareInGroups &&
          other.source == this.source &&
          other.targetMinutes == this.targetMinutes);
}

class ScreenTimeDailyCompanion extends UpdateCompanion<ScreenTimeDailyData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> userId;
  final Value<String> localDate;
  final Value<int> totalMinutes;
  final Value<String> categoryMinutes;
  final Value<int> lateEveningMinutes;
  final Value<bool> shareInGroups;
  final Value<ScreenTimeSource> source;
  final Value<int?> targetMinutes;
  final Value<int> rowid;
  const ScreenTimeDailyCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.localDate = const Value.absent(),
    this.totalMinutes = const Value.absent(),
    this.categoryMinutes = const Value.absent(),
    this.lateEveningMinutes = const Value.absent(),
    this.shareInGroups = const Value.absent(),
    this.source = const Value.absent(),
    this.targetMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScreenTimeDailyCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String userId,
    required String localDate,
    required int totalMinutes,
    this.categoryMinutes = const Value.absent(),
    this.lateEveningMinutes = const Value.absent(),
    this.shareInGroups = const Value.absent(),
    this.source = const Value.absent(),
    this.targetMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       userId = Value(userId),
       localDate = Value(localDate),
       totalMinutes = Value(totalMinutes);
  static Insertable<ScreenTimeDailyData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? userId,
    Expression<String>? localDate,
    Expression<int>? totalMinutes,
    Expression<String>? categoryMinutes,
    Expression<int>? lateEveningMinutes,
    Expression<bool>? shareInGroups,
    Expression<String>? source,
    Expression<int>? targetMinutes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (userId != null) 'user_id': userId,
      if (localDate != null) 'local_date': localDate,
      if (totalMinutes != null) 'total_minutes': totalMinutes,
      if (categoryMinutes != null) 'category_minutes': categoryMinutes,
      if (lateEveningMinutes != null)
        'late_evening_minutes': lateEveningMinutes,
      if (shareInGroups != null) 'share_in_groups': shareInGroups,
      if (source != null) 'source': source,
      if (targetMinutes != null) 'target_minutes': targetMinutes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScreenTimeDailyCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? userId,
    Value<String>? localDate,
    Value<int>? totalMinutes,
    Value<String>? categoryMinutes,
    Value<int>? lateEveningMinutes,
    Value<bool>? shareInGroups,
    Value<ScreenTimeSource>? source,
    Value<int?>? targetMinutes,
    Value<int>? rowid,
  }) {
    return ScreenTimeDailyCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      userId: userId ?? this.userId,
      localDate: localDate ?? this.localDate,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      categoryMinutes: categoryMinutes ?? this.categoryMinutes,
      lateEveningMinutes: lateEveningMinutes ?? this.lateEveningMinutes,
      shareInGroups: shareInGroups ?? this.shareInGroups,
      source: source ?? this.source,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (totalMinutes.present) {
      map['total_minutes'] = Variable<int>(totalMinutes.value);
    }
    if (categoryMinutes.present) {
      map['category_minutes'] = Variable<String>(categoryMinutes.value);
    }
    if (lateEveningMinutes.present) {
      map['late_evening_minutes'] = Variable<int>(lateEveningMinutes.value);
    }
    if (shareInGroups.present) {
      map['share_in_groups'] = Variable<bool>(shareInGroups.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $ScreenTimeDailyTable.$convertersource.toSql(source.value),
      );
    }
    if (targetMinutes.present) {
      map['target_minutes'] = Variable<int>(targetMinutes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScreenTimeDailyCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('localDate: $localDate, ')
          ..write('totalMinutes: $totalMinutes, ')
          ..write('categoryMinutes: $categoryMinutes, ')
          ..write('lateEveningMinutes: $lateEveningMinutes, ')
          ..write('shareInGroups: $shareInGroups, ')
          ..write('source: $source, ')
          ..write('targetMinutes: $targetMinutes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeeklyInsightsTable extends WeeklyInsights
    with TableInfo<$WeeklyInsightsTable, WeeklyInsight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeeklyInsightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekStartMeta = const VerificationMeta(
    'weekStart',
  );
  @override
  late final GeneratedColumn<String> weekStart = GeneratedColumn<String>(
    'week_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _insightKeyMeta = const VerificationMeta(
    'insightKey',
  );
  @override
  late final GeneratedColumn<String> insightKey = GeneratedColumn<String>(
    'insight_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paramsMeta = const VerificationMeta('params');
  @override
  late final GeneratedColumn<String> params = GeneratedColumn<String>(
    'params',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    weekStart,
    insightKey,
    params,
    generatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weekly_insights';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeeklyInsight> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('week_start')) {
      context.handle(
        _weekStartMeta,
        weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta),
      );
    } else if (isInserting) {
      context.missing(_weekStartMeta);
    }
    if (data.containsKey('insight_key')) {
      context.handle(
        _insightKeyMeta,
        insightKey.isAcceptableOrUnknown(data['insight_key']!, _insightKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_insightKeyMeta);
    }
    if (data.containsKey('params')) {
      context.handle(
        _paramsMeta,
        params.isAcceptableOrUnknown(data['params']!, _paramsMeta),
      );
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_generatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeeklyInsight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeeklyInsight(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      weekStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_start'],
      )!,
      insightKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}insight_key'],
      )!,
      params: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}params'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
    );
  }

  @override
  $WeeklyInsightsTable createAlias(String alias) {
    return $WeeklyInsightsTable(attachedDatabase, alias);
  }
}

class WeeklyInsight extends DataClass implements Insertable<WeeklyInsight> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String userId;
  final String weekStart;
  final String insightKey;
  final String params;
  final DateTime generatedAt;
  const WeeklyInsight({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.userId,
    required this.weekStart,
    required this.insightKey,
    required this.params,
    required this.generatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['user_id'] = Variable<String>(userId);
    map['week_start'] = Variable<String>(weekStart);
    map['insight_key'] = Variable<String>(insightKey);
    map['params'] = Variable<String>(params);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    return map;
  }

  WeeklyInsightsCompanion toCompanion(bool nullToAbsent) {
    return WeeklyInsightsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      userId: Value(userId),
      weekStart: Value(weekStart),
      insightKey: Value(insightKey),
      params: Value(params),
      generatedAt: Value(generatedAt),
    );
  }

  factory WeeklyInsight.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeeklyInsight(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      userId: serializer.fromJson<String>(json['userId']),
      weekStart: serializer.fromJson<String>(json['weekStart']),
      insightKey: serializer.fromJson<String>(json['insightKey']),
      params: serializer.fromJson<String>(json['params']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'userId': serializer.toJson<String>(userId),
      'weekStart': serializer.toJson<String>(weekStart),
      'insightKey': serializer.toJson<String>(insightKey),
      'params': serializer.toJson<String>(params),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
    };
  }

  WeeklyInsight copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? userId,
    String? weekStart,
    String? insightKey,
    String? params,
    DateTime? generatedAt,
  }) => WeeklyInsight(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    userId: userId ?? this.userId,
    weekStart: weekStart ?? this.weekStart,
    insightKey: insightKey ?? this.insightKey,
    params: params ?? this.params,
    generatedAt: generatedAt ?? this.generatedAt,
  );
  WeeklyInsight copyWithCompanion(WeeklyInsightsCompanion data) {
    return WeeklyInsight(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      userId: data.userId.present ? data.userId.value : this.userId,
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      insightKey: data.insightKey.present
          ? data.insightKey.value
          : this.insightKey,
      params: data.params.present ? data.params.value : this.params,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyInsight(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('weekStart: $weekStart, ')
          ..write('insightKey: $insightKey, ')
          ..write('params: $params, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    weekStart,
    insightKey,
    params,
    generatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeeklyInsight &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.userId == this.userId &&
          other.weekStart == this.weekStart &&
          other.insightKey == this.insightKey &&
          other.params == this.params &&
          other.generatedAt == this.generatedAt);
}

class WeeklyInsightsCompanion extends UpdateCompanion<WeeklyInsight> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> userId;
  final Value<String> weekStart;
  final Value<String> insightKey;
  final Value<String> params;
  final Value<DateTime> generatedAt;
  final Value<int> rowid;
  const WeeklyInsightsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.weekStart = const Value.absent(),
    this.insightKey = const Value.absent(),
    this.params = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeeklyInsightsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String userId,
    required String weekStart,
    required String insightKey,
    this.params = const Value.absent(),
    required DateTime generatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       userId = Value(userId),
       weekStart = Value(weekStart),
       insightKey = Value(insightKey),
       generatedAt = Value(generatedAt);
  static Insertable<WeeklyInsight> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? userId,
    Expression<String>? weekStart,
    Expression<String>? insightKey,
    Expression<String>? params,
    Expression<DateTime>? generatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (userId != null) 'user_id': userId,
      if (weekStart != null) 'week_start': weekStart,
      if (insightKey != null) 'insight_key': insightKey,
      if (params != null) 'params': params,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeeklyInsightsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? userId,
    Value<String>? weekStart,
    Value<String>? insightKey,
    Value<String>? params,
    Value<DateTime>? generatedAt,
    Value<int>? rowid,
  }) {
    return WeeklyInsightsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      userId: userId ?? this.userId,
      weekStart: weekStart ?? this.weekStart,
      insightKey: insightKey ?? this.insightKey,
      params: params ?? this.params,
      generatedAt: generatedAt ?? this.generatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (weekStart.present) {
      map['week_start'] = Variable<String>(weekStart.value);
    }
    if (insightKey.present) {
      map['insight_key'] = Variable<String>(insightKey.value);
    }
    if (params.present) {
      map['params'] = Variable<String>(params.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyInsightsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('weekStart: $weekStart, ')
          ..write('insightKey: $insightKey, ')
          ..write('params: $params, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TipsLibraryTable extends TipsLibrary
    with TableInfo<$TipsLibraryTable, TipsLibraryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TipsLibraryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _triggerKeyMeta = const VerificationMeta(
    'triggerKey',
  );
  @override
  late final GeneratedColumn<String> triggerKey = GeneratedColumn<String>(
    'trigger_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceLabelMeta = const VerificationMeta(
    'sourceLabel',
  );
  @override
  late final GeneratedColumn<String> sourceLabel = GeneratedColumn<String>(
    'source_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    triggerKey,
    body,
    sourceLabel,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tips_library';
  @override
  VerificationContext validateIntegrity(
    Insertable<TipsLibraryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('trigger_key')) {
      context.handle(
        _triggerKeyMeta,
        triggerKey.isAcceptableOrUnknown(data['trigger_key']!, _triggerKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_triggerKeyMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('source_label')) {
      context.handle(
        _sourceLabelMeta,
        sourceLabel.isAcceptableOrUnknown(
          data['source_label']!,
          _sourceLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceLabelMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TipsLibraryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TipsLibraryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      triggerKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger_key'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      sourceLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_label'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $TipsLibraryTable createAlias(String alias) {
    return $TipsLibraryTable(attachedDatabase, alias);
  }
}

class TipsLibraryData extends DataClass implements Insertable<TipsLibraryData> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String triggerKey;
  final String body;
  final String sourceLabel;
  final bool isActive;
  const TipsLibraryData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.triggerKey,
    required this.body,
    required this.sourceLabel,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['trigger_key'] = Variable<String>(triggerKey);
    map['body'] = Variable<String>(body);
    map['source_label'] = Variable<String>(sourceLabel);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  TipsLibraryCompanion toCompanion(bool nullToAbsent) {
    return TipsLibraryCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      triggerKey: Value(triggerKey),
      body: Value(body),
      sourceLabel: Value(sourceLabel),
      isActive: Value(isActive),
    );
  }

  factory TipsLibraryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TipsLibraryData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      triggerKey: serializer.fromJson<String>(json['triggerKey']),
      body: serializer.fromJson<String>(json['body']),
      sourceLabel: serializer.fromJson<String>(json['sourceLabel']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'triggerKey': serializer.toJson<String>(triggerKey),
      'body': serializer.toJson<String>(body),
      'sourceLabel': serializer.toJson<String>(sourceLabel),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  TipsLibraryData copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? triggerKey,
    String? body,
    String? sourceLabel,
    bool? isActive,
  }) => TipsLibraryData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    triggerKey: triggerKey ?? this.triggerKey,
    body: body ?? this.body,
    sourceLabel: sourceLabel ?? this.sourceLabel,
    isActive: isActive ?? this.isActive,
  );
  TipsLibraryData copyWithCompanion(TipsLibraryCompanion data) {
    return TipsLibraryData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      triggerKey: data.triggerKey.present
          ? data.triggerKey.value
          : this.triggerKey,
      body: data.body.present ? data.body.value : this.body,
      sourceLabel: data.sourceLabel.present
          ? data.sourceLabel.value
          : this.sourceLabel,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TipsLibraryData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('triggerKey: $triggerKey, ')
          ..write('body: $body, ')
          ..write('sourceLabel: $sourceLabel, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    triggerKey,
    body,
    sourceLabel,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TipsLibraryData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.triggerKey == this.triggerKey &&
          other.body == this.body &&
          other.sourceLabel == this.sourceLabel &&
          other.isActive == this.isActive);
}

class TipsLibraryCompanion extends UpdateCompanion<TipsLibraryData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> triggerKey;
  final Value<String> body;
  final Value<String> sourceLabel;
  final Value<bool> isActive;
  final Value<int> rowid;
  const TipsLibraryCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.triggerKey = const Value.absent(),
    this.body = const Value.absent(),
    this.sourceLabel = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TipsLibraryCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String triggerKey,
    required String body,
    required String sourceLabel,
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       triggerKey = Value(triggerKey),
       body = Value(body),
       sourceLabel = Value(sourceLabel);
  static Insertable<TipsLibraryData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? triggerKey,
    Expression<String>? body,
    Expression<String>? sourceLabel,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (triggerKey != null) 'trigger_key': triggerKey,
      if (body != null) 'body': body,
      if (sourceLabel != null) 'source_label': sourceLabel,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TipsLibraryCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? triggerKey,
    Value<String>? body,
    Value<String>? sourceLabel,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return TipsLibraryCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      triggerKey: triggerKey ?? this.triggerKey,
      body: body ?? this.body,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (triggerKey.present) {
      map['trigger_key'] = Variable<String>(triggerKey.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (sourceLabel.present) {
      map['source_label'] = Variable<String>(sourceLabel.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TipsLibraryCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('triggerKey: $triggerKey, ')
          ..write('body: $body, ')
          ..write('sourceLabel: $sourceLabel, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $WorkoutTypesTable workoutTypes = $WorkoutTypesTable(this);
  late final $WorkoutsTable workouts = $WorkoutsTable(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $HabitLogsTable habitLogs = $HabitLogsTable(this);
  late final $HabitSkipsTable habitSkips = $HabitSkipsTable(this);
  late final $HobbiesTable hobbies = $HobbiesTable(this);
  late final $HobbyLogsTable hobbyLogs = $HobbyLogsTable(this);
  late final $BodyMeasurementsTable bodyMeasurements = $BodyMeasurementsTable(
    this,
  );
  late final $SleepTargetsTable sleepTargets = $SleepTargetsTable(this);
  late final $SleepLogsTable sleepLogs = $SleepLogsTable(this);
  late final $RestDaysTable restDays = $RestDaysTable(this);
  late final $StreakStatesTable streakStates = $StreakStatesTable(this);
  late final $BadgesAwardedTable badgesAwarded = $BadgesAwardedTable(this);
  late final $ScreenTimeDailyTable screenTimeDaily = $ScreenTimeDailyTable(
    this,
  );
  late final $WeeklyInsightsTable weeklyInsights = $WeeklyInsightsTable(this);
  late final $TipsLibraryTable tipsLibrary = $TipsLibraryTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    workoutTypes,
    workouts,
    habits,
    habitLogs,
    habitSkips,
    hobbies,
    hobbyLogs,
    bodyMeasurements,
    sleepTargets,
    sleepLogs,
    restDays,
    streakStates,
    badgesAwarded,
    screenTimeDaily,
    weeklyInsights,
    tipsLibrary,
  ];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> displayName,
  Value<String?> avatarUrl,
  Value<String> timezone,
  Value<int> dayCutoffMinutes,
  Value<int?> quietHoursStart,
  Value<int?> quietHoursEnd,
  Value<int> dailyReminderCap,
  Value<int> weeklyRestDays,
  Value<bool> freezeEnabled,
  Value<int> freezeIntervalDays,
  Value<String?> dateOfBirth,
  Value<String?> gender,
  Value<double?> heightCm,
  Value<double?> weightKg,
  Value<String> measurementCadence,
  Value<bool> measurementReminderEnabled,
  Value<String?> nextMeasurementDue,
  Value<String?> reminderSound,
  Value<int> habitThreshold,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> displayName,
  Value<String?> avatarUrl,
  Value<String> timezone,
  Value<int> dayCutoffMinutes,
  Value<int?> quietHoursStart,
  Value<int?> quietHoursEnd,
  Value<int> dailyReminderCap,
  Value<int> weeklyRestDays,
  Value<bool> freezeEnabled,
  Value<int> freezeIntervalDays,
  Value<String?> dateOfBirth,
  Value<String?> gender,
  Value<double?> heightCm,
  Value<double?> weightKg,
  Value<String> measurementCadence,
  Value<bool> measurementReminderEnabled,
  Value<String?> nextMeasurementDue,
  Value<String?> reminderSound,
  Value<int> habitThreshold,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayCutoffMinutes => $composableBuilder(
    column: $table.dayCutoffMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quietHoursStart => $composableBuilder(
    column: $table.quietHoursStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quietHoursEnd => $composableBuilder(
    column: $table.quietHoursEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyReminderCap => $composableBuilder(
    column: $table.dailyReminderCap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weeklyRestDays => $composableBuilder(
    column: $table.weeklyRestDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get freezeEnabled => $composableBuilder(
    column: $table.freezeEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get freezeIntervalDays => $composableBuilder(
    column: $table.freezeIntervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get measurementCadence => $composableBuilder(
    column: $table.measurementCadence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get measurementReminderEnabled => $composableBuilder(
    column: $table.measurementReminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextMeasurementDue => $composableBuilder(
    column: $table.nextMeasurementDue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderSound => $composableBuilder(
    column: $table.reminderSound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get habitThreshold => $composableBuilder(
    column: $table.habitThreshold,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayCutoffMinutes => $composableBuilder(
    column: $table.dayCutoffMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quietHoursStart => $composableBuilder(
    column: $table.quietHoursStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quietHoursEnd => $composableBuilder(
    column: $table.quietHoursEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyReminderCap => $composableBuilder(
    column: $table.dailyReminderCap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weeklyRestDays => $composableBuilder(
    column: $table.weeklyRestDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get freezeEnabled => $composableBuilder(
    column: $table.freezeEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get freezeIntervalDays => $composableBuilder(
    column: $table.freezeIntervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get measurementCadence => $composableBuilder(
    column: $table.measurementCadence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get measurementReminderEnabled => $composableBuilder(
    column: $table.measurementReminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextMeasurementDue => $composableBuilder(
    column: $table.nextMeasurementDue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderSound => $composableBuilder(
    column: $table.reminderSound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get habitThreshold => $composableBuilder(
    column: $table.habitThreshold,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<int> get dayCutoffMinutes => $composableBuilder(
    column: $table.dayCutoffMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quietHoursStart => $composableBuilder(
    column: $table.quietHoursStart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quietHoursEnd => $composableBuilder(
    column: $table.quietHoursEnd,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyReminderCap => $composableBuilder(
    column: $table.dailyReminderCap,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weeklyRestDays => $composableBuilder(
    column: $table.weeklyRestDays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get freezeEnabled => $composableBuilder(
    column: $table.freezeEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get freezeIntervalDays => $composableBuilder(
    column: $table.freezeIntervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get measurementCadence => $composableBuilder(
    column: $table.measurementCadence,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get measurementReminderEnabled => $composableBuilder(
    column: $table.measurementReminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nextMeasurementDue => $composableBuilder(
    column: $table.nextMeasurementDue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderSound => $composableBuilder(
    column: $table.reminderSound,
    builder: (column) => column,
  );

  GeneratedColumn<int> get habitThreshold => $composableBuilder(
    column: $table.habitThreshold,
    builder: (column) => column,
  );
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<int> dayCutoffMinutes = const Value.absent(),
                Value<int?> quietHoursStart = const Value.absent(),
                Value<int?> quietHoursEnd = const Value.absent(),
                Value<int> dailyReminderCap = const Value.absent(),
                Value<int> weeklyRestDays = const Value.absent(),
                Value<bool> freezeEnabled = const Value.absent(),
                Value<int> freezeIntervalDays = const Value.absent(),
                Value<String?> dateOfBirth = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<String> measurementCadence = const Value.absent(),
                Value<bool> measurementReminderEnabled = const Value.absent(),
                Value<String?> nextMeasurementDue = const Value.absent(),
                Value<String?> reminderSound = const Value.absent(),
                Value<int> habitThreshold = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                displayName: displayName,
                avatarUrl: avatarUrl,
                timezone: timezone,
                dayCutoffMinutes: dayCutoffMinutes,
                quietHoursStart: quietHoursStart,
                quietHoursEnd: quietHoursEnd,
                dailyReminderCap: dailyReminderCap,
                weeklyRestDays: weeklyRestDays,
                freezeEnabled: freezeEnabled,
                freezeIntervalDays: freezeIntervalDays,
                dateOfBirth: dateOfBirth,
                gender: gender,
                heightCm: heightCm,
                weightKg: weightKg,
                measurementCadence: measurementCadence,
                measurementReminderEnabled: measurementReminderEnabled,
                nextMeasurementDue: nextMeasurementDue,
                reminderSound: reminderSound,
                habitThreshold: habitThreshold,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<int> dayCutoffMinutes = const Value.absent(),
                Value<int?> quietHoursStart = const Value.absent(),
                Value<int?> quietHoursEnd = const Value.absent(),
                Value<int> dailyReminderCap = const Value.absent(),
                Value<int> weeklyRestDays = const Value.absent(),
                Value<bool> freezeEnabled = const Value.absent(),
                Value<int> freezeIntervalDays = const Value.absent(),
                Value<String?> dateOfBirth = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<String> measurementCadence = const Value.absent(),
                Value<bool> measurementReminderEnabled = const Value.absent(),
                Value<String?> nextMeasurementDue = const Value.absent(),
                Value<String?> reminderSound = const Value.absent(),
                Value<int> habitThreshold = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                displayName: displayName,
                avatarUrl: avatarUrl,
                timezone: timezone,
                dayCutoffMinutes: dayCutoffMinutes,
                quietHoursStart: quietHoursStart,
                quietHoursEnd: quietHoursEnd,
                dailyReminderCap: dailyReminderCap,
                weeklyRestDays: weeklyRestDays,
                freezeEnabled: freezeEnabled,
                freezeIntervalDays: freezeIntervalDays,
                dateOfBirth: dateOfBirth,
                gender: gender,
                heightCm: heightCm,
                weightKg: weightKg,
                measurementCadence: measurementCadence,
                measurementReminderEnabled: measurementReminderEnabled,
                nextMeasurementDue: nextMeasurementDue,
                reminderSound: reminderSound,
                habitThreshold: habitThreshold,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsersTable, User>(table),
                  BaseReferences<_$AppDatabase, $UsersTable, User>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$WorkoutTypesTableCreateCompanionBuilder =
    WorkoutTypesCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> userId,
      required String name,
      required String iconKey,
      Value<bool> isBuiltin,
      Value<int> rowid,
    });
typedef $$WorkoutTypesTableUpdateCompanionBuilder =
    WorkoutTypesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> userId,
      Value<String> name,
      Value<String> iconKey,
      Value<bool> isBuiltin,
      Value<int> rowid,
    });

class $$WorkoutTypesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutTypesTable> {
  $$WorkoutTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltin => $composableBuilder(
    column: $table.isBuiltin,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutTypesTable> {
  $$WorkoutTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltin => $composableBuilder(
    column: $table.isBuiltin,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutTypesTable> {
  $$WorkoutTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltin =>
      $composableBuilder(column: $table.isBuiltin, builder: (column) => column);
}

class $$WorkoutTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutTypesTable,
          WorkoutType,
          $$WorkoutTypesTableFilterComposer,
          $$WorkoutTypesTableOrderingComposer,
          $$WorkoutTypesTableAnnotationComposer,
          $$WorkoutTypesTableCreateCompanionBuilder,
          $$WorkoutTypesTableUpdateCompanionBuilder,
          (
            WorkoutType,
            BaseReferences<_$AppDatabase, $WorkoutTypesTable, WorkoutType>,
          ),
          WorkoutType,
          PrefetchHooks Function()
        > {
  $$WorkoutTypesTableTableManager(_$AppDatabase db, $WorkoutTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<bool> isBuiltin = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutTypesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                name: name,
                iconKey: iconKey,
                isBuiltin: isBuiltin,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                required String name,
                required String iconKey,
                Value<bool> isBuiltin = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutTypesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                name: name,
                iconKey: iconKey,
                isBuiltin: isBuiltin,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutTypesTable, WorkoutType>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WorkoutTypesTable,
                    WorkoutType
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutTypesTable,
      WorkoutType,
      $$WorkoutTypesTableFilterComposer,
      $$WorkoutTypesTableOrderingComposer,
      $$WorkoutTypesTableAnnotationComposer,
      $$WorkoutTypesTableCreateCompanionBuilder,
      $$WorkoutTypesTableUpdateCompanionBuilder,
      (
        WorkoutType,
        BaseReferences<_$AppDatabase, $WorkoutTypesTable, WorkoutType>,
      ),
      WorkoutType,
      PrefetchHooks Function()
    >;
typedef $$WorkoutsTableCreateCompanionBuilder = WorkoutsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String userId,
  required String workoutTypeId,
  required DateTime startedAt,
  required DateTime endedAt,
  required int durationMinutes,
  Value<WorkoutIntensity?> intensity,
  Value<String?> note,
  required WorkoutSource source,
  Value<int> tzOffsetMinutes,
  required String localDate,
  Value<int?> caloriesEstimate,
  Value<int?> steps,
  Value<String?> stepsSource,
  Value<double?> distanceKm,
  Value<double?> avgSpeedKmh,
  Value<int> pausedSeconds,
  Value<int?> activeSeconds,
  Value<String?> metricsNote,
  Value<int> rowid,
});
typedef $$WorkoutsTableUpdateCompanionBuilder = WorkoutsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> userId,
  Value<String> workoutTypeId,
  Value<DateTime> startedAt,
  Value<DateTime> endedAt,
  Value<int> durationMinutes,
  Value<WorkoutIntensity?> intensity,
  Value<String?> note,
  Value<WorkoutSource> source,
  Value<int> tzOffsetMinutes,
  Value<String> localDate,
  Value<int?> caloriesEstimate,
  Value<int?> steps,
  Value<String?> stepsSource,
  Value<double?> distanceKm,
  Value<double?> avgSpeedKmh,
  Value<int> pausedSeconds,
  Value<int?> activeSeconds,
  Value<String?> metricsNote,
  Value<int> rowid,
});

class $$WorkoutsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workoutTypeId => $composableBuilder(
    column: $table.workoutTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WorkoutIntensity?, WorkoutIntensity, String>
  get intensity => $composableBuilder(
    column: $table.intensity,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WorkoutSource, WorkoutSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get caloriesEstimate => $composableBuilder(
    column: $table.caloriesEstimate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stepsSource => $composableBuilder(
    column: $table.stepsSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgSpeedKmh => $composableBuilder(
    column: $table.avgSpeedKmh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pausedSeconds => $composableBuilder(
    column: $table.pausedSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeSeconds => $composableBuilder(
    column: $table.activeSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metricsNote => $composableBuilder(
    column: $table.metricsNote,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workoutTypeId => $composableBuilder(
    column: $table.workoutTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intensity => $composableBuilder(
    column: $table.intensity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get caloriesEstimate => $composableBuilder(
    column: $table.caloriesEstimate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stepsSource => $composableBuilder(
    column: $table.stepsSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgSpeedKmh => $composableBuilder(
    column: $table.avgSpeedKmh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pausedSeconds => $composableBuilder(
    column: $table.pausedSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeSeconds => $composableBuilder(
    column: $table.activeSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metricsNote => $composableBuilder(
    column: $table.metricsNote,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get workoutTypeId => $composableBuilder(
    column: $table.workoutTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<WorkoutIntensity?, String> get intensity =>
      $composableBuilder(column: $table.intensity, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WorkoutSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<int> get caloriesEstimate => $composableBuilder(
    column: $table.caloriesEstimate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<String> get stepsSource => $composableBuilder(
    column: $table.stepsSource,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgSpeedKmh => $composableBuilder(
    column: $table.avgSpeedKmh,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pausedSeconds => $composableBuilder(
    column: $table.pausedSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get activeSeconds => $composableBuilder(
    column: $table.activeSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metricsNote => $composableBuilder(
    column: $table.metricsNote,
    builder: (column) => column,
  );
}

class $$WorkoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutsTable,
          Workout,
          $$WorkoutsTableFilterComposer,
          $$WorkoutsTableOrderingComposer,
          $$WorkoutsTableAnnotationComposer,
          $$WorkoutsTableCreateCompanionBuilder,
          $$WorkoutsTableUpdateCompanionBuilder,
          (Workout, BaseReferences<_$AppDatabase, $WorkoutsTable, Workout>),
          Workout,
          PrefetchHooks Function()
        > {
  $$WorkoutsTableTableManager(_$AppDatabase db, $WorkoutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> workoutTypeId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> endedAt = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<WorkoutIntensity?> intensity = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<WorkoutSource> source = const Value.absent(),
                Value<int> tzOffsetMinutes = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<int?> caloriesEstimate = const Value.absent(),
                Value<int?> steps = const Value.absent(),
                Value<String?> stepsSource = const Value.absent(),
                Value<double?> distanceKm = const Value.absent(),
                Value<double?> avgSpeedKmh = const Value.absent(),
                Value<int> pausedSeconds = const Value.absent(),
                Value<int?> activeSeconds = const Value.absent(),
                Value<String?> metricsNote = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                workoutTypeId: workoutTypeId,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMinutes: durationMinutes,
                intensity: intensity,
                note: note,
                source: source,
                tzOffsetMinutes: tzOffsetMinutes,
                localDate: localDate,
                caloriesEstimate: caloriesEstimate,
                steps: steps,
                stepsSource: stepsSource,
                distanceKm: distanceKm,
                avgSpeedKmh: avgSpeedKmh,
                pausedSeconds: pausedSeconds,
                activeSeconds: activeSeconds,
                metricsNote: metricsNote,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String userId,
                required String workoutTypeId,
                required DateTime startedAt,
                required DateTime endedAt,
                required int durationMinutes,
                Value<WorkoutIntensity?> intensity = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required WorkoutSource source,
                Value<int> tzOffsetMinutes = const Value.absent(),
                required String localDate,
                Value<int?> caloriesEstimate = const Value.absent(),
                Value<int?> steps = const Value.absent(),
                Value<String?> stepsSource = const Value.absent(),
                Value<double?> distanceKm = const Value.absent(),
                Value<double?> avgSpeedKmh = const Value.absent(),
                Value<int> pausedSeconds = const Value.absent(),
                Value<int?> activeSeconds = const Value.absent(),
                Value<String?> metricsNote = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                workoutTypeId: workoutTypeId,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMinutes: durationMinutes,
                intensity: intensity,
                note: note,
                source: source,
                tzOffsetMinutes: tzOffsetMinutes,
                localDate: localDate,
                caloriesEstimate: caloriesEstimate,
                steps: steps,
                stepsSource: stepsSource,
                distanceKm: distanceKm,
                avgSpeedKmh: avgSpeedKmh,
                pausedSeconds: pausedSeconds,
                activeSeconds: activeSeconds,
                metricsNote: metricsNote,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutsTable, Workout>(table),
                  BaseReferences<_$AppDatabase, $WorkoutsTable, Workout>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutsTable,
      Workout,
      $$WorkoutsTableFilterComposer,
      $$WorkoutsTableOrderingComposer,
      $$WorkoutsTableAnnotationComposer,
      $$WorkoutsTableCreateCompanionBuilder,
      $$WorkoutsTableUpdateCompanionBuilder,
      (Workout, BaseReferences<_$AppDatabase, $WorkoutsTable, Workout>),
      Workout,
      PrefetchHooks Function()
    >;
typedef $$HabitsTableCreateCompanionBuilder = HabitsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String userId,
  required String name,
  required HabitKind kind,
  Value<int> dailyTarget,
  Value<bool> remindersEnabled,
  Value<String> reminderConfig,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$HabitsTableUpdateCompanionBuilder = HabitsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> userId,
  Value<String> name,
  Value<HabitKind> kind,
  Value<int> dailyTarget,
  Value<bool> remindersEnabled,
  Value<String> reminderConfig,
  Value<bool> isActive,
  Value<int> rowid,
});

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<HabitKind, HabitKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get dailyTarget => $composableBuilder(
    column: $table.dailyTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderConfig => $composableBuilder(
    column: $table.reminderConfig,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyTarget => $composableBuilder(
    column: $table.dailyTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderConfig => $composableBuilder(
    column: $table.reminderConfig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<HabitKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get dailyTarget => $composableBuilder(
    column: $table.dailyTarget,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderConfig => $composableBuilder(
    column: $table.reminderConfig,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          Habit,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (Habit, BaseReferences<_$AppDatabase, $HabitsTable, Habit>),
          Habit,
          PrefetchHooks Function()
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<HabitKind> kind = const Value.absent(),
                Value<int> dailyTarget = const Value.absent(),
                Value<bool> remindersEnabled = const Value.absent(),
                Value<String> reminderConfig = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                name: name,
                kind: kind,
                dailyTarget: dailyTarget,
                remindersEnabled: remindersEnabled,
                reminderConfig: reminderConfig,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String userId,
                required String name,
                required HabitKind kind,
                Value<int> dailyTarget = const Value.absent(),
                Value<bool> remindersEnabled = const Value.absent(),
                Value<String> reminderConfig = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                name: name,
                kind: kind,
                dailyTarget: dailyTarget,
                remindersEnabled: remindersEnabled,
                reminderConfig: reminderConfig,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitsTable, Habit>(table),
                  BaseReferences<_$AppDatabase, $HabitsTable, Habit>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      Habit,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (Habit, BaseReferences<_$AppDatabase, $HabitsTable, Habit>),
      Habit,
      PrefetchHooks Function()
    >;
typedef $$HabitLogsTableCreateCompanionBuilder = HabitLogsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String habitId,
  required String userId,
  required DateTime loggedAt,
  Value<int> count,
  Value<int> tzOffsetMinutes,
  required String localDate,
  Value<int> rowid,
});
typedef $$HabitLogsTableUpdateCompanionBuilder = HabitLogsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> habitId,
  Value<String> userId,
  Value<DateTime> loggedAt,
  Value<int> count,
  Value<int> tzOffsetMinutes,
  Value<String> localDate,
  Value<int> rowid,
});

class $$HabitLogsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);
}

class $$HabitLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitLogsTable,
          HabitLog,
          $$HabitLogsTableFilterComposer,
          $$HabitLogsTableOrderingComposer,
          $$HabitLogsTableAnnotationComposer,
          $$HabitLogsTableCreateCompanionBuilder,
          $$HabitLogsTableUpdateCompanionBuilder,
          (HabitLog, BaseReferences<_$AppDatabase, $HabitLogsTable, HabitLog>),
          HabitLog,
          PrefetchHooks Function()
        > {
  $$HabitLogsTableTableManager(_$AppDatabase db, $HabitLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int> tzOffsetMinutes = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitLogsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                habitId: habitId,
                userId: userId,
                loggedAt: loggedAt,
                count: count,
                tzOffsetMinutes: tzOffsetMinutes,
                localDate: localDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String habitId,
                required String userId,
                required DateTime loggedAt,
                Value<int> count = const Value.absent(),
                Value<int> tzOffsetMinutes = const Value.absent(),
                required String localDate,
                Value<int> rowid = const Value.absent(),
              }) => HabitLogsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                habitId: habitId,
                userId: userId,
                loggedAt: loggedAt,
                count: count,
                tzOffsetMinutes: tzOffsetMinutes,
                localDate: localDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitLogsTable, HabitLog>(table),
                  BaseReferences<_$AppDatabase, $HabitLogsTable, HabitLog>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitLogsTable,
      HabitLog,
      $$HabitLogsTableFilterComposer,
      $$HabitLogsTableOrderingComposer,
      $$HabitLogsTableAnnotationComposer,
      $$HabitLogsTableCreateCompanionBuilder,
      $$HabitLogsTableUpdateCompanionBuilder,
      (HabitLog, BaseReferences<_$AppDatabase, $HabitLogsTable, HabitLog>),
      HabitLog,
      PrefetchHooks Function()
    >;
typedef $$HabitSkipsTableCreateCompanionBuilder = HabitSkipsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String habitId,
  required String userId,
  required DateTime skippedAt,
  Value<int> tzOffsetMinutes,
  required String localDate,
  Value<int> rowid,
});
typedef $$HabitSkipsTableUpdateCompanionBuilder = HabitSkipsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> habitId,
  Value<String> userId,
  Value<DateTime> skippedAt,
  Value<int> tzOffsetMinutes,
  Value<String> localDate,
  Value<int> rowid,
});

class $$HabitSkipsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitSkipsTable> {
  $$HabitSkipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get skippedAt => $composableBuilder(
    column: $table.skippedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitSkipsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitSkipsTable> {
  $$HabitSkipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get skippedAt => $composableBuilder(
    column: $table.skippedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitSkipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitSkipsTable> {
  $$HabitSkipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get skippedAt =>
      $composableBuilder(column: $table.skippedAt, builder: (column) => column);

  GeneratedColumn<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);
}

class $$HabitSkipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitSkipsTable,
          HabitSkip,
          $$HabitSkipsTableFilterComposer,
          $$HabitSkipsTableOrderingComposer,
          $$HabitSkipsTableAnnotationComposer,
          $$HabitSkipsTableCreateCompanionBuilder,
          $$HabitSkipsTableUpdateCompanionBuilder,
          (
            HabitSkip,
            BaseReferences<_$AppDatabase, $HabitSkipsTable, HabitSkip>,
          ),
          HabitSkip,
          PrefetchHooks Function()
        > {
  $$HabitSkipsTableTableManager(_$AppDatabase db, $HabitSkipsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitSkipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitSkipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitSkipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> skippedAt = const Value.absent(),
                Value<int> tzOffsetMinutes = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitSkipsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                habitId: habitId,
                userId: userId,
                skippedAt: skippedAt,
                tzOffsetMinutes: tzOffsetMinutes,
                localDate: localDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String habitId,
                required String userId,
                required DateTime skippedAt,
                Value<int> tzOffsetMinutes = const Value.absent(),
                required String localDate,
                Value<int> rowid = const Value.absent(),
              }) => HabitSkipsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                habitId: habitId,
                userId: userId,
                skippedAt: skippedAt,
                tzOffsetMinutes: tzOffsetMinutes,
                localDate: localDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitSkipsTable, HabitSkip>(table),
                  BaseReferences<_$AppDatabase, $HabitSkipsTable, HabitSkip>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitSkipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitSkipsTable,
      HabitSkip,
      $$HabitSkipsTableFilterComposer,
      $$HabitSkipsTableOrderingComposer,
      $$HabitSkipsTableAnnotationComposer,
      $$HabitSkipsTableCreateCompanionBuilder,
      $$HabitSkipsTableUpdateCompanionBuilder,
      (HabitSkip, BaseReferences<_$AppDatabase, $HabitSkipsTable, HabitSkip>),
      HabitSkip,
      PrefetchHooks Function()
    >;
typedef $$HobbiesTableCreateCompanionBuilder = HobbiesCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String userId,
  required String name,
  required String iconKey,
  Value<bool> isBuiltin,
  Value<HobbyGoalPeriod?> goalPeriod,
  Value<int?> goalValue,
  Value<HobbyGoalUnit> goalUnit,
  Value<bool> reminderEnabled,
  Value<String> reminderConfig,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$HobbiesTableUpdateCompanionBuilder = HobbiesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> userId,
  Value<String> name,
  Value<String> iconKey,
  Value<bool> isBuiltin,
  Value<HobbyGoalPeriod?> goalPeriod,
  Value<int?> goalValue,
  Value<HobbyGoalUnit> goalUnit,
  Value<bool> reminderEnabled,
  Value<String> reminderConfig,
  Value<bool> isActive,
  Value<int> rowid,
});

class $$HobbiesTableFilterComposer
    extends Composer<_$AppDatabase, $HobbiesTable> {
  $$HobbiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltin => $composableBuilder(
    column: $table.isBuiltin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<HobbyGoalPeriod?, HobbyGoalPeriod, String>
  get goalPeriod => $composableBuilder(
    column: $table.goalPeriod,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get goalValue => $composableBuilder(
    column: $table.goalValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<HobbyGoalUnit, HobbyGoalUnit, String>
  get goalUnit => $composableBuilder(
    column: $table.goalUnit,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderConfig => $composableBuilder(
    column: $table.reminderConfig,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HobbiesTableOrderingComposer
    extends Composer<_$AppDatabase, $HobbiesTable> {
  $$HobbiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltin => $composableBuilder(
    column: $table.isBuiltin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalPeriod => $composableBuilder(
    column: $table.goalPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goalValue => $composableBuilder(
    column: $table.goalValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalUnit => $composableBuilder(
    column: $table.goalUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderConfig => $composableBuilder(
    column: $table.reminderConfig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HobbiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HobbiesTable> {
  $$HobbiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltin =>
      $composableBuilder(column: $table.isBuiltin, builder: (column) => column);

  GeneratedColumnWithTypeConverter<HobbyGoalPeriod?, String> get goalPeriod =>
      $composableBuilder(
        column: $table.goalPeriod,
        builder: (column) => column,
      );

  GeneratedColumn<int> get goalValue =>
      $composableBuilder(column: $table.goalValue, builder: (column) => column);

  GeneratedColumnWithTypeConverter<HobbyGoalUnit, String> get goalUnit =>
      $composableBuilder(column: $table.goalUnit, builder: (column) => column);

  GeneratedColumn<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderConfig => $composableBuilder(
    column: $table.reminderConfig,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$HobbiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HobbiesTable,
          Hobby,
          $$HobbiesTableFilterComposer,
          $$HobbiesTableOrderingComposer,
          $$HobbiesTableAnnotationComposer,
          $$HobbiesTableCreateCompanionBuilder,
          $$HobbiesTableUpdateCompanionBuilder,
          (Hobby, BaseReferences<_$AppDatabase, $HobbiesTable, Hobby>),
          Hobby,
          PrefetchHooks Function()
        > {
  $$HobbiesTableTableManager(_$AppDatabase db, $HobbiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HobbiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HobbiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HobbiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<bool> isBuiltin = const Value.absent(),
                Value<HobbyGoalPeriod?> goalPeriod = const Value.absent(),
                Value<int?> goalValue = const Value.absent(),
                Value<HobbyGoalUnit> goalUnit = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<String> reminderConfig = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HobbiesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                name: name,
                iconKey: iconKey,
                isBuiltin: isBuiltin,
                goalPeriod: goalPeriod,
                goalValue: goalValue,
                goalUnit: goalUnit,
                reminderEnabled: reminderEnabled,
                reminderConfig: reminderConfig,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String userId,
                required String name,
                required String iconKey,
                Value<bool> isBuiltin = const Value.absent(),
                Value<HobbyGoalPeriod?> goalPeriod = const Value.absent(),
                Value<int?> goalValue = const Value.absent(),
                Value<HobbyGoalUnit> goalUnit = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<String> reminderConfig = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HobbiesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                name: name,
                iconKey: iconKey,
                isBuiltin: isBuiltin,
                goalPeriod: goalPeriod,
                goalValue: goalValue,
                goalUnit: goalUnit,
                reminderEnabled: reminderEnabled,
                reminderConfig: reminderConfig,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HobbiesTable, Hobby>(table),
                  BaseReferences<_$AppDatabase, $HobbiesTable, Hobby>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HobbiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HobbiesTable,
      Hobby,
      $$HobbiesTableFilterComposer,
      $$HobbiesTableOrderingComposer,
      $$HobbiesTableAnnotationComposer,
      $$HobbiesTableCreateCompanionBuilder,
      $$HobbiesTableUpdateCompanionBuilder,
      (Hobby, BaseReferences<_$AppDatabase, $HobbiesTable, Hobby>),
      Hobby,
      PrefetchHooks Function()
    >;
typedef $$HobbyLogsTableCreateCompanionBuilder = HobbyLogsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String userId,
  required String hobbyId,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  required int durationMinutes,
  Value<int> countOrSessions,
  required HobbyLogSource source,
  Value<int> tzOffsetMinutes,
  required String localDate,
  Value<String?> note,
  Value<int> rowid,
});
typedef $$HobbyLogsTableUpdateCompanionBuilder = HobbyLogsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> userId,
  Value<String> hobbyId,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<int> durationMinutes,
  Value<int> countOrSessions,
  Value<HobbyLogSource> source,
  Value<int> tzOffsetMinutes,
  Value<String> localDate,
  Value<String?> note,
  Value<int> rowid,
});

class $$HobbyLogsTableFilterComposer
    extends Composer<_$AppDatabase, $HobbyLogsTable> {
  $$HobbyLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hobbyId => $composableBuilder(
    column: $table.hobbyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get countOrSessions => $composableBuilder(
    column: $table.countOrSessions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<HobbyLogSource, HobbyLogSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HobbyLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $HobbyLogsTable> {
  $$HobbyLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hobbyId => $composableBuilder(
    column: $table.hobbyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get countOrSessions => $composableBuilder(
    column: $table.countOrSessions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HobbyLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HobbyLogsTable> {
  $$HobbyLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get hobbyId =>
      $composableBuilder(column: $table.hobbyId, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get countOrSessions => $composableBuilder(
    column: $table.countOrSessions,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<HobbyLogSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$HobbyLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HobbyLogsTable,
          HobbyLog,
          $$HobbyLogsTableFilterComposer,
          $$HobbyLogsTableOrderingComposer,
          $$HobbyLogsTableAnnotationComposer,
          $$HobbyLogsTableCreateCompanionBuilder,
          $$HobbyLogsTableUpdateCompanionBuilder,
          (HobbyLog, BaseReferences<_$AppDatabase, $HobbyLogsTable, HobbyLog>),
          HobbyLog,
          PrefetchHooks Function()
        > {
  $$HobbyLogsTableTableManager(_$AppDatabase db, $HobbyLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HobbyLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HobbyLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HobbyLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> hobbyId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<int> countOrSessions = const Value.absent(),
                Value<HobbyLogSource> source = const Value.absent(),
                Value<int> tzOffsetMinutes = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HobbyLogsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                hobbyId: hobbyId,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMinutes: durationMinutes,
                countOrSessions: countOrSessions,
                source: source,
                tzOffsetMinutes: tzOffsetMinutes,
                localDate: localDate,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String userId,
                required String hobbyId,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                required int durationMinutes,
                Value<int> countOrSessions = const Value.absent(),
                required HobbyLogSource source,
                Value<int> tzOffsetMinutes = const Value.absent(),
                required String localDate,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HobbyLogsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                hobbyId: hobbyId,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMinutes: durationMinutes,
                countOrSessions: countOrSessions,
                source: source,
                tzOffsetMinutes: tzOffsetMinutes,
                localDate: localDate,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HobbyLogsTable, HobbyLog>(table),
                  BaseReferences<_$AppDatabase, $HobbyLogsTable, HobbyLog>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HobbyLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HobbyLogsTable,
      HobbyLog,
      $$HobbyLogsTableFilterComposer,
      $$HobbyLogsTableOrderingComposer,
      $$HobbyLogsTableAnnotationComposer,
      $$HobbyLogsTableCreateCompanionBuilder,
      $$HobbyLogsTableUpdateCompanionBuilder,
      (HobbyLog, BaseReferences<_$AppDatabase, $HobbyLogsTable, HobbyLog>),
      HobbyLog,
      PrefetchHooks Function()
    >;
typedef $$BodyMeasurementsTableCreateCompanionBuilder =
    BodyMeasurementsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String userId,
      required DateTime measuredAt,
      Value<int> tzOffsetMinutes,
      required String localDate,
      Value<double?> weightKg,
      Value<double?> heightCm,
      Value<double?> bmi,
      Value<double?> waistIn,
      Value<double?> hipsIn,
      Value<double?> chestIn,
      Value<double?> armIn,
      Value<double?> thighIn,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$BodyMeasurementsTableUpdateCompanionBuilder =
    BodyMeasurementsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> userId,
      Value<DateTime> measuredAt,
      Value<int> tzOffsetMinutes,
      Value<String> localDate,
      Value<double?> weightKg,
      Value<double?> heightCm,
      Value<double?> bmi,
      Value<double?> waistIn,
      Value<double?> hipsIn,
      Value<double?> chestIn,
      Value<double?> armIn,
      Value<double?> thighIn,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$BodyMeasurementsTableFilterComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bmi => $composableBuilder(
    column: $table.bmi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get waistIn => $composableBuilder(
    column: $table.waistIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hipsIn => $composableBuilder(
    column: $table.hipsIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get chestIn => $composableBuilder(
    column: $table.chestIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get armIn => $composableBuilder(
    column: $table.armIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get thighIn => $composableBuilder(
    column: $table.thighIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BodyMeasurementsTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bmi => $composableBuilder(
    column: $table.bmi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get waistIn => $composableBuilder(
    column: $table.waistIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hipsIn => $composableBuilder(
    column: $table.hipsIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get chestIn => $composableBuilder(
    column: $table.chestIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get armIn => $composableBuilder(
    column: $table.armIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get thighIn => $composableBuilder(
    column: $table.thighIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BodyMeasurementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get bmi =>
      $composableBuilder(column: $table.bmi, builder: (column) => column);

  GeneratedColumn<double> get waistIn =>
      $composableBuilder(column: $table.waistIn, builder: (column) => column);

  GeneratedColumn<double> get hipsIn =>
      $composableBuilder(column: $table.hipsIn, builder: (column) => column);

  GeneratedColumn<double> get chestIn =>
      $composableBuilder(column: $table.chestIn, builder: (column) => column);

  GeneratedColumn<double> get armIn =>
      $composableBuilder(column: $table.armIn, builder: (column) => column);

  GeneratedColumn<double> get thighIn =>
      $composableBuilder(column: $table.thighIn, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$BodyMeasurementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BodyMeasurementsTable,
          BodyMeasurement,
          $$BodyMeasurementsTableFilterComposer,
          $$BodyMeasurementsTableOrderingComposer,
          $$BodyMeasurementsTableAnnotationComposer,
          $$BodyMeasurementsTableCreateCompanionBuilder,
          $$BodyMeasurementsTableUpdateCompanionBuilder,
          (
            BodyMeasurement,
            BaseReferences<
              _$AppDatabase,
              $BodyMeasurementsTable,
              BodyMeasurement
            >,
          ),
          BodyMeasurement,
          PrefetchHooks Function()
        > {
  $$BodyMeasurementsTableTableManager(
    _$AppDatabase db,
    $BodyMeasurementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyMeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyMeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyMeasurementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> measuredAt = const Value.absent(),
                Value<int> tzOffsetMinutes = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> bmi = const Value.absent(),
                Value<double?> waistIn = const Value.absent(),
                Value<double?> hipsIn = const Value.absent(),
                Value<double?> chestIn = const Value.absent(),
                Value<double?> armIn = const Value.absent(),
                Value<double?> thighIn = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BodyMeasurementsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                measuredAt: measuredAt,
                tzOffsetMinutes: tzOffsetMinutes,
                localDate: localDate,
                weightKg: weightKg,
                heightCm: heightCm,
                bmi: bmi,
                waistIn: waistIn,
                hipsIn: hipsIn,
                chestIn: chestIn,
                armIn: armIn,
                thighIn: thighIn,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String userId,
                required DateTime measuredAt,
                Value<int> tzOffsetMinutes = const Value.absent(),
                required String localDate,
                Value<double?> weightKg = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> bmi = const Value.absent(),
                Value<double?> waistIn = const Value.absent(),
                Value<double?> hipsIn = const Value.absent(),
                Value<double?> chestIn = const Value.absent(),
                Value<double?> armIn = const Value.absent(),
                Value<double?> thighIn = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BodyMeasurementsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                measuredAt: measuredAt,
                tzOffsetMinutes: tzOffsetMinutes,
                localDate: localDate,
                weightKg: weightKg,
                heightCm: heightCm,
                bmi: bmi,
                waistIn: waistIn,
                hipsIn: hipsIn,
                chestIn: chestIn,
                armIn: armIn,
                thighIn: thighIn,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BodyMeasurementsTable, BodyMeasurement>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BodyMeasurementsTable,
                    BodyMeasurement
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BodyMeasurementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BodyMeasurementsTable,
      BodyMeasurement,
      $$BodyMeasurementsTableFilterComposer,
      $$BodyMeasurementsTableOrderingComposer,
      $$BodyMeasurementsTableAnnotationComposer,
      $$BodyMeasurementsTableCreateCompanionBuilder,
      $$BodyMeasurementsTableUpdateCompanionBuilder,
      (
        BodyMeasurement,
        BaseReferences<_$AppDatabase, $BodyMeasurementsTable, BodyMeasurement>,
      ),
      BodyMeasurement,
      PrefetchHooks Function()
    >;
typedef $$SleepTargetsTableCreateCompanionBuilder =
    SleepTargetsCompanion Function({
      required String userId,
      required int bedtimeMinutes,
      required int wakeMinutes,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SleepTargetsTableUpdateCompanionBuilder =
    SleepTargetsCompanion Function({
      Value<String> userId,
      Value<int> bedtimeMinutes,
      Value<int> wakeMinutes,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SleepTargetsTableFilterComposer
    extends Composer<_$AppDatabase, $SleepTargetsTable> {
  $$SleepTargetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bedtimeMinutes => $composableBuilder(
    column: $table.bedtimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wakeMinutes => $composableBuilder(
    column: $table.wakeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SleepTargetsTableOrderingComposer
    extends Composer<_$AppDatabase, $SleepTargetsTable> {
  $$SleepTargetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bedtimeMinutes => $composableBuilder(
    column: $table.bedtimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wakeMinutes => $composableBuilder(
    column: $table.wakeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SleepTargetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SleepTargetsTable> {
  $$SleepTargetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get bedtimeMinutes => $composableBuilder(
    column: $table.bedtimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wakeMinutes => $composableBuilder(
    column: $table.wakeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SleepTargetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SleepTargetsTable,
          SleepTarget,
          $$SleepTargetsTableFilterComposer,
          $$SleepTargetsTableOrderingComposer,
          $$SleepTargetsTableAnnotationComposer,
          $$SleepTargetsTableCreateCompanionBuilder,
          $$SleepTargetsTableUpdateCompanionBuilder,
          (
            SleepTarget,
            BaseReferences<_$AppDatabase, $SleepTargetsTable, SleepTarget>,
          ),
          SleepTarget,
          PrefetchHooks Function()
        > {
  $$SleepTargetsTableTableManager(_$AppDatabase db, $SleepTargetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SleepTargetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SleepTargetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SleepTargetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<int> bedtimeMinutes = const Value.absent(),
                Value<int> wakeMinutes = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SleepTargetsCompanion(
                userId: userId,
                bedtimeMinutes: bedtimeMinutes,
                wakeMinutes: wakeMinutes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required int bedtimeMinutes,
                required int wakeMinutes,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SleepTargetsCompanion.insert(
                userId: userId,
                bedtimeMinutes: bedtimeMinutes,
                wakeMinutes: wakeMinutes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SleepTargetsTable, SleepTarget>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SleepTargetsTable,
                    SleepTarget
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SleepTargetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SleepTargetsTable,
      SleepTarget,
      $$SleepTargetsTableFilterComposer,
      $$SleepTargetsTableOrderingComposer,
      $$SleepTargetsTableAnnotationComposer,
      $$SleepTargetsTableCreateCompanionBuilder,
      $$SleepTargetsTableUpdateCompanionBuilder,
      (
        SleepTarget,
        BaseReferences<_$AppDatabase, $SleepTargetsTable, SleepTarget>,
      ),
      SleepTarget,
      PrefetchHooks Function()
    >;
typedef $$SleepLogsTableCreateCompanionBuilder = SleepLogsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String userId,
  required DateTime bedtimeAt,
  required DateTime wakeAt,
  required int durationMinutes,
  Value<int> tzOffsetMinutes,
  required String localDate,
  Value<int> rowid,
});
typedef $$SleepLogsTableUpdateCompanionBuilder = SleepLogsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> userId,
  Value<DateTime> bedtimeAt,
  Value<DateTime> wakeAt,
  Value<int> durationMinutes,
  Value<int> tzOffsetMinutes,
  Value<String> localDate,
  Value<int> rowid,
});

class $$SleepLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SleepLogsTable> {
  $$SleepLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get bedtimeAt => $composableBuilder(
    column: $table.bedtimeAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get wakeAt => $composableBuilder(
    column: $table.wakeAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SleepLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SleepLogsTable> {
  $$SleepLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get bedtimeAt => $composableBuilder(
    column: $table.bedtimeAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get wakeAt => $composableBuilder(
    column: $table.wakeAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SleepLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SleepLogsTable> {
  $$SleepLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get bedtimeAt =>
      $composableBuilder(column: $table.bedtimeAt, builder: (column) => column);

  GeneratedColumn<DateTime> get wakeAt =>
      $composableBuilder(column: $table.wakeAt, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);
}

class $$SleepLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SleepLogsTable,
          SleepLog,
          $$SleepLogsTableFilterComposer,
          $$SleepLogsTableOrderingComposer,
          $$SleepLogsTableAnnotationComposer,
          $$SleepLogsTableCreateCompanionBuilder,
          $$SleepLogsTableUpdateCompanionBuilder,
          (SleepLog, BaseReferences<_$AppDatabase, $SleepLogsTable, SleepLog>),
          SleepLog,
          PrefetchHooks Function()
        > {
  $$SleepLogsTableTableManager(_$AppDatabase db, $SleepLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SleepLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SleepLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SleepLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> bedtimeAt = const Value.absent(),
                Value<DateTime> wakeAt = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<int> tzOffsetMinutes = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SleepLogsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                bedtimeAt: bedtimeAt,
                wakeAt: wakeAt,
                durationMinutes: durationMinutes,
                tzOffsetMinutes: tzOffsetMinutes,
                localDate: localDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String userId,
                required DateTime bedtimeAt,
                required DateTime wakeAt,
                required int durationMinutes,
                Value<int> tzOffsetMinutes = const Value.absent(),
                required String localDate,
                Value<int> rowid = const Value.absent(),
              }) => SleepLogsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                bedtimeAt: bedtimeAt,
                wakeAt: wakeAt,
                durationMinutes: durationMinutes,
                tzOffsetMinutes: tzOffsetMinutes,
                localDate: localDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SleepLogsTable, SleepLog>(table),
                  BaseReferences<_$AppDatabase, $SleepLogsTable, SleepLog>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SleepLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SleepLogsTable,
      SleepLog,
      $$SleepLogsTableFilterComposer,
      $$SleepLogsTableOrderingComposer,
      $$SleepLogsTableAnnotationComposer,
      $$SleepLogsTableCreateCompanionBuilder,
      $$SleepLogsTableUpdateCompanionBuilder,
      (SleepLog, BaseReferences<_$AppDatabase, $SleepLogsTable, SleepLog>),
      SleepLog,
      PrefetchHooks Function()
    >;
typedef $$RestDaysTableCreateCompanionBuilder = RestDaysCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String userId,
  required String localDate,
  Value<int> rowid,
});
typedef $$RestDaysTableUpdateCompanionBuilder = RestDaysCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> userId,
  Value<String> localDate,
  Value<int> rowid,
});

class $$RestDaysTableFilterComposer
    extends Composer<_$AppDatabase, $RestDaysTable> {
  $$RestDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RestDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $RestDaysTable> {
  $$RestDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RestDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $RestDaysTable> {
  $$RestDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);
}

class $$RestDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RestDaysTable,
          RestDay,
          $$RestDaysTableFilterComposer,
          $$RestDaysTableOrderingComposer,
          $$RestDaysTableAnnotationComposer,
          $$RestDaysTableCreateCompanionBuilder,
          $$RestDaysTableUpdateCompanionBuilder,
          (RestDay, BaseReferences<_$AppDatabase, $RestDaysTable, RestDay>),
          RestDay,
          PrefetchHooks Function()
        > {
  $$RestDaysTableTableManager(_$AppDatabase db, $RestDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RestDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RestDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RestDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RestDaysCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                localDate: localDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String userId,
                required String localDate,
                Value<int> rowid = const Value.absent(),
              }) => RestDaysCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                localDate: localDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RestDaysTable, RestDay>(table),
                  BaseReferences<_$AppDatabase, $RestDaysTable, RestDay>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RestDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RestDaysTable,
      RestDay,
      $$RestDaysTableFilterComposer,
      $$RestDaysTableOrderingComposer,
      $$RestDaysTableAnnotationComposer,
      $$RestDaysTableCreateCompanionBuilder,
      $$RestDaysTableUpdateCompanionBuilder,
      (RestDay, BaseReferences<_$AppDatabase, $RestDaysTable, RestDay>),
      RestDay,
      PrefetchHooks Function()
    >;
typedef $$StreakStatesTableCreateCompanionBuilder =
    StreakStatesCompanion Function({
      required String userId,
      required String scope,
      Value<int> currentStreak,
      Value<int> longestStreak,
      Value<String?> lastCountedDate,
      Value<bool> freezeAvailable,
      Value<String?> freezeLastGrantedOn,
      Value<int> rowid,
    });
typedef $$StreakStatesTableUpdateCompanionBuilder =
    StreakStatesCompanion Function({
      Value<String> userId,
      Value<String> scope,
      Value<int> currentStreak,
      Value<int> longestStreak,
      Value<String?> lastCountedDate,
      Value<bool> freezeAvailable,
      Value<String?> freezeLastGrantedOn,
      Value<int> rowid,
    });

class $$StreakStatesTableFilterComposer
    extends Composer<_$AppDatabase, $StreakStatesTable> {
  $$StreakStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastCountedDate => $composableBuilder(
    column: $table.lastCountedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get freezeAvailable => $composableBuilder(
    column: $table.freezeAvailable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get freezeLastGrantedOn => $composableBuilder(
    column: $table.freezeLastGrantedOn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StreakStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $StreakStatesTable> {
  $$StreakStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastCountedDate => $composableBuilder(
    column: $table.lastCountedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get freezeAvailable => $composableBuilder(
    column: $table.freezeAvailable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get freezeLastGrantedOn => $composableBuilder(
    column: $table.freezeLastGrantedOn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StreakStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StreakStatesTable> {
  $$StreakStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastCountedDate => $composableBuilder(
    column: $table.lastCountedDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get freezeAvailable => $composableBuilder(
    column: $table.freezeAvailable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get freezeLastGrantedOn => $composableBuilder(
    column: $table.freezeLastGrantedOn,
    builder: (column) => column,
  );
}

class $$StreakStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StreakStatesTable,
          StreakState,
          $$StreakStatesTableFilterComposer,
          $$StreakStatesTableOrderingComposer,
          $$StreakStatesTableAnnotationComposer,
          $$StreakStatesTableCreateCompanionBuilder,
          $$StreakStatesTableUpdateCompanionBuilder,
          (
            StreakState,
            BaseReferences<_$AppDatabase, $StreakStatesTable, StreakState>,
          ),
          StreakState,
          PrefetchHooks Function()
        > {
  $$StreakStatesTableTableManager(_$AppDatabase db, $StreakStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StreakStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StreakStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StreakStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<String?> lastCountedDate = const Value.absent(),
                Value<bool> freezeAvailable = const Value.absent(),
                Value<String?> freezeLastGrantedOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StreakStatesCompanion(
                userId: userId,
                scope: scope,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                lastCountedDate: lastCountedDate,
                freezeAvailable: freezeAvailable,
                freezeLastGrantedOn: freezeLastGrantedOn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String scope,
                Value<int> currentStreak = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<String?> lastCountedDate = const Value.absent(),
                Value<bool> freezeAvailable = const Value.absent(),
                Value<String?> freezeLastGrantedOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StreakStatesCompanion.insert(
                userId: userId,
                scope: scope,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                lastCountedDate: lastCountedDate,
                freezeAvailable: freezeAvailable,
                freezeLastGrantedOn: freezeLastGrantedOn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StreakStatesTable, StreakState>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $StreakStatesTable,
                    StreakState
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StreakStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StreakStatesTable,
      StreakState,
      $$StreakStatesTableFilterComposer,
      $$StreakStatesTableOrderingComposer,
      $$StreakStatesTableAnnotationComposer,
      $$StreakStatesTableCreateCompanionBuilder,
      $$StreakStatesTableUpdateCompanionBuilder,
      (
        StreakState,
        BaseReferences<_$AppDatabase, $StreakStatesTable, StreakState>,
      ),
      StreakState,
      PrefetchHooks Function()
    >;
typedef $$BadgesAwardedTableCreateCompanionBuilder =
    BadgesAwardedCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String userId,
      required String badgeKey,
      required DateTime awardedAt,
      Value<String> context,
      Value<int> rowid,
    });
typedef $$BadgesAwardedTableUpdateCompanionBuilder =
    BadgesAwardedCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> userId,
      Value<String> badgeKey,
      Value<DateTime> awardedAt,
      Value<String> context,
      Value<int> rowid,
    });

class $$BadgesAwardedTableFilterComposer
    extends Composer<_$AppDatabase, $BadgesAwardedTable> {
  $$BadgesAwardedTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get badgeKey => $composableBuilder(
    column: $table.badgeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get awardedAt => $composableBuilder(
    column: $table.awardedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BadgesAwardedTableOrderingComposer
    extends Composer<_$AppDatabase, $BadgesAwardedTable> {
  $$BadgesAwardedTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get badgeKey => $composableBuilder(
    column: $table.badgeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get awardedAt => $composableBuilder(
    column: $table.awardedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BadgesAwardedTableAnnotationComposer
    extends Composer<_$AppDatabase, $BadgesAwardedTable> {
  $$BadgesAwardedTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get badgeKey =>
      $composableBuilder(column: $table.badgeKey, builder: (column) => column);

  GeneratedColumn<DateTime> get awardedAt =>
      $composableBuilder(column: $table.awardedAt, builder: (column) => column);

  GeneratedColumn<String> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);
}

class $$BadgesAwardedTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BadgesAwardedTable,
          BadgesAwardedData,
          $$BadgesAwardedTableFilterComposer,
          $$BadgesAwardedTableOrderingComposer,
          $$BadgesAwardedTableAnnotationComposer,
          $$BadgesAwardedTableCreateCompanionBuilder,
          $$BadgesAwardedTableUpdateCompanionBuilder,
          (
            BadgesAwardedData,
            BaseReferences<
              _$AppDatabase,
              $BadgesAwardedTable,
              BadgesAwardedData
            >,
          ),
          BadgesAwardedData,
          PrefetchHooks Function()
        > {
  $$BadgesAwardedTableTableManager(_$AppDatabase db, $BadgesAwardedTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BadgesAwardedTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BadgesAwardedTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BadgesAwardedTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> badgeKey = const Value.absent(),
                Value<DateTime> awardedAt = const Value.absent(),
                Value<String> context = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BadgesAwardedCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                badgeKey: badgeKey,
                awardedAt: awardedAt,
                context: context,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String userId,
                required String badgeKey,
                required DateTime awardedAt,
                Value<String> context = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BadgesAwardedCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                badgeKey: badgeKey,
                awardedAt: awardedAt,
                context: context,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BadgesAwardedTable, BadgesAwardedData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BadgesAwardedTable,
                    BadgesAwardedData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BadgesAwardedTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BadgesAwardedTable,
      BadgesAwardedData,
      $$BadgesAwardedTableFilterComposer,
      $$BadgesAwardedTableOrderingComposer,
      $$BadgesAwardedTableAnnotationComposer,
      $$BadgesAwardedTableCreateCompanionBuilder,
      $$BadgesAwardedTableUpdateCompanionBuilder,
      (
        BadgesAwardedData,
        BaseReferences<_$AppDatabase, $BadgesAwardedTable, BadgesAwardedData>,
      ),
      BadgesAwardedData,
      PrefetchHooks Function()
    >;
typedef $$ScreenTimeDailyTableCreateCompanionBuilder =
    ScreenTimeDailyCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String userId,
      required String localDate,
      required int totalMinutes,
      Value<String> categoryMinutes,
      Value<int> lateEveningMinutes,
      Value<bool> shareInGroups,
      Value<ScreenTimeSource> source,
      Value<int?> targetMinutes,
      Value<int> rowid,
    });
typedef $$ScreenTimeDailyTableUpdateCompanionBuilder =
    ScreenTimeDailyCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> userId,
      Value<String> localDate,
      Value<int> totalMinutes,
      Value<String> categoryMinutes,
      Value<int> lateEveningMinutes,
      Value<bool> shareInGroups,
      Value<ScreenTimeSource> source,
      Value<int?> targetMinutes,
      Value<int> rowid,
    });

class $$ScreenTimeDailyTableFilterComposer
    extends Composer<_$AppDatabase, $ScreenTimeDailyTable> {
  $$ScreenTimeDailyTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMinutes => $composableBuilder(
    column: $table.totalMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryMinutes => $composableBuilder(
    column: $table.categoryMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lateEveningMinutes => $composableBuilder(
    column: $table.lateEveningMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shareInGroups => $composableBuilder(
    column: $table.shareInGroups,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ScreenTimeSource, ScreenTimeSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get targetMinutes => $composableBuilder(
    column: $table.targetMinutes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScreenTimeDailyTableOrderingComposer
    extends Composer<_$AppDatabase, $ScreenTimeDailyTable> {
  $$ScreenTimeDailyTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMinutes => $composableBuilder(
    column: $table.totalMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryMinutes => $composableBuilder(
    column: $table.categoryMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lateEveningMinutes => $composableBuilder(
    column: $table.lateEveningMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shareInGroups => $composableBuilder(
    column: $table.shareInGroups,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetMinutes => $composableBuilder(
    column: $table.targetMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScreenTimeDailyTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScreenTimeDailyTable> {
  $$ScreenTimeDailyTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<int> get totalMinutes => $composableBuilder(
    column: $table.totalMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryMinutes => $composableBuilder(
    column: $table.categoryMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lateEveningMinutes => $composableBuilder(
    column: $table.lateEveningMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get shareInGroups => $composableBuilder(
    column: $table.shareInGroups,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ScreenTimeSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get targetMinutes => $composableBuilder(
    column: $table.targetMinutes,
    builder: (column) => column,
  );
}

class $$ScreenTimeDailyTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScreenTimeDailyTable,
          ScreenTimeDailyData,
          $$ScreenTimeDailyTableFilterComposer,
          $$ScreenTimeDailyTableOrderingComposer,
          $$ScreenTimeDailyTableAnnotationComposer,
          $$ScreenTimeDailyTableCreateCompanionBuilder,
          $$ScreenTimeDailyTableUpdateCompanionBuilder,
          (
            ScreenTimeDailyData,
            BaseReferences<
              _$AppDatabase,
              $ScreenTimeDailyTable,
              ScreenTimeDailyData
            >,
          ),
          ScreenTimeDailyData,
          PrefetchHooks Function()
        > {
  $$ScreenTimeDailyTableTableManager(
    _$AppDatabase db,
    $ScreenTimeDailyTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScreenTimeDailyTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScreenTimeDailyTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScreenTimeDailyTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<int> totalMinutes = const Value.absent(),
                Value<String> categoryMinutes = const Value.absent(),
                Value<int> lateEveningMinutes = const Value.absent(),
                Value<bool> shareInGroups = const Value.absent(),
                Value<ScreenTimeSource> source = const Value.absent(),
                Value<int?> targetMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScreenTimeDailyCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                localDate: localDate,
                totalMinutes: totalMinutes,
                categoryMinutes: categoryMinutes,
                lateEveningMinutes: lateEveningMinutes,
                shareInGroups: shareInGroups,
                source: source,
                targetMinutes: targetMinutes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String userId,
                required String localDate,
                required int totalMinutes,
                Value<String> categoryMinutes = const Value.absent(),
                Value<int> lateEveningMinutes = const Value.absent(),
                Value<bool> shareInGroups = const Value.absent(),
                Value<ScreenTimeSource> source = const Value.absent(),
                Value<int?> targetMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScreenTimeDailyCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                localDate: localDate,
                totalMinutes: totalMinutes,
                categoryMinutes: categoryMinutes,
                lateEveningMinutes: lateEveningMinutes,
                shareInGroups: shareInGroups,
                source: source,
                targetMinutes: targetMinutes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScreenTimeDailyTable, ScreenTimeDailyData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $ScreenTimeDailyTable,
                    ScreenTimeDailyData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScreenTimeDailyTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScreenTimeDailyTable,
      ScreenTimeDailyData,
      $$ScreenTimeDailyTableFilterComposer,
      $$ScreenTimeDailyTableOrderingComposer,
      $$ScreenTimeDailyTableAnnotationComposer,
      $$ScreenTimeDailyTableCreateCompanionBuilder,
      $$ScreenTimeDailyTableUpdateCompanionBuilder,
      (
        ScreenTimeDailyData,
        BaseReferences<
          _$AppDatabase,
          $ScreenTimeDailyTable,
          ScreenTimeDailyData
        >,
      ),
      ScreenTimeDailyData,
      PrefetchHooks Function()
    >;
typedef $$WeeklyInsightsTableCreateCompanionBuilder =
    WeeklyInsightsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String userId,
      required String weekStart,
      required String insightKey,
      Value<String> params,
      required DateTime generatedAt,
      Value<int> rowid,
    });
typedef $$WeeklyInsightsTableUpdateCompanionBuilder =
    WeeklyInsightsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> userId,
      Value<String> weekStart,
      Value<String> insightKey,
      Value<String> params,
      Value<DateTime> generatedAt,
      Value<int> rowid,
    });

class $$WeeklyInsightsTableFilterComposer
    extends Composer<_$AppDatabase, $WeeklyInsightsTable> {
  $$WeeklyInsightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get insightKey => $composableBuilder(
    column: $table.insightKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get params => $composableBuilder(
    column: $table.params,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeeklyInsightsTableOrderingComposer
    extends Composer<_$AppDatabase, $WeeklyInsightsTable> {
  $$WeeklyInsightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get insightKey => $composableBuilder(
    column: $table.insightKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get params => $composableBuilder(
    column: $table.params,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeeklyInsightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeeklyInsightsTable> {
  $$WeeklyInsightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumn<String> get insightKey => $composableBuilder(
    column: $table.insightKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get params =>
      $composableBuilder(column: $table.params, builder: (column) => column);

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );
}

class $$WeeklyInsightsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeeklyInsightsTable,
          WeeklyInsight,
          $$WeeklyInsightsTableFilterComposer,
          $$WeeklyInsightsTableOrderingComposer,
          $$WeeklyInsightsTableAnnotationComposer,
          $$WeeklyInsightsTableCreateCompanionBuilder,
          $$WeeklyInsightsTableUpdateCompanionBuilder,
          (
            WeeklyInsight,
            BaseReferences<_$AppDatabase, $WeeklyInsightsTable, WeeklyInsight>,
          ),
          WeeklyInsight,
          PrefetchHooks Function()
        > {
  $$WeeklyInsightsTableTableManager(
    _$AppDatabase db,
    $WeeklyInsightsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeeklyInsightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeeklyInsightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeeklyInsightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> weekStart = const Value.absent(),
                Value<String> insightKey = const Value.absent(),
                Value<String> params = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeeklyInsightsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                weekStart: weekStart,
                insightKey: insightKey,
                params: params,
                generatedAt: generatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String userId,
                required String weekStart,
                required String insightKey,
                Value<String> params = const Value.absent(),
                required DateTime generatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WeeklyInsightsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                weekStart: weekStart,
                insightKey: insightKey,
                params: params,
                generatedAt: generatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WeeklyInsightsTable, WeeklyInsight>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WeeklyInsightsTable,
                    WeeklyInsight
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeeklyInsightsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeeklyInsightsTable,
      WeeklyInsight,
      $$WeeklyInsightsTableFilterComposer,
      $$WeeklyInsightsTableOrderingComposer,
      $$WeeklyInsightsTableAnnotationComposer,
      $$WeeklyInsightsTableCreateCompanionBuilder,
      $$WeeklyInsightsTableUpdateCompanionBuilder,
      (
        WeeklyInsight,
        BaseReferences<_$AppDatabase, $WeeklyInsightsTable, WeeklyInsight>,
      ),
      WeeklyInsight,
      PrefetchHooks Function()
    >;
typedef $$TipsLibraryTableCreateCompanionBuilder =
    TipsLibraryCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String triggerKey,
      required String body,
      required String sourceLabel,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$TipsLibraryTableUpdateCompanionBuilder =
    TipsLibraryCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> triggerKey,
      Value<String> body,
      Value<String> sourceLabel,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$TipsLibraryTableFilterComposer
    extends Composer<_$AppDatabase, $TipsLibraryTable> {
  $$TipsLibraryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get triggerKey => $composableBuilder(
    column: $table.triggerKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceLabel => $composableBuilder(
    column: $table.sourceLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TipsLibraryTableOrderingComposer
    extends Composer<_$AppDatabase, $TipsLibraryTable> {
  $$TipsLibraryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get triggerKey => $composableBuilder(
    column: $table.triggerKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceLabel => $composableBuilder(
    column: $table.sourceLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TipsLibraryTableAnnotationComposer
    extends Composer<_$AppDatabase, $TipsLibraryTable> {
  $$TipsLibraryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get triggerKey => $composableBuilder(
    column: $table.triggerKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get sourceLabel => $composableBuilder(
    column: $table.sourceLabel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$TipsLibraryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TipsLibraryTable,
          TipsLibraryData,
          $$TipsLibraryTableFilterComposer,
          $$TipsLibraryTableOrderingComposer,
          $$TipsLibraryTableAnnotationComposer,
          $$TipsLibraryTableCreateCompanionBuilder,
          $$TipsLibraryTableUpdateCompanionBuilder,
          (
            TipsLibraryData,
            BaseReferences<_$AppDatabase, $TipsLibraryTable, TipsLibraryData>,
          ),
          TipsLibraryData,
          PrefetchHooks Function()
        > {
  $$TipsLibraryTableTableManager(_$AppDatabase db, $TipsLibraryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TipsLibraryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TipsLibraryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TipsLibraryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> triggerKey = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> sourceLabel = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TipsLibraryCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                triggerKey: triggerKey,
                body: body,
                sourceLabel: sourceLabel,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String triggerKey,
                required String body,
                required String sourceLabel,
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TipsLibraryCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                triggerKey: triggerKey,
                body: body,
                sourceLabel: sourceLabel,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TipsLibraryTable, TipsLibraryData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TipsLibraryTable,
                    TipsLibraryData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TipsLibraryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TipsLibraryTable,
      TipsLibraryData,
      $$TipsLibraryTableFilterComposer,
      $$TipsLibraryTableOrderingComposer,
      $$TipsLibraryTableAnnotationComposer,
      $$TipsLibraryTableCreateCompanionBuilder,
      $$TipsLibraryTableUpdateCompanionBuilder,
      (
        TipsLibraryData,
        BaseReferences<_$AppDatabase, $TipsLibraryTable, TipsLibraryData>,
      ),
      TipsLibraryData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$WorkoutTypesTableTableManager get workoutTypes =>
      $$WorkoutTypesTableTableManager(_db, _db.workoutTypes);
  $$WorkoutsTableTableManager get workouts =>
      $$WorkoutsTableTableManager(_db, _db.workouts);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$HabitLogsTableTableManager get habitLogs =>
      $$HabitLogsTableTableManager(_db, _db.habitLogs);
  $$HabitSkipsTableTableManager get habitSkips =>
      $$HabitSkipsTableTableManager(_db, _db.habitSkips);
  $$HobbiesTableTableManager get hobbies =>
      $$HobbiesTableTableManager(_db, _db.hobbies);
  $$HobbyLogsTableTableManager get hobbyLogs =>
      $$HobbyLogsTableTableManager(_db, _db.hobbyLogs);
  $$BodyMeasurementsTableTableManager get bodyMeasurements =>
      $$BodyMeasurementsTableTableManager(_db, _db.bodyMeasurements);
  $$SleepTargetsTableTableManager get sleepTargets =>
      $$SleepTargetsTableTableManager(_db, _db.sleepTargets);
  $$SleepLogsTableTableManager get sleepLogs =>
      $$SleepLogsTableTableManager(_db, _db.sleepLogs);
  $$RestDaysTableTableManager get restDays =>
      $$RestDaysTableTableManager(_db, _db.restDays);
  $$StreakStatesTableTableManager get streakStates =>
      $$StreakStatesTableTableManager(_db, _db.streakStates);
  $$BadgesAwardedTableTableManager get badgesAwarded =>
      $$BadgesAwardedTableTableManager(_db, _db.badgesAwarded);
  $$ScreenTimeDailyTableTableManager get screenTimeDaily =>
      $$ScreenTimeDailyTableTableManager(_db, _db.screenTimeDaily);
  $$WeeklyInsightsTableTableManager get weeklyInsights =>
      $$WeeklyInsightsTableTableManager(_db, _db.weeklyInsights);
  $$TipsLibraryTableTableManager get tipsLibrary =>
      $$TipsLibraryTableTableManager(_db, _db.tipsLibrary);
}
