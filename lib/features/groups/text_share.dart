import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Hands a piece of text to the phone's share sheet, where the person picks
/// the app to send it with.
abstract class TextSharer {
  Future<void> share(String text, {String? subject});
}

class ShareSheetTextSharer implements TextSharer {
  @override
  Future<void> share(String text, {String? subject}) async {
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  }
}

class FakeTextSharer implements TextSharer {
  final shared = <String>[];
  bool fail = false;

  @override
  Future<void> share(String text, {String? subject}) async {
    if (fail) throw StateError('no share sheet');
    shared.add(text);
  }
}

final textSharerProvider = Provider<TextSharer>((_) => ShareSheetTextSharer());
