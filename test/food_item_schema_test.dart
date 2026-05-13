import 'package:flutter_test/flutter_test.dart';
import 'package:smartnutri/src/features/search/domain/food_item.dart';

void main() {
  test('Đọc food schema canonical từ Firestore', () {
    final food = FoodItem.fromMap(const {
      'id': 'pho_bo',
      'name': 'Phở bò',
      'calorieKcal': 68,
      'proteinG': 5.8,
      'carbG': 9.2,
      'fatG': 1.2,
      'category': 'Món nước',
      'defaultPortionG': 400,
      'region': 'miền Bắc',
      'brand': 'Quán Việt',
      'tags': ['truyền thống', 'món nước'],
      'imageUrl': 'https://example.com/pho.jpg',
      'verified': true,
    });

    expect(food.id, 'pho_bo');
    expect(food.name, 'Phở bò');
    expect(food.calorieKcal, 68);
    expect(food.proteinG, 5.8);
    expect(food.carbG, 9.2);
    expect(food.fatG, 1.2);
    expect(food.category, 'Món nước');
    expect(food.defaultPortionG, 400);
    expect(food.region, 'miền Bắc');
    expect(food.brand, 'Quán Việt');
    expect(food.tags, ['truyền thống', 'món nước']);
    expect(food.imageUrl, 'https://example.com/pho.jpg');
    expect(food.verified, isTrue);
  });

  test('Đọc legacy admin schema và map sang canonical fields', () {
    final food = FoodItem.fromMap(const {
      'id': 'legacy-1',
      'name': 'Cơm gà',
      'calories': 140,
      'protein': 9.8,
      'carbs': 18.5,
      'fat': 3.5,
      'category': 'Cơm',
      'servingSize': '350g',
      'tags': ['truyền thống'],
    });

    expect(food.calorieKcal, 140);
    expect(food.proteinG, 9.8);
    expect(food.carbG, 18.5);
    expect(food.fatG, 3.5);
    expect(food.defaultPortionG, 350);
  });

  test('Ưu tiên canonical fields khi legacy fields cùng tồn tại', () {
    final food = FoodItem.fromMap(const {
      'id': 'mixed-1',
      'name': 'Bún bò Huế',
      'calorieKcal': 72,
      'calories': 999,
      'proteinG': 6.2,
      'protein': 99,
      'carbG': 9.8,
      'carbs': 99,
      'fatG': 1.4,
      'fat': 99,
      'defaultPortionG': 400,
      'servingSize': '999g',
    });

    expect(food.calorieKcal, 72);
    expect(food.proteinG, 6.2);
    expect(food.carbG, 9.8);
    expect(food.fatG, 1.4);
    expect(food.defaultPortionG, 400);
  });

  test('toMap chỉ ghi canonical schema', () {
    const food = FoodItem(
      id: 'chao_ga',
      name: 'Cháo gà',
      calorieKcal: 55,
      proteinG: 4.2,
      carbG: 7.8,
      fatG: 0.8,
      category: 'Cháo',
      defaultPortionG: 350,
      tags: ['ấm bụng'],
      verified: true,
    );

    final map = food.toMap();

    expect(map['calorieKcal'], 55);
    expect(map['proteinG'], 4.2);
    expect(map['carbG'], 7.8);
    expect(map['fatG'], 0.8);
    expect(map['defaultPortionG'], 350);
    expect(map.containsKey('calories'), isFalse);
    expect(map.containsKey('protein'), isFalse);
    expect(map.containsKey('carbs'), isFalse);
    expect(map.containsKey('fat'), isFalse);
    expect(map.containsKey('servingSize'), isFalse);
  });

  test('Dùng giá trị mặc định khi thiếu field optional', () {
    final food = FoodItem.fromMap(const {
      'name': 'Món mới',
    });

    expect(food.id, '');
    expect(food.name, 'Món mới');
    expect(food.calorieKcal, 0);
    expect(food.proteinG, 0);
    expect(food.carbG, 0);
    expect(food.fatG, 0);
    expect(food.defaultPortionG, 100);
    expect(food.tags, isEmpty);
    expect(food.verified, isFalse);
  });
}
