import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/time/local_date.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/providers.dart';
import '../hobbies/chant_controller.dart' show chantPlatformProvider;
import '../hobbies/chant_platform.dart' show ChantPlatform;
import '../hobbies/chant_logic.dart' show ReminderMode;
import '../week/week_providers.dart';
import 'meditation_logic.dart';

/// The time source for the meditation timer. Tests replace it.
final meditationNowProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

/// Minutes meditated in the week on screen, for the quiet line under Start.
final meditationWeekMinutesProvider = StreamProvider<int>((ref) async* {
  final start = ref.watch(weekStartProvider);
  if (start == null) return;
  final user = await ref.watch(currentUserProvider.future);
  yield* ref
      .watch(meditationRepositoryProvider)
      .watchBetween(user.id, start, shiftLocalDate(start, 6))
      .map(
        (rows) => rows.fold<int>(0, (sum, r) => sum + r.durationSeconds) ~/ 60,
      );
});

enum _Phase { choose, running, done }

/// A calm place to sit for a while. The length is chosen each time; there is
/// no goal to set up first.
class MeditationScreen extends ConsumerStatefulWidget {
  const MeditationScreen({super.key});

  @override
  ConsumerState<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends ConsumerState<MeditationScreen> {
  _Phase _phase = _Phase.choose;
  int _minutes = 10;
  bool _custom = false;
  DateTime? _startedAt;
  Timer? _ticker;
  MeditationOutcome? _outcome;
  ChantPlatform? _platform;

  @override
  void dispose() {
    _ticker?.cancel();
    // `ref` cannot be read once the widget is going away, so the platform
    // kept at the start is used to let the screen sleep again.
    if (_phase == _Phase.running) _platform?.keepAwake(false);
    super.dispose();
  }

  Duration get _elapsed => _startedAt == null
      ? Duration.zero
      : ref.read(meditationNowProvider)().difference(_startedAt!);

  Future<void> _start() async {
    _startedAt = ref.read(meditationNowProvider)();
    setState(() => _phase = _Phase.running);
    final platform = ref.read(chantPlatformProvider);
    _platform = platform;
    unawaited(platform.keepAwake(true));
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (remainingSeconds(_minutes, _elapsed) == 0) {
        _finish();
      } else {
        setState(() {});
      }
    });
  }

  Future<void> _finish() async {
    if (_phase != _Phase.running) return;
    _ticker?.cancel();
    final outcome = outcomeOf(plannedMinutes: _minutes, elapsed: _elapsed);
    final platform = ref.read(chantPlatformProvider);
    unawaited(platform.keepAwake(false));
    setState(() {
      _phase = _Phase.done;
      _outcome = outcome;
    });
    if (outcome.completed) {
      unawaited(platform.announce(ReminderMode.chime, 1, isFinal: true));
    }
    if (outcome.saved) {
      final user = await ref.read(currentUserProvider.future);
      await ref
          .read(meditationRepositoryProvider)
          .add(
            userId: user.id,
            dayCutoffMinutes: user.dayCutoffMinutes,
            startedAt: _startedAt!,
            plannedMinutes: _minutes,
            durationSeconds: outcome.seconds,
            completed: outcome.completed,
          );
    }
  }

  Future<bool> _confirmEnd() async {
    final end = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End this session?'),
        content: const Text('Time so far is saved if it was a minute or more.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('End session'),
          ),
        ],
      ),
    );
    return end ?? false;
  }

  Future<void> _pickCustom() async {
    final controller = TextEditingController(text: _custom ? '$_minutes' : '');
    final value = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Custom length'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Minutes',
            helperText: 'Between 1 and $meditationMaxMinutes',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final v = int.tryParse(controller.text.trim());
              if (v != null && v >= 1 && v <= meditationMaxMinutes) {
                Navigator.pop(ctx, v);
              }
            },
            child: const Text('Use'),
          ),
        ],
      ),
    );
    if (value != null) {
      setState(() {
        _minutes = value;
        _custom = !meditationQuickMinutes.contains(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    final topInset = MediaQuery.paddingOf(context).top;

    return PopScope(
      canPop: _phase != _Phase.running,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmEnd()) await _finish();
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            HillsHeader(
              height: 200 + topInset,
              child: Padding(
                padding: EdgeInsets.fromLTRB(8, topInset + 4, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Text('Meditation', style: text.titleLarge),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              child: switch (_phase) {
                _Phase.choose => _choose(text, t),
                _Phase.running => _running(text, t),
                _Phase.done => _done(text, t),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _choose(TextTheme text, AppTokens t) {
    final week = ref.watch(meditationWeekMinutesProvider).value ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Find your calm',
          style: text.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'A few minutes each day can make a difference.',
          style: text.bodyMedium?.copyWith(color: t.textMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            for (final m in meditationQuickMinutes) ...[
              Expanded(
                child: _DurationChip(
                  label: '$m min',
                  selected: !_custom && _minutes == m,
                  onTap: () => setState(() {
                    _minutes = m;
                    _custom = false;
                  }),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: _DurationChip(
                label: _custom ? '$_minutes min' : 'Custom',
                selected: _custom,
                onTap: _pickCustom,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton(onPressed: _start, child: const Text('Start')),
        if (week > 0) ...[
          const SizedBox(height: 14),
          Text(
            '$week min this week',
            style: text.bodySmall?.copyWith(color: t.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _running(TextTheme text, AppTokens t) {
    final left = remainingSeconds(_minutes, _elapsed);
    final progress = 1 - left / (_minutes * 60);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Semantics(
            liveRegion: false,
            label: '${clockText(left)} remaining',
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                      backgroundColor: t.track,
                      color: t.accent,
                    ),
                  ),
                  ExcludeSemantics(
                    child: Text(clockText(left), style: text.displayMedium),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Breathe slowly. Let thoughts pass.',
          style: text.bodyMedium?.copyWith(color: t.textMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () async {
            if (await _confirmEnd()) await _finish();
          },
          child: const Text('End session'),
        ),
      ],
    );
  }

  Widget _done(TextTheme text, AppTokens t) {
    final o = _outcome!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          o.completed ? Icons.check_circle_outline_rounded : Icons.spa_outlined,
          size: 56,
          color: t.accent,
        ),
        const SizedBox(height: 12),
        Text(
          o.completed ? 'Session complete' : 'Session ended',
          style: text.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          o.message,
          style: text.bodyMedium?.copyWith(color: t.textMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text('Done'),
        ),
        TextButton(
          onPressed: () => setState(() {
            _phase = _Phase.choose;
            _outcome = null;
          }),
          child: const Text('Meditate again'),
        ),
      ],
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: ExcludeSemantics(
        child: SoftCard(
          onTap: onTap,
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: selected ? t.accentSoft : null,
          borderColor: selected ? t.accent : null,
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(color: selected ? t.accentDeep : t.text),
            ),
          ),
        ),
      ),
    );
  }
}
