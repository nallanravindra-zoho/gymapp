import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Avatar at top right that opens Profile and Settings (spec section 5).
class AvatarButton extends StatelessWidget {
  const AvatarButton({super.key});

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
