/// Quick durations offered on the Meditation screen, in minutes.
const meditationQuickMinutes = [5, 10, 15];

/// The longest session a person can choose.
const meditationMaxMinutes = 180;

/// A session shorter than this is not saved: it was a false start.
const meditationMinSavedSeconds = 60;

/// Seconds left of a [plannedMinutes] session after [elapsed] has passed,
/// never below zero.
int remainingSeconds(int plannedMinutes, Duration elapsed) {
  final left = plannedMinutes * 60 - elapsed.inSeconds;
  return left < 0 ? 0 : left;
}

/// `10:00`, `4:07`, `1:05:00`.
String clockText(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  final ss = s.toString().padLeft(2, '0');
  if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:$ss';
  return '$m:$ss';
}

/// How a finished session is described and whether it is kept.
class MeditationOutcome {
  const MeditationOutcome({
    required this.saved,
    required this.seconds,
    required this.completed,
  });

  /// Seconds actually spent, never more than the chosen length.
  final int seconds;
  final bool completed;
  final bool saved;

  /// Whole minutes, rounded to the nearest, at least 1 when saved.
  int get minutes => (seconds / 60).round().clamp(saved ? 1 : 0, 1 << 20);

  String get message => saved
      ? 'Logged. $minutes min meditation.'
      : 'Session ended. Nothing saved.';
}

/// What to do with a session that ran for [elapsed] of [plannedMinutes].
MeditationOutcome outcomeOf({
  required int plannedMinutes,
  required Duration elapsed,
}) {
  final planned = plannedMinutes * 60;
  final spent = elapsed.inSeconds.clamp(0, planned);
  return MeditationOutcome(
    saved: spent >= meditationMinSavedSeconds,
    seconds: spent,
    completed: spent >= planned,
  );
}
