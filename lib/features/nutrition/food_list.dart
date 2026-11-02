/// A food from the built-in list, with typical values for one serving.
///
/// The numbers are rounded, typical values for common home-style portions.
/// They have not been checked against a national food composition database,
/// so the app always labels them as estimates and lets the person change
/// them. Coverage of Indian foods and recipes is deliberately a starting
/// point, to be reviewed against IFCT and USDA FoodData Central before it is
/// described as anything more.
class FoodItem {
  const FoodItem(
    this.name,
    this.serving,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
  );

  final String name;

  /// What one serving is, such as `1 cup` or `1 medium`.
  final String serving;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
}

const foodListNote =
    'Typical values for one serving, rounded. They are estimates and vary '
    'with the recipe and portion.';

const builtinFoods = <FoodItem>[
  FoodItem('Roti (chapati)', '1 medium', 120, 3.5, 20, 3),
  FoodItem('Paratha, plain', '1', 210, 4, 30, 8),
  FoodItem('Rice, cooked', '1 cup', 205, 4, 45, 0.4),
  FoodItem('Dal, cooked', '1 cup', 180, 12, 30, 1),
  FoodItem('Sambar', '1 cup', 130, 6, 20, 3),
  FoodItem('Rajma', '1 cup', 215, 13, 37, 1),
  FoodItem('Chole', '1 cup', 270, 12, 40, 7),
  FoodItem('Vegetable curry', '1 cup', 150, 4, 16, 8),
  FoodItem('Chicken curry', '1 cup', 240, 20, 6, 15),
  FoodItem('Paneer', '50 g', 130, 9, 1.5, 10),
  FoodItem('Idli', '1', 40, 2, 8, 0.2),
  FoodItem('Dosa, plain', '1', 135, 3, 25, 3),
  FoodItem('Upma', '1 cup', 230, 5, 36, 7),
  FoodItem('Poha', '1 cup', 250, 5, 40, 8),
  FoodItem('Biryani', '1 plate', 450, 15, 60, 15),
  FoodItem('Samosa', '1', 260, 4, 24, 17),
  FoodItem('Curd (yogurt)', '1 cup', 150, 8.5, 11, 8),
  FoodItem('Milk', '1 cup', 150, 8, 12, 8),
  FoodItem('Tea with milk and sugar', '1 cup', 70, 2, 10, 2.5),
  FoodItem('Egg, boiled', '1', 78, 6, 0.6, 5),
  FoodItem('Bread', '1 slice', 80, 3, 14, 1),
  FoodItem('Oats, cooked', '1 cup', 160, 6, 28, 3.5),
  FoodItem('Salad, mixed', '1 bowl', 50, 2, 10, 0.5),
  FoodItem('Banana', '1', 105, 1.3, 27, 0.4),
  FoodItem('Apple', '1', 95, 0.5, 25, 0.3),
  FoodItem('Orange', '1', 62, 1.2, 15, 0.2),
  FoodItem('Almonds', '10', 70, 2.6, 2.5, 6),
  FoodItem('Fruit juice', '1 glass', 110, 1, 26, 0.3),
];

/// Foods whose name contains [query], ignoring case, in list order.
List<FoodItem> searchFoods(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  return [
    for (final f in builtinFoods)
      if (f.name.toLowerCase().contains(q)) f,
  ];
}
