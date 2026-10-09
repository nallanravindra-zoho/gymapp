import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../../data/tables/tables.dart';
import 'workout_timer.dart';

final workoutTypesProvider = StreamProvider<List<WorkoutType>>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  yield* ref.watch(workoutRepositoryProvider).watchTypes(user.id);
});

/// Workouts for the current local day.
final todayWorkoutsProvider = StreamProvider<List<Workout>>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  final today = ref.watch(userRepositoryProvider).today(user);
  yield* ref
      .watch(workoutRepositoryProvider)
      .watchBetween(user.id, today, today);
});

const _timerKey = 'active_workout_timer';

/// The running timer, if any. Persisted so it survives the app being closed.
class ActiveTimerNotifier extends AsyncNotifier<TimerState?> {
  @override
  Future<TimerState?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return TimerState.fromJson(prefs.getString(_timerKey));
  }

  Future<void> _set(TimerState? s) async {
    final prefs = await SharedPreferences.getInstance();
    if (s == null) {
      await prefs.remove(_timerKey);
    } else {
      await prefs.setString(_timerKey, s.toJson());
    }
    state = AsyncData(s);
  }

  Future<void> start(String workoutTypeId) => _set(
    TimerState(
      workoutTypeId: workoutTypeId,
      startedAt: ref.read(clockProvider).now(),
    ),
  );

  Future<void> pause() async {
    final s = state.value;
    if (s != null) await _set(s.pause(ref.read(clockProvider).now()));
  }

  Future<void> resume() async {
    final s = state.value;
    if (s != null) await _set(s.resume(ref.read(clockProvider).now()));
  }

  Future<void> cancel() => _set(null);

  /// Saves the workout and clears the timer. The saved end time is start plus
  /// active time, so paused periods are excluded from the duration.
  Future<SavedWorkout?> stopAndSave() async {
    final s = state.value;
    if (s == null) return null;
    final now = ref.read(clockProvider).now();
    final active = s.elapsed(now);
    final user = await ref.read(currentUserProvider.future);
    final repo = ref.read(workoutRepositoryProvider);
    await repo.add(
      userId: user.id,
      dayCutoffMinutes: user.dayCutoffMinutes,
      workoutTypeId: s.workoutTypeId,
      startedAt: s.startedAt,
      endedAt: s.startedAt.add(active),
      source: WorkoutSource.timer,
    );
    await _set(null);
    return SavedWorkout(s.workoutTypeId, active.inMinutes);
  }
}

final activeTimerProvider =
    AsyncNotifierProvider<ActiveTimerNotifier, TimerState?>(
      ActiveTimerNotifier.new,
    );

class SavedWorkout {
  const SavedWorkout(this.workoutTypeId, this.minutes);
  final String workoutTypeId;
  final int minutes;
}

/// Microcopy for a saved workout (spec 4.5): `Logged. 35 min yoga.`
String loggedMessage(int minutes, String typeName) =>
    'Logged. $minutes min ${typeName.toLowerCase()}.';
