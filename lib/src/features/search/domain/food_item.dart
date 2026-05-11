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
    this.region,
    this.brand,
    this.tags = const [],
    this.imageUrl,
    this.verified = false,
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

  /// 'miền Bắc' | 'miền Trung' | 'miền Nam'
  final String? region;

  /// 'Highlands' | 'Phúc Long' | 'KFC' | ...
  final String? brand;

  /// ['chay', 'giàu đạm', 'ăn kiêng', ...]
  final List<String> tags;

  final String? imageUrl;
  final bool verified;

  double calorieForPortion(double portionG) => calorieKcal * portionG / 100;
  double proteinForPortion(double portionG) => proteinG * portionG / 100;
  double carbForPortion(double portionG) => carbG * portionG / 100;
  double fatForPortion(double portionG) => fatG * portionG / 100;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'name': name,
      'calorieKcal': calorieKcal,
      'proteinG': proteinG,
      'carbG': carbG,
      'fatG': fatG,
      'category': category,
      'defaultPortionG': defaultPortionG,
      'tags': tags,
      'verified': verified,
    };
    if (region != null) map['region'] = region;
    if (brand != null) map['brand'] = brand;
    if (imageUrl != null) map['imageUrl'] = imageUrl;
    return map;
  }

  factory FoodItem.fromMap(Map<String, dynamic> m) => FoodItem(
        id: m['id'] as String? ?? '',
        name: m['name'] as String? ?? '',
        calorieKcal: (m['calorieKcal'] as num?)?.toDouble() ?? 0,
        proteinG: (m['proteinG'] as num?)?.toDouble() ?? 0,
        carbG: (m['carbG'] as num?)?.toDouble() ?? 0,
        fatG: (m['fatG'] as num?)?.toDouble() ?? 0,
        category: m['category'] as String? ?? '',
        defaultPortionG: (m['defaultPortionG'] as num?)?.toDouble() ?? 100,
        region: m['region'] as String?,
        brand: m['brand'] as String?,
        tags: (m['tags'] as List?)?.cast<String>() ?? [],
        imageUrl: m['imageUrl'] as String?,
        verified: m['verified'] as bool? ?? false,
      );
}
