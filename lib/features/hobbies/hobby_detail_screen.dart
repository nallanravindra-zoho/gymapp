import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/durations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/time/local_date.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/app_database.dart';
import 'hobby_log_screen.dart';
import 'hobby_logic.dart';
import 'hobby_providers.dart';
import 'hobby_timer.dart';
import '../week/week_providers.dart';

/// One hobby: goal progress, a timer, manual logging, and recent logs to edit
/// or delete.
class HobbyDetailScreen extends ConsumerWidget {
  const HobbyDetailScreen({super.key, required this.hobby});

  final Hobby hobby;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref
        .watch(activeHobbiesProvider)
        .value
        ?.where((h) => h.id == hobby.id)
        .firstOrNull;
    final h = live ?? hobby;
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    final today = ref.watch(todayDateProvider).value;
    final acts = ref.watch(hobbyActivitiesProvider);
    final goal = HobbyGoal.of(h);
    final streak = ref.watch(hobbyStreaksByHobbyProvider)[h.id];
    final logs = [
      for (final l
          in ref.watch(allHobbyLogsProvider).value ?? const <HobbyLog>[])
        if (l.hobbyId == h.id) l,
    ]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final timer = ref.watch(hobbyTimerProvider);
    final thisTimer = timer?.hobbyId == h.id;

    Future<void> stop() async {
      final r = ref.read(hobbyTimerProvider.notifier).stop();
      if (r == null) return;
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => HobbyLogScreen(
            hobby: h,
            timerStart: r.startedAt,
            timerEnd: r.endedAt,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(h.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (goal != null && today != null) ...[
            _GoalCard(
              progress: hobbyProgress(
                goal: goal,
                activities: acts,
                hobbyId: h.id,
                today: today,
              ),
              streakLabel: streak?.label ?? '',
            ),
            const SizedBox(height: 12),
          ] else
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'No goal set. You can add one from Manage.',
                style: text.bodyMedium?.copyWith(color: t.textMuted),
              ),
            ),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (thisTimer) ...[
                  Center(
                    child: _Elapsed(
                      since: timer!.startedAt,
                      style: text.displaySmall,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(kMinTapTarget),
                    ),
                    onPressed: stop,
                    child: const Text('Stop and save'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(kMinTapTarget),
                    ),
                    onPressed: () =>
                        ref.read(hobbyTimerProvider.notifier).discard(),
                    child: const Text('Discard timer'),
                  ),
                ] else ...[
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(kMinTapTarget),
                    ),
                    onPressed: timer != null
                        ? null
                        : () =>
                              ref.read(hobbyTimerProvider.notifier).start(h.id),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start timer'),
                  ),
                  if (timer != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Another hobby timer is running.',
                        style: text.bodySmall,
                      ),
                    ),
                ],
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(kMinTapTarget),
                  ),
                  onPressed: () => Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => HobbyLogScreen(hobby: h)),
                  ),
                  icon: const Icon(Icons.edit_calendar_rounded),
                  label: const Text('Add time manually'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Recent', style: text.titleMedium),
          const SizedBox(height: 6),
          if (logs.isEmpty)
            Text(
              'Nothing logged yet. Whenever you are ready.',
              style: text.bodyMedium?.copyWith(color: t.textMuted),
            )
          else
            for (final l in logs.take(30)) _LogRow(hobby: h, log: l),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.progress, required this.streakLabel});

  final HobbyProgress progress;
  final String streakLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Goal: ${progress.goal.describe()}',
                  style: text.titleSmall,
                ),
              ),
              DoneMark(done: progress.met, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.fraction,
              minHeight: 10,
              backgroundColor: t.track,
              color: t.accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(progress.describe(), style: text.bodyMedium),
          if (streakLabel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(streakLabel, style: text.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.hobby, required this.log});

  final Hobby hobby;
  final HobbyLog log;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    final d = parseLocalDate(log.localDate);
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final when = '${months[d.month - 1]} ${d.day}';
    final sessions = log.countOrSessions > 1
        ? ', ${log.countOrSessions} sessions'
        : '';
    final note = (log.note ?? '').trim();
    return Semantics(
      button: true,
      label: 'Edit log, $when, ${durationShort(log.durationMinutes)}',
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => HobbyLogScreen(hobby: hobby, existing: log),
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: ExcludeSemantics(
            child: Row(
              children: [
                SizedBox(width: 64, child: Text(when, style: text.bodyMedium)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${durationShort(log.durationMinutes)}$sessions',
                        style: text.titleSmall,
                      ),
                      if (note.isNotEmpty)
                        Text(
                          note,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall?.copyWith(color: t.textMuted),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: t.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Elapsed time since [since], redrawn each second from the clock.
class _Elapsed extends ConsumerStatefulWidget {
  const _Elapsed({required this.since, this.style});
  final DateTime since;
  final TextStyle? style;

  @override
  ConsumerState<_Elapsed> createState() => _ElapsedState();
}

class _ElapsedState extends ConsumerState<_Elapsed> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = ref.read(hobbyTimerNowProvider)();
    final text = formatElapsed(now.difference(widget.since));
    return Semantics(
      label: 'Elapsed $text',
      child: ExcludeSemantics(child: Text(text, style: widget.style)),
    );
  }
}
