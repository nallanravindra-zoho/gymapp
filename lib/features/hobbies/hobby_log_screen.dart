import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/time/local_date.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/dialogs.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../../data/tables/tables.dart';
import '../week/week_providers.dart';
import 'hobby_timer.dart';
import 'hobby_widgets.dart';

enum _EntryMode { minutes, range }

/// Add, edit or delete one hobby log: a number of minutes, or a start and end
/// time. Also the place a finished timer lands, so notes can be added.
class HobbyLogScreen extends ConsumerStatefulWidget {
  const HobbyLogScreen({
    super.key,
    required this.hobby,
    this.existing,
    this.timerStart,
    this.timerEnd,
  });

  final Hobby hobby;

  /// Editing this log; null for a new one.
  final HobbyLog? existing;

  /// A timer that just stopped.
  final DateTime? timerStart;
  final DateTime? timerEnd;

  @override
  ConsumerState<HobbyLogScreen> createState() => _HobbyLogScreenState();
}

class _HobbyLogScreenState extends ConsumerState<HobbyLogScreen> {
  final _minutes = TextEditingController();
  final _note = TextEditingController();
  _EntryMode _mode = _EntryMode.minutes;
  String _date = '';
  int _start = 18 * 60;
  int _end = 18 * 60 + 30;
  int _sessions = 1;
  String? _error;
  bool _ready = false;
  bool _saving = false;

