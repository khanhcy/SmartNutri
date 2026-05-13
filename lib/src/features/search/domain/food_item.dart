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
        calorieKcal: _numberField(m, 'calorieKcal', 'calories'),
        proteinG: _numberField(m, 'proteinG', 'protein'),
        carbG: _numberField(m, 'carbG', 'carbs'),
        fatG: _numberField(m, 'fatG', 'fat'),
        category: m['category'] as String? ?? '',
        defaultPortionG: _numberField(
          m,
          'defaultPortionG',
          'servingSize',
          fallback: 100,
        ),
        region: m['region'] as String?,
        brand: m['brand'] as String?,
        tags: (m['tags'] as List?)?.whereType<String>().toList() ?? [],
        imageUrl: m['imageUrl'] as String?,
        verified: m['verified'] as bool? ?? false,
      );

  static double _numberField(
    Map<String, dynamic> map,
    String canonical,
    String legacy, {
    double fallback = 0,
  }) {
    return _toDouble(map[canonical]) ?? _toDouble(map[legacy]) ?? fallback;
  }

  static double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
    }
    return null;
  }
}
