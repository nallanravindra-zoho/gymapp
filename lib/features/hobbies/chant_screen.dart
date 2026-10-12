import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/dialogs.dart';
import 'chant_controller.dart';
import 'chant_logic.dart';

/// Om chanting: the phone listens and counts each chant, with a reminder at
/// every checkpoint.
class ChantScreen extends ConsumerWidget {
  const ChantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(chantControllerProvider);
    final c = ref.read(chantControllerProvider.notifier);
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    final upcoming = nextMilestone(s.count, s.milestones);
    final progress = (s.count / s.settings.target).clamp(0.0, 1.0);

    final status = switch (s.phase) {
      ChantPhase.calibrating => 'Getting used to the room noise',
      ChantPhase.listening => 'Listening',
      ChantPhase.complete => '${s.settings.target} complete',
      ChantPhase.idle => s.count == 0 ? 'Ready when you are' : 'Paused',
    };
    final primary = switch (s.phase) {
      ChantPhase.calibrating || ChantPhase.listening => 'Pause',
      ChantPhase.complete => 'Start again',
      ChantPhase.idle => s.count > 0 ? 'Resume' : 'Start',
    };

    Future<void> onPrimary() async {
      if (s.active) {
        await c.pause();
      } else if (s.phase == ChantPhase.complete) {
        await c.reset();
        await c.start();
      } else {
        await c.start();
      }
    }

    Future<void> onReset() async {
      if (s.count == 0) return c.reset();
      final ok = await confirm(
        context,
        title: 'Restart the count?',
        body: 'This clears the current count of ${s.count}.',
        action: 'Restart',
      );
      if (ok) await c.reset();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Om chanting'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Chant settings',
            constraints: const BoxConstraints(
              minWidth: kMinTapTarget,
              minHeight: kMinTapTarget,
            ),
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (_) => const _ChantSettingsSheet(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Semantics(
                          label: '${s.count} of ${s.settings.target} chants',
                          excludeSemantics: true,
                          child: Text(
                            '${s.count}',
                            style: text.displaySmall?.copyWith(
                              fontSize: 96,
                              height: 1.05,
                              color: t.accentDeep,
                            ),
                          ),
                        ),
                        Text(
                          'of ${s.settings.target}',
                          style: text.titleMedium?.copyWith(color: t.textMuted),
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: t.track,
                            color: t.accent,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(status, style: text.titleMedium),
                        if (s.active) ...[
                          const SizedBox(height: 14),
                          _LevelMeter(level: s.level, threshold: s.threshold),
                        ],
                        if (s.phase != ChantPhase.complete &&
                            upcoming != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Next reminder at $upcoming',
                            style: text.bodySmall,
                          ),
                        ],
                        if (s.micDenied)
                          const _Notice(
                            'Microphone access is needed to count chants. '
                            'Allow it in the phone settings for this app.',
                          ),
                        if (s.error != null) _Notice(s.error!),
                      ],
                    ),
                  ),
                ),
              ),
              FilledButton(onPressed: onPrimary, child: Text(primary)),
              const SizedBox(height: 10),
              OutlinedButton(onPressed: onReset, child: const Text('Reset')),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: SoftCard(
      color: context.tokens.mint,
      child: Text(message, textAlign: TextAlign.center),
    ),
  );
}

/// The live sound level with a marker where a sound starts to count.
class _LevelMeter extends StatelessWidget {
  const _LevelMeter({required this.level, required this.threshold});
  final double level;
  final double threshold;

  static double _fraction(double db) =>
      ((db.clamp(-60, 0) + 60) / 60).toDouble();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ExcludeSemantics(
      child: SizedBox(
        height: 16,
        child: LayoutBuilder(
          builder: (context, box) => Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: t.track,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              Container(
                height: 10,
                width: box.maxWidth * _fraction(level),
                decoration: BoxDecoration(
                  color: t.accent,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              Positioned(
                left: box.maxWidth * _fraction(threshold),
                child: Container(
                  width: 2,
                  height: 16,
                  color: t.text.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChantSettingsSheet extends ConsumerStatefulWidget {
  const _ChantSettingsSheet();

  @override
  ConsumerState<_ChantSettingsSheet> createState() => _SheetState();
}

class _SheetState extends ConsumerState<_ChantSettingsSheet> {
  late final TextEditingController _target;
  late final TextEditingController _interval;

  @override
  void initState() {
    super.initState();
    final s = ref.read(chantControllerProvider).settings;
    _target = TextEditingController(text: '${s.target}');
    _interval = TextEditingController(text: '${s.interval}');
  }

  @override
  void dispose() {
    _target.dispose();
    _interval.dispose();
    super.dispose();
  }

  void _save(ChantSettings current) {
    final target = int.tryParse(_target.text.trim());
    final interval = int.tryParse(_interval.text.trim());
    ref
        .read(chantControllerProvider.notifier)
        .updateSettings(
          current.copyWith(
            target: target != null && target >= 1 ? target : null,
            interval: interval != null && interval >= 1 ? interval : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(chantControllerProvider).settings;
    final c = ref.read(chantControllerProvider.notifier);
    final text = Theme.of(context).textTheme;
    final marks = chantMilestones(s.interval, s.target);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chant settings', style: text.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _target,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Total chants',
                    ),
                    onChanged: (_) => _save(s),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _interval,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Remind every',
                    ),
                    onChanged: (_) => _save(s),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Reminders at: ${marks.join(', ')}', style: text.bodySmall),
            const SizedBox(height: 18),
            Text('Reminder style', style: text.titleSmall),
            const SizedBox(height: 8),
            PillTabs<ReminderMode>(
              options: const {
                ReminderMode.voice: 'Spoken number',
                ReminderMode.chime: 'Chime and vibration',
              },
              selected: s.mode,
              onChanged: (m) => c.updateSettings(s.copyWith(mode: m)),
            ),
            const SizedBox(height: 18),
            Text('Microphone sensitivity', style: text.titleSmall),
            const SizedBox(height: 6),
            RadioGroup<double?>(
              groupValue: s.sensitivity,
              onChanged: (v) => c.updateSettings(
                v == null ? s.copyWith(auto: true) : s.copyWith(sensitivity: v),
              ),
              child: Column(
                children: [
                  for (final (label, value) in kSensitivityPresets)
                    RadioListTile<double?>(
                      contentPadding: EdgeInsets.zero,
                      minTileHeight: kMinTapTarget,
                      title: Text(label),
                      value: value,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Auto listens to the room for a moment each time you press '
              'Start. If counts are missed or extra, try a fixed setting.',
              style: text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
