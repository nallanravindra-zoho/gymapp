import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/section_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/providers.dart';
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

    if (timer == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final type = types.where((x) => x.id == timer.workoutTypeId).firstOrNull;
    final elapsed = timer.elapsed(ref.read(clockProvider).now());
    final notifier = ref.read(activeTimerProvider.notifier);

    return SectionTheme(
      section: AppSection.workout,
      child: Scaffold(
        backgroundColor: t.accent.withValues(alpha: 0.08),
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                CircleAvatar(
                  radius: 36,
                  backgroundColor: t.accent.withValues(alpha: 0.15),
                  child: Icon(
                    workoutIcon(type?.iconKey ?? 'other'),
                    size: 36,
                    color: t.accent,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  type?.name ?? 'Workout',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  timer.isPaused ? 'Paused' : 'In progress',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 32),
                Semantics(
                  liveRegion: false,
                  label: 'Elapsed ${formatElapsed(elapsed)}',
                  child: Text(
                    formatElapsed(elapsed),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 56,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filled(
                      iconSize: 36,
                      constraints: const BoxConstraints(
                        minWidth: 72,
                        minHeight: 72,
                      ),
                      tooltip: timer.isPaused ? 'Resume' : 'Pause',
                      onPressed: timer.isPaused
                          ? notifier.resume
                          : notifier.pause,
                      icon: Icon(
                        timer.isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                      ),
                    ),
                    const SizedBox(width: 24),
                    IconButton.outlined(
                      iconSize: 32,
                      constraints: const BoxConstraints(
                        minWidth: 72,
                        minHeight: 72,
                      ),
                      tooltip: 'Stop and save',
                      onPressed: _stop,
                      icon: const Icon(Icons.stop_rounded),
                    ),
                  ],
                ),
                const Spacer(),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(kMinTapTarget),
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
