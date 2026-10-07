import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../habits/habit_providers.dart';
import '../week/week_providers.dart';
import 'badges.dart';
import 'streak_engine.dart';
import 'streak_snapshot.dart';

final userStreamProvider = StreamProvider<User?>(
  (ref) => ref.watch(userRepositoryProvider).watchUser(),
);

final allWorkoutsProvider = StreamProvider<List<Workout>>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  yield* ref.watch(workoutRepositoryProvider).watchAll(user.id);
});

final allRestDaysProvider = StreamProvider<Set<String>>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  yield* ref
      .watch(restDayRepositoryProvider)
      .watchAll(user.id)
      .map((rows) => {for (final r in rows) r.localDate});
});

final awardedBadgesProvider = StreamProvider<Set<String>>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  yield* ref.watch(badgeRepositoryProvider).watchAwardedKeys(user.id);
});

/// Recomputed from the logs whenever any of them (or the settings) change,
/// so edits and deletes always leave streaks correct.
final streakSnapshotProvider = Provider<StreakSnapshot?>((ref) {
  final user = ref.watch(userStreamProvider).value;
  final workouts = ref.watch(allWorkoutsProvider).value;
  final rest = ref.watch(allRestDaysProvider).value;
  final today = ref.watch(todayDateProvider).value;
  if (user == null || workouts == null || rest == null || today == null) {
    return null;
  }
  return buildSnapshot(
    workouts: workouts,
    restDates: rest,
    today: today,
    freezeEnabled: user.freezeEnabled,
    freezeIntervalDays: user.freezeIntervalDays,
  );
});

/// One-line messages waiting to be shown as a quiet celebration.
class CelebrationQueue extends Notifier<List<String>> {
  @override
  List<String> build() => const [];

  void add(String message) => state = [...state, message];

  void removeFirst() {
    if (state.isNotEmpty) state = state.sublist(1);
  }
}

final celebrationQueueProvider =
    NotifierProvider<CelebrationQueue, List<String>>(CelebrationQueue.new);

/// Keeps the streak cache fresh and awards badges. Watch it once, from the
/// app shell. Work is serialised so a burst of changes cannot double-award.
final streakEffectsProvider = Provider<void>((ref) {
  var tail = Future<void>.value();

  Future<void> process(StreakSnapshot snap) async {
    final user = await ref.read(currentUserProvider.future);
    final cache = ref.read(streakCacheRepositoryProvider);
    final badges = ref.read(badgeRepositoryProvider);

    Future<void> store(String scope, StreakResult r) => cache.upsert(
      userId: user.id,
      scope: scope,
      current: r.current,
      longest: r.longest,
      lastCountedDate: r.lastCountedDate,
      freezeAvailable: r.freezeAvailable,
      lastFreezeDate: r.lastFreezeDate,
    );

    await store('overall', snap.overall);
    for (final e in snap.byType.entries) {
      await store('workout_type:${e.key}', e.value);
    }

    final awarded = await badges.awardedKeys(user.id);
    final due = milestonesDue(
      scope: 'overall',
      currentStreak: snap.overall.current,
      alreadyAwarded: awarded,
    );
    for (final days in due) {
      final isNew = await badges.award(
        user.id,
        streakBadgeKey('overall', days),
      );
      if (isNew) {
        ref.read(celebrationQueueProvider.notifier).add(milestoneMessage(days));
      }
    }
  }

  Future<void> processHabits(Map<String, StreakResult> streaks) async {
    final user = await ref.read(currentUserProvider.future);
    final badges = ref.read(badgeRepositoryProvider);
    final awarded = await badges.awardedKeys(user.id);
    for (final e in streaks.entries) {
      final due = milestonesDue(
        scope: 'habit:${e.key}',
        currentStreak: e.value.current,
        alreadyAwarded: awarded,
      );
      for (final days in due) {
        final isNew = await badges.award(
          user.id,
          streakBadgeKey('habit:${e.key}', days),
        );
        if (isNew) {
          ref
              .read(celebrationQueueProvider.notifier)
              .add(milestoneMessage(days));
        }
      }
    }
  }

  ref.listen<Map<String, StreakResult>>(habitStreaksProvider, (_, next) {
    if (next.isEmpty) return;
    tail = tail.then((_) => processHabits(next)).catchError((Object _) {});
  }, fireImmediately: true);

  ref.listen<StreakSnapshot?>(streakSnapshotProvider, (_, next) {
    if (next == null) return;
    tail = tail.then((_) => process(next)).catchError((Object _) {});
  }, fireImmediately: true);
});
