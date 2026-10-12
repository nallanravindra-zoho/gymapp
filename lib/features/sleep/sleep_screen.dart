import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/durations.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/providers.dart';
import 'sleep_log_sheet.dart';
import 'sleep_logic.dart';
import 'sleep_providers.dart';

String _fmt(BuildContext context, int minutes) =>
    TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60).format(context);

const _sunColor = Color(0xFFF2A33A);

/// Sleep: targets, last night, and how consistent the last week was. Manual
/// logging only (R6); the wind-down checklist is gone.
class SleepScreen extends ConsumerWidget {
  const SleepScreen({super.key});

  Future<void> _editTarget(
    BuildContext context,
    WidgetRef ref, {
    required bool bedtime,
  }) async {
    final t = ref.read(effectiveSleepTargetProvider);
    final current = bedtime ? t.bedtimeMinutes : t.wakeMinutes;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked == null) return;
    final minutes = picked.hour * 60 + picked.minute;
    final user = await ref.read(currentUserProvider.future);
    await ref
        .read(sleepRepositoryProvider)
        .setTarget(
          userId: user.id,
          bedtimeMinutes: bedtime ? minutes : t.bedtimeMinutes,
          wakeMinutes: bedtime ? t.wakeMinutes : minutes,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = ref.watch(effectiveSleepTargetProvider);
    final last = ref.watch(lastNightProvider);
    final consistency = ref.watch(sleepConsistencyProvider);
    final text = Theme.of(context).textTheme;
    final t = context.tokens;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          SoftCard(
            padding: const EdgeInsets.fromLTRB(18, 14, 12, 8),
            child: Column(
              children: [
                _TargetRow(
                  label: 'Target bedtime',
                  value: _fmt(context, target.bedtimeMinutes),
                  icon: Icons.nightlight_round,
                  iconColor: t.cat(Cat.sleep).icon,
                  onEdit: () => _editTarget(context, ref, bedtime: true),
                ),
                const RowDivider(),
                _TargetRow(
                  label: 'Wake up',
                  value: _fmt(context, target.wakeMinutes),
                  icon: Icons.wb_sunny_outlined,
                  iconColor: _sunColor,
                  onEdit: () => _editTarget(context, ref, bedtime: false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SoftCard(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Actual (last night)', style: text.titleSmall),
                const SizedBox(height: 14),
                if (last == null) ...[
                  Text(
                    'No sleep logged for last night.',
                    style: text.bodyMedium?.copyWith(color: t.textMuted),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: () => showSleepLogSheet(context),
                    child: const Text('Log sleep'),
                  ),
                ] else ...[
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _ActualTime(
                            icon: Icons.nightlight_round,
                            color: const Color(0xFF3B73C9),
                            label: 'Bedtime',
                            value: TimeOfDay.fromDateTime(
                              last.bedtimeAt.toLocal(),
                            ).format(context),
                          ),
                        ),
                        VerticalDivider(width: 24, color: t.border),
                        Expanded(
                          child: _ActualTime(
                            icon: Icons.wb_sunny_rounded,
                            color: _sunColor,
                            label: 'Wake up',
                            value: TimeOfDay.fromDateTime(last.wakeAt.toLocal())
                                .format(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Slept ${durationShort(last.durationMinutes)}',
                          style: text.bodyMedium?.copyWith(color: t.textMuted),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            showSleepLogSheet(context, existing: last),
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (consistency != null)
            SoftCard(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      ConsistencyRing(
                        fraction: consistency.days == 0
                            ? 0
                            : consistency.onSchedule / consistency.days,
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Consistency score',
                              style: text.bodyMedium?.copyWith(
                                color: t.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              consistencyLabel(consistency),
                              style: text.titleSmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      for (final v in consistency.byDate.values)
                        Expanded(
                          child: Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: v == true
                                    ? t.accent
                                    : Colors.transparent,
                                border: Border.all(
                                  color: v == null
                                      ? t.textMuted.withValues(alpha: 0.3)
                                      : t.accent,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TargetRow extends StatelessWidget {
  const _TargetRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.onEdit,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: text.bodyMedium?.copyWith(
                      color: context.tokens.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(icon, size: 24, color: iconColor),
                      const SizedBox(width: 14),
                      Text(
                        value,
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            TextButton(onPressed: onEdit, child: const Text('Edit')),
          ],
        ),
      ),
    );
  }
}

class _ActualTime extends StatelessWidget {
  const _ActualTime({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 30, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: text.bodyMedium?.copyWith(
                  color: context.tokens.textMuted,
                ),
              ),
              Text(
                value,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A ring with the share filled in and the percentage in the middle.
class ConsistencyRing extends StatelessWidget {
  const ConsistencyRing({super.key, required this.fraction, this.size = 88});

  final double fraction;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final f = fraction.clamp(0.0, 1.0);
    return Semantics(
      label: '${(f * 100).round()} percent',
      child: ExcludeSemantics(
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(f, t.accent, t.track),
            child: Center(
              child: Text(
                '${(f * 100).round()}%',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.fraction, this.color, this.track);

  final double fraction;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 9.0;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, base..color = track);
    if (fraction > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * fraction,
        false,
        base..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.color != color || old.track != track;
}
