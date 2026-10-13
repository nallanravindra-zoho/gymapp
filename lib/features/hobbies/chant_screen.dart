import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/dialogs.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../habits/habit_providers.dart';
import 'chant_controller.dart';
import 'chant_logic.dart';
import 'chant_save.dart';
import 'hobby_providers.dart';
import 'hobby_timer.dart';

/// Om chanting. First release: set a target, tap Start, then tap the large
/// +1 for each completed chant. Elapsed time and the count are shown, and a
/// gentle ping plays when the target is reached. Counting by listening is an
/// optional mode in the settings.
class ChantScreen extends ConsumerStatefulWidget {
  const ChantScreen({super.key});

  @override
  ConsumerState<ChantScreen> createState() => _ChantScreenState();
}

class _ChantScreenState extends ConsumerState<ChantScreen> {
  Timer? _tick;
  bool _logToHabit = true;
  String? _hobbyId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && ref.read(chantControllerProvider).runningSince != null) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _save(ChantSummary summary) async {
    setState(() => _saving = true);
    final user = await ref.read(currentUserProvider.future);
    final habit = _logToHabit
        ? findChantingHabit(ref.read(activeHabitsProvider).value ?? const [])
        : null;
    final result = await saveChantSession(
      summary: summary,
      userId: user.id,
      dayCutoffMinutes: user.dayCutoffMinutes,
      habits: ref.read(habitRepositoryProvider),
      hobbies: ref.read(hobbyRepositoryProvider),
      habit: habit,
      hobbyId: _hobbyId,
    );
    await ref.read(chantControllerProvider.notifier).reset();
    if (!mounted) return;
    setState(() {
      _saving = false;
      _hobbyId = null;
    });
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            result.savedAnything ? 'Session saved.' : 'Session not saved.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(chantControllerProvider);
    final c = ref.read(chantControllerProvider.notifier);
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    final now = ref.read(chantNowProvider)();
    final elapsed = s.elapsed(now);
    final target = s.settings.target;
    final progress = (s.count / target).clamp(0.0, 1.0);
    final upcoming = nextMilestone(s.count, s.milestones);
    final started = s.startedAt != null;
    final reached = s.count >= target;

    final status = switch (s.phase) {
      ChantPhase.calibrating => 'Getting used to the room noise',
      ChantPhase.listening => 'Listening',
      ChantPhase.running => 'Chanting',
      ChantPhase.complete => reached ? '$target reached' : 'Finished',
      ChantPhase.idle => !started ? 'Ready when you are' : 'Paused',
    };

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

    final summary = s.summary(now);
    final habit = findChantingHabit(
      ref.watch(activeHabitsProvider).value ?? const [],
    );
    final hobbies = ref.watch(activeHobbiesProvider).value ?? const <Hobby>[];

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
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            Center(
              child: Semantics(
                label: '${s.count} of $target chants',
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
            ),
            Center(
              child: Text(
                'of $target',
                style: text.titleMedium?.copyWith(color: t.textMuted),
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: t.track,
                color: t.accent,
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Semantics(
                label: 'Elapsed time ${formatElapsed(elapsed)}',
                excludeSemantics: true,
                child: Text(formatElapsed(elapsed), style: text.headlineSmall),
              ),
            ),
            const SizedBox(height: 4),
            Center(child: Text(status, style: text.titleMedium)),
            if (s.active) ...[
              const SizedBox(height: 14),
              _LevelMeter(level: s.level, threshold: s.threshold),
            ],
            if (s.settings.micMode &&
                s.phase != ChantPhase.complete &&
                upcoming != null) ...[
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Next reminder at $upcoming',
                  style: text.bodySmall,
                ),
              ),
            ],
            if (s.micDenied)
              const _Notice(
                'Microphone access is needed to count by listening. Allow it '
                'in the phone settings for this app, or switch to tapping.',
              ),
            if (s.error != null) _Notice(s.error!),
            const SizedBox(height: 20),
            if (s.phase == ChantPhase.complete && summary != null)
              _SaveCard(
                summary: summary,
                habitName: habit?.name,
                logToHabit: _logToHabit,
                onLogToHabit: (v) => setState(() => _logToHabit = v),
                hobbies: hobbies,
                hobbyId: _hobbyId,
                onHobby: (v) => setState(() => _hobbyId = v),
                saving: _saving,
                onSave: () => _save(summary),
                onDiscard: c.reset,
                onUndo: c.decrement,
              )
            else ...[
              if (s.counting)
                Center(
                  child: Semantics(
                    button: true,
                    label: 'Add one chant',
                    excludeSemantics: true,
                    child: SizedBox(
                      width: 168,
                      height: 168,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          c.increment();
                        },
                        child: const Text(
                          '+1',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (!s.counting && !started) ...[
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    for (final n in const [27, 54, 108])
                      ChoiceChip(
                        label: Text('$n'),
                        selected: target == n,
                        onSelected: (_) =>
                            c.updateSettings(s.settings.copyWith(target: n)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'Target: $target chants. Change it in settings.',
                    style: text.bodySmall,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (s.counting) const SizedBox(height: 16),
              if (s.counting)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, kMinTapTarget),
                        ),
                        onPressed: s.count > 0 ? c.decrement : null,
                        child: const Text('Undo one'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, kMinTapTarget),
                        ),
                        onPressed: c.pause,
                        child: const Text('Pause'),
                      ),
                    ),
                  ],
                )
              else ...[
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(kMinTapTarget),
                  ),
                  onPressed: c.start,
                  child: Text(started ? 'Resume' : 'Start'),
                ),
                if (started && s.count > 0) ...[
                  const SizedBox(height: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(kMinTapTarget),
                    ),
                    onPressed: c.decrement,
                    child: const Text('Undo one'),
                  ),
                ],
              ],
              if (started) ...[
                const SizedBox(height: 10),
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(kMinTapTarget),
                  ),
                  onPressed: c.finish,
                  child: const Text('Finish'),
                ),
                const SizedBox(height: 6),
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(kMinTapTarget),
                  ),
                  onPressed: onReset,
                  child: const Text('Reset'),
                ),
              ],
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// After a session: choose where to save it.
class _SaveCard extends StatelessWidget {
  const _SaveCard({
    required this.summary,
    required this.habitName,
    required this.logToHabit,
    required this.onLogToHabit,
    required this.hobbies,
    required this.hobbyId,
    required this.onHobby,
    required this.saving,
    required this.onSave,
    required this.onDiscard,
    required this.onUndo,
  });

