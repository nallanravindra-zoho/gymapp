import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../../data/sync/local_reset.dart';
import '../account/sync_providers.dart';
import '../groups/groups_providers.dart';
import '../groups/groups_widgets.dart';
import '../reminders/reminder_planner.dart';
import '../streaks/streak_providers.dart';
import 'data_export.dart';

/// Profile, appearance, reminder and streak settings, and the person's data:
/// export, erase on this phone, delete the account.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userStreamProvider).value;
    final signedIn = ref.watch(authUserProvider).value != null;
    final text = Theme.of(context).textTheme;

    Widget section(String title, List<Widget> children, {String? note}) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(title, style: text.titleLarge),
            if (note != null) ...[
              const SizedBox(height: 4),
              Text(
                note,
                style: text.bodySmall?.copyWith(
                  color: context.tokens.textMuted,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Card(child: Column(children: children)),
          ],
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: user == null
          ? const SizedBox.shrink()
          : ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              children: [
                section('Profile', [
                  _NameTile(user: user),
                ], note: 'Your name is shown to members of your groups.'),
                section('Appearance', [const _ThemeTile()]),
                section(
                  'Reminders',
                  [
                    _QuietHoursTile(user: user, start: true),
                    _QuietHoursTile(user: user, start: false),
                    _StepperTile(
                      title: 'Most reminders in a day',
                      value: user.dailyReminderCap,
                      min: 1,
                      max: 12,
                      format: (v) => '$v',
                      onChanged: (v) => _save(
                        ref,
                        user,
                        UsersCompanion(dailyReminderCap: Value(v)),
                      ),
                    ),
                  ],
                  note:
                      'No reminders are sent during quiet hours. If more are '
                      'due than the daily limit, the least important are dropped.',
                ),
                section('Streaks', [
                  _StepperTile(
                    title: 'Rest days per week',
                    value: user.weeklyRestDays,
                    min: 0,
                    max: 4,
                    format: (v) => '$v',
                    onChanged: (v) => _save(
                      ref,
                      user,
                      UsersCompanion(weeklyRestDays: Value(v)),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Streak freeze'),
                    subtitle: const Text(
                      'A missed day can be covered once per interval.',
                    ),
                    value: user.freezeEnabled,
                    onChanged: (v) => _save(
                      ref,
                      user,
                      UsersCompanion(freezeEnabled: Value(v)),
                    ),
                  ),
                  if (user.freezeEnabled)
                    _StepperTile(
                      title: 'Freeze interval',
                      value: user.freezeIntervalDays,
                      min: 3,
                      max: 30,
                      format: (v) => '$v days',
                      onChanged: (v) => _save(
                        ref,
                        user,
                        UsersCompanion(freezeIntervalDays: Value(v)),
                      ),
                    ),
                ], note: 'Changes apply to your streaks straight away.'),
                section(
                  'Day',
                  [
                    _StepperTile(
                      title: 'A new day starts at',
                      value: user.dayCutoffMinutes ~/ 60,
                      min: 0,
                      max: 5,
                      format: (v) => '${v.toString().padLeft(2, '0')}:00',
                      onChanged: (v) => _save(
                        ref,
                        user,
                        UsersCompanion(dayCutoffMinutes: Value(v * 60)),
                      ),
                    ),
                  ],
                  note:
                      'Entries before this time count towards the previous '
                      'day. Entries already logged keep their day.',
                ),
                section('Your data', [
                  ListTile(
                    minTileHeight: kMinTapTarget + 8,
                    title: const Text('Export all data'),
                    subtitle: const Text('Everything on this phone, as JSON.'),
                    trailing: const Icon(Icons.ios_share_outlined),
                    onTap: () => _export(context, ref, json: true),
                  ),
                  ListTile(
                    minTileHeight: kMinTapTarget + 8,
                    title: const Text('Export workouts'),
                    subtitle: const Text('A spreadsheet (CSV), one row each.'),
                    trailing: const Icon(Icons.ios_share_outlined),
                    onTap: () => _export(context, ref, json: false),
                  ),
                  if (!signedIn)
                    ListTile(
                      minTileHeight: kMinTapTarget + 8,
                      title: const Text('Erase data on this phone'),
                      subtitle: const Text(
                        'Removes your entries and settings from this phone.',
                      ),
                      onTap: () => _erase(context, ref, user),
                    ),
                  if (signedIn)
                    ListTile(
                      minTileHeight: kMinTapTarget + 8,
                      title: Text(
                        'Delete account',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      subtitle: const Text(
                        'Removes your account and its data from the server.',
                      ),
                      onTap: () => _deleteAccount(context, ref),
                    ),
                ]),
              ],
            ),
    );
  }
}

