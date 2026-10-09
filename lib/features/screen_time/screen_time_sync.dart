import 'dart:convert';

import '../../core/time/app_clock.dart';
import '../../core/time/local_date.dart';
import '../../data/repositories/screen_time_repository.dart';
import '../../data/repositories/user_repository.dart';
import 'usage_source.dart';

enum SyncOutcome { noAccess, done, failed }

/// Copies recent daily usage from the system into the local database.
///
/// Today is re-read every time since it is still growing. Earlier days are
/// read once, when no stored row exists, because their totals no longer change.
class ScreenTimeSync {
  ScreenTimeSync({
    required this.source,
    required this.clock,
    required this.users,
    required this.repo,
    required this.existingDates,
  });

  final UsageSource source;
  final AppClock clock;
  final UserRepository users;
  final ScreenTimeRepository repo;

  /// Dates in `[from, to]` that already have a stored row.
  final Future<Set<String>> Function(String userId, String from, String to)
  existingDates;

  static const historyDays = 7;

  Future<SyncOutcome> sync() async {
    if (!await source.hasAccess()) return SyncOutcome.noAccess;

    try {
      final user = await users.ensureUser();
      final now = clock.now().toLocal();
      final today = users.today(user);
      final from = shiftLocalDate(today, -(historyDays - 1));
      final have = await existingDates(user.id, from, today);

      for (var back = historyDays - 1; back >= 0; back--) {
        final date = shiftLocalDate(today, -back);
        final isToday = back == 0;
        if (!isToday && have.contains(date)) continue;

        final d = parseLocalDate(date);
        final start = DateTime(
          d.year,
          d.month,
          d.day,
        ).add(Duration(minutes: user.dayCutoffMinutes));
        var end = start.add(const Duration(days: 1));
        if (end.isAfter(now)) end = now;
        if (!end.isAfter(start)) continue;

        final usage = await source.readDay(start, end);
        await repo.upsertDay(
          userId: user.id,
          localDate: date,
          totalMinutes: usage.totalMinutes,
          categoryMinutesJson: jsonEncode(usage.categories),
          lateEveningMinutes: usage.lateEveningMinutes,
        );
      }
      return SyncOutcome.done;
    } catch (_) {
      return SyncOutcome.failed;
    }
  }
}
