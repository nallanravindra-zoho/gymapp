import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/account/account_screen.dart';
import '../../features/streaks/streak_providers.dart';
import '../theme/tokens.dart';

/// Avatar at top right that opens Profile and Settings (spec section 5).
/// Shows the person's initial, or a person glyph until a name is set.
class AvatarButton extends ConsumerWidget {
  const AvatarButton({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final user = ref.watch(userStreamProvider).value;
    final name = user?.displayName.trim() ?? '';
    final photo = user?.avatarUrl;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Semantics(
        button: true,
        label: 'Profile and settings',
        child: Tooltip(
          message: 'Profile and settings',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AccountScreen()),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: Center(
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.cat(Cat.leaf).tint,
                    border: Border.all(color: t.surface, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A1B2B45),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  clipBehavior: Clip.antiAlias,
                  child: photo != null && photo.isNotEmpty
                      ? Image.file(
                          File(photo),
                          width: size,
                          height: size,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _initial(t, name),
                        )
                      : _initial(t, name),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _initial(AppTokens t, String name) => name.isEmpty
      ? Icon(
          Icons.person_rounded,
          size: size * 0.55,
          color: t.cat(Cat.leaf).icon,
        )
      : Text(
          name.characters.first.toUpperCase(),
          style: TextStyle(
            fontSize: size * 0.42,
            fontWeight: FontWeight.w700,
            color: t.cat(Cat.leaf).icon,
          ),
        );
}
