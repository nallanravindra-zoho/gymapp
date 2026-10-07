import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/time/app_clock.dart';
import 'app_database.dart';
import 'repositories/habit_repository.dart';
import 'repositories/rest_day_repository.dart';
import 'repositories/screen_time_repository.dart';
import 'repositories/sleep_repository.dart';
import 'repositories/user_repository.dart';
import 'repositories/workout_repository.dart';

final clockProvider = Provider<AppClock>((_) => const AppClock());

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final userRepositoryProvider = Provider(
  (ref) =>
      UserRepository(ref.watch(databaseProvider), ref.watch(clockProvider)),
);
final workoutRepositoryProvider = Provider(
  (ref) =>
      WorkoutRepository(ref.watch(databaseProvider), ref.watch(clockProvider)),
);
final habitRepositoryProvider = Provider(
  (ref) =>
      HabitRepository(ref.watch(databaseProvider), ref.watch(clockProvider)),
);
final sleepRepositoryProvider = Provider(
  (ref) =>
      SleepRepository(ref.watch(databaseProvider), ref.watch(clockProvider)),
);
final restDayRepositoryProvider = Provider(
  (ref) =>
      RestDayRepository(ref.watch(databaseProvider), ref.watch(clockProvider)),
);
final screenTimeRepositoryProvider = Provider(
  (ref) => ScreenTimeRepository(
    ref.watch(databaseProvider),
    ref.watch(clockProvider),
  ),
);

/// The local user, created on first read.
final currentUserProvider = FutureProvider(
  (ref) => ref.watch(userRepositoryProvider).ensureUser(),
);
