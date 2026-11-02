import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'gps_logic.dart';

/// Whether location can be used for a walk or run.
enum GpsAccess { granted, denied, deniedForever, serviceOff }

/// Why GPS is not being used, with what to do instead.
String gpsUnavailableMessage(GpsAccess a) => switch (a) {
  GpsAccess.granted => '',
  GpsAccess.serviceOff =>
    'Location is turned off on this phone. Distance can be entered by hand '
        'or estimated from steps.',
  GpsAccess.denied || GpsAccess.deniedForever =>
    'Location access was not given. Distance can be entered by hand or '
        'estimated from steps.',
};

/// Where position readings come from. Location is asked for only when a
/// person starts a GPS walk or run, never earlier.
abstract class LocationSource {
  /// Asks for location permission if needed and says what happened.
  Future<GpsAccess> requestAccess();

  /// Position readings until the subscription is cancelled.
  Stream<GpsPoint> track();
}

class GeolocatorLocationSource implements LocationSource {
  @override
  Future<GpsAccess> requestAccess() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return GpsAccess.serviceOff;
    }
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    return switch (p) {
      LocationPermission.always ||
      LocationPermission.whileInUse => GpsAccess.granted,
      LocationPermission.deniedForever => GpsAccess.deniedForever,
      _ => GpsAccess.denied,
    };
  }

  @override
  Stream<GpsPoint> track() =>
      Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 3,
          intervalDuration: const Duration(seconds: 2),
        ),
      ).map(
        (p) => GpsPoint(
          latitude: p.latitude,
          longitude: p.longitude,
          time: p.timestamp,
          accuracyM: p.accuracy,
        ),
      );
}

final locationSourceProvider = Provider<LocationSource>(
  (ref) => GeolocatorLocationSource(),
);

/// For tests: a source whose access is chosen and whose readings are pushed.
class FakeLocationSource implements LocationSource {
  FakeLocationSource({this.access = GpsAccess.granted});

  GpsAccess access;
  int accessRequests = 0;
  final readings = StreamController<GpsPoint>.broadcast();

  @override
  Future<GpsAccess> requestAccess() async {
    accessRequests++;
    return access;
  }

  @override
  Stream<GpsPoint> track() => readings.stream;
}
