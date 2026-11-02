import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'gps_logic.dart';
import 'location_source.dart';

/// Live state of a GPS walk or run.
class GpsState {
  const GpsState({this.active = false, this.distanceKm = 0});

  final bool active;
  final double distanceKm;
}

/// Follows the position while a timed walk or run is going. It lives in
/// memory: if the app is closed mid-workout the distance so far is lost and
/// the workout falls back to the step estimate.
class GpsTracker extends Notifier<GpsState> {
  final _track = GpsTrack();
  StreamSubscription<GpsPoint>? _sub;

  @override
  GpsState build() {
    ref.onDispose(() => _sub?.cancel());
    return const GpsState();
  }

  /// Asks for location access and, if given, starts following the position.
  Future<GpsAccess> start() async {
    final source = ref.read(locationSourceProvider);
    final access = await source.requestAccess();
    if (access != GpsAccess.granted) return access;
    await _sub?.cancel();
    _track
      ..resume()
      ..reset();
    _sub = source.track().listen((p) {
      if (_track.add(p)) {
        state = GpsState(active: true, distanceKm: _track.distanceKm);
      }
    }, onError: (Object _) {});
    state = const GpsState(active: true);
    return access;
  }

  void pause() => _track.pause();

  void resume() => _track.resume();

  /// Stops following and returns the distance covered, in kilometres.
  double stop() {
    final km = _track.distanceKm;
    _sub?.cancel();
    _sub = null;
    state = const GpsState();
    return km;
  }
}

final gpsTrackerProvider = NotifierProvider<GpsTracker, GpsState>(
  GpsTracker.new,
);
