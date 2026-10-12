import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/time/app_clock.dart';
import '../../core/time/local_date.dart';
import '../app_database.dart';
import '../tables/tables.dart';

/// The hobbies every account starts with (R5): name and icon key.
const builtinHobbies = <({String name, String iconKey})>[
  (name: 'Music', iconKey: 'music'),
  (name: 'Art', iconKey: 'art'),
  (name: 'Dance', iconKey: 'dance'),
  (name: 'Learning', iconKey: 'learning'),
  (name: 'Reading', iconKey: 'reading'),
  (name: 'Writing', iconKey: 'writing'),
];

/// Time and sessions logged over a span of days.
class HobbyTotals {
  const HobbyTotals({required this.minutes, required this.sessions});
  final int minutes;
  final int sessions;
}

class HobbyRepository {
  HobbyRepository(this._db, this._clock);

  final AppDatabase _db;
  final AppClock _clock;

  // --- hobbies -------------------------------------------------------------

  /// Adds the built-in hobbies this account does not have yet. Safe to call
  /// on every start: a built-in is matched by name, so nothing is duplicated,
  /// and one the person deleted is not brought back.
  Future<void> ensureDefaults(String userId) {
    return _db.transaction(() async {
      final existing =
          await (_db.select(_db.hobbies)..where(
                (h) => h.userId.equals(userId) & h.isBuiltin.equals(true),
              ))
              .get();
      final have = {for (final h in existing) h.name};
      final now = _clock.now();
      for (final (i, b) in builtinHobbies.indexed) {
        if (have.contains(b.name)) continue;
        await _db
            .into(_db.hobbies)
            .insert(
              HobbiesCompanion.insert(
                id: const Uuid().v4(),
                // Staggered so the list keeps the order above.
                createdAt: now.add(Duration(seconds: i)),
                updatedAt: now,
                userId: userId,
                name: b.name,
                iconKey: b.iconKey,
                isBuiltin: const Value(true),
              ),
            );
      }
    });
  }

