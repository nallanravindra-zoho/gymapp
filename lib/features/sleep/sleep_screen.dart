import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/section_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/providers.dart';
import 'sleep_log_sheet.dart';
import 'sleep_logic.dart';
import 'sleep_providers.dart';
import 'wind_down.dart';

String _fmt(BuildContext context, int minutes) =>
    TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60).format(context);

/// Sleep: log and targets, plus an optional wind-down checklist. Calmer look
/// via [SectionTheme].
class SleepScreen extends StatelessWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionTheme(
      section: AppSection.sleep,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Sleep'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Log'),
                Tab(text: 'Wind down'),
              ],
            ),
          ),
          body: const TabBarView(children: [_LogTab(), _WindDownTab()]),
        ),
      ),
    );
  }
}

class _LogTab extends ConsumerWidget {
  const _LogTab();

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _TargetRow(
                  label: 'Target bedtime',
                  value: _fmt(context, target.bedtimeMinutes),
                  onEdit: () => _editTarget(context, ref, bedtime: true),
                ),
                _TargetRow(
                  label: 'Wake up',
                  value: _fmt(context, target.wakeMinutes),
                  onEdit: () => _editTarget(context, ref, bedtime: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Last night', style: text.bodySmall),
                const SizedBox(height: 8),
                if (last == null) ...[
                  Text(
                    'No sleep logged for last night.',
                    style: text.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(kMinTapTarget),
                    ),
                    onPressed: () => showSleepLogSheet(context),
                    child: const Text('Log sleep'),
                  ),
                ] else ...[
                  Text(
                    formatSleepDuration(last.durationMinutes),
                    style: text.displaySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${TimeOfDay.fromDateTime(last.bedtimeAt.toLocal()).format(context)}'
                    ' to ${TimeOfDay.fromDateTime(last.wakeAt.toLocal()).format(context)}',
                    style: text.bodySmall,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, kMinTapTarget),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: () => showSleepLogSheet(context, existing: last),
                    child: const Text('Edit'),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (consistency != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Consistency, last 7 days', style: text.bodySmall),
                  const SizedBox(height: 8),
                  Text(consistencyLabel(consistency), style: text.titleLarge),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (final v in consistency.byDate.values)
                        Expanded(
                          child: Center(
                            child: Container(
                              width: 14,
                              height: 14,
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
          ),
      ],
    );
  }
}

class _TargetRow extends StatelessWidget {
  const _TargetRow({
    required this.label,
    required this.value,
    required this.onEdit,
  });

  final String label;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minTileHeight: kMinTapTarget + 8,
      title: Text(label, style: Theme.of(context).textTheme.bodySmall),
      subtitle: Text(value, style: Theme.of(context).textTheme.titleLarge),
      trailing: TextButton(onPressed: onEdit, child: const Text('Edit')),
      onTap: onEdit,
    );
  }
}

class _WindDownTab extends ConsumerWidget {
  const _WindDownTab();

  Future<String?> _askLabel(BuildContext context, {String initial = ''}) {
    return showDialog<String>(
      context: context,
      builder: (_) => _LabelDialog(initial: initial),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(windDownProvider).value;
    final notifier = ref.read(windDownProvider.notifier);
    if (state == null) return const SizedBox.shrink();

    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      children: [
        Card(
          child: Column(
            children: [
              if (state.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No wind-down items.'),
                ),
              for (final item in state.items)
                CheckboxListTile(
                  minTileHeight: kMinTapTarget,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: state.checked.contains(item.id),
                  onChanged: (_) => notifier.toggle(item.id),
                  title: Text(item.label),
                  secondary: PopupMenuButton<String>(
                    tooltip: 'Edit ${item.label}',
                    onSelected: (v) async {
                      if (v == 'rename') {
                        final label = await _askLabel(
                          context,
                          initial: item.label,
                        );
                        if (label != null) notifier.rename(item.id, label);
                      } else {
                        notifier.remove(item.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'rename', child: Text('Rename')),
                      PopupMenuItem(value: 'remove', child: Text('Remove')),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(kMinTapTarget),
          ),
          onPressed: () async {
            final label = await _askLabel(context);
            if (label != null) notifier.add(label);
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add item'),
        ),
      ],
    );
  }
}

class _LabelDialog extends StatefulWidget {
  const _LabelDialog({required this.initial});
  final String initial;

  @override
  State<_LabelDialog> createState() => _LabelDialogState();
}

class _LabelDialogState extends State<_LabelDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial.isEmpty ? 'New item' : 'Rename item'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: const InputDecoration(hintText: 'Name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