  final ChantSummary summary;
  final String? habitName;
  final bool logToHabit;
  final ValueChanged<bool> onLogToHabit;
  final List<Hobby> hobbies;
  final String? hobbyId;
  final ValueChanged<String?> onHobby;
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onDiscard;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Save this session?', style: text.titleMedium),
          const SizedBox(height: 4),
          Text(
            '${summary.count} ${summary.count == 1 ? 'chant' : 'chants'} in '
            '${formatElapsed(summary.elapsed)}',
            style: text.bodyMedium,
          ),
          const SizedBox(height: 8),
          if (habitName != null)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Add to $habitName habit'),
              subtitle: Text('Logs ${summary.count} for today'),
              value: logToHabit,
              onChanged: onLogToHabit,
            )
          else
            Text(
              'Add a habit called Chanting in Healthy Habits to log '
              'sessions there too.',
              style: text.bodySmall,
            ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            initialValue: hobbyId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Also log as hobby time',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Not as a hobby'),
              ),
              for (final h in hobbies)
                DropdownMenuItem<String?>(value: h.id, child: Text(h.name)),
            ],
            onChanged: onHobby,
          ),
          const SizedBox(height: 14),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(kMinTapTarget),
            ),
            onPressed: saving ? null : onSave,
            child: const Text('Save session'),
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, kMinTapTarget),
                  ),
                  onPressed: onUndo,
                  child: const Text('Undo one'),
                ),
              ),
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, kMinTapTarget),
                  ),
                  onPressed: onDiscard,
                  child: const Text('Discard'),
                ),
              ),
            ],
          ),
        ],
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
            TextField(
              controller: _target,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total chants'),
              onChanged: (_) => _save(s),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Count by listening'),
              subtitle: const Text(
                'Optional. Uses the microphone only while a session runs. '
                'Sound is measured live and never saved.',
              ),
              value: s.micMode,
              onChanged: (v) => c.updateSettings(s.copyWith(micMode: v)),
            ),
            if (s.micMode) ...[
              TextField(
                controller: _interval,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Remind every'),
                onChanged: (_) => _save(s),
              ),
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
                  v == null
                      ? s.copyWith(auto: true)
                      : s.copyWith(sensitivity: v),
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
          ],
        ),
      ),
    );
  }
}
