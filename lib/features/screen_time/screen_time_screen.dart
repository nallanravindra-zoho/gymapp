import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/time/local_date.dart';
import '../../data/app_database.dart';
import '../week/week_providers.dart';
import 'screen_time_logic.dart';
import 'screen_time_providers.dart';

class ScreenTimeScreen extends ConsumerWidget {
  const ScreenTimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(screenTimeAccessProvider);

    return access.when(
      loading: () => Scaffold(appBar: AppBar(title: const Text('Screen time'))),
      error: (_, _) => const _AccessExplanation(),
      data: (granted) => granted
          ? DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Screen time'),
                  bottom: const TabBar(
                    tabs: [
                      Tab(text: 'Today'),
                      Tab(text: 'Week'),
                    ],
                  ),
                ),
                body: const TabBarView(children: [_TodayTab(), _WeekTab()]),
              ),
            )
          : const _AccessExplanation(),
    );
  }
}

/// Explains why access is needed before sending the user to system settings
/// (spec 8.1, section 9).
class _AccessExplanation extends ConsumerWidget {
  const _AccessExplanation();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Screen time')),
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
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(kMinTapTarget),
              ),
              onPressed: () => ref.read(usageSourceProvider).openSettings(),
              child: const Text('Open settings'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(kMinTapTarget),
              ),
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
          16,
          16,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formatScreenTime(total), style: text.displaySmall),
                  const SizedBox(height: 4),
                  Text('Total screen time', style: text.bodySmall),
                  if (goal != null) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (total / goal).clamp(0.0, 1.0),
                        minHeight: 8,
                        color: t.accent,
                        backgroundColor: t.textMuted.withValues(alpha: 0.2),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(goalLabel(goal), style: text.bodySmall),
                  ],
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, kMinTapTarget),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: () => _editGoal(context, ref, goal),
                    child: Text(
                      goal == null ? 'Set a daily goal' : 'Change goal',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('By category', style: text.bodySmall),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: categories.isEmpty
                  ? const Text('No screen time recorded yet today.')
                  : Column(
                      children: [
                        for (final c in categories)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Expanded(child: Text(categoryLabel(c.key))),
                                Text(formatScreenTime(c.value)),
                                SizedBox(
                                  width: 48,
                                  child: Text(
                                    '${percentOf(c.value, total)}%',
                                    textAlign: TextAlign.end,
                                    style: text.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          if (row != null && row.lateEveningMinutes > 0) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                minTileHeight: kMinTapTarget,
                leading: const Icon(Icons.nights_stay_outlined),
                title: const Text('Late evening'),
                subtitle: const Text('After 9 PM'),
                trailing: Text(formatScreenTime(row.lateEveningMinutes)),
              ),
            ),
          ],
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
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _Stat(
                    value: formatScreenTime(summary.averageMinutes),
                    label: 'Daily average',
                  ),
                ),
                Expanded(
                  child: _Stat(
                    value: formatScreenTime(summary.totalMinutes),
                    label: 'Last 7 days',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _Bars(dates: dates, minutes: byDate, goal: goal),
          ),
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
