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
  });

  final String workoutTypeId;
  final DateTime startedAt;

  /// Set while paused.
  final DateTime? pausedAt;

  /// Total time spent paused, excluding the current pause.
  final int pausedMs;

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
    );
  }

  TimerState _copy({DateTime? pausedAt, bool keepPausedAt = false}) =>
      TimerState(
        workoutTypeId: workoutTypeId,
        startedAt: startedAt,
        pausedAt: keepPausedAt ? pausedAt : this.pausedAt,
        pausedMs: pausedMs,
      );

  String toJson() => jsonEncode({
    'type': workoutTypeId,
    'start': startedAt.toUtc().millisecondsSinceEpoch,
    'pausedAt': pausedAt?.toUtc().millisecondsSinceEpoch,
    'pausedMs': pausedMs,
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
  return h > 0 ? '${two(h)}:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}
