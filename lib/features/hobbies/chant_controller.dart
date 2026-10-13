import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chant_logic.dart';
import 'chant_platform.dart';

final chantPlatformProvider = Provider<ChantPlatform>(
  (ref) => DeviceChantPlatform(),
);

/// The time source for sound detection. Tests replace it.
final chantNowProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// idle: not started or paused. running: timer and manual counter going.
/// calibrating/listening: the optional microphone mode. complete: finished,
/// either at the target or by the user; the session can be saved.
enum ChantPhase { idle, calibrating, listening, running, complete }

class ChantState {
  const ChantState({
    this.settings = const ChantSettings(),
    this.count = 0,
    this.phase = ChantPhase.idle,
    this.level = kSilenceDb,
    this.threshold = -35,
    this.micDenied = false,
    this.error,
    this.accumulated = Duration.zero,
    this.runningSince,
    this.startedAt,
    this.endedAt,
  });

  final ChantSettings settings;
  final int count;
  final ChantPhase phase;
  final double level;
  final double threshold;
  final bool micDenied;
  final String? error;

  /// Time chanted in earlier stretches (before a pause).
  final Duration accumulated;

  /// When the current stretch began; null while paused or finished.
  final DateTime? runningSince;

  /// When the session first started, and when it finished.
  final DateTime? startedAt;
  final DateTime? endedAt;

  /// The microphone is on.
  bool get active =>
      phase == ChantPhase.listening || phase == ChantPhase.calibrating;

  /// The timer is going and +1 counts a chant.
  bool get counting => active || phase == ChantPhase.running;

  /// Elapsed chanting time as of [now].
  Duration elapsed(DateTime now) => chantElapsed(
    accumulated: accumulated,
    runningSince: runningSince,
    now: now,
  );

  /// The finished session, or null until [ChantPhase.complete].
  ChantSummary? summary(DateTime now) =>
      phase == ChantPhase.complete && startedAt != null
      ? ChantSummary(
          count: count,
          target: settings.target,
          elapsed: elapsed(now),
          startedAt: startedAt!,
          endedAt: endedAt ?? now,
        )
      : null;

  List<int> get milestones =>
      chantMilestones(settings.interval, settings.target);

  ChantState copyWith({
    ChantSettings? settings,
    int? count,
    ChantPhase? phase,
    double? level,
    double? threshold,
    bool? micDenied,
    String? error,
    bool clearError = false,
    Duration? accumulated,
    DateTime? runningSince,
    bool clearRunningSince = false,
    DateTime? startedAt,
    DateTime? endedAt,
    bool clearEnded = false,
    bool clearTimes = false,
  }) => ChantState(
    accumulated: accumulated ?? this.accumulated,
    runningSince: clearRunningSince
        ? null
        : (runningSince ?? this.runningSince),
    startedAt: clearTimes ? null : (startedAt ?? this.startedAt),
    endedAt: clearTimes || clearEnded ? null : (endedAt ?? this.endedAt),
    settings: settings ?? this.settings,
    count: count ?? this.count,
    phase: phase ?? this.phase,
    level: level ?? this.level,
    threshold: threshold ?? this.threshold,
    micDenied: micDenied ?? this.micDenied,
    error: clearError ? null : (error ?? this.error),
  );
}

const _prefsKey = 'chant_settings_v1';

class ChantController extends Notifier<ChantState> {
  StreamSubscription<double>? _sub;
  Timer? _calibrationTimer;
  final List<double> _samples = [];
  DateTime? _calibrationStart;
  bool _announcing = false;
  late final ChantDetector _detector = ChantDetector(threshold: -35);

  late ChantPlatform _platform;
  DateTime _now() => ref.read(chantNowProvider)();

