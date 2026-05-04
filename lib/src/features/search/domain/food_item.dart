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

  double calorieForPortion(double portionG) => calorieKcal * portionG / 100;
  double proteinForPortion(double portionG) => proteinG * portionG / 100;
  double carbForPortion(double portionG) => carbG * portionG / 100;
  double fatForPortion(double portionG) => fatG * portionG / 100;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'calorieKcal': calorieKcal,
        'proteinG': proteinG,
        'carbG': carbG,
        'fatG': fatG,
        'category': category,
        'defaultPortionG': defaultPortionG,
      };

  factory FoodItem.fromMap(Map<String, dynamic> m) => FoodItem(
        id: m['id'] as String,
        name: m['name'] as String,
        calorieKcal: (m['calorieKcal'] as num).toDouble(),
        proteinG: (m['proteinG'] as num).toDouble(),
        carbG: (m['carbG'] as num).toDouble(),
        fatG: (m['fatG'] as num).toDouble(),
        category: m['category'] as String? ?? '',
        defaultPortionG: (m['defaultPortionG'] as num?)?.toDouble() ?? 100,
      );
}
