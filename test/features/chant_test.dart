import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/repositories/habit_repository.dart';
import 'package:wellbeing/data/repositories/hobby_repository.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/data/tables/tables.dart';
import 'package:wellbeing/features/hobbies/chant_save.dart';
import 'package:wellbeing/features/hobbies/chant_controller.dart';
import 'package:wellbeing/features/hobbies/chant_logic.dart';
import 'package:wellbeing/features/hobbies/chant_platform.dart';
import 'package:wellbeing/features/hobbies/chant_screen.dart';

class FakeChantPlatform implements ChantPlatform {
  bool micAllowed = true;
  int micRequests = 0;
  bool failStart = false;
  final levels = StreamController<double>.broadcast();
  final announced = <(ReminderMode, int, bool)>[];
  bool awake = false;
  bool listening = false;

  @override
  Future<bool> requestMic() async {
    micRequests++;
    return micAllowed;
  }

  @override
  Future<Stream<double>> startListening() async {
    if (failStart) throw StateError('mic busy');
    listening = true;
    return levels.stream;
  }

  @override
  Future<void> stopListening() async => listening = false;

  @override
  Future<void> announce(
    ReminderMode mode,
    int count, {
    required bool isFinal,
  }) async => announced.add((mode, count, isFinal));

  @override
  Future<void> keepAwake(bool on) async => awake = on;
}

