import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/time/local_date.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';

/// Monday of the week being viewed. Null means the current week.
class SelectedWeekNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void shift(String current, int weeks) =>
      state = shiftLocalDate(state ?? current, weeks * 7);

  void reset() => state = null;
}

final selectedWeekProvider = NotifierProvider<SelectedWeekNotifier, String?>(
  SelectedWeekNotifier.new,
);

final todayDateProvider = FutureProvider<String>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  return ref.watch(userRepositoryProvider).today(user);
});

/// Monday of the week on screen.
final weekStartProvider = Provider<String?>((ref) {
  final today = ref.watch(todayDateProvider).value;
  if (today == null) return null;
  return ref.watch(selectedWeekProvider) ?? weekStartOf(today);
});

final weekWorkoutsProvider = StreamProvider<List<Workout>>((ref) async* {
  final start = ref.watch(weekStartProvider);
  if (start == null) return;
  final user = await ref.watch(currentUserProvider.future);
  yield* ref
      .watch(workoutRepositoryProvider)
      .watchBetween(user.id, start, shiftLocalDate(start, 6));
});

final weekRestDaysProvider = StreamProvider<Set<String>>((ref) async* {
  final start = ref.watch(weekStartProvider);
  if (start == null) return;
  final user = await ref.watch(currentUserProvider.future);
  yield* ref
      .watch(restDayRepositoryProvider)
      .watchBetween(user.id, start, shiftLocalDate(start, 6))
      .map((rows) => {for (final r in rows) r.localDate});
});
