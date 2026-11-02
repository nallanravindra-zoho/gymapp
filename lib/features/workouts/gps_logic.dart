import 'dart:math' as math;

/// One position reading.
class GpsPoint {
  const GpsPoint({
    required this.latitude,
    required this.longitude,
    required this.time,
    this.accuracyM,
  });

  final double latitude;
  final double longitude;
  final DateTime time;

  /// Radius of the reading's uncertainty, in metres.
  final double? accuracyM;
}

/// Great-circle distance between two readings, in kilometres.
double haversineKm(GpsPoint a, GpsPoint b) {
  const earthKm = 6371.0088;
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(b.latitude - a.latitude);
  final dLon = rad(b.longitude - a.longitude);
  final h =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(a.latitude)) *
          math.cos(rad(b.latitude)) *
          math.pow(math.sin(dLon / 2), 2);
  return 2 * earthKm * math.asin(math.min(1, math.sqrt(h)));
}

/// Readings less accurate than this (metres) are ignored.
const gpsMaxAccuracyM = 30.0;

/// Movement smaller than this (metres) is treated as standing still.
const gpsMinStepM = 3.0;

/// Faster than this (metres per second, about 43 km/h) is a jump in the
/// signal, not a walk or run.
const gpsMaxSpeedMps = 12.0;

/// Adds up distance from position readings while a walk or run is going.
///
/// It drops readings that are too vague, ignores movement that is only
/// signal wobble, and ignores jumps no walker or runner could make. Time
/// spent paused is never counted: the caller pauses it, and the first reading
/// after a resume starts a fresh segment instead of joining the last one.
class GpsTrack {
  double _meters = 0;
  GpsPoint? _last;
  bool _paused = false;

  /// Distance so far, in kilometres.
  double get distanceKm => _meters / 1000;

  bool get isPaused => _paused;

  /// Clears the distance and any paused state, for a new workout.
  void reset() {
    _meters = 0;
    _last = null;
    _paused = false;
  }

  void pause() {
    _paused = true;
    _last = null;
  }

  void resume() {
    _paused = false;
    _last = null;
  }

  /// Takes one reading; returns true when it added distance.
  bool add(GpsPoint p) {
    if (_paused) return false;
    final acc = p.accuracyM;
    if (acc != null && acc > gpsMaxAccuracyM) return false;
    final last = _last;
    if (last == null) {
      _last = p;
      return false;
    }
    final meters = haversineKm(last, p) * 1000;
    final seconds = p.time.difference(last.time).inMilliseconds / 1000;
    if (meters < gpsMinStepM) return false;
    if (seconds <= 0 || meters / seconds > gpsMaxSpeedMps) {
      // Start again from this reading rather than trusting the jump.
      _last = p;
      return false;
    }
    _meters += meters;
    _last = p;
    return true;
  }
}

/// Average pace as `m:ss /km`, or null when there is no distance yet.
String? paceText(double distanceKm, int activeSeconds) {
  if (distanceKm < 0.01 || activeSeconds <= 0) return null;
  final perKm = (activeSeconds / distanceKm).round();
  final m = perKm ~/ 60;
  final s = (perKm % 60).toString().padLeft(2, '0');
  return '$m:$s /km';
}
