import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'groups_models.dart';

/// Invite links that open the app (`wellbeing://join/CODE`), from the phone.
abstract class InviteLinkSource {
  /// The link that started the app, if it was started by one. Read once.
  Future<String?> initialLink();

  /// Links that arrive while the app is already running.
  Stream<String> get links;
}

class AndroidInviteLinkSource implements InviteLinkSource {
  AndroidInviteLinkSource([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel('wellbeing/links') {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'link' && call.arguments is String) {
        _controller.add(call.arguments as String);
      }
      return null;
    });
  }

  final MethodChannel _channel;
  final _controller = StreamController<String>.broadcast();

  @override
  Future<String?> initialLink() async {
    try {
      return await _channel.invokeMethod<String>('initialLink');
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Stream<String> get links => _controller.stream;
}

/// For tests: choose the link the app starts with and send more later.
class FakeInviteLinkSource implements InviteLinkSource {
  FakeInviteLinkSource({this.initial});

  final String? initial;
  final _controller = StreamController<String>.broadcast();

  void emit(String link) => _controller.add(link);

  @override
  Future<String?> initialLink() async => initial;

  @override
  Stream<String> get links => _controller.stream;
}

final inviteLinkSourceProvider = Provider<InviteLinkSource>(
  (_) => FakeInviteLinkSource(),
);

/// An invite code the person tapped but has not yet been asked about: held
/// until they are signed in and the Groups tab can show the confirmation.
class PendingInvite extends Notifier<String?> {
  @override
  String? build() => null;

  /// Takes a link or code; ignores anything that is not an invite.
  bool offer(String link) {
    final code = parseInviteCode(link);
    if (code == null) return false;
    state = code;
    return true;
  }

  /// Returns the waiting code and forgets it, so it is handled once.
  String? take() {
    final code = state;
    state = null;
    return code;
  }
}

final pendingInviteProvider = NotifierProvider<PendingInvite, String?>(
  PendingInvite.new,
);
