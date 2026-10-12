import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/providers.dart';
import 'workout_calc.dart';
import 'workout_icons.dart';
import 'workout_providers.dart';
import 'workout_timer.dart';

/// Running timer (Start/Pause/Stop). Reads elapsed time from stored
/// timestamps, so it is correct after the app was closed.
class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => mounted ? setState(() {}) : null,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _stop() async {
    final types = ref.read(workoutTypesProvider).value ?? const [];
    final saved = await ref.read(activeTimerProvider.notifier).stopAndSave();
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    if (saved != null) {
      final name = types
          .where((t) => t.id == saved.workoutTypeId)
          .map((t) => t.name)
          .firstOrNull;
      messenger
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(loggedMessage(saved.minutes, name ?? 'workout')),
          ),
        );
    }
  }

  Future<void> _cancel() async {
    await ref.read(activeTimerProvider.notifier).cancel();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(activeTimerProvider).value;
    final types = ref.watch(workoutTypesProvider).value ?? const [];
    final t = context.tokens;
    final dark = Theme.of(context).brightness == Brightness.dark;

    if (timer == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final type = types.where((x) => x.id == timer.workoutTypeId).firstOrNull;
    final elapsed = timer.elapsed(ref.read(clockProvider).now());
    final notifier = ref.read(activeTimerProvider.notifier);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: dark
                ? const [Color(0xFF16231E), Color(0xFF1B2D26)]
                : const [Color(0xFFE9F6EE), Color(0xFFD3F0E1)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Column(
              children: [
                const SizedBox(height: 28),
                TintedIcon(
                  icon: workoutIcon(type?.iconKey ?? 'other'),
                  tint: dark
                      ? const Color(0xFF2C4A3D)
                      : const Color(0xFFBFE8D2),
                  color: dark
                      ? const Color(0xFF86DDA9)
                      : const Color(0xFF1D6D57),
                  size: 92,
                  iconSize: 48,
                ),
                const SizedBox(height: 16),
                Text(type?.name ?? 'Workout', style: text.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  timer.isPaused ? 'Paused' : 'In progress',
                  style: text.titleMedium?.copyWith(color: t.accent),
                ),
                if (tracksDistance(type?.iconKey)) ...[
                  const SizedBox(height: 6),
                  Text(
                    timer.stepBase != null
                        ? 'Counting steps with your phone'
                        : stepsUnavailable,
                    style: text.bodySmall?.copyWith(color: t.textMuted),
                  ),
                ],
                const SizedBox(height: 34),
                Semantics(
                  liveRegion: false,
                  label: 'Elapsed ${formatElapsed(elapsed)}',
                  child: Text(
                    formatElapsed(elapsed),
                    style: text.displaySmall?.copyWith(
                      fontSize: 60,
                      color: t.accentDeep,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(height: 38),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _RoundButton(
                      size: 88,
                      color: t.accent,
                      tooltip: timer.isPaused ? 'Resume' : 'Pause',
                      onPressed: timer.isPaused
                          ? notifier.resume
                          : notifier.pause,
                      child: Icon(
                        timer.isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 26),
                    _RoundButton(
                      size: 76,
                      color: t.surface,
                      tooltip: 'Stop and save',
                      onPressed: _stop,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: t.text,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SoftCard(
                  color: t.surface,
                  borderColor: Colors.transparent,
                  radius: 24,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Row(
                    children: [
                      const SproutIcon(size: 62),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("You've got this.", style: text.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                              'A little progress each day adds up to big results.',
                              style: text.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: _cancel,
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.size,
    required this.color,
    required this.tooltip,
    required this.onPressed,
    required this.child,
  });

  final double size;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: const [
              BoxShadow(
                color: Color(0x261B2B45),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: SizedBox(
                width: size,
                height: size,
                child: Center(child: ExcludeSemantics(child: child)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
