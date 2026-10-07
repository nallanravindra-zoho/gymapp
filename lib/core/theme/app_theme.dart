import 'package:flutter/material.dart';

import 'tokens.dart';

/// Minimum tap target from spec 4.1.
const double kMinTapTarget = 48;

/// Three text sizes only (spec 4.3): body, title, display.
const double kBodySize = 15;
const double kTitleSize = 20;
const double kDisplaySize = 32;

ThemeData buildTheme(Brightness brightness) {
  final t = brightness == Brightness.dark ? AppTokens.dark : AppTokens.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: t.accent,
    brightness: brightness,
  ).copyWith(primary: t.accent, surface: t.surface, onSurface: t.text);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: t.bg,
    extensions: [t],
    textTheme: TextTheme(
      bodyMedium: TextStyle(fontSize: kBodySize, color: t.text),
      bodySmall: TextStyle(fontSize: 13, color: t.textMuted),
      titleLarge: TextStyle(
        fontSize: kTitleSize,
        fontWeight: FontWeight.w600,
        color: t.text,
      ),
      displaySmall: TextStyle(
        fontSize: kDisplaySize,
        fontWeight: FontWeight.w600,
        color: t.text,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: t.bg,
      foregroundColor: t.text,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: t.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: t.surface,
      indicatorColor: t.accent.withValues(alpha: 0.15),
      height: 64,
    ),
    materialTapTargetSize: MaterialTapTargetSize.padded,
  );
}
