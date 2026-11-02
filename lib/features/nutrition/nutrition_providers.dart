import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/time/local_date.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../week/week_providers.dart';

/// Meals logged today, newest first.
final todayMealsProvider = StreamProvider<List<MealLog>>((ref) async* {
  final today = await ref.watch(todayDateProvider.future);
  final user = await ref.watch(currentUserProvider.future);
  yield* ref.watch(mealRepositoryProvider).watchBetween(user.id, today, today);
});

/// Meals from the last 30 days, for quick re-entry of common ones.
final recentMealsProvider = StreamProvider<List<MealLog>>((ref) async* {
  final today = await ref.watch(todayDateProvider.future);
  final user = await ref.watch(currentUserProvider.future);
  yield* ref
      .watch(mealRepositoryProvider)
      .watchBetween(user.id, shiftLocalDate(today, -29), today);
});
