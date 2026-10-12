import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the phone's step count comes from (Android TYPE_STEP_COUNTER).
///
/// The sensor reports a running total since the phone last started, so a
/// workout's steps are the total at the end minus the total at the start.
/// The starting total is kept with the stored timer, which means it survives
/// the app being closed.
abstract class StepSource {
  /// Asks for the activity permission if needed (only called when a timed
  /// walk or run starts) and returns the current running total, or null when
  /// there is no step sensor, permission was declined, or it gave no reading.
  Future<int?> startReading();

  /// The current running total without asking for anything, or null.
  Future<int?> readTotal();
}

class ChannelStepSource implements StepSource {
  ChannelStepSource([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel('wellbeing/steps');

  final MethodChannel _channel;

  @override
  Future<int?> startReading() async {
    try {
      final granted = await _channel.invokeMethod<bool>('requestPermission');
      if (granted != true) return null;
      return await readTotal();
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<int?> readTotal() async {
    try {
      final v = await _channel.invokeMethod<num>('readTotal');
      return v?.toInt();
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}

final stepSourceProvider = Provider<StepSource>((ref) => ChannelStepSource());

/// For tests: a fixed running total that tests can move.
class FakeStepSource implements StepSource {
  FakeStepSource({this.total, this.granted = true});
  int? total;
  bool granted;
  int permissionRequests = 0;

  @override
  Future<int?> startReading() async {
    permissionRequests++;
    return granted ? total : null;
  }

  @override
  Future<int?> readTotal() async => granted ? total : null;
}
