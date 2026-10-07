import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/time/local_date.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../week/week_providers.dart';
import 'screen_time_sync.dart';
import 'usage_source.dart';

/// Overridden with the Android implementation in main().
final usageSourceProvider = Provider<UsageSource>((_) => NoopUsageSource());

/// Whether Usage access is granted. Invalidate it to re-check, for example
/// when the app returns from the system settings page.
final screenTimeAccessProvider = FutureProvider<bool>(
  (ref) => ref.watch(usageSourceProvider).hasAccess(),
);

final screenTimeSyncProvider = Provider(
  (ref) => ScreenTimeSync(
    source: ref.watch(usageSourceProvider),
    clock: ref.watch(clockProvider),
    users: ref.watch(userRepositoryProvider),
    repo: ref.watch(screenTimeRepositoryProvider),
    existingDates: ref.watch(screenTimeRepositoryProvider).datesBetween,
  ),
);

/// Reads usage into the database whenever access is (re)confirmed. Watch it
/// from the app shell.
final screenTimeEffectsProvider = Provider<void>((ref) {
  var tail = Future<void>.value();
  ref.listen(screenTimeAccessProvider, (_, next) {
    if (next.value != true) return;
    tail = tail
        .then((_) => ref.read(screenTimeSyncProvider).sync())
        .then((_) {})
        .catchError((Object _) {});
  }, fireImmediately: true);
});

/// Rows for the 7 days ending today.
final screenTimeWeekProvider = StreamProvider<List<ScreenTimeDailyData>>((
  ref,
) async* {
  final user = await ref.watch(currentUserProvider.future);
  final today = await ref.watch(todayDateProvider.future);
  yield* ref
      .watch(screenTimeRepositoryProvider)
      .watchBetween(user.id, shiftLocalDate(today, -6), today);
});

final screenTimeTodayProvider = Provider<ScreenTimeDailyData?>((ref) {
  final today = ref.watch(todayDateProvider).value;
  final rows = ref.watch(screenTimeWeekProvider).value;
  if (today == null || rows == null) return null;
  return rows.where((r) => r.localDate == today).firstOrNull;
});

const _goalKey = 'screen_time_goal_minutes';

/// Optional daily goal in minutes; null means no goal.
class ScreenTimeGoalNotifier extends AsyncNotifier<int?> {
  @override
  Future<int?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_goalKey);
  }

  Future<void> set(int? minutes) async {
    final prefs = await SharedPreferences.getInstance();
    if (minutes == null) {
      await prefs.remove(_goalKey);
    } else {
      await prefs.setInt(_goalKey, minutes);
    }
    state = AsyncData(minutes);
  }
}

final screenTimeGoalProvider =
    AsyncNotifierProvider<ScreenTimeGoalNotifier, int?>(
      ScreenTimeGoalNotifier.new,
    );
