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

enum ChantPhase { idle, calibrating, listening, complete }

class ChantState {
  const ChantState({
    this.settings = const ChantSettings(),
    this.count = 0,
    this.phase = ChantPhase.idle,
    this.level = kSilenceDb,
    this.threshold = -35,
    this.micDenied = false,
    this.error,
  });

  final ChantSettings settings;
  final int count;
  final ChantPhase phase;
  final double level;
  final double threshold;
  final bool micDenied;
  final String? error;

  bool get active =>
      phase == ChantPhase.listening || phase == ChantPhase.calibrating;

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
  }) => ChantState(
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

  Future<void> start() async {
    state = state.copyWith(clearError: true);
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
    } else if (state.milestones.contains(count)) {
      _announcing = true;
      _platform.announce(s.mode, count, isFinal: false).whenComplete(() {
        _announcing = false;
      });
    }
  }

  Future<void> _complete() async {
    state = state.copyWith(phase: ChantPhase.complete);
    await _stop();
    await _platform.announce(
      state.settings.mode,
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
    state = state.copyWith(phase: ChantPhase.idle);
  }

  Future<void> reset() async {
    await _stop();
    _detector.reset();
    state = state.copyWith(count: 0, phase: ChantPhase.idle, level: kSilenceDb);
  }
}

final chantControllerProvider = NotifierProvider<ChantController, ChantState>(
  ChantController.new,
);
