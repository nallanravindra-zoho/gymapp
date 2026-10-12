import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/durations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/time/local_date.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/app_database.dart';
import '../habits/habits_screen.dart';
import '../week/week_providers.dart';
import 'screen_time_logic.dart';
import 'screen_time_providers.dart';

enum _Tab { today, week }

class ScreenTimeScreen extends ConsumerStatefulWidget {
  const ScreenTimeScreen({super.key});

  @override
  ConsumerState<ScreenTimeScreen> createState() => _ScreenTimeScreenState();
}

class _ScreenTimeScreenState extends ConsumerState<ScreenTimeScreen> {
  _Tab _tab = _Tab.today;

  @override
  Widget build(BuildContext context) {
    final access = ref.watch(screenTimeAccessProvider);

    return access.when(
      loading: () => Scaffold(appBar: _bar(context)),
      error: (_, _) => const _AccessExplanation(),
      data: (granted) => granted
          ? Scaffold(
              appBar: _bar(context),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: PillTabs<_Tab>(
                      options: const {_Tab.today: 'Today', _Tab.week: 'Week'},
                      selected: _tab,
                      onChanged: (v) => setState(() => _tab = v),
                    ),
                  ),
                  Expanded(
                    child: _tab == _Tab.today
                        ? const _TodayTab()
                        : const _WeekTab(),
                  ),
                ],
              ),
            )
          : const _AccessExplanation(),
    );
  }
}

AppBar _bar(BuildContext context) => AppBar(
  title: const Text('Screen Time'),
  leading: IconButton(
    tooltip: 'Back',
    icon: const Icon(Icons.arrow_back_rounded),
    onPressed: () => Navigator.maybePop(context),
  ),
);

