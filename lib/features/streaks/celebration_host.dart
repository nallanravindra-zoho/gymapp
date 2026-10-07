import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import 'streak_providers.dart';

/// Shows queued milestone lines one at a time as a small card that fades in
/// and out at the top of the screen: one line of text, no confetti.
/// Animation is skipped when the system asks to reduce motion.
class CelebrationHost extends ConsumerStatefulWidget {
  const CelebrationHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<CelebrationHost> createState() => _CelebrationHostState();
}

class _CelebrationHostState extends ConsumerState<CelebrationHost> {
  static const _visibleFor = Duration(seconds: 3);

  String? _message;
  bool _visible = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _maybeShowNext() {
    if (_message != null) return;
    final queue = ref.read(celebrationQueueProvider);
    if (queue.isEmpty) return;
    setState(() {
      _message = queue.first;
      _visible = true;
    });
    ref.read(celebrationQueueProvider.notifier).removeFirst();
    _timer = Timer(_visibleFor, () {
      if (!mounted) return;
      setState(() => _visible = false);
      // Let the fade-out finish before the next message.
      _timer = Timer(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() => _message = null);
        _maybeShowNext();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(celebrationQueueProvider, (_, _) => _maybeShowNext());
    final t = context.tokens;
    final reduce = MediaQuery.disableAnimationsOf(context);

    return Stack(
      children: [
        widget.child,
        if (_message != null)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 16,
            right: 16,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: reduce
                    ? Duration.zero
                    : const Duration(milliseconds: 250),
                child: Semantics(
                  liveRegion: true,
                  child: Material(
                    color: t.surface,
                    elevation: 2,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_fire_department_outlined,
                            color: t.accent,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _message!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
