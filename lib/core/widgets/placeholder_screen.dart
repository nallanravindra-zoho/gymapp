import 'package:flutter/material.dart';

import '../theme/section_theme.dart';
import '../theme/tokens.dart';

/// Temporary body for tabs whose features land in later build steps.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.note,
    this.section = AppSection.neutral,
  });

  final String title;
  final String note;
  final AppSection section;

  @override
  Widget build(BuildContext context) {
    return SectionTheme(
      section: section,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(title), actions: const [_AvatarButton()]),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              note,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: context.tokens.textMuted),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        tooltip: 'Profile and settings',
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        icon: CircleAvatar(
          radius: 14,
          backgroundColor: context.tokens.accent.withValues(alpha: 0.15),
          child: Icon(
            Icons.person_outline,
            size: 18,
            color: context.tokens.accent,
          ),
        ),
        onPressed: () {},
      ),
    );
  }
}
