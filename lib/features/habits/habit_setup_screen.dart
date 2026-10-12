import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../../data/tables/tables.dart';
import '../reminders/reminder_providers.dart';
import 'habit_defaults.dart';
import 'reminder_config.dart';

const _maxTarget = 60;
const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String formatMinutes(BuildContext context, int minutes) =>
    TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60).format(context);

/// Create or edit a habit: what to track, daily target, and reminders.
class HabitSetupScreen extends ConsumerStatefulWidget {
  const HabitSetupScreen({super.key, this.existing});

  final Habit? existing;

  @override
  ConsumerState<HabitSetupScreen> createState() => _HabitSetupScreenState();
}

class _HabitSetupScreenState extends ConsumerState<HabitSetupScreen> {
  late HabitKind _kind;
  final _name = TextEditingController();
  late int _target;
  late bool _reminders;
  late ReminderConfig _config;
  bool _nameEdited = false;

  /// Once the person changes the target themselves it is kept, and no longer
  /// follows the number of reminders a day.
  bool _targetEdited = false;
  bool _saving = false;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final h = widget.existing;
    if (h != null) {
      _kind = h.kind;
      _name.text = h.name;
      _nameEdited = true;
      _target = h.dailyTarget;
      _reminders = h.remindersEnabled;
      _config = ReminderConfig.fromJson(h.reminderConfig);
      // A target that differs from the schedule was chosen by the person.
      _targetEdited =
          !_reminders ||
          _config.problem != null ||
          h.dailyTarget != _config.occurrences;
    } else {
      _reminders = false; // reminders are off by default (spec 7.4)
      _kind = HabitKind.water;
      _applyKind(HabitKind.water, keepName: false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _applyKind(HabitKind kind, {bool keepName = true}) {
    final d = habitDefaults[kind]!;
    _kind = kind;
    _target = d.dailyTarget;
    _targetEdited = false;
    _config = d.config;
    _syncTarget();
    if (!(keepName && _nameEdited)) {
      _name.text = kind == HabitKind.custom ? '' : d.label;
      _nameEdited = false;
    }
  }

  /// With reminders on and no target of the person's own, the daily target is
  /// the number of reminders a day (both ends of a window count).
  void _syncTarget() {
    if (!_reminders || _targetEdited || _config.problem != null) return;
    _target = _config.occurrences.clamp(1, _maxTarget);
  }

  void _setConfig(ReminderConfig c) => setState(() {
    _config = c;
    _syncTarget();
  });

  /// Reminders are on but the schedule cannot be saved.
  String? get _problem => _reminders ? _config.problem : null;

  Future<int?> _pickMinutes(int initial) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial ~/ 60, minute: initial % 60),
    );
    return t == null ? null : t.hour * 60 + t.minute;
  }

  void _toast(String message) => ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));

  /// Asks for notification access at the moment it is needed, with a short
  /// explanation first (spec section 9).
  Future<void> _ensureNotificationAccess() async {
    final scheduler = ref.read(notificationSchedulerProvider);
    if (await scheduler.hasPermission()) return;
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Allow notifications'),
        content: const Text('Reminders need permission to show notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (ok != true) {
      if (mounted) {
        _toast('Reminders will start once notifications are allowed.');
      }
      return;
    }
    final granted = await scheduler.requestPermission();
    if (!granted && mounted) _toast('Notifications are off for this app.');
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      _toast('Enter a name.');
      return;
    }
    if (_problem != null) return; // shown in red; Save is disabled
    setState(() => _saving = true);

    if (_reminders) await _ensureNotificationAccess();

    final user = await ref.read(currentUserProvider.future);
    final repo = ref.read(habitRepositoryProvider);
    if (_editing) {
      await repo.update(
        widget.existing!.id,
        HabitsCompanion(
          name: Value(name),
          kind: Value(_kind),
          dailyTarget: Value(_target),
          remindersEnabled: Value(_reminders),
          reminderConfig: Value(_config.toJson()),
        ),
      );
    } else {
      await repo.create(
        userId: user.id,
        name: name,
        kind: _kind,
        dailyTarget: _target,
        remindersEnabled: _reminders,
        reminderConfig: _config.toJson(),
      );
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit habit' : 'New habit')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(kMinTapTarget),
            ),
            onPressed: (_saving || _problem != null) ? null : _save,
            child: const Text('Save'),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text('What do you want to track?', style: text.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final k in HabitKind.values)
                ChoiceChip(
                  avatar: Icon(habitIcon(k), size: 18),
                  label: Text(habitDefaults[k]!.label),
                  selected: _kind == k,
                  onSelected: (_) => setState(() => _applyKind(k)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => _nameEdited = true,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          if (_kind == HabitKind.custom) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final s in customSuggestions)
                  ActionChip(
                    label: Text(s),
                    onPressed: () => setState(() {
                      _name.text = s;
                      _nameEdited = true;
                    }),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          // 1. Reminder
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reminder'),
            subtitle: const Text('Off unless you turn it on'),
            value: _reminders,
            onChanged: (v) => setState(() {
              _reminders = v;
              _syncTarget();
            }),
          ),
          // 2. Repeating or set times
          if (_reminders) _reminderOptions(context),
          const SizedBox(height: 16),
          // 3. Target and other details
          Text('Daily target', style: text.bodySmall),
          Row(
            children: [
              IconButton.outlined(
                tooltip: 'Decrease target',
                onPressed: _target > 1
                    ? () => setState(() {
                        _target--;
                        _targetEdited = true;
                      })
                    : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('$_target', style: text.titleLarge),
              ),
              IconButton.outlined(
                tooltip: 'Increase target',
                onPressed: _target < _maxTarget
                    ? () => setState(() {
                        _target++;
                        _targetEdited = true;
                      })
                    : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          if (_reminders)
            Text(
              _targetEdited
                  ? 'Your own target. It no longer follows the reminders.'
                  : 'Set from the number of reminders a day. Change it to use your own.',
              style: text.bodySmall,
            ),
        ],
      ),
    );
  }

  Widget _reminderOptions(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final problem = _problem;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<ReminderMode>(
          segments: const [
            ButtonSegment(
              value: ReminderMode.interval,
              label: Text('Repeating'),
            ),
            ButtonSegment(value: ReminderMode.times, label: Text('Set times')),
          ],
          selected: {_config.mode},
          onSelectionChanged: (s) =>
              _setConfig(_config.copyWith(mode: s.first)),
        ),
        const SizedBox(height: 12),
        if (_config.mode == ReminderMode.interval) ...[
          Wrap(
            spacing: 8,
            children: [
              for (final m in reminderIntervals)
                ChoiceChip(
                  label: Text(describeInterval(m)),
                  selected: _config.everyMinutes == m,
                  onSelected: (_) =>
                      _setConfig(_config.copyWith(everyMinutes: m)),
                ),
            ],
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            minTileHeight: kMinTapTarget,
            title: const Text('From'),
            trailing: Text(formatMinutes(context, _config.windowStart)),
            onTap: () async {
              final m = await _pickMinutes(_config.windowStart);
              if (m != null) _setConfig(_config.copyWith(windowStart: m));
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            minTileHeight: kMinTapTarget,
            title: const Text('To'),
            trailing: Text(formatMinutes(context, _config.windowEnd)),
            onTap: () async {
              final m = await _pickMinutes(_config.windowEnd);
              if (m != null) _setConfig(_config.copyWith(windowEnd: m));
            },
          ),
        ] else ...[
          Wrap(
            spacing: 8,
            children: [
              for (final m in _config.minutesOfDay)
                InputChip(
                  label: Text(formatMinutes(context, m)),
                  onDeleted: () => _setConfig(
                    _config.copyWith(times: [..._config.times]..remove(m)),
                  ),
                ),
              ActionChip(
                avatar: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add time'),
                onPressed: () async {
                  final m = await _pickMinutes(12 * 60);
                  if (m != null) {
                    _setConfig(_config.copyWith(times: [..._config.times, m]));
                  }
                },
              ),
            ],
          ),
        ],
        if (problem != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Semantics(
              liveRegion: true,
              child: Text(
                problem,
                key: const Key('reminder-problem'),
                style: text.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              describeOccurrences(_config.occurrences),
              key: const Key('reminder-count'),
              style: text.bodySmall,
            ),
          ),
        const SizedBox(height: 16),
        Text('Active days', style: text.bodySmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (var d = 1; d <= 7; d++)
              FilterChip(
                label: Text(_dayNames[d - 1]),
                selected: _config.activeDays.contains(d),
                onSelected: (on) {
                  final days = {..._config.activeDays};
                  on ? days.add(d) : days.remove(d);
                  _setConfig(_config.copyWith(activeDays: days));
                },
              ),
          ],
        ),
      ],
    );
  }
}
