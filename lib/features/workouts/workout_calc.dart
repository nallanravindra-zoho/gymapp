/// Pure calculations for workout metrics (R3). No Flutter, no database, so
/// every rule can be unit tested. Everything here produces estimates.
library;

import 'met_table.dart';

const caloriesLabel = 'Estimated, approximate';
const caloriesUnavailable = 'Estimate unavailable';
const caloriesNeedWeightHint = 'Add your weight in Profile to see an estimate.';
const caloriesNoTypeHint = 'There is no estimate for this kind of workout.';
const stepsUnavailable = 'Steps unavailable';

/// kcal = MET x 3.5 x weight(kg) / 200 x minutes (Compendium convention).
/// Returns null when the weight or MET is missing, or no time was active.
int? caloriesEstimate({
  required double? met,
  required double? weightKg,
  required int activeSeconds,
}) {
  if (met == null || weightKg == null || weightKg <= 0) return null;
  if (activeSeconds <= 0) return null;
  final minutes = activeSeconds / 60;
  return (met * 3.5 * weightKg / 200 * minutes).round();
}

/// Whether a type key counts steps and distance (Walk and Run).
bool tracksDistance(String? iconKey) => iconKey == 'walk' || iconKey == 'run';

/// Estimated stride in metres from height: about 0.415 of height walking and
/// 0.65 running. Null when height is unknown.
double? strideMeters({required double? heightCm, required String? iconKey}) {
  if (heightCm == null || heightCm <= 0) return null;
  final factor = iconKey == 'run' ? 0.65 : 0.415;
  return heightCm / 100 * factor;
}

double? distanceKmFromSteps(int steps, double? strideM) {
  if (strideM == null || steps <= 0) return null;
  return _round2(steps * strideM / 1000);
}

int? stepsFromDistanceKm(double distanceKm, double? strideM) {
  if (strideM == null || distanceKm <= 0) return null;
  return (distanceKm * 1000 / strideM).round();
}

/// Average speed in km/h over active time only (paused time excluded).
double? avgSpeedKmh(double? distanceKm, int activeSeconds) {
  if (distanceKm == null || distanceKm <= 0 || activeSeconds <= 0) return null;
  return _round2(distanceKm / (activeSeconds / 3600));
}

double _round2(double v) => (v * 100).round() / 100;

/// What the user supplied or the phone measured for one workout.
class MetricInputs {
  const MetricInputs({
    required this.iconKey,
    required this.activeSeconds,
    this.pausedSeconds = 0,
    this.intensity,
    this.weightKg,
    this.heightCm,
    this.sensorSteps,
    this.enteredDistanceKm,
  });

  final String? iconKey;
  final int activeSeconds;
  final int pausedSeconds;

  /// `low`, `mid` or `high`.
  final String? intensity;
  final double? weightKg;
  final double? heightCm;

  /// Steps counted by the phone sensor during the timed workout.
  final int? sensorSteps;
  final double? enteredDistanceKm;
}

class ComputedMetrics {
  const ComputedMetrics({
    this.calories,
    this.steps,
    this.stepsSource,
    this.distanceKm,
    this.distanceSource,
    this.avgSpeedKmh,
    required this.activeSeconds,
    required this.pausedSeconds,
  });

  final int? calories;
  final int? steps;

  /// `sensor` or `estimate`, as stored in `stepsSource`.
  final String? stepsSource;
  final double? distanceKm;

  /// `entered` or `estimate`.
  final String? distanceSource;
  final double? avgSpeedKmh;
  final int activeSeconds;
  final int pausedSeconds;

  /// Stored in `metricsNote`: `estimated` when distance came from steps.
  String? get note => distanceKm == null
      ? null
      : (distanceSource == 'estimate' ? 'estimated' : 'measured');
}

/// Combines inputs into the metrics saved with a workout.
ComputedMetrics computeMetrics(MetricInputs i) {
  final calories = caloriesEstimate(
    met: metFor(i.iconKey, i.intensity),
    weightKg: i.weightKg,
    activeSeconds: i.activeSeconds,
  );
  int? steps;
  String? stepsSource;
  double? distance;
  String? distanceSource;

  if (tracksDistance(i.iconKey)) {
    final stride = strideMeters(heightCm: i.heightCm, iconKey: i.iconKey);
    if (i.sensorSteps != null && i.sensorSteps! > 0) {
      steps = i.sensorSteps;
      stepsSource = 'sensor';
    }
    if (i.enteredDistanceKm != null && i.enteredDistanceKm! > 0) {
      distance = _round2(i.enteredDistanceKm!);
      distanceSource = 'entered';
    } else if (steps != null) {
      distance = distanceKmFromSteps(steps, stride);
      if (distance != null) distanceSource = 'estimate';
    }
    if (steps == null && distance != null && distanceSource == 'entered') {
      final est = stepsFromDistanceKm(distance, stride);
      if (est != null) {
        steps = est;
        stepsSource = 'estimate';
      }
    }
  }

  return ComputedMetrics(
    calories: calories,
    steps: steps,
    stepsSource: stepsSource,
    distanceKm: distance,
    distanceSource: distanceSource,
    avgSpeedKmh: avgSpeedKmh(distance, i.activeSeconds),
    activeSeconds: i.activeSeconds,
    pausedSeconds: i.pausedSeconds,
  );
}

String formatDistanceKm(double km) =>
    '${km.toStringAsFixed(km >= 10 ? 1 : 2)} km';

String formatSpeed(double kmh) => '${kmh.toStringAsFixed(1)} km/h';

String formatSteps(int steps) {
  final s = steps.toString();
  final b = StringBuffer();
  for (var k = 0; k < s.length; k++) {
    if (k > 0 && (s.length - k) % 3 == 0) b.write(',');
    b.write(s[k]);
  }
  return b.toString();
}
