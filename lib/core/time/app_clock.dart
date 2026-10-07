/// Source of "now" and the device's UTC offset. Injected so tests can fix both.
class AppClock {
  const AppClock();

  DateTime now() => DateTime.now().toUtc();

  /// UTC offset in minutes at [instant] on this device.
  int offsetAt(DateTime instant) =>
      instant.toUtc().toLocal().timeZoneOffset.inMinutes;
}

class FixedClock extends AppClock {
  const FixedClock(this._now, {this.offsetMinutes = 0});

  final DateTime _now;
  final int offsetMinutes;

  @override
  DateTime now() => _now.toUtc();

  @override
  int offsetAt(DateTime instant) => offsetMinutes;
}
