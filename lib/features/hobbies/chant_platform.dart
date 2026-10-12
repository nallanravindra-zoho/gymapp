import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'chant_logic.dart';

/// The phone features the chant counter needs: the microphone level, spoken
/// or chime reminders, and keeping the screen on. Faked in tests.
abstract class ChantPlatform {
  /// Asks for microphone access; true when granted.
  Future<bool> requestMic();

  /// Starts listening and returns sound levels in dB. Throws if the
  /// microphone cannot be opened.
  Future<Stream<double>> startListening();

  Future<void> stopListening();

  /// Gives the reminder and resolves once it has finished, so the counter can
  /// ignore the phone's own sound.
  Future<void> announce(ReminderMode mode, int count, {required bool isFinal});

  Future<void> keepAwake(bool on);
}

class DeviceChantPlatform implements ChantPlatform {
  final AudioRecorder _recorder = AudioRecorder();
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _chime = AudioPlayer();
  final AudioPlayer _done = AudioPlayer();

  @override
  Future<bool> requestMic() => _recorder.hasPermission();

  @override
  Future<Stream<double>> startListening() async {
    // Audio is read only to measure loudness and is never kept.
    final audio = await _recorder.startStream(
      const RecordConfig(encoder: AudioEncoder.pcm16bits, numChannels: 1),
    );
    audio.listen((_) {}, onError: (_) {});
    return _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .map((a) => a.current);
  }

  @override
  Future<void> stopListening() async {
    try {
      if (await _recorder.isRecording()) await _recorder.stop();
    } catch (_) {
      // Already stopped.
    }
  }

  @override
  Future<void> announce(
    ReminderMode mode,
    int count, {
    required bool isFinal,
  }) async {
    HapticFeedback.heavyImpact();
    try {
      if (mode == ReminderMode.voice) {
        await _tts.setLanguage('en-IN');
        await _tts.setSpeechRate(0.5);
        await _tts.awaitSpeakCompletion(true);
        await _tts.speak(isFinal ? '$count. Complete.' : '$count');
      } else {
        final player = isFinal ? _done : _chime;
        await player.stop();
        await player.play(
          AssetSource(isFinal ? 'sounds/complete.wav' : 'sounds/chime.wav'),
        );
        await Future<void>.delayed(Duration(milliseconds: isFinal ? 900 : 750));
      }
    } catch (_) {
      // A reminder that cannot play must never stop the count.
    }
  }

  @override
  Future<void> keepAwake(bool on) async {
    try {
      on ? await WakelockPlus.enable() : await WakelockPlus.disable();
    } catch (_) {}
  }
}
