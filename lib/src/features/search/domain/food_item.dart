class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.calorieKcal,
    required this.proteinG,
    required this.carbG,
    required this.fatG,
    this.category = '',
    this.defaultPortionG = 100,
  });

  final String id;
  final String name;

  /// Nutritional values per 100g.
  final double calorieKcal;
  final double proteinG;
  final double carbG;
  final double fatG;
  final String category;
  final double defaultPortionG;

  /// Calculate nutrients for a given portion size.
  double calorieForPortion(double portionG) => calorieKcal * portionG / 100;
  double proteinForPortion(double portionG) => proteinG * portionG / 100;
  double carbForPortion(double portionG) => carbG * portionG / 100;
  double fatForPortion(double portionG) => fatG * portionG / 100;
}