/// Explains why access is needed before sending the user to system settings
/// (spec 8.1, section 9).
class _AccessExplanation extends ConsumerWidget {
  const _AccessExplanation();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: _bar(context),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Allow usage access', style: text.titleLarge),
            const SizedBox(height: 12),
            const Text(
              'Screen time reads how long apps are open, using Android\'s '
              'usage access setting.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Only daily totals are kept. App names stay on your phone, '
              'and nothing is shared with groups unless you turn it on.',
            ),
            const SizedBox(height: 12),
            Text(
              'In the next screen, choose Well-Being and switch on '
              'permission. Then come back here.',
              style: text.bodySmall,
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => ref.read(usageSourceProvider).openSettings(),
              child: const Text('Open settings'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Not now'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayTab extends ConsumerWidget {
  const _TodayTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final row = ref.watch(screenTimeTodayProvider);
    final goal = ref.watch(screenTimeGoalProvider).value;
    final total = row?.totalMinutes ?? 0;
    final categories = row == null
        ? const <MapEntry<String, int>>[]
        : categoriesOf(row);
    final text = Theme.of(context).textTheme;
    final t = context.tokens;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(screenTimeSyncProvider).sync();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          20,
          14,
          20,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          Text(
            durationShort(total),
            style: text.displaySmall?.copyWith(
              fontSize: 38,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total screen time',
                  style: text.bodyLarge?.copyWith(color: t.textMuted),
                ),
              ),
              if (goal != null)
                Text(
                  '(${goalLabel(goal)})',
                  style: text.bodyMedium?.copyWith(color: t.textMuted),
                ),
            ],
          ),
          if (goal != null) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (total / goal).clamp(0.0, 1.0),
                minHeight: 9,
                color: t.accent,
                backgroundColor: t.track,
              ),
            ),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(0, kMinTapTarget),
                padding: EdgeInsets.zero,
              ),
              onPressed: () => _editGoal(context, ref, goal),
              child: Text(goal == null ? 'Set a daily goal' : 'Change goal'),
            ),
          ),
          const RowDivider(),
          const SizedBox(height: 16),
          Text('By category', style: text.titleSmall),
          const SizedBox(height: 4),
          if (categories.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No screen time recorded yet today.',
                style: text.bodyMedium?.copyWith(color: t.textMuted),
              ),
            )
          else
            for (var i = 0; i < categories.length; i++) ...[
              if (i > 0) const RowDivider(indent: 66),
              _CategoryRow(
                category: categories[i].key,
                minutes: categories[i].value,
                percent: percentOf(categories[i].value, total),
              ),
            ],
          const SizedBox(height: 14),
          if (row != null && row.lateEveningMinutes > 0) ...[
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const TintedIcon(
                    icon: Icons.nights_stay_rounded,
                    cat: Cat.sleep,
                    size: 44,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Late evening', style: text.titleSmall),
                        Text('After 9 PM', style: text.bodySmall),
                      ],
                    ),
                  ),
                  Text(
                    durationShort(row.lateEveningMinutes),
                    style: text.titleSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (total > 0)
            SoftCard(
              color: t.cat(Cat.screen).tint.withValues(alpha: 0.55),
              borderColor: Colors.transparent,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const HabitsScreen()),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const TintedIcon(
                    icon: Icons.self_improvement_rounded,
                    tint: Color(0xFFBFE8C9),
                    color: Color(0xFF1D6D57),
                    size: 48,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Try a 10 min\nscreen break',
                      style: text.titleSmall,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: t.text),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _editGoal(
    BuildContext context,
    WidgetRef ref,
    int? current,
  ) async {
    final result = await showDialog<_GoalChoice>(
      context: context,
      builder: (_) => _GoalDialog(current: current),
    );
    if (result != null) {
      await ref.read(screenTimeGoalProvider.notifier).set(result.minutes);
    }
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.minutes,
    required this.percent,
  });

  final String category;
  final int minutes;
  final int percent;

  static (IconData, Color, Color) _style(String key) => switch (key) {
    'social' => (
      Icons.forum_rounded,
      const Color(0xFFF6D5F0),
      const Color(0xFF9B2FA0),
    ),
    'video' => (
      Icons.smart_display_rounded,
      const Color(0xFFFAD9D4),
      const Color(0xFFD13B2E),
    ),
    'browser' => (
      Icons.language_rounded,
      const Color(0xFFD1ECEE),
      const Color(0xFF1B7E96),
    ),
    'productivity' => (
      Icons.edit_note_rounded,
      const Color(0xFFD9E1F8),
      const Color(0xFF2D4EA6),
    ),
    'games' => (
      Icons.sports_esports_rounded,
      const Color(0xFFE3DAF5),
      const Color(0xFF5A3BA8),
    ),
    _ => (Icons.apps_rounded, const Color(0xFFE6E8EB), const Color(0xFF3C4F66)),
  };

  @override
  Widget build(BuildContext context) {
    final (icon, tint, color) = _style(category);
    final text = Theme.of(context).textTheme;
    return Semantics(
      label:
          '${categoryLabel(category)}, ${formatScreenTime(minutes)}, $percent percent',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              TintedIcon(
                icon: icon,
                tint: tint,
                color: color,
                size: 46,
                iconSize: 24,
                square: true,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(categoryLabel(category), style: text.bodyLarge),
              ),
              Text(durationCompact(minutes), style: text.bodyLarge),
              SizedBox(
                width: 52,
                child: Text(
                  '$percent%',
                  textAlign: TextAlign.end,
                  style: text.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalChoice {
  const _GoalChoice(this.minutes);
  final int? minutes;
}

class _GoalDialog extends StatelessWidget {
  const _GoalDialog({required this.current});
  final int? current;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Daily goal'),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final m in goalChoices)
            ChoiceChip(
              label: Text(formatScreenTime(m)),
              selected: current == m,
              onSelected: (_) => Navigator.pop(context, _GoalChoice(m)),
            ),
        ],
      ),
      actions: [
        if (current != null)
          TextButton(
            onPressed: () => Navigator.pop(context, const _GoalChoice(null)),
            child: const Text('No goal'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

const _short = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class _WeekTab extends ConsumerWidget {
  const _WeekTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows =
        ref.watch(screenTimeWeekProvider).value ??
        const <ScreenTimeDailyData>[];
    final today = ref.watch(todayDateProvider).value;
    final goal = ref.watch(screenTimeGoalProvider).value;
    final text = Theme.of(context).textTheme;
    if (today == null) return const SizedBox.shrink();

    final dates = [for (var i = 6; i >= 0; i--) shiftLocalDate(today, -i)];
    final byDate = {for (final r in rows) r.localDate: r.totalMinutes};
    final summary = summarizeScreenTime(rows);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      children: [
        SoftCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: _Stat(
                  value: durationShort(summary.averageMinutes),
                  label: 'Daily average',
                ),
              ),
              Expanded(
                child: _Stat(
                  value: durationShort(summary.totalMinutes),
                  label: 'Last 7 days',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SoftCard(
          padding: const EdgeInsets.all(16),
          child: _Bars(dates: dates, minutes: byDate, goal: goal),
        ),
        if (summary.daysWithData == 0)
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 4),
            child: Text('No screen time recorded yet.', style: text.bodySmall),
          ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: text.titleLarge),
        Text(label, style: text.bodySmall),
      ],
    );
  }
}

/// Seven bars, oldest first, with an optional goal line.
class _Bars extends StatelessWidget {
  const _Bars({required this.dates, required this.minutes, required this.goal});

  final List<String> dates;
  final Map<String, int> minutes;
  final int? goal;

  static const _height = 140.0;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final values = [for (final d in dates) minutes[d] ?? 0];
    var scale = values.fold(0, (a, b) => a > b ? a : b);
    if (goal != null && goal! > scale) scale = goal!;
    if (scale == 0) scale = 60;

    return SizedBox(
      height: _height + 44,
      child: Stack(
        children: [
          if (goal != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 22 + _height * (goal! / scale),
              child: Container(
                height: 1,
                color: t.textMuted.withValues(alpha: 0.5),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < dates.length; i++)
                Expanded(
                  child: Semantics(
                    label:
                        '${_short[parseLocalDate(dates[i]).weekday - 1]}: ${formatScreenTime(values[i])}',
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          values[i] == 0
                              ? ''
                              : '${(values[i] / 60).toStringAsFixed(1)}h',
                          style: text.bodySmall?.copyWith(fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: _height * values[i] / scale,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: i == dates.length - 1
                                ? t.accent
                                : t.accent.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 18,
                          child: Text(
                            _short[parseLocalDate(dates[i]).weekday - 1],
                            style: text.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
