import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';

/// The source of "now" for the hobby timer. Tests replace it.
final hobbyTimerNowProvider = Provider<DateTime Function()>(
  (ref) => ref.watch(clockProvider).now,
);

/// A running hobby timer. Elapsed time is always `now - startedAt`, so it
/// stays right if the screen closes or the phone sleeps.
@immutable
class HobbyTimerState {
  const HobbyTimerState({required this.hobbyId, required this.startedAt});
  final String hobbyId;
  final DateTime startedAt;
}

/// At most one hobby timer runs at a time; it lives until stopped.
class HobbyTimerNotifier extends Notifier<HobbyTimerState?> {
  @override
  HobbyTimerState? build() => null;

  void start(String hobbyId) => state = HobbyTimerState(
    hobbyId: hobbyId,
    startedAt: ref.read(hobbyTimerNowProvider)(),
  );

  /// Stops the timer and returns what ran, or null if none was running.
  ({String hobbyId, DateTime startedAt, DateTime endedAt})? stop() {
    final s = state;
    if (s == null) return null;
    state = null;
    return (
      hobbyId: s.hobbyId,
      startedAt: s.startedAt,
      endedAt: ref.read(hobbyTimerNowProvider)(),
    );
  }

  void discard() => state = null;
}

final hobbyTimerProvider =
    NotifierProvider<HobbyTimerNotifier, HobbyTimerState?>(
      HobbyTimerNotifier.new,
    );

/// Whole minutes for a timed span, at least one so a short session still
/// counts as a session.
int minutesForSpan(Duration d) {
  final m = (d.inSeconds / 60).round();
  return m < 1 ? 1 : m;
}

/// `0:05`, `12:34`, `1:02:03`.
String formatElapsed(Duration d) {
  final s = d.inSeconds < 0 ? 0 : d.inSeconds;
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  final sec = s % 60;
  String two(int n) => n.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(sec)}' : '$m:${two(sec)}';
}