Future<void> _save(WidgetRef ref, User user, UsersCompanion changes) =>
    ref.read(userRepositoryProvider).update(user.id, changes);

void _say(BuildContext context, String message) => ScaffoldMessenger.of(context)
  ..clearSnackBars()
  ..showSnackBar(SnackBar(content: Text(message)));

Future<void> _export(
  BuildContext context,
  WidgetRef ref, {
  required bool json,
}) async {
  try {
    final db = ref.read(databaseProvider);
    final now = ref.read(clockProvider).now();
    final export = json
        ? await buildJsonExport(db, now)
        : await buildWorkoutsCsv(db, now);
    await ref.read(exportSinkProvider).deliver(export);
  } catch (_) {
    if (context.mounted) _say(context, 'Could not create the file. Try again.');
  }
}

Future<void> _erase(BuildContext context, WidgetRef ref, User user) async {
  final ok = await confirm(
    context,
    title: 'Erase data on this phone?',
    body:
        'Your workouts, habits, sleep, screen time and settings on this phone '
        'will be removed. This cannot be undone.',
    action: 'Erase',
  );
  if (!ok || !context.mounted) return;
  final store = ref.read(syncStateProvider);
  await wipeLocalAccountData(ref.read(databaseProvider), user.id);
  await store.reset();
  await store.setAccountId(null);
  if (context.mounted) _say(context, 'Data on this phone erased.');
}

Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
  final ok = await confirm(
    context,
    title: 'Delete your account?',
    body:
        'This removes your account and everything stored for it on the '
        'server, including your place in groups. Data on this phone stays. '
        'This cannot be undone.',
    action: 'Delete account',
  );
  if (!ok || !context.mounted) return;
  final deleted = await ref.read(authServiceProvider).deleteAccount();
  if (!context.mounted) return;
  if (!deleted) {
    _say(
      context,
      'Could not delete the account. Check your connection and try again.',
    );
    return;
  }
  // The next account to sign in on this phone starts from what is here.
  final store = ref.read(syncStateProvider);
  await store.reset();
  await store.setAccountId(null);
  ref.invalidate(groupsListProvider);
  if (context.mounted) {
    _say(context, 'Account deleted. Your data is still on this phone.');
  }
}

class _NameTile extends ConsumerWidget {
  const _NameTile({required this.user});
  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      minTileHeight: kMinTapTarget + 8,
      title: const Text('Name'),
      subtitle: Text(user.displayName.isEmpty ? 'Not set' : user.displayName),
      trailing: const Icon(Icons.edit_outlined),
      onTap: () async {
        final name = await showDialog<String>(
          context: context,
          builder: (_) => TextPromptDialog(
            title: 'Your name',
            label: 'Name',
            action: 'Save',
            initial: user.displayName,
            maxLength: 40,
          ),
        );
        if (name != null) {
          await _save(ref, user, UsersCompanion(displayName: Value(name)));
        }
      },
    );
  }
}

class _ThemeTile extends ConsumerWidget {
  const _ThemeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(value: ThemeMode.system, label: Text('System')),
          ButtonSegment(value: ThemeMode.light, label: Text('Light')),
          ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
        ],
        selected: {mode},
        onSelectionChanged: (s) =>
            ref.read(themeModeProvider.notifier).set(s.first),
      ),
    );
  }
}

class _QuietHoursTile extends ConsumerWidget {
  const _QuietHoursTile({required this.user, required this.start});
  final User user;
  final bool start;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minutes = start
        ? user.quietHoursStart ?? defaultQuietStart
        : user.quietHoursEnd ?? defaultQuietEnd;
    return ListTile(
      minTileHeight: kMinTapTarget + 8,
      title: Text(start ? 'Quiet hours start' : 'Quiet hours end'),
      trailing: Text(
        TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60).format(context),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
        );
        if (picked == null) return;
        final value = picked.hour * 60 + picked.minute;
        await _save(
          ref,
          user,
          start
              ? UsersCompanion(quietHoursStart: Value(value))
              : UsersCompanion(quietHoursEnd: Value(value)),
        );
      },
    );
  }
}

/// A number with minus and plus buttons, for small bounded settings.
class _StepperTile extends StatelessWidget {
  const _StepperTile({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.format,
    required this.onChanged,
  });

  final String title;
  final int value;
  final int min;
  final int max;
  final String Function(int) format;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: kMinTapTarget + 8,
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Less: $title',
            constraints: const BoxConstraints(
              minWidth: kMinTapTarget,
              minHeight: kMinTapTarget,
            ),
            icon: const Icon(Icons.remove),
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 64,
            child: Text(
              format(value),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: 'More: $title',
            constraints: const BoxConstraints(
              minWidth: kMinTapTarget,
              minHeight: kMinTapTarget,
            ),
            icon: const Icon(Icons.add),
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}
