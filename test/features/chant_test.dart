import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellbeing/core/theme/app_theme.dart';
import 'package:wellbeing/features/hobbies/chant_controller.dart';
import 'package:wellbeing/features/hobbies/chant_logic.dart';
import 'package:wellbeing/features/hobbies/chant_platform.dart';
import 'package:wellbeing/features/hobbies/chant_screen.dart';

class FakeChantPlatform implements ChantPlatform {
  bool micAllowed = true;
  bool failStart = false;
  final levels = StreamController<double>.broadcast();
  final announced = <(ReminderMode, int, bool)>[];
  bool awake = false;
  bool listening = false;

  @override
  Future<bool> requestMic() async => micAllowed;

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
      );
      final back = ChantSettings.fromJson(s.toJson());
      expect(back.target, 54);
      expect(back.interval, 9);
      expect(back.mode, ReminderMode.chime);
      expect(back.sensitivity, -28);
      final bad = ChantSettings.fromJson({
        'target': -3,
        'interval': 'x',
        'mode': 'nope',
      });
      expect(bad.target, 108);
      expect(bad.interval, 27);
      expect(bad.mode, ReminderMode.voice);
      expect(bad.sensitivity, isNull);
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
        ChantSettings(target: target, interval: interval, sensitivity: -30),
      );
      await ctl().start();
    }

    test('counts chants, reminds at checkpoints and completes', () async {
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
    });

    test('auto sensitivity calibrates, then listens', () async {
      container.read(chantControllerProvider);
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
      await ctl().start();
      expect(st().micDenied, isTrue);
      expect(st().phase, ChantPhase.idle);
      expect(platform.listening, isFalse);
    });

    test('a microphone that will not open says so', () async {
      platform.failStart = true;
      container.read(chantControllerProvider);
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

  testWidgets('screen shows the count, next reminder and Start', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final platform = FakeChantPlatform();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [chantPlatformProvider.overrideWithValue(platform)],
        child: MaterialApp(
          theme: buildTheme(Brightness.light),
          home: const ChantScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Om chanting'), findsOneWidget);
    expect(find.text('Ready when you are'), findsOneWidget);
    expect(find.text('of 108'), findsOneWidget);
    expect(find.text('Next reminder at 27'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(platform.listening, isTrue);
    expect(find.text('Pause'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Pause'));
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Paused'), findsNothing, reason: 'count is still 0');
    expect(find.text('Ready when you are'), findsOneWidget);
    await tester.tap(find.byTooltip('Chant settings'));
    await tester.pumpAndSettle();
    expect(find.text('Reminders at: 27, 54, 81, 108'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });
}
