import 'package:flutter/material.dart';

import 'tokens.dart';

enum AppSection { workout, sleep, hobby, neutral }

/// Applies a section's identity (spec 4.1) on top of the base theme:
/// workout is bolder, sleep is calmer with a cool wash, hobby is warm.
/// Screens are shared; only this wrapper varies.
class SectionTheme extends StatelessWidget {
  const SectionTheme({super.key, required this.section, required this.child});

  final AppSection section;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final t = context.tokens;

    final (Color? wash, FontWeight weight, double spacing) = switch (section) {
      AppSection.workout => (null, FontWeight.w700, 1.0),
      AppSection.sleep => (t.tintSleep, FontWeight.w300, 1.25),
      AppSection.hobby => (t.tintHobby, FontWeight.w500, 1.1),
      AppSection.neutral => (null, FontWeight.w400, 1.0),
    };

    final themed = base.copyWith(
      scaffoldBackgroundColor: wash ?? base.scaffoldBackgroundColor,
      textTheme: base.textTheme.copyWith(
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          fontWeight: section == AppSection.neutral ? null : weight,
          height: spacing,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: section == AppSection.neutral ? null : weight,
        ),
      ),
    );

    return Theme(
      data: themed,
      child: ColoredBox(color: wash ?? Colors.transparent, child: child),
    );
  }
}
