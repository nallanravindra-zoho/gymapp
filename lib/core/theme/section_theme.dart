import 'package:flutter/material.dart';

enum AppSection { workout, sleep, hobby, neutral }

/// Kept so screens can still say which section they belong to, but every
/// section now shares the same calm look as the reference screens (spec 4.1
/// as revised on 10 October): one background, one type scale.
class SectionTheme extends StatelessWidget {
  const SectionTheme({super.key, required this.section, required this.child});

  final AppSection section;
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