  Future<String> addCustom({
    required String userId,
    required String name,
    String iconKey = 'hobby',
    HobbyGoalPeriod? goalPeriod,
    int? goalValue,
    HobbyGoalUnit goalUnit = HobbyGoalUnit.minutes,
    bool reminderEnabled = false,
    String reminderConfig = '{}',
  }) async {
    final now = _clock.now();
    final id = const Uuid().v4();
    await _db
        .into(_db.hobbies)
        .insert(
          HobbiesCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            userId: userId,
            name: name,
            iconKey: iconKey,
            goalPeriod: Value(goalPeriod),
            goalValue: Value(goalValue),
            goalUnit: Value(goalUnit),
            reminderEnabled: Value(reminderEnabled),
            reminderConfig: Value(reminderConfig),
          ),
        );
    return id;
  }

  /// Changes any fields of a hobby (name, goal, reminder...).
  Future<void> update(String id, HobbiesCompanion changes) =>
      (_db.update(_db.hobbies)..where((h) => h.id.equals(id))).write(
        changes.copyWith(updatedAt: Value(_clock.now())),
      );

  /// Hides a hobby from the active list but keeps it and its logs.
  Future<void> archive(String id) =>
      update(id, const HobbiesCompanion(isActive: Value(false)));

  Future<void> unarchive(String id) =>
      update(id, const HobbiesCompanion(isActive: Value(true)));

  /// Soft-deletes a hobby (it syncs as deleted). Its logs are kept.
  Future<void> delete(String id) =>
      update(id, HobbiesCompanion(deletedAt: Value(_clock.now())));

  Future<Hobby?> byId(String id) => (_db.select(
    _db.hobbies,
  )..where((h) => h.id.equals(id) & h.deletedAt.isNull())).getSingleOrNull();

  Stream<List<Hobby>> watchActive(String userId) => _watch(userId, true);

  /// Archived hobbies only.
  Stream<List<Hobby>> watchArchived(String userId) => _watch(userId, false);

  Stream<List<Hobby>> _watch(String userId, bool active) {
    return (_db.select(_db.hobbies)
          ..where(
            (h) =>
                h.userId.equals(userId) &
                h.deletedAt.isNull() &
                h.isActive.equals(active),
          )
          ..orderBy([
            (h) => OrderingTerm.asc(h.createdAt),
            (h) => OrderingTerm.asc(h.name),
          ]))
        .watch();
  }

  // --- logs ----------------------------------------------------------------

  /// Records time spent on a hobby. If [endedAt] is given and [durationMinutes]
  /// is not, the duration is the difference. The local date comes from
  /// [startedAt] (or now, for a manual entry without a start).
  Future<String> addLog({
    required String userId,
    required String hobbyId,
    required int dayCutoffMinutes,
    required HobbyLogSource source,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationMinutes,
    int countOrSessions = 1,
    String? note,
  }) async {
    final now = _clock.now();
    final start =
        (startedAt ?? endedAt?.subtract(_span(durationMinutes)) ?? now).toUtc();
    final minutes =
        durationMinutes ??
        (endedAt == null
            ? 0
            : endedAt.toUtc().difference(start).inMinutes.clamp(0, 1 << 30));
    final offset = _clock.offsetAt(start);
    final id = const Uuid().v4();
    await _db
        .into(_db.hobbyLogs)
        .insert(
          HobbyLogsCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            userId: userId,
            hobbyId: hobbyId,
            startedAt: start,
            endedAt: Value(endedAt?.toUtc()),
            durationMinutes: minutes,
            countOrSessions: Value(countOrSessions),
            source: source,
            tzOffsetMinutes: Value(offset),
            localDate: localDateOf(
              start,
              offsetMinutes: offset,
              cutoffMinutes: dayCutoffMinutes,
            ),
            note: Value(note),
          ),
        );
    return id;
  }

  Duration _span(int? minutes) => Duration(minutes: minutes ?? 0);

  /// Edits a log. A new [startedAt] re-derives the local date.
  Future<void> updateLog({
    required String id,
    required int dayCutoffMinutes,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationMinutes,
    int? countOrSessions,
    String? note,
  }) async {
    final current = await (_db.select(
      _db.hobbyLogs,
    )..where((l) => l.id.equals(id))).getSingle();
    final start = (startedAt ?? current.startedAt).toUtc();
    final offset = startedAt != null
        ? _clock.offsetAt(start)
        : current.tzOffsetMinutes;
    await (_db.update(_db.hobbyLogs)..where((l) => l.id.equals(id))).write(
      HobbyLogsCompanion(
        startedAt: Value(start),
        endedAt: endedAt == null
            ? const Value.absent()
            : Value(endedAt.toUtc()),
        durationMinutes: durationMinutes == null
            ? const Value.absent()
            : Value(durationMinutes),
        countOrSessions: countOrSessions == null
            ? const Value.absent()
            : Value(countOrSessions),
        note: note == null ? const Value.absent() : Value(note),
        tzOffsetMinutes: Value(offset),
        localDate: Value(
          localDateOf(
            start,
            offsetMinutes: offset,
            cutoffMinutes: dayCutoffMinutes,
          ),
        ),
        updatedAt: Value(_clock.now()),
      ),
    );
  }

  Future<void> deleteLog(String id) =>
      (_db.update(_db.hobbyLogs)..where((l) => l.id.equals(id))).write(
        HobbyLogsCompanion(
          deletedAt: Value(_clock.now()),
          updatedAt: Value(_clock.now()),
        ),
      );

  SimpleSelectStatement<$HobbyLogsTable, HobbyLog> _logsQuery(
    String userId,
    String from,
    String to, {
    String? hobbyId,
  }) {
    return _db.select(_db.hobbyLogs)
      ..where(
        (l) =>
            l.userId.equals(userId) &
            l.deletedAt.isNull() &
            l.localDate.isBiggerOrEqualValue(from) &
            l.localDate.isSmallerOrEqualValue(to) &
            (hobbyId == null
                ? const Constant(true)
                : l.hobbyId.equals(hobbyId)),
      )
      ..orderBy([(l) => OrderingTerm.asc(l.startedAt)]);
  }

  /// Live logs on one local date, oldest first.
  Future<List<HobbyLog>> logsForDate(String userId, String localDate) =>
      _logsQuery(userId, localDate, localDate).get();

  Stream<List<HobbyLog>> watchLogsForDate(String userId, String localDate) =>
      _logsQuery(userId, localDate, localDate).watch();

  /// Live logs with local dates in [from, to] inclusive; optionally one hobby.
  Future<List<HobbyLog>> logsBetween(
    String userId,
    String from,
    String to, {
    String? hobbyId,
  }) => _logsQuery(userId, from, to, hobbyId: hobbyId).get();

  Stream<List<HobbyLog>> watchLogsBetween(
    String userId,
    String from,
    String to, {
    String? hobbyId,
  }) => _logsQuery(userId, from, to, hobbyId: hobbyId).watch();

  /// Every live log, for streaks and history.
  Stream<List<HobbyLog>> watchAllLogs(String userId) {
    return (_db.select(
      _db.hobbyLogs,
    )..where((l) => l.userId.equals(userId) & l.deletedAt.isNull())).watch();
  }

  /// Minutes logged in [from, to] (inclusive local dates).
  Future<int> minutesBetween(
    String userId,
    String from,
    String to, {
    String? hobbyId,
  }) async => (await totalsBetween(userId, from, to, hobbyId: hobbyId)).minutes;

  /// Sessions (sum of `countOrSessions`) logged in [from, to].
  Future<int> sessionsBetween(
    String userId,
    String from,
    String to, {
    String? hobbyId,
  }) async =>
      (await totalsBetween(userId, from, to, hobbyId: hobbyId)).sessions;

  Future<HobbyTotals> totalsBetween(
    String userId,
    String from,
    String to, {
    String? hobbyId,
  }) async {
    final logs = await logsBetween(userId, from, to, hobbyId: hobbyId);
    return HobbyTotals(
      minutes: logs.fold(0, (a, l) => a + l.durationMinutes),
      sessions: logs.fold(0, (a, l) => a + l.countOrSessions),
    );
  }
}
