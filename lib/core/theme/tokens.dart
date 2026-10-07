import 'package:flutter/material.dart';

/// Colour tokens from spec section 4.2. Defined once; widgets read them
/// through [Theme] / [AppTokens], never as raw hex values.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.bg,
    required this.surface,
    required this.text,
    required this.textMuted,
    required this.accent,
    required this.tintSleep,
    required this.tintHobby,
  });

  final Color bg;
  final Color surface;
  final Color text;
  final Color textMuted;
  final Color accent;
  final Color tintSleep;
  final Color tintHobby;

  static const light = AppTokens(
    bg: Color(0xFFFAFAF8),
    surface: Color(0xFFFFFFFF),
    text: Color(0xFF1C1F1E),
    textMuted: Color(0xFF6B706E),
    accent: Color(0xFF2F7D6B),
    tintSleep: Color(0xFFE8EDF3),
    tintHobby: Color(0xFFF4ECDD),
  );

  static const dark = AppTokens(
    bg: Color(0xFF121413),
    surface: Color(0xFF1B1D1C),
    text: Color(0xFFECEDEC),
    textMuted: Color(0xFF9AA09D),
    accent: Color(0xFF4FA68F),
    tintSleep: Color(0xFF1E2530),
    tintHobby: Color(0xFF2B261C),
  );

  @override
  AppTokens copyWith({
    Color? bg,
    Color? surface,
    Color? text,
    Color? textMuted,
    Color? accent,
    Color? tintSleep,
    Color? tintHobby,
  }) => AppTokens(
    bg: bg ?? this.bg,
    surface: surface ?? this.surface,
    text: text ?? this.text,
    textMuted: textMuted ?? this.textMuted,
    accent: accent ?? this.accent,
    tintSleep: tintSleep ?? this.tintSleep,
    tintHobby: tintHobby ?? this.tintHobby,
  );

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      tintSleep: Color.lerp(tintSleep, other.tintSleep, t)!,
      tintHobby: Color.lerp(tintHobby, other.tintHobby, t)!,
    );
  }
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}