  bool get _editing => widget.existing != null;
  bool get _fromTimer => widget.timerStart != null && widget.timerEnd != null;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _minutes.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final today = await ref.read(todayDateProvider.future);
    final clock = ref.read(clockProvider);
    final now = clock.now();
    final offset = clock.offsetAt(now);
    final nowWall = now.add(Duration(minutes: offset));
    final nowMin = nowWall.hour * 60 + nowWall.minute;
    final e = widget.existing;
    if (e != null) {
      final wall = e.startedAt.toUtc().add(
        Duration(minutes: e.tzOffsetMinutes),
      );
      _date = e.localDate;
      _minutes.text = '${e.durationMinutes}';
      _start = wall.hour * 60 + wall.minute;
      _end = (_start + e.durationMinutes).clamp(0, 1439);
      _sessions = e.countOrSessions;
      _note.text = e.note ?? '';
    } else if (_fromTimer) {
      final s = widget.timerStart!.toUtc().add(Duration(minutes: offset));
      _date = localDateOf(
        widget.timerStart!,
        offsetMinutes: offset,
        cutoffMinutes: (await ref.read(currentUserProvider.future))
            .dayCutoffMinutes,
      );
      _minutes.text =
          '${minutesForSpan(widget.timerEnd!.difference(widget.timerStart!))}';
      _start = s.hour * 60 + s.minute;
    } else {
      _date = today;
      _end = nowMin;
      _start = nowMin >= 30 ? nowMin - 30 : 0;
    }
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _pickDate() async {
    final today = await ref.read(todayDateProvider.future);
    if (!mounted) return;
    final cur = parseLocalDate(_date);
    final last = parseLocalDate(today);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(cur.year, cur.month, cur.day),
      firstDate: DateTime(2020),
      lastDate: DateTime(last.year, last.month, last.day),
    );
    if (picked != null) {
      setState(
        () => _date = formatLocalDate(picked.year, picked.month, picked.day),
      );
    }
  }

  Future<int?> _pickTime(int initial) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial ~/ 60, minute: initial % 60),
    );
    return t == null ? null : t.hour * 60 + t.minute;
  }

  DateTime _instant(String date, int minuteOfDay, int offset) =>
      parseLocalDate(date).add(Duration(minutes: minuteOfDay - offset));

  Future<void> _save() async {
    final clock = ref.read(clockProvider);
    final offset = clock.offsetAt(clock.now());
    final user = await ref.read(currentUserProvider.future);
    final repo = ref.read(hobbyRepositoryProvider);
    final today = await ref.read(todayDateProvider.future);

    int minutes;
    DateTime? startedAt;
    DateTime? endedAt;
    if (_mode == _EntryMode.range) {
      if (_end <= _start) {
        setState(() => _error = 'The end time must be after the start time.');
        return;
      }
      minutes = _end - _start;
      startedAt = _instant(_date, _start, offset);
      endedAt = _instant(_date, _end, offset);
    } else {
      final m = int.tryParse(_minutes.text.trim());
      if (m == null || m < 1 || m > 1440) {
        setState(() => _error = 'Enter a number of minutes, 1 or more.');
        return;
      }
      minutes = m;
      if (_fromTimer) {
        startedAt = widget.timerStart;
        endedAt = widget.timerEnd;
      } else if (!_editing || _date != widget.existing!.localDate) {
        startedAt = _date == today
            ? clock.now()
            : _instant(_date, 12 * 60, offset);
      }
    }
    final note = _note.text.trim();
    setState(() {
      _error = null;
      _saving = true;
    });
    if (_editing) {
      await repo.updateLog(
        id: widget.existing!.id,
        dayCutoffMinutes: user.dayCutoffMinutes,
        startedAt: startedAt,
        endedAt: endedAt,
        durationMinutes: minutes,
        countOrSessions: _sessions,
        note: note,
      );
    } else {
      await repo.addLog(
        userId: user.id,
        hobbyId: widget.hobby.id,
        dayCutoffMinutes: user.dayCutoffMinutes,
        source: _fromTimer ? HobbyLogSource.timer : HobbyLogSource.manual,
        startedAt: startedAt,
        endedAt: endedAt,
        durationMinutes: minutes,
        countOrSessions: _sessions,
        note: note.isEmpty ? null : note,
      );
    }
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final ok = await confirm(
      context,
      title: 'Delete this log?',
      body: 'It will be removed from your ${widget.hobby.name} history.',
      action: 'Delete',
    );
    if (!ok || !mounted) return;
    await ref.read(hobbyRepositoryProvider).deleteLog(widget.existing!.id);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final title = _editing
        ? 'Edit ${widget.hobby.name} log'
        : 'Log ${widget.hobby.name}';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (_editing)
            IconButton(
              tooltip: 'Delete log',
              constraints: const BoxConstraints(
                minWidth: kMinTapTarget,
                minHeight: kMinTapTarget,
              ),
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _delete,
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(kMinTapTarget),
            ),
            onPressed: _ready && !_saving ? _save : null,
            child: const Text('Save'),
          ),
        ),
      ),
      body: !_ready
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (_fromTimer)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Timed ${formatElapsed(widget.timerEnd!.difference(widget.timerStart!))}. '
                      'Adjust the minutes if you like.',
                      style: text.bodyMedium,
                    ),
                  ),
                if (!_fromTimer)
                  PillTabs<_EntryMode>(
                    options: const {
                      _EntryMode.minutes: 'Minutes',
                      _EntryMode.range: 'Start and end',
                    },
                    selected: _mode,
                    onChanged: (m) => setState(() {
                      _mode = m;
                      _error = null;
                    }),
                  ),
                const SizedBox(height: 8),
                PickerTile(label: 'Date', value: _date, onTap: _pickDate),
                if (_mode == _EntryMode.minutes || _fromTimer)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextField(
                      controller: _minutes,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Minutes',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  )
                else ...[
                  PickerTile(
                    label: 'Start',
                    value: formatMinuteOfDay(context, _start),
                    onTap: () async {
                      final m = await _pickTime(_start);
                      if (m != null) setState(() => _start = m);
                    },
                  ),
                  PickerTile(
                    label: 'End',
                    value: formatMinuteOfDay(context, _end),
                    onTap: () async {
                      final m = await _pickTime(_end);
                      if (m != null) setState(() => _end = m);
                    },
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text('Sessions', style: text.bodyLarge)),
                    IconButton.outlined(
                      tooltip: 'Fewer sessions',
                      constraints: const BoxConstraints(
                        minWidth: kMinTapTarget,
                        minHeight: kMinTapTarget,
                      ),
                      onPressed: _sessions > 1
                          ? () => setState(() => _sessions--)
                          : null,
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('$_sessions', style: text.titleLarge),
                    ),
                    IconButton.outlined(
                      tooltip: 'More sessions',
                      constraints: const BoxConstraints(
                        minWidth: kMinTapTarget,
                        minHeight: kMinTapTarget,
                      ),
                      onPressed: _sessions < 99
                          ? () => setState(() => _sessions++)
                          : null,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _note,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _error!,
                      style: text.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
