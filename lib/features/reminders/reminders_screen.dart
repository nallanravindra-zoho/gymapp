import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/providers.dart';
import 'reminder_planner.dart';
import 'reminder_providers.dart';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', //
];

/// `Today`, `Tomorrow`, or `Fri 15 May`, relative to [now].
String dayLabel(DateTime at, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(at.year, at.month, at.day);
  final diff = day.difference(today).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  return '${_weekdays[at.weekday - 1]} ${at.day} ${_months[at.month - 1]}';
}

/// Shows what is scheduled and lets you check that notifications work.
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  String _clock(BuildContext context, int minutes) =>
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60).format(context);

  void _say(BuildContext context, String message) =>
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(message)));

  Future<void> _allow(BuildContext context, WidgetRef ref) async {
    final granted = await ref
        .read(notificationSchedulerProvider)
        .requestPermission();
    if (granted) await ref.read(reminderServiceProvider).reschedule();
    ref.invalidate(upcomingRemindersProvider);
    if (!granted && context.mounted) {
      _say(context, 'Notifications are off for this app.');
    }
  }

  Future<void> _test(
    BuildContext context,
    WidgetRef ref, {
    required Duration delay,
  }) async {
    final result = await ref
        .read(reminderServiceProvider)
        .sendTest(delay: delay);
    ref.invalidate(upcomingRemindersProvider);
    if (!context.mounted) return;

    if (result.noPermissionGiven) {
      _say(context, 'Allow notifications first.');
    } else if (result.error != null) {
      _say(context, 'Could not send the test: ${result.error}');
    } else if (delay == Duration.zero) {
      _say(
        context,
        result.confirmed
            ? 'The phone accepted the test notification. If you do not see '
                  'it, open Notification settings and allow banners and sound.'
            : 'The phone did not show the test notification. Open '
                  'Notification settings and check that this app is allowed.',
      );
    } else {
      final when = TimeOfDay.fromDateTime(result.at!).format(context);
      _say(
        context,
        result.confirmed
            ? 'Test set for $when. Close the app and wait. Android can '
                  'deliver it a few minutes late.'
            : 'The phone did not register the test. Open Battery settings '
                  'and allow background activity.',
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(upcomingRemindersProvider);
    final now = ref.watch(clockProvider).now().toLocal();
    final text = Theme.of(context).textTheme;
    final t = context.tokens;

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(reminderServiceProvider).reschedule();
          ref.invalidate(upcomingRemindersProvider);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            MediaQuery.paddingOf(context).bottom + 24,
          ),
          children: [
            data.when(
              loading: () => const SizedBox(height: 120),
              error: (_, _) => const Text('Could not load reminders.'),
              data: (u) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Line(
                            'Notifications',
                            u.permitted ? 'Allowed' : 'Not allowed',
                          ),
                          if (u.permitted)
                            _Line(
                              'Set up on this phone',
                              '${u.scheduledOnPhone} of ${u.totalPlanned}',
                            ),
                          _Line(
                            'Quiet hours',
                            '${_clock(context, u.quietStart)} to ${_clock(context, u.quietEnd)}',
                          ),
                          if (u.diagnostics.channelLevel != null)
                            _Line('Alert level', u.diagnostics.channelLevel!),
                          const _BatteryLine(),
                          if (u.problem != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Last problem: ${u.problem}',
                              style: text.bodySmall,
                            ),
                          ],
                          if (!u.permitted) ...[
                            const SizedBox(height: 12),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(
                                  kMinTapTarget,
                                ),
                              ),
                              onPressed: () => _allow(context, ref),
                              child: const Text('Allow notifications'),
                            ),
                          ],
                          if (u.permitted &&
                              u.totalPlanned > 0 &&
                              u.scheduledOnPhone == 0) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Reminders are planned but not set up on this '
                              'phone yet. Pull down to refresh.',
                              style: text.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Next reminders', style: text.titleLarge),
                  const SizedBox(height: 8),
                  if (u.enabledHabits == 0)
                    Text(
                      'No habit has reminders turned on. Open a habit and '
                      'switch on Reminders.',
                      style: text.bodySmall,
                    )
                  else if (u.next.isEmpty)
                    Text(
                      'No reminders are left to send. Quiet hours and '
                      'completed targets can cause this.',
                      style: text.bodySmall,
                    )
                  else
                    for (final r in u.next)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          minTileHeight: kMinTapTarget + 8,
                          leading: Icon(
                            Icons.notifications_none_rounded,
                            color: t.accent,
                          ),
                          title: Text(reminderText(r).title),
                          subtitle: reminderText(r).body == null
                              ? null
                              : Text(reminderText(r).body!),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                TimeOfDay.fromDateTime(r.at).format(context),
                              ),
                              Text(dayLabel(r.at, now), style: text.bodySmall),
                            ],
                          ),
                        ),
                      ),
                  if (u.totalPlanned > u.next.length)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, top: 4),
                      child: Text(
                        '${u.totalPlanned - u.next.length} more this week.',
                        style: text.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Check that it works', style: text.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Send a test now, or in a minute to see whether reminders '
              'arrive while the app is closed.',
              style: text.bodySmall,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(kMinTapTarget),
              ),
              onPressed: () => _test(context, ref, delay: Duration.zero),
              child: const Text('Send test now'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(kMinTapTarget),
              ),
              onPressed: () =>
                  _test(context, ref, delay: const Duration(minutes: 1)),
              child: const Text('Test in 1 minute'),
            ),
            const SizedBox(height: 24),
            Text('Phone settings', style: text.titleLarge),
            const SizedBox(height: 8),
            Text(
              'If reminders do not arrive, allow banners and sound for this '
              'app, and let it run in the background.',
              style: text.bodySmall,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(kMinTapTarget),
              ),
              onPressed: () =>
                  ref.read(systemSettingsProvider).openNotificationSettings(),
              child: const Text('Notification settings'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(kMinTapTarget),
              ),
              onPressed: () async {
                await ref.read(systemSettingsProvider).openBatterySettings();
                ref.invalidate(batteryUnrestrictedProvider);
              },
              child: const Text('Battery settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}

/// Whether the phone lets the app run in the background despite battery
/// saving. Hidden when the phone cannot say.
class _BatteryLine extends ConsumerWidget {
  const _BatteryLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unrestricted = ref.watch(batteryUnrestrictedProvider).value;
    if (unrestricted == null) return const SizedBox.shrink();
    return _Line('Background use', unrestricted ? 'Allowed' : 'Limited');
  }
}
