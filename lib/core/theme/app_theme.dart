import 'package:flutter/material.dart';

import 'tokens.dart';

/// Minimum tap target from spec 4.1.
const double kMinTapTarget = 48;

/// The app's typeface: Plus Jakarta Sans, bundled (assets/fonts).
const String kFontFamily = 'PlusJakartaSans';

/// Text scale (reference screens): display for big numbers, headline for
/// screen greetings, title for screen titles, heading for section titles,
/// then body and small.
const double kBodySize = 15;
const double kTitleSize = 22;
const double kDisplaySize = 40;

ThemeData buildTheme(Brightness brightness) {
  final t = brightness == Brightness.dark ? AppTokens.dark : AppTokens.light;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: t.accent,
        brightness: brightness,
      ).copyWith(
        primary: t.accent,
        onPrimary: Colors.white,
        surface: t.surface,
        onSurface: t.text,
        surfaceContainerHighest: t.track,
        outline: t.border,
        outlineVariant: t.border,
      );

  TextStyle style(double size, FontWeight w, Color c, {double? height}) =>
      TextStyle(
        fontFamily: kFontFamily,
        fontSize: size,
        fontWeight: w,
        color: c,
        height: height,
      );

  final textTheme = TextTheme(
    displaySmall: style(kDisplaySize, FontWeight.w600, t.text),
    headlineMedium: style(28, FontWeight.w600, t.text),
    headlineSmall: style(24, FontWeight.w600, t.text),
    titleLarge: style(kTitleSize, FontWeight.w600, t.text),
    titleMedium: style(17, FontWeight.w600, t.text),
    titleSmall: style(15, FontWeight.w600, t.text),
    bodyLarge: style(16, FontWeight.w400, t.text, height: 1.4),
    bodyMedium: style(kBodySize, FontWeight.w400, t.text, height: 1.4),
    bodySmall: style(13, FontWeight.w400, t.textMuted, height: 1.35),
    labelLarge: style(15, FontWeight.w600, t.text),
    labelMedium: style(12, FontWeight.w500, t.textMuted),
    labelSmall: style(11, FontWeight.w500, t.textMuted),
  );

  final fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: t.border),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: kFontFamily,
    scaffoldBackgroundColor: t.bg,
    canvasColor: t.bg,
    extensions: [t],
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    splashFactory: InkRipple.splashFactory,
    dividerTheme: DividerThemeData(color: t.border, thickness: 1, space: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: t.bg,
      foregroundColor: t.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      titleTextStyle: textTheme.titleLarge,
      iconTheme: IconThemeData(color: t.text),
    ),
    cardTheme: CardThemeData(
      color: t.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: t.border),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: t.textMuted,
      titleTextStyle: textTheme.titleSmall,
      subtitleTextStyle: textTheme.bodySmall,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: t.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      elevation: 0,
      height: 68,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          size: 25,
          color: s.contains(WidgetState.selected) ? t.accentDeep : t.textMuted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => style(
          11.5,
          s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          s.contains(WidgetState.selected) ? t.accentDeep : t.textMuted,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: t.accent,
        foregroundColor: Colors.white,
        disabledBackgroundColor: t.track,
        minimumSize: const Size(0, 52),
        textStyle: style(16, FontWeight.w600, Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: t.accentDeep,
        minimumSize: const Size(0, 52),
        side: BorderSide(color: t.accent.withValues(alpha: 0.45)),
        textStyle: style(16, FontWeight.w600, t.accentDeep),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: t.accentDeep,
        textStyle: style(15, FontWeight.w600, t.accentDeep),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        side: const WidgetStatePropertyAll(BorderSide.none),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.accentSoft : t.track,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.accentDeep : t.text,
        ),
        textStyle: WidgetStatePropertyAll(style(15, FontWeight.w600, t.text)),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? t.accent : t.border,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? t.accent : Colors.transparent,
      ),
      side: BorderSide(color: t.textMuted.withValues(alpha: 0.6), width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.surface,
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: t.accent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: t.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: textTheme.titleLarge,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: t.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: t.text,
      contentTextStyle: style(14, FontWeight.w500, t.bg),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: t.accent,
      linearTrackColor: t.track,
      circularTrackColor: t.track,
    ),
    materialTapTargetSize: MaterialTapTargetSize.padded,
  );
}
