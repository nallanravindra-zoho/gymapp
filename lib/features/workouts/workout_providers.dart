import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/workout_repository.dart';
import '../../data/tables/tables.dart';
import 'step_source.dart';
import 'workout_calc.dart';
import 'workout_timer.dart';

final workoutTypesProvider = StreamProvider<List<WorkoutType>>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  yield* ref.watch(workoutRepositoryProvider).watchTypes(user.id);
});

/// The live user row, so profile changes (weight, height) show immediately.
final liveUserProvider = StreamProvider<User?>(
  (ref) => ref.watch(userRepositoryProvider).watchUser(),
);

/// Every type including deleted custom ones, for naming past workouts.
final allWorkoutTypesProvider = StreamProvider<List<WorkoutType>>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  yield* ref.watch(workoutRepositoryProvider).watchAllTypes(user.id);
});

/// One live workout by id (null once deleted).
final workoutByIdProvider = StreamProvider.family<Workout?, String>(
  (ref, id) => ref.watch(workoutRepositoryProvider).watchById(id),
);

/// Maps pure calculation results onto the columns saved with a workout.
WorkoutMetrics toWorkoutMetrics(ComputedMetrics c) => WorkoutMetrics(
  caloriesEstimate: c.calories,
  steps: c.steps,
  stepsSource: c.stepsSource,
  distanceKm: c.distanceKm,
  avgSpeedKmh: c.avgSpeedKmh,
  pausedSeconds: c.pausedSeconds,
  activeSeconds: c.activeSeconds,
  metricsNote: c.note,
);

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

  /// Starts a timer. For Walk and Run this is the one point where the phone's
  /// step sensor is used (and its permission asked for).
  Future<void> start(
    String workoutTypeId, {
    String? iconKey,
    String? intensity,
    String? note,
  }) async {
    int? stepBase;
    if (tracksDistance(iconKey)) {
      stepBase = await ref.read(stepSourceProvider).startReading();
    }
    await _set(
      TimerState(
        workoutTypeId: workoutTypeId,
        startedAt: ref.read(clockProvider).now(),
        stepBase: stepBase,
        intensity: intensity,
        note: note,
      ),
    );
  }

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
    final paused = s.paused(now);
    final repo = ref.read(workoutRepositoryProvider);
    final user = await ref.read(userRepositoryProvider).ensureUser();
    final type = await repo.typeById(s.workoutTypeId);

    int? sensorSteps;
    if (s.stepBase != null) {
      final total = await ref.read(stepSourceProvider).readTotal();
      // A total below the starting one means the phone restarted meanwhile.
      if (total != null && total >= s.stepBase!) {
        sensorSteps = total - s.stepBase!;
      }
    }
    final metrics = computeMetrics(
      MetricInputs(
        iconKey: type?.iconKey,
        activeSeconds: active.inSeconds,
        pausedSeconds: paused.inSeconds,
        intensity: s.intensity,
        weightKg: user.weightKg,
        heightCm: user.heightCm,
        sensorSteps: sensorSteps,
      ),
    );
    final id = await repo.add(
      userId: user.id,
      dayCutoffMinutes: user.dayCutoffMinutes,
      workoutTypeId: s.workoutTypeId,
      startedAt: s.startedAt,
      endedAt: s.startedAt.add(active),
      source: WorkoutSource.timer,
      intensity: _intensityFrom(s.intensity),
      note: s.note,
      metrics: toWorkoutMetrics(metrics),
    );
    await _set(null);
    return SavedWorkout(s.workoutTypeId, active.inMinutes, id);
  }
}

final activeTimerProvider =
    AsyncNotifierProvider<ActiveTimerNotifier, TimerState?>(
      ActiveTimerNotifier.new,
    );

class SavedWorkout {
  const SavedWorkout(this.workoutTypeId, this.minutes, this.workoutId);
  final String workoutTypeId;
  final int minutes;
  final String workoutId;
}

/// Microcopy for a saved workout (spec 4.5): `Logged. 35 min yoga.`
String loggedMessage(int minutes, String typeName) =>
    'Logged. $minutes min ${typeName.toLowerCase()}.';

WorkoutIntensity? _intensityFrom(String? name) => switch (name) {
  'low' => WorkoutIntensity.low,
  'mid' => WorkoutIntensity.mid,
  'high' => WorkoutIntensity.high,
  _ => null,
};

WorkoutIntensity? intensityFromName(String? name) => _intensityFrom(name);