void main() {
  group('milestones', () {
    test('every interval up to and including the target', () {
      expect(chantMilestones(27, 108), [27, 54, 81, 108]);
    });
    test('target is always included when not a multiple', () {
      expect(chantMilestones(50, 108), [50, 100, 108]);
    });
    test('bad numbers fall back to 1', () {
      expect(chantMilestones(0, 3), [1, 2, 3]);
      expect(chantMilestones(5, 0), [1]);
    });
    test('next milestone', () {
      expect(nextMilestone(0, [27, 54]), 27);
      expect(nextMilestone(27, [27, 54]), 54);
      expect(nextMilestone(54, [27, 54]), isNull);
    });
  });

  group('detector', () {
    final t0 = DateTime(2026);
    DateTime at(int ms) => t0.add(Duration(milliseconds: ms));

    test('counts a sustained sound once silence follows', () {
      final d = ChantDetector(threshold: -30);
      var counted = 0;
      for (var ms = 0; ms <= 1000; ms += 100) {
        if (d.add(-10, at(ms))) counted++;
      }
      expect(counted, 0, reason: 'still sounding');
      for (var ms = 1100; ms <= 1600; ms += 100) {
        if (d.add(-60, at(ms))) counted++;
      }
      expect(counted, 1);
    });

    test('a click shorter than the minimum is ignored', () {
      final d = ChantDetector(threshold: -30);
      var counted = 0;
      if (d.add(-10, at(0))) counted++;
      for (var ms = 100; ms <= 1000; ms += 100) {
        if (d.add(-60, at(ms))) counted++;
      }
      expect(counted, 0);
    });

    test('a short pause inside a chant does not split it', () {
      final d = ChantDetector(threshold: -30);
      var counted = 0;
      for (var ms = 0; ms <= 500; ms += 100) {
        if (d.add(-10, at(ms))) counted++;
      }
      if (d.add(-60, at(600))) counted++;
      if (d.add(-60, at(700))) counted++;
      for (var ms = 800; ms <= 1200; ms += 100) {
        if (d.add(-10, at(ms))) counted++;
      }
      expect(counted, 0);
    });

    test('calibrated threshold is the loudest noise plus the margin', () {
      expect(calibratedThreshold([-50, -42, -47]), -42 + kCalibrationMarginDb);
      expect(calibratedThreshold([]), kSilenceDb + kCalibrationMarginDb);
    });
  });

  group('settings', () {
    test('round trip and bad values fall back', () {
      const s = ChantSettings(
        target: 54,
        interval: 9,
        mode: ReminderMode.chime,
        sensitivity: -28,
        micMode: true,
      );
      final back = ChantSettings.fromJson(s.toJson());
      expect(back.target, 54);
      expect(back.interval, 9);
      expect(back.mode, ReminderMode.chime);
      expect(back.sensitivity, -28);
      expect(back.micMode, isTrue);
      final bad = ChantSettings.fromJson({
        'target': -3,
        'interval': 'x',
        'mode': 'nope',
      });
      expect(bad.target, 108);
      expect(bad.interval, 27);
      expect(bad.mode, ReminderMode.voice);
      expect(bad.sensitivity, isNull);
      expect(bad.micMode, isFalse, reason: 'listening is off by default');
    });

    test('auto clears a fixed sensitivity', () {
      const s = ChantSettings(sensitivity: -28);
      expect(s.copyWith(auto: true).sensitivity, isNull);
      expect(s.copyWith(target: 9).sensitivity, -28);
    });
  });

  group('controller', () {
    late FakeChantPlatform platform;
    late DateTime clock;
    late ProviderContainer container;

    ChantController ctl() => container.read(chantControllerProvider.notifier);
    ChantState st() => container.read(chantControllerProvider);

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      platform = FakeChantPlatform();
      clock = DateTime(2026);
      container = ProviderContainer(
        overrides: [
          chantPlatformProvider.overrideWithValue(platform),
          chantNowProvider.overrideWithValue(() => clock),
        ],
      );
      addTearDown(container.dispose);
    });

    /// One chant: loud for 400 ms, then quiet for 500 ms.
    Future<void> chant() async {
      for (var i = 0; i < 4; i++) {
        platform.levels.add(-10);
        clock = clock.add(const Duration(milliseconds: 100));
        await Future<void>.delayed(Duration.zero);
      }
      for (var i = 0; i < 5; i++) {
        platform.levels.add(-70);
        clock = clock.add(const Duration(milliseconds: 100));
        await Future<void>.delayed(Duration.zero);
      }
    }

    Future<void> startFixed({int target = 3, int interval = 2}) async {
      container.read(chantControllerProvider);
      await ctl().updateSettings(
        ChantSettings(
          target: target,
          interval: interval,
          sensitivity: -30,
          micMode: true,
        ),
      );
      await ctl().start();
    }

    test(
      'mic mode counts chants, reminds at checkpoints and completes',
      () async {
        await startFixed();
        expect(st().phase, ChantPhase.listening);
        expect(platform.awake, isTrue);
        await chant();
        expect(st().count, 1);
        expect(platform.announced, isEmpty);
        await chant();
        expect(st().count, 2);
        expect(platform.announced, [(ReminderMode.voice, 2, false)]);
        await chant();
        await Future<void>.delayed(Duration.zero);
        expect(st().count, 3);
        expect(st().phase, ChantPhase.complete);
        expect(platform.announced.last, (ReminderMode.voice, 3, true));
        expect(platform.awake, isFalse);
        expect(platform.listening, isFalse);
      },
    );

    test('auto sensitivity calibrates, then listens', () async {
      container.read(chantControllerProvider);
      await ctl().updateSettings(const ChantSettings(micMode: true));
      await ctl().start();
      expect(st().phase, ChantPhase.calibrating);
      for (var i = 0; i < 9; i++) {
        platform.levels.add(-50);
        clock = clock.add(const Duration(milliseconds: 100));
        await Future<void>.delayed(Duration.zero);
      }
      expect(st().phase, ChantPhase.listening);
      expect(st().threshold, -50 + kCalibrationMarginDb);
    });

    test('pause keeps the count; reset clears it', () async {
      await startFixed(target: 10, interval: 5);
      await chant();
      await ctl().pause();
      expect(st().phase, ChantPhase.idle);
      expect(st().count, 1);
      expect(platform.listening, isFalse);
      await ctl().reset();
      expect(st().count, 0);
    });

    test('refused microphone is reported and nothing starts', () async {
      platform.micAllowed = false;
      container.read(chantControllerProvider);
      await ctl().updateSettings(const ChantSettings(micMode: true));
      await ctl().start();
      expect(st().micDenied, isTrue);
      expect(st().phase, ChantPhase.idle);
      expect(platform.listening, isFalse);
    });

    test('a microphone that will not open says so', () async {
      platform.failStart = true;
      container.read(chantControllerProvider);
      await ctl().updateSettings(const ChantSettings(micMode: true));
      await ctl().start();
      expect(st().phase, ChantPhase.idle);
      expect(st().error, contains('Could not start listening'));
    });

    test('settings are remembered', () async {
      container.read(chantControllerProvider);
      await ctl().updateSettings(const ChantSettings(target: 21, interval: 7));
      final other = ProviderContainer(
        overrides: [chantPlatformProvider.overrideWithValue(platform)],
      );
      addTearDown(other.dispose);
      other.read(chantControllerProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(other.read(chantControllerProvider).settings.target, 21);
    });
  });

  group('manual counter (default)', () {
    late FakeChantPlatform platform;
    late DateTime clock;
    late ProviderContainer container;

    ChantController ctl() => container.read(chantControllerProvider.notifier);
    ChantState st() => container.read(chantControllerProvider);

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      platform = FakeChantPlatform();
      clock = DateTime(2026, 5, 13, 7);
      container = ProviderContainer(
        overrides: [
          chantPlatformProvider.overrideWithValue(platform),
          chantNowProvider.overrideWithValue(() => clock),
        ],
      );
      addTearDown(container.dispose);
      container.read(chantControllerProvider);
    });

    test(
      'listening is off by default and the microphone is not asked',
      () async {
        expect(st().settings.micMode, isFalse);
        await ctl().start();
        expect(st().phase, ChantPhase.running);
        expect(platform.micRequests, 0);
        expect(platform.listening, isFalse);
        expect(platform.awake, isTrue);
      },
    );

    test(
      '+1 counts, undo takes one back, nothing counts before Start',
      () async {
        ctl().increment();
        expect(st().count, 0);
        await ctl().start();
        ctl().increment();
        ctl().increment();
        expect(st().count, 2);
        ctl().decrement();
        expect(st().count, 1);
        ctl().decrement();
        ctl().decrement();
        expect(st().count, 0, reason: 'never below zero');
      },
    );

    test('reaching the target pings once and completes', () async {
      await ctl().updateSettings(const ChantSettings(target: 3));
      await ctl().start();
      ctl().increment();
      ctl().increment();
      expect(platform.announced, isEmpty, reason: 'no ping before the target');
      ctl().increment();
      await Future<void>.delayed(Duration.zero);
      expect(st().phase, ChantPhase.complete);
      expect(platform.announced, [(ReminderMode.chime, 3, true)]);
      expect(platform.awake, isFalse);
      ctl().increment();
      expect(st().count, 3, reason: 'no more counting once complete');
    });

    test('undo after completing goes back to paused', () async {
      await ctl().updateSettings(const ChantSettings(target: 1));
      await ctl().start();
      ctl().increment();
      await Future<void>.delayed(Duration.zero);
      expect(st().phase, ChantPhase.complete);
      ctl().decrement();
      expect(st().phase, ChantPhase.idle);
      expect(st().count, 0);
    });

    test('elapsed time comes from timestamps and survives pause', () async {
      await ctl().start();
      clock = clock.add(const Duration(seconds: 90));
      expect(st().elapsed(clock), const Duration(seconds: 90));
      await ctl().pause();
      clock = clock.add(const Duration(minutes: 10));
      expect(st().elapsed(clock), const Duration(seconds: 90));
      await ctl().start();
      clock = clock.add(const Duration(seconds: 30));
      expect(st().elapsed(clock), const Duration(seconds: 120));
    });

    test('Finish before the target gives a summary to save', () async {
      await ctl().updateSettings(const ChantSettings(target: 108));
      await ctl().start();
      for (var i = 0; i < 5; i++) {
        ctl().increment();
      }
      clock = clock.add(const Duration(minutes: 7));
      final s = await ctl().finish();
      expect(s, isNotNull);
      expect(s!.count, 5);
      expect(s.reachedTarget, isFalse);
      expect(s.minutes, 7);
      expect(s.startedAt, DateTime(2026, 5, 13, 7));
      expect(st().phase, ChantPhase.complete);
    });

    test('Finish with nothing counted just resets', () async {
      await ctl().start();
      expect(await ctl().finish(), isNull);
      expect(st().phase, ChantPhase.idle);
      expect(st().startedAt, isNull);
    });

    test('reset clears the session but keeps settings', () async {
      await ctl().updateSettings(const ChantSettings(target: 9));
      await ctl().start();
      ctl().increment();
      await ctl().reset();
      expect(st().count, 0);
      expect(st().startedAt, isNull);
      expect(st().settings.target, 9);
    });

    test(
      'mic mode can be switched on, and +1 still corrects the count',
      () async {
        await ctl().updateSettings(
          const ChantSettings(target: 5, micMode: true, sensitivity: -30),
        );
        await ctl().start();
        expect(platform.micRequests, 1);
        expect(st().phase, ChantPhase.listening);
        ctl().increment();
        expect(st().count, 1);
        ctl().decrement();
        expect(st().count, 0);
      },
    );
  });

  test('chantElapsed handles paused and running', () {
    final t = DateTime(2026);
    expect(
      chantElapsed(
        accumulated: const Duration(seconds: 5),
        runningSince: null,
        now: t,
      ),
      const Duration(seconds: 5),
    );
    expect(
      chantElapsed(
        accumulated: const Duration(seconds: 5),
        runningSince: t,
        now: t.add(const Duration(seconds: 7)),
      ),
      const Duration(seconds: 12),
    );
  });

  group('saving a session', () {
    late AppDatabase db;
    late HabitRepository habits;
    late HobbyRepository hobbies;
    late String userId;
    final clock = FixedClock(DateTime.utc(2026, 5, 13, 10));
    final summary = ChantSummary(
      count: 108,
      target: 108,
      elapsed: const Duration(minutes: 12, seconds: 20),
      startedAt: DateTime.utc(2026, 5, 13, 9, 40),
      endedAt: DateTime.utc(2026, 5, 13, 9, 52, 20),
    );

    setUp(() async {
      drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      habits = HabitRepository(db, clock);
      hobbies = HobbyRepository(db, clock);
      userId = (await UserRepository(db, clock).ensureUser()).id;
    });

    test('finds the Chanting habit by name, ignoring case', () async {
      await habits.create(userId: userId, name: 'Water', kind: HabitKind.water);
      expect(findChantingHabit(await habits.watchActive(userId).first), isNull);
      final id = await habits.create(
        userId: userId,
        name: ' chanting ',
        kind: HabitKind.custom,
      );
      expect(findChantingHabit(await habits.watchActive(userId).first)?.id, id);
    });

    test('logs the chant count into the habit and a hobby log', () async {
      final habitId = await habits.create(
        userId: userId,
        name: 'Chanting',
        kind: HabitKind.custom,
        dailyTarget: 108,
      );
      await hobbies.ensureDefaults(userId);
      final music = (await hobbies.watchActive(userId).first).firstWhere(
        (h) => h.name == 'Music',
      );
      final habit = (await habits.byId(habitId))!;
      final r = await saveChantSession(
        summary: summary,
        userId: userId,
        dayCutoffMinutes: 0,
        habits: habits,
        hobbies: hobbies,
        habit: habit,
        hobbyId: music.id,
      );
      expect(r.savedAnything, isTrue);
      final hl = await habits.logsBetween(habitId, '2026-05-13', '2026-05-13');
      expect(hl.fold<int>(0, (a, l) => a + l.count), 108);
      final ol = await hobbies.logsForDate(userId, '2026-05-13');
      expect(ol, hasLength(1));
      expect(ol.single.hobbyId, music.id);
      expect(ol.single.durationMinutes, 12);
      expect(ol.single.source, HobbyLogSource.timer);
      expect(ol.single.note, contains('108 chants'));
    });

    test('with neither chosen nothing is written', () async {
      final r = await saveChantSession(
        summary: summary,
        userId: userId,
        dayCutoffMinutes: 0,
        habits: habits,
        hobbies: hobbies,
      );
      expect(r.savedAnything, isFalse);
      expect(await hobbies.logsForDate(userId, '2026-05-13'), isEmpty);
    });

    test('a hobby alone does not touch habits', () async {
      final habitId = await habits.create(
        userId: userId,
        name: 'Chanting',
        kind: HabitKind.custom,
      );
      await hobbies.ensureDefaults(userId);
      final h = (await hobbies.watchActive(userId).first).first;
      await saveChantSession(
        summary: summary,
        userId: userId,
        dayCutoffMinutes: 0,
        habits: habits,
        hobbies: hobbies,
        hobbyId: h.id,
      );
      expect(
        await habits.logsBetween(habitId, '2026-05-13', '2026-05-13'),
        isEmpty,
      );
    });
  });
}
