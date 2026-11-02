import '../../data/app_database.dart';
import 'food_list.dart';

/// Values for [servings] of [food], rounded for display. Never more precise
/// than the estimate they come from.
class ScaledFood {
  const ScaledFood({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
}

double _round1(double v) => (v * 10).round() / 10;

ScaledFood scaleFood(FoodItem food, double servings) => ScaledFood(
  calories: (food.calories * servings).round(),
  proteinG: _round1(food.proteinG * servings),
  carbsG: _round1(food.carbsG * servings),
  fatG: _round1(food.fatG * servings),
);

/// What a set of meals adds up to.
class MealTotals {
  const MealTotals({
    required this.servings,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.withoutValues,
  });

  final double servings;

  /// Sum over meals that have a calorie value; null when none do.
  final int? calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  /// Meals left out of the calorie total because they have no value.
  final int withoutValues;
}

MealTotals totalsOf(Iterable<MealLog> meals) {
  var servings = 0.0;
  var kcal = 0;
  var any = false;
  var missing = 0;
  var p = 0.0, c = 0.0, f = 0.0;
  for (final m in meals) {
    if (m.deletedAt != null) continue;
    servings += m.servings;
    if (m.calories == null) {
      missing++;
    } else {
      any = true;
      kcal += m.calories!;
    }
    p += m.proteinG ?? 0;
    c += m.carbsG ?? 0;
    f += m.fatG ?? 0;
  }
  return MealTotals(
    servings: servings,
    calories: any ? kcal : null,
    proteinG: _round1(p),
    carbsG: _round1(c),
    fatG: _round1(f),
    withoutValues: missing,
  );
}

/// The meals logged most often, newest example of each, for quick re-entry.
/// Names are compared ignoring case. Ties go to the more recent meal.
List<MealLog> commonMeals(Iterable<MealLog> logs, {int limit = 6}) {
  final counts = <String, int>{};
  final latest = <String, MealLog>{};
  for (final l in logs) {
    if (l.deletedAt != null) continue;
    final key = l.name.trim().toLowerCase();
    counts[key] = (counts[key] ?? 0) + 1;
    final seen = latest[key];
    if (seen == null || l.loggedAt.isAfter(seen.loggedAt)) latest[key] = l;
  }
  final keys = counts.keys.toList()
    ..sort((a, b) {
      final byCount = counts[b]!.compareTo(counts[a]!);
      if (byCount != 0) return byCount;
      return latest[b]!.loggedAt.compareTo(latest[a]!.loggedAt);
    });
  return [for (final k in keys.take(limit)) latest[k]!];
}

/// `1 serving`, `1.5 servings`, `2 servings`.
String servingsText(double s) {
  final whole = s == s.roundToDouble();
  final n = whole ? s.round().toString() : s.toStringAsFixed(1);
  return '$n ${s == 1 ? 'serving' : 'servings'}';
}

/// `~270 kcal`: rounded, with the estimate marked.
String kcalText(int kcal) => '~$kcal kcal';
