import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/features/workouts/gps_logic.dart';
import 'package:wellbeing/features/workouts/gps_tracker.dart';
import 'package:wellbeing/features/workouts/location_source.dart';
import 'package:wellbeing/features/workouts/workout_providers.dart';
import 'package:wellbeing/features/workouts/workout_calc.dart';

import '../helpers/nav_a.dart';
import '../test_helpers.dart';

final _t0 = DateTime.utc(2026, 5, 13, 10);

const _steps = MethodChannel('wellbeing/steps');

/// The phone's step sensor, answering with a permission and a running total.
void _mockSteps(WidgetTester tester) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(_steps, (
    call,
  ) async {
    return switch (call.method) {
      'requestPermission' => true,
      'readTotal' => 1000,
      _ => null,
    };
  });
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      _steps,
      null,
    ),
  );
}

GpsPoint pt(double lat, double lon, int seconds, {double? acc = 5}) => GpsPoint(
  latitude: lat,
  longitude: lon,
  time: _t0.add(Duration(seconds: seconds)),
  accuracyM: acc,
);

void main() {
  group('distance', () {
    test('haversine matches a known distance', () {
      // 0.001 degrees of latitude is about 111 m.
      expect(
        haversineKm(pt(12.9716, 77.5946, 0), pt(12.9726, 77.5946, 0)),
        closeTo(0.1112, 0.001),
      );
      expect(haversineKm(pt(1, 1, 0), pt(1, 1, 0)), 0);
    });

    test('adds up a steady walk', () {
      final track = GpsTrack();
      for (var i = 0; i < 11; i++) {
        track.add(pt(12.9716 + i * 0.0001, 77.5946, i * 8));
      }
      // Ten steps of about 11 m.
      expect(track.distanceKm, closeTo(0.111, 0.003));
    });

    test('vague readings are ignored', () {
      final track = GpsTrack()
        ..add(pt(12.9716, 77.5946, 0))
        ..add(pt(12.9726, 77.5946, 60, acc: 80));
      expect(track.distanceKm, 0);
    });

    test('standing still adds nothing', () {
      final track = GpsTrack()
        ..add(pt(12.9716, 77.5946, 0))
        ..add(pt(12.97161, 77.5946, 10))
        ..add(pt(12.97162, 77.59461, 20));
      expect(track.distanceKm, 0);
    });

    test('a jump no runner could make is not counted', () {
      final track = GpsTrack()
        ..add(pt(12.9716, 77.5946, 0))
        // About 1.1 km in 5 seconds.
        ..add(pt(12.9816, 77.5946, 5));
      expect(track.distanceKm, 0);
    });

    test('paused time adds no distance and resume starts a new segment', () {
      final track = GpsTrack()..add(pt(12.9716, 77.5946, 0));
      track.pause();
      expect(track.add(pt(12.9726, 77.5946, 60)), isFalse);
      track.resume();
      // The first reading after resume only sets the start of a segment.
      expect(track.add(pt(13.0, 77.5946, 600)), isFalse);
      expect(track.add(pt(13.0001, 77.5946, 608)), isTrue);
      expect(track.distanceKm, closeTo(0.011, 0.002));
    });

    test('pace is minutes and seconds per kilometre', () {
      expect(paceText(5, 1800), '6:00 /km');
      expect(paceText(1.2, 480), '6:40 /km');
      expect(paceText(0, 100), isNull);
      expect(paceText(2, 0), isNull);
    });
  });

  group('metrics', () {
    test('GPS distance wins and is labelled', () {
      final m = computeMetrics(
        const MetricInputs(
          iconKey: 'walk',
          activeSeconds: 1800,
          weightKg: 70,
          heightCm: 170,
          sensorSteps: 4000,
          gpsDistanceKm: 3.2,
        ),
      );
      expect(m.distanceKm, 3.2);
      expect(m.distanceSource, 'gps');
      expect(m.note, 'gps');
      expect(m.avgSpeedKmh, closeTo(6.4, 0.01));
    });

    test('GPS far below what the steps imply is not trusted', () {
      // 3,000 steps at 170 cm is about 2.1 km; GPS only saw 1.5 km, under
      // 80% of that.
      final m = computeMetrics(
        const MetricInputs(
          iconKey: 'walk',
          activeSeconds: 3120,
          heightCm: 170,
          sensorSteps: 3000,
          gpsDistanceKm: 1.5,
        ),
      );
      expect(m.distanceSource, 'estimate');
      expect(m.distanceKm, closeTo(2.12, 0.01));
      expect(m.note, 'estimated');
    });

    test('GPS close to the steps is kept', () {
      final m = computeMetrics(
        const MetricInputs(
          iconKey: 'walk',
          activeSeconds: 3120,
          heightCm: 170,
          sensorSteps: 3000,
          gpsDistanceKm: 1.9,
        ),
      );
      expect(m.distanceSource, 'gps');
      expect(m.distanceKm, 1.9);
    });

    test('with no height or steps to compare, GPS is all there is', () {
      final m = computeMetrics(
        const MetricInputs(
          iconKey: 'walk',
          activeSeconds: 1800,
          sensorSteps: 3000,
          gpsDistanceKm: 1.7,
        ),
      );
      expect(m.distanceSource, 'gps');
    });

    test('with no GPS distance, steps are used as before', () {
      final m = computeMetrics(
        const MetricInputs(
          iconKey: 'walk',
          activeSeconds: 1800,
          heightCm: 170,
          sensorSteps: 4000,
          gpsDistanceKm: 0,
        ),
      );
      expect(m.distanceSource, 'estimate');
      expect(m.note, 'estimated');
    });
  });

  group('screen', () {
    late FakeLocationSource location;

    // The source is made when each test builds its app, so every test has
    // its own.
    Widget Function(Widget) wrap({GpsAccess access = GpsAccess.granted}) {
      return (app) {
        location = FakeLocationSource(access: access);
        return ProviderScope(
          overrides: [
            locationSourceProvider.overrideWithValue(location),
            // Providers that read the source are rebuilt in this scope.
            gpsTrackerProvider.overrideWith(GpsTracker.new),
            activeTimerProvider.overrideWith(ActiveTimerNotifier.new),
          ],
          child: app,
        );
      };
    }

    Future<void> startWalk(WidgetTester tester, {required bool gps}) async {
      _mockSteps(tester);
      await openLogScreen(tester);
      await tester.tap(find.text('Walk'));
      await tester.pumpAndSettle();
      expect(location.accessRequests, 0);
      if (gps) {
        await tester.tap(find.text('Follow distance with GPS'));
        await tester.pumpAndSettle();
        expect(location.accessRequests, 0);
      }
      await tester.tap(find.widgetWithText(FilledButton, 'Start timer'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
    }

    appTest('location is asked for only when GPS tracking starts', (
      tester,
      db,
    ) async {
      expect(location.accessRequests, 0);
      await startWalk(tester, gps: true);
      expect(location.accessRequests, 1);

      location.readings
        ..add(pt(12.9716, 77.5946, 0))
        ..add(pt(12.9726, 77.5946, 60));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('0.11 km'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    }, wrapApp: wrap());

    appTest('without the switch location is never requested', (
      tester,
      db,
    ) async {
      await startWalk(tester, gps: false);
      expect(location.accessRequests, 0);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    }, wrapApp: wrap());

    appTest('denied location still starts the walk and says what to do', (
      tester,
      db,
    ) async {
      await startWalk(tester, gps: true);
      expect(location.accessRequests, 1);
      expect(find.byType(Scaffold), findsWidgets);
      expect(
        find.textContaining('Location access was not given'),
        findsOneWidget,
      );
      expect(find.textContaining('km'), findsNothing);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    }, wrapApp: wrap(access: GpsAccess.denied));

    appTest('a stopped GPS walk is saved with its distance and source', (
      tester,
      db,
    ) async {
      await startWalk(tester, gps: true);
      location.readings
        ..add(pt(12.9716, 77.5946, 0))
        ..add(pt(12.9726, 77.5946, 60));
      await tester.pump();

      await tester.tap(find.byTooltip('Stop and save'));
      await tester.pumpAndSettle();

      final w = (await db.select(db.workouts).get()).single;
      expect(w.distanceKm, closeTo(0.11, 0.01));
      expect(w.metricsNote, 'gps');
    }, wrapApp: wrap());
  });

  test('copy has no exclamation marks', () {
    for (final a in GpsAccess.values) {
      expect(gpsUnavailableMessage(a).contains('!'), isFalse);
    }
  });
}
