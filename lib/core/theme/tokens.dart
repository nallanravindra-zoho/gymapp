import 'package:flutter/material.dart';

/// What a piece of the app is about. Each kind has one tinted circle colour
/// and one icon colour, used everywhere that kind shows up (Today, Week,
/// Groups, Insights...), so the app reads as one system.
enum Cat {
  workout,
  habit,
  water,
  stretch,
  leaf,
  sleep,
  screen,
  streak,
  hobby,
  trophy,
  strength,
  neutral,
}

/// A tint (the circle) and the colour of the icon drawn on it.
class CatColors {
  const CatColors(this.tint, this.icon);
  final Color tint;
  final Color icon;

  static CatColors lerp(CatColors a, CatColors b, double t) =>
      CatColors(Color.lerp(a.tint, b.tint, t)!, Color.lerp(a.icon, b.icon, t)!);
}

/// Colour tokens, matched to the reference screens (spec 4.2 and the 10
/// October revision). Defined once; widgets read them through [Theme] /
/// [AppTokens], never as raw hex values.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.bg,
    required this.surface,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.accent,
    required this.accentDeep,
    required this.accentSoft,
    required this.track,
    required this.mint,
    required this.tintSleep,
    required this.tintHobby,
    required this.cats,
  });

  /// Page background (warm off-white).
  final Color bg;

  /// Cards.
  final Color surface;

  /// Hairline around cards and between list rows.
  final Color border;

  /// Headings and body text (deep navy).
  final Color text;
  final Color textMuted;

  /// Buttons, selected states.
  final Color accent;

  /// Selected navigation, "in progress" text, emphasised numbers.
  final Color accentDeep;

  /// Selected pill background.
  final Color accentSoft;

  /// Unselected pill / progress track.
  final Color track;

  /// Soft green wash behind friendly callouts.
  final Color mint;

  final Color tintSleep;
  final Color tintHobby;

  final Map<Cat, CatColors> cats;

  CatColors cat(Cat c) => cats[c]!;

  static const _lightCats = {
    Cat.workout: CatColors(Color(0xFFCBEBD5), Color(0xFF1E7753)),
    Cat.habit: CatColors(Color(0xFFD6EFDC), Color(0xFF2E8A55)),
    Cat.water: CatColors(Color(0xFFD3EEF6), Color(0xFF2A8CC8)),
    Cat.stretch: CatColors(Color(0xFFF7DCE3), Color(0xFF6B3FA0)),
    Cat.leaf: CatColors(Color(0xFFD2EBE0), Color(0xFF2B8062)),
    Cat.sleep: CatColors(Color(0xFFE5DDF5), Color(0xFF4639A8)),
    Cat.screen: CatColors(Color(0xFFDCE5F8), Color(0xFF2D4EA6)),
    Cat.streak: CatColors(Color(0xFFFDE8DA), Color(0xFFEF6A2A)),
    Cat.hobby: CatColors(Color(0xFFF8E4C6), Color(0xFFB4701B)),
    Cat.trophy: CatColors(Color(0xFFFBE7CC), Color(0xFFD9822B)),
    Cat.strength: CatColors(Color(0xFFE0EBF2), Color(0xFF1E4F8E)),
    Cat.neutral: CatColors(Color(0xFFE9ECEA), Color(0xFF3C4F66)),
  };

  static const _darkCats = {
    Cat.workout: CatColors(Color(0xFF23392E), Color(0xFF7FD3A5)),
    Cat.habit: CatColors(Color(0xFF243A2A), Color(0xFF86D49C)),
    Cat.water: CatColors(Color(0xFF1F3744), Color(0xFF69BDEB)),
    Cat.stretch: CatColors(Color(0xFF3B2A35), Color(0xFFC49BEA)),
    Cat.leaf: CatColors(Color(0xFF213A33), Color(0xFF79CBAE)),
    Cat.sleep: CatColors(Color(0xFF2D2A4A), Color(0xFFB4A9F2)),
    Cat.screen: CatColors(Color(0xFF26304F), Color(0xFF9DB4F0)),
    Cat.streak: CatColors(Color(0xFF42291C), Color(0xFFFF8E57)),
    Cat.hobby: CatColors(Color(0xFF3E3220), Color(0xFFE9B567)),
    Cat.trophy: CatColors(Color(0xFF3F3220), Color(0xFFF0A650)),
    Cat.strength: CatColors(Color(0xFF23323F), Color(0xFF8FB5EC)),
    Cat.neutral: CatColors(Color(0xFF2A302E), Color(0xFFB9C6D6)),
  };

  static const light = AppTokens(
    bg: Color(0xFFFBF9F4),
    surface: Color(0xFFFEFDFA),
    border: Color(0xFFE6EAE5),
    text: Color(0xFF1B2B45),
    textMuted: Color(0xFF63768A),
    accent: Color(0xFF368A6C),
    accentDeep: Color(0xFF1D6D57),
    accentSoft: Color(0xFFC6E4DA),
    track: Color(0xFFEDF1EE),
    mint: Color(0xFFDFF1E7),
    tintSleep: Color(0xFFE8EDF3),
    tintHobby: Color(0xFFF4ECDD),
    cats: _lightCats,
  );

  static const dark = AppTokens(
    bg: Color(0xFF121614),
    surface: Color(0xFF1A1F1C),
    border: Color(0xFF2A322E),
    text: Color(0xFFECF0EE),
    textMuted: Color(0xFF9AA8A3),
    accent: Color(0xFF4FA88B),
    accentDeep: Color(0xFF7FCFB3),
    accentSoft: Color(0xFF26453B),
    track: Color(0xFF222A26),
    mint: Color(0xFF1E3029),
    tintSleep: Color(0xFF1E2530),
    tintHobby: Color(0xFF2B261C),
    cats: _darkCats,
  );

  @override
  AppTokens copyWith({
    Color? bg,
    Color? surface,
    Color? border,
    Color? text,
    Color? textMuted,
    Color? accent,
    Color? accentDeep,
    Color? accentSoft,
    Color? track,
    Color? mint,
    Color? tintSleep,
    Color? tintHobby,
  }) => AppTokens(
    bg: bg ?? this.bg,
    surface: surface ?? this.surface,
    border: border ?? this.border,
    text: text ?? this.text,
    textMuted: textMuted ?? this.textMuted,
    accent: accent ?? this.accent,
    accentDeep: accentDeep ?? this.accentDeep,
    accentSoft: accentSoft ?? this.accentSoft,
    track: track ?? this.track,
    mint: mint ?? this.mint,
    tintSleep: tintSleep ?? this.tintSleep,
    tintHobby: tintHobby ?? this.tintHobby,
    cats: cats,
  );

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentDeep: Color.lerp(accentDeep, other.accentDeep, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      track: Color.lerp(track, other.track, t)!,
      mint: Color.lerp(mint, other.mint, t)!,
      tintSleep: Color.lerp(tintSleep, other.tintSleep, t)!,
      tintHobby: Color.lerp(tintHobby, other.tintHobby, t)!,
      cats: {
        for (final c in Cat.values)
          c: CatColors.lerp(cats[c]!, other.cats[c]!, t),
      },
    );
  }
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}