  @override
  ChantState build() {
    final platform = _platform = ref.read(chantPlatformProvider);
    ref.onDispose(() {
      _sub?.cancel();
      _calibrationTimer?.cancel();
      platform.stopListening();
      platform.keepAwake(false);
    });
    _loadSettings();
    return const ChantState();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final settings = ChantSettings.fromJson(
        (jsonDecode(raw) as Map).cast<String, Object?>(),
      );
      state = state.copyWith(settings: settings);
    } catch (_) {
      // Keep the defaults.
    }
  }

  Future<void> updateSettings(ChantSettings next) async {
    state = state.copyWith(settings: next);
    if (state.active) {
      // Apply a sensitivity change straight away, without losing the count.
      if (next.sensitivity == null) {
        _beginCalibration();
      } else {
        _setThreshold(next.sensitivity!);
      }
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(next.toJson()));
    } catch (_) {}
  }

  void _setThreshold(double db) {
    _detector.threshold = db;
    state = state.copyWith(threshold: db);
  }

  /// Starts, or resumes after a pause. Manual counting by default; the
  /// microphone is only asked for when mic mode is switched on.
  Future<void> start() async {
    state = state.copyWith(clearError: true);
    if (!state.settings.micMode) return _startManual();
    try {
      if (!await _platform.requestMic()) {
        state = state.copyWith(micDenied: true);
        return;
      }
      state = state.copyWith(micDenied: false);
      _detector.reset();
      final levels = await _platform.startListening();
      unawaited(_sub?.cancel() ?? Future<void>.value());
      _sub = levels.listen(_onLevel, onError: (_) {});
      await _platform.keepAwake(true);
      _markRunning();
      final fixed = state.settings.sensitivity;
      if (fixed == null) {
        _beginCalibration();
      } else {
        _setThreshold(fixed);
        state = state.copyWith(phase: ChantPhase.listening);
      }
    } catch (_) {
      await _platform.stopListening();
      state = state.copyWith(
        phase: ChantPhase.idle,
        error:
            'Could not start listening. Close any other app using the '
            'microphone and try again.',
      );
    }
  }

  Future<void> _startManual() async {
    await _platform.keepAwake(true);
    _markRunning();
    state = state.copyWith(phase: ChantPhase.running, micDenied: false);
  }

  /// Starts the clock for a new stretch.
  void _markRunning() {
    final now = _now();
    state = state.copyWith(
      runningSince: now,
      startedAt: state.startedAt ?? now,
    );
  }

  /// Banks the current stretch and stops the clock.
  void _markPaused() {
    final now = _now();
    state = state.copyWith(
      accumulated: state.elapsed(now),
      clearRunningSince: true,
    );
  }

  /// Counts one chant by hand: the large +1 button, also a correction in mic
  /// mode.
  void increment() {
    if (!state.counting) return;
    _onChant();
  }

  /// Takes one chant back (undo). Works while counting, paused or finished;
  /// from finished it returns to paused so the session can go on.
  void decrement() {
    if (state.count == 0) return;
    final wasComplete = state.phase == ChantPhase.complete;
    state = state.copyWith(count: state.count - 1);
    if (wasComplete) {
      state = state.copyWith(phase: ChantPhase.idle, clearEnded: true);
    }
  }

  void _beginCalibration() {
    _samples.clear();
    _calibrationStart = _now();
    state = state.copyWith(phase: ChantPhase.calibrating);
    _calibrationTimer?.cancel();
    // If readings stall, do not wait forever.
    _calibrationTimer = Timer(
      kCalibration + const Duration(seconds: 1),
      _finishCalibration,
    );
  }

  void _finishCalibration() {
    _calibrationTimer?.cancel();
    _calibrationTimer = null;
    _setThreshold(calibratedThreshold(_samples));
    _samples.clear();
    _calibrationStart = null;
    state = state.copyWith(phase: ChantPhase.listening);
  }

  void _onLevel(double db) {
    if (!state.active || _announcing) return;
    state = state.copyWith(level: db);
    final now = _now();
    if (state.phase == ChantPhase.calibrating) {
      _samples.add(db);
      if (_calibrationStart != null &&
          now.difference(_calibrationStart!) >= kCalibration) {
        _finishCalibration();
      }
      return;
    }
    if (_detector.add(db, now)) _onChant();
  }

  void _onChant() {
    final count = state.count + 1;
    state = state.copyWith(count: count);
    final s = state.settings;
    if (count >= s.target) {
      _complete();
    } else if (s.micMode && state.milestones.contains(count)) {
      // Checkpoint reminders belong to the microphone mode.
      _announcing = true;
      _platform.announce(s.mode, count, isFinal: false).whenComplete(() {
        _announcing = false;
      });
    }
  }

  Future<void> _complete() async {
    _markPaused();
    state = state.copyWith(phase: ChantPhase.complete, endedAt: _now());
    await _stop();
    // A gentle ping and a buzz. Manual counting always uses the chime; the
    // microphone mode keeps its chosen reminder style.
    await _platform.announce(
      state.settings.micMode ? state.settings.mode : ReminderMode.chime,
      state.settings.target,
      isFinal: true,
    );
  }

  Future<void> _stop() async {
    // Not awaited: a cancel that never settles must not block pausing.
    unawaited(_sub?.cancel() ?? Future<void>.value());
    _sub = null;
    _calibrationTimer?.cancel();
    _calibrationTimer = null;
    _samples.clear();
    await _platform.stopListening();
    await _platform.keepAwake(false);
  }

  Future<void> pause() async {
    await _stop();
    _markPaused();
    state = state.copyWith(phase: ChantPhase.idle);
  }

  /// Ends the session before or at the target so it can be saved. Returns
  /// null when nothing was counted.
  Future<ChantSummary?> finish() async {
    if (state.phase == ChantPhase.complete) return state.summary(_now());
    await _stop();
    if (state.count == 0 || state.startedAt == null) {
      await reset();
      return null;
    }
    _markPaused();
    state = state.copyWith(phase: ChantPhase.complete, endedAt: _now());
    return state.summary(_now());
  }

  Future<void> reset() async {
    await _stop();
    _detector.reset();
    state = ChantState(settings: state.settings, threshold: state.threshold);
  }
}

final chantControllerProvider = NotifierProvider<ChantController, ChantState>(
  ChantController.new,
);
