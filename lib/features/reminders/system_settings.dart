import 'package:flutter/services.dart';

/// The phone's own settings that decide whether reminders can reach you.
abstract class SystemSettings {
  /// Whether the app is exempt from battery optimisation (so it may run in the
  /// background). Null when the phone cannot say.
  Future<bool?> isUnrestrictedByBattery();

  Future<void> openBatterySettings();
  Future<void> openNotificationSettings();
}

class AndroidSystemSettings implements SystemSettings {
  AndroidSystemSettings([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel('wellbeing/system');

  final MethodChannel _channel;

  @override
  Future<bool?> isUnrestrictedByBattery() async {
    try {
      return await _channel.invokeMethod<bool>(
        'isIgnoringBatteryOptimizations',
      );
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<void> openBatterySettings() =>
      _channel.invokeMethod<void>('openBatterySettings');

  @override
  Future<void> openNotificationSettings() =>
      _channel.invokeMethod<void>('openNotificationSettings');
}

/// Used where there is no phone to ask (other platforms, and by default).
class NoopSystemSettings implements SystemSettings {
  @override
  Future<bool?> isUnrestrictedByBattery() async => null;
  @override
  Future<void> openBatterySettings() async {}
  @override
  Future<void> openNotificationSettings() async {}
}

/// Scripted settings for tests.
class FakeSystemSettings implements SystemSettings {
  FakeSystemSettings({this.unrestricted = false});

  bool? unrestricted;
  int batteryOpened = 0;
  int notificationsOpened = 0;

  @override
  Future<bool?> isUnrestrictedByBattery() async => unrestricted;
  @override
  Future<void> openBatterySettings() async => batteryOpened++;
  @override
  Future<void> openNotificationSettings() async => notificationsOpened++;
}
