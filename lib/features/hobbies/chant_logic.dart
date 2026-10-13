/// Pure logic for Om chanting.
///
/// First release: a timer plus a manual counter (tap +1 for each chant). The
/// microphone auto-count (ported from the omchantcount app) is an optional
/// mode, off by default, switched on in the chant settings.
library;

/// How the reminder at each checkpoint is given.
enum ReminderMode { voice, chime }

/// Sound levels are in dB, from about -160 (silence) up to 0 (very loud).
const double kSilenceDb = -160;

/// A sound must stay above the threshold this long before it counts as a
/// chant starting (filters clicks and pops).
const Duration kMinSound = Duration(milliseconds: 150);

/// Silence must last this long before a chant is finished and counted.
const Duration kMinSilence = Duration(milliseconds: 350);

/// How long room noise is sampled before starting, when sensitivity is auto.
const Duration kCalibration = Duration(milliseconds: 700);

/// How far above the measured noise the automatic threshold is set.
const double kCalibrationMarginDb = 12;

/// Fixed sensitivity presets; null is automatic.
const List<(String, double?)> kSensitivityPresets = [
  ('Auto (recommended)', null),
  ('Very sensitive', -45),
  ('Sensitive', -35),
  ('Normal', -28),
  ('Firm voice only', -20),
];

class ChantSettings {
  const ChantSettings({
    this.target = 108,
    this.interval = 27,
    this.mode = ReminderMode.voice,
    this.sensitivity,
    this.micMode = false,
  });

  /// Count chants by listening through the microphone instead of by tapping.
  /// Off by default; the microphone is only asked for when this mode starts.
  final bool micMode;

  /// Chants to count up to.
  final int target;

  /// Remind at every Nth chant.
  final int interval;
  final ReminderMode mode;

  /// Fixed threshold in dB, or null to measure the room each time.
  final double? sensitivity;

  ChantSettings copyWith({
    int? target,
    int? interval,
    ReminderMode? mode,
    double? sensitivity,
    bool auto = false,
    bool? micMode,
  }) => ChantSettings(
    micMode: micMode ?? this.micMode,
    target: target ?? this.target,
    interval: interval ?? this.interval,
    mode: mode ?? this.mode,
    sensitivity: auto ? null : (sensitivity ?? this.sensitivity),
  );

  Map<String, Object?> toJson() => {
    'target': target,
    'interval': interval,
    'mode': mode.name,
    'sensitivity': sensitivity,
    'micMode': micMode,
  };

  static ChantSettings fromJson(Map<String, Object?> j) {
    int positive(Object? v, int fallback) =>
        v is num && v >= 1 ? v.round() : fallback;
    final s = j['sensitivity'];
    return ChantSettings(
      target: positive(j['target'], 108),
      interval: positive(j['interval'], 27),
      mode: ReminderMode.values.firstWhere(
        (m) => m.name == j['mode'],
        orElse: () => ReminderMode.voice,
      ),
      sensitivity: s is num ? s.toDouble() : null,
      micMode: j['micMode'] == true,
    );
  }
}

/// Checkpoints: every [interval] up to, and always including, [target].
List<int> chantMilestones(int interval, int target) {
  final step = interval < 1 ? 1 : interval;
  final end = target < 1 ? 1 : target;
  return [for (var m = step; m < end; m += step) m, end];
}

/// The next checkpoint after [count], or null once past the last.
int? nextMilestone(int count, List<int> milestones) {
  for (final m in milestones) {
    if (m > count) return m;
  }
  return null;
}

/// Turns a stream of sound levels into counted chants: a chant is a sound
/// that lasts at least [kMinSound] followed by [kMinSilence] of quiet.
class ChantDetector {
  ChantDetector({required this.threshold});

  double threshold;
  bool _inSound = false;
  DateTime? _soundStart;
  DateTime? _silenceStart;

  /// Feeds one reading. Returns true when a chant has just ended.
  bool add(double db, DateTime now) {
    if (db > threshold) {
      _silenceStart = null;
      if (!_inSound) {
        _soundStart ??= now;
        if (now.difference(_soundStart!) >= kMinSound) _inSound = true;
      }
      return false;
    }
    _soundStart = null;
    if (!_inSound) return false;
    _silenceStart ??= now;
    if (now.difference(_silenceStart!) >= kMinSilence) {
      _inSound = false;
      _silenceStart = null;
      return true;
    }
    return false;
  }

  void reset() {
    _inSound = false;
    _soundStart = null;
    _silenceStart = null;
  }
}

/// Threshold for automatic sensitivity: the loudest room-noise reading plus a
/// margin. With no readings, assumes silence.
double calibratedThreshold(List<double> samples) {
  final floor = samples.isEmpty
      ? kSilenceDb
      : samples.reduce((a, b) => a > b ? a : b);
  return floor + kCalibrationMarginDb;
}

/// Time spent chanting: [accumulated] from earlier stretches plus the current
/// stretch since [runningSince] (null while paused). Timestamp based, so it is
/// right after the screen sleeps.
Duration chantElapsed({
  required Duration accumulated,
  required DateTime? runningSince,
  required DateTime now,
}) {
  if (runningSince == null) return accumulated;
  final run = now.difference(runningSince);
  return accumulated + (run.isNegative ? Duration.zero : run);
}

/// What a finished chanting session was.
class ChantSummary {
  const ChantSummary({
    required this.count,
    required this.target,
    required this.elapsed,
    required this.startedAt,
    required this.endedAt,
  });

  final int count;
  final int target;
  final Duration elapsed;
  final DateTime startedAt;
  final DateTime endedAt;

  bool get reachedTarget => count >= target;

  /// Whole minutes, at least 1.
  int get minutes {
    final m = (elapsed.inSeconds / 60).round();
    return m < 1 ? 1 : m;
  }
}
