import 'dart:convert';

/// Timestamp-based timer state (spec 7.3). Elapsed time is always computed
/// from stored instants, so it stays correct if the app is killed and
/// reopened. No foreground service is needed.
class TimerState {
  const TimerState({
    required this.workoutTypeId,
    required this.startedAt,
    this.pausedAt,
    this.pausedMs = 0,
    this.stepBase,
    this.intensity,
    this.note,
  });

  final String workoutTypeId;
  final DateTime startedAt;

  /// Set while paused.
  final DateTime? pausedAt;

  /// Total time spent paused, excluding the current pause.
  final int pausedMs;

  /// Running step total from the phone sensor when the timer started (Walk and
  /// Run only), or null when steps are not being counted.
  final int? stepBase;

  /// Optional choices made before starting: `low`, `mid` or `high`, and a note.
  final String? intensity;
  final String? note;

  /// Total time paused up to [now], including a pause still in progress.
  Duration paused(DateTime now) => Duration(
    milliseconds:
        pausedMs +
        (pausedAt == null ? 0 : now.difference(pausedAt!).inMilliseconds),
  );

  bool get isPaused => pausedAt != null;

  Duration elapsed(DateTime now) {
    final end = pausedAt ?? now;
    final ms = end.difference(startedAt).inMilliseconds - pausedMs;
    return Duration(milliseconds: ms < 0 ? 0 : ms);
  }

  TimerState pause(DateTime now) =>
      isPaused ? this : _copy(pausedAt: now, keepPausedAt: true);

  TimerState resume(DateTime now) {
    if (!isPaused) return this;
    return TimerState(
      workoutTypeId: workoutTypeId,
      startedAt: startedAt,
      pausedMs: pausedMs + now.difference(pausedAt!).inMilliseconds,
      stepBase: stepBase,
      intensity: intensity,
      note: note,
    );
  }

  TimerState _copy({DateTime? pausedAt, bool keepPausedAt = false}) =>
      TimerState(
        workoutTypeId: workoutTypeId,
        startedAt: startedAt,
        pausedAt: keepPausedAt ? pausedAt : this.pausedAt,
        pausedMs: pausedMs,
        stepBase: stepBase,
        intensity: intensity,
        note: note,
      );

  String toJson() => jsonEncode({
    'type': workoutTypeId,
    'start': startedAt.toUtc().millisecondsSinceEpoch,
    'pausedAt': pausedAt?.toUtc().millisecondsSinceEpoch,
    'pausedMs': pausedMs,
    'stepBase': stepBase,
    'intensity': intensity,
    'note': note,
  });

  static TimerState? fromJson(String? raw) {
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final p = m['pausedAt'] as int?;
      return TimerState(
        workoutTypeId: m['type'] as String,
        startedAt: DateTime.fromMillisecondsSinceEpoch(
          m['start'] as int,
          isUtc: true,
        ),
        pausedAt: p == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(p, isUtc: true),
        pausedMs: m['pausedMs'] as int,
        stepBase: m['stepBase'] as int?,
        intensity: m['intensity'] as String?,
        note: m['note'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

String formatElapsed(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  return '${two(h)}:${two(m)}:${two(s)}';
}
