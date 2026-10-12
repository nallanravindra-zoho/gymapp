import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Chooses a profile picture from the gallery and keeps a copy in the app's
/// documents folder. Returns that local path, or null when cancelled.
abstract class ProfilePhotoStore {
  Future<String?> chooseFromGallery();
  Future<void> remove(String path);
}

class GalleryProfilePhotoStore implements ProfilePhotoStore {
  @override
  Future<String?> chooseFromGallery() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 768,
      maxHeight: 768,
      imageQuality: 85,
    );
    if (picked == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final dest = File(
      '${dir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await File(picked.path).copy(dest.path);
    return dest.path;
  }

  @override
  Future<void> remove(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}

final profilePhotoStoreProvider = Provider<ProfilePhotoStore>(
  (_) => GalleryProfilePhotoStore(),
);

/// What the Android ringtone picker returned.
class RingtoneChoice {
  const RingtoneChoice({this.uri, this.title});

  /// Null means the phone's default notification sound.
  final String? uri;
  final String? title;
}

abstract class RingtonePicker {
  /// Opens the picker. Null when cancelled.
  Future<RingtoneChoice?> pick(String? currentUri);

  /// A readable name for a stored sound, or null if unknown.
  Future<String?> titleOf(String uri);
}

class AndroidRingtonePicker implements RingtonePicker {
  AndroidRingtonePicker([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel('wellbeing/ringtone');
  final MethodChannel _channel;

  @override
  Future<RingtoneChoice?> pick(String? currentUri) async {
    try {
      final r = await _channel.invokeMapMethod<String, Object?>('pick', {
        'current': currentUri,
      });
      if (r == null || r['cancelled'] == true) return null;
      final uri = r['uri'] as String?;
      return RingtoneChoice(
        uri: (uri == null || uri.isEmpty) ? null : uri,
        title: r['title'] as String?,
      );
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<String?> titleOf(String uri) async {
    try {
      return await _channel.invokeMethod<String>('title', {'uri': uri});
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}

final ringtonePickerProvider = Provider<RingtonePicker>(
  (_) => AndroidRingtonePicker(),
);

/// Scripted picker for tests.
class FakeRingtonePicker implements RingtonePicker {
  FakeRingtonePicker({this.next, this.titles = const {}});
  RingtoneChoice? next;
  final Map<String, String> titles;
  String? lastCurrent;
  int calls = 0;

  @override
  Future<RingtoneChoice?> pick(String? currentUri) async {
    calls++;
    lastCurrent = currentUri;
    return next;
  }

  @override
  Future<String?> titleOf(String uri) async => titles[uri];
}

/// Scripted photo store for tests.
class FakeProfilePhotoStore implements ProfilePhotoStore {
  FakeProfilePhotoStore({this.next});
  String? next;
  final removed = <String>[];

  @override
  Future<String?> chooseFromGallery() async => next;
  @override
  Future<void> remove(String path) async => removed.add(path);
}
