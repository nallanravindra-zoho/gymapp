import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/features/workouts/met_table.dart';
import 'package:wellbeing/features/workouts/workout_calc.dart';

void main() {
  group('calories', () {
    test('kcal = MET x 3.5 x kg / 200 x minutes', () {
      // 3.5 MET, 70 kg, 60 minutes: 3.5 * 3.5 * 70 / 200 * 60 = 257.25
      expect(
        caloriesEstimate(met: 3.5, weightKg: 70, activeSeconds: 3600),
        257,
      );
    });

    test('missing weight, MET or time gives null, never zero', () {
      expect(
        caloriesEstimate(met: 3.5, weightKg: null, activeSeconds: 600),
        isNull,
      );
      expect(
        caloriesEstimate(met: null, weightKg: 70, activeSeconds: 600),
        isNull,
      );
      expect(
        caloriesEstimate(met: 3.5, weightKg: 70, activeSeconds: 0),
        isNull,
      );
      expect(
        caloriesEstimate(met: 3.5, weightKg: 0, activeSeconds: 600),
        isNull,
      );
    });

    test('intensity picks the MET; none means mid; custom has none', () {
      expect(metFor('run', 'low'), 8.3);
      expect(metFor('run', null), 9.8);
      expect(metFor('run', 'high'), 11.0);
      expect(metFor('custom', 'mid'), isNull);
      expect(metFor('other', null), isNull);
    });

    test('every built-in type except Other has a MET with low<=mid<=high', () {
      for (final k in [
        'yoga', 'zumba', 'walk', 'run', 'weights', 'legs', 'arms', 'chest',
        'back', 'stability', 'flexibility', //
      ]) {
        final m = metByTypeKey[k]!;
        expect(m.low <= m.mid && m.mid <= m.high, isTrue, reason: k);
      }
    });
  });

  group('stride, distance and speed', () {
    test('stride from height, longer when running', () {
      expect(
        strideMeters(heightCm: 170, iconKey: 'walk'),
        closeTo(0.7055, 1e-4),
      );
      expect(strideMeters(heightCm: 170, iconKey: 'run'), closeTo(1.105, 1e-4));
      expect(strideMeters(heightCm: null, iconKey: 'walk'), isNull);
    });

    test('distance from steps needs a stride', () {
      expect(distanceKmFromSteps(1000, 0.7), 0.7);
      expect(distanceKmFromSteps(1000, null), isNull);
      expect(distanceKmFromSteps(0, 0.7), isNull);
    });

    test('speed uses active time only', () {
      // 5 km in 30 active minutes = 10 km/h, whatever was paused.
      expect(avgSpeedKmh(5, 1800), 10.0);
      expect(avgSpeedKmh(null, 1800), isNull);
      expect(avgSpeedKmh(5, 0), isNull);
    });

    test('steps formatting', () {
      expect(formatSteps(1234567), '1,234,567');
      expect(formatSteps(980), '980');
    });
  });

  group('computeMetrics', () {
    test('timed walk: sensor steps, estimated distance and speed', () {
      final m = computeMetrics(
        const MetricInputs(
          iconKey: 'walk',
          activeSeconds: 1800,
          pausedSeconds: 120,
          weightKg: 70,
          heightCm: 170,
          sensorSteps: 3000,
        ),
      );
      expect(m.steps, 3000);
      expect(m.stepsSource, 'sensor');
      expect(m.distanceKm, 2.12); // 3000 * 0.7055 m
      expect(m.note, 'estimated');
      expect(m.avgSpeedKmh, 4.24);
      expect(m.pausedSeconds, 120);
      expect(m.calories, isNotNull);
    });

    test('manual run: entered distance, steps estimated from stride', () {
      final m = computeMetrics(
        const MetricInputs(
          iconKey: 'run',
          activeSeconds: 1800,
          heightCm: 170,
          enteredDistanceKm: 5,
        ),
      );
      expect(m.distanceKm, 5);
      expect(m.note, 'measured');
      expect(m.stepsSource, 'estimate');
      expect(m.steps, 4525);
      expect(m.avgSpeedKmh, 10.0);
      expect(m.calories, isNull); // no weight
    });

    test('no sensor and no height: steps unavailable, not guessed', () {
      final m = computeMetrics(
        const MetricInputs(iconKey: 'walk', activeSeconds: 600),
      );
      expect(m.steps, isNull);
      expect(m.distanceKm, isNull);
      expect(m.avgSpeedKmh, isNull);
    });

    test('non walk/run types never get steps or distance', () {
      final m = computeMetrics(
        const MetricInputs(
          iconKey: 'yoga',
          activeSeconds: 1800,
          weightKg: 60,
          heightCm: 160,
          sensorSteps: 500,
          enteredDistanceKm: 3,
        ),
      );
      expect(m.steps, isNull);
      expect(m.distanceKm, isNull);
      expect(m.calories, isNotNull);
    });
  });
}
