import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Microcopy rules (spec 4.5): neutral wording, no exclamation marks, no
/// emojis in system text, no guilt language. This reads every string literal
/// in the app's source, so new screens are covered without extra work.
final _literal = RegExp(
  r"""'((?:[^'\\\n]|\\.)*)'|"((?:[^"\\\n]|\\.)*)" """.trim(),
);

Iterable<(String file, int line, String text)> literals() sync* {
  for (final f in Directory('lib').listSync(recursive: true)) {
    if (f is! File || !f.path.endsWith('.dart') || f.path.endsWith('.g.dart')) {
      continue;
    }
    final lines = f.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trimLeft().startsWith('//')) continue;
      for (final m in _literal.allMatches(line)) {
        var text = m.group(1) ?? m.group(2) ?? '';
        // Code inside ${...} is not text.
        text = text.replaceAll(RegExp(r'\$\{[^}]*\}'), '');
        yield (f.path, i + 1, text);
      }
    }
  }
}

void main() {
  test('no exclamation marks in any text', () {
    final bad = [
      for (final (file, line, text) in literals())
        if (text.contains('!')) '$file:$line "$text"',
    ];
    expect(bad, isEmpty);
  });

  test('no emojis in any text', () {
    final emoji = RegExp(
      r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B50}\u{2B06}]',
      unicode: true,
    );
    final bad = [
      for (final (file, line, text) in literals())
        if (emoji.hasMatch(text)) '$file:$line "$text"',
    ];
    expect(bad, isEmpty);
  });

  test('no guilt or pressure wording', () {
    final banned = RegExp(
      r"\b(you missed|you failed|failed to log|don'?t give up|lazy|shame|"
      r'guilty|you broke|streak (is )?(lost|broken)|falling behind|'
      r'no excuses|you should have|slacking)\b',
      caseSensitive: false,
    );
    final bad = [
      for (final (file, line, text) in literals())
        if (banned.hasMatch(text)) '$file:$line "$text"',
    ];
    expect(bad, isEmpty);
  });

  test('the scanner does find text', () {
    // Guards against the regex silently matching nothing.
    expect(literals().length, greaterThan(500));
    expect(literals().any((l) => l.$3 == 'Delete account'), isTrue);
  });
}
