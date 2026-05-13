import 'package:flutter_test/flutter_test.dart';
import 'package:smartnutri/src/features/meal_log/domain/meal_entry.dart';

void main() {
  group('MealTypeX', () {
    test('trả về nhãn tiếng Việt cho từng loại bữa', () {
      expect(MealType.breakfast.label, 'Bữa sáng');
      expect(MealType.lunch.label, 'Bữa trưa');
      expect(MealType.dinner.label, 'Bữa tối');
      expect(MealType.snack.label, 'Bữa phụ');
    });

    test('trả về icon tương ứng cho từng loại bữa', () {
      expect(MealType.breakfast.icon, isNotNull);
      expect(MealType.lunch.icon, isNotNull);
      expect(MealType.dinner.icon, isNotNull);
      expect(MealType.snack.icon, isNotNull);
    });
  });

  group('MealEntry.fromMap', () {
    test('đọc đầy đủ các trường từ Firestore map', () {
      final entry = MealEntry.fromMap('entry-1', {
        'uid': 'user-1',
        'date': '2026-05-14',
        'mealType': 'lunch',
        'foodName': 'Phở bò',
        'portionG': 400,
        'calorieKcal': 272,
        'proteinG': 23.2,
        'carbG': 36.8,
        'fatG': 4.8,
        'loggedAt': '2026-05-14T12:00:00.000Z',
      });

      expect(entry.id, 'entry-1');
      expect(entry.uid, 'user-1');
      expect(entry.date, '2026-05-14');
      expect(entry.mealType, MealType.lunch);
      expect(entry.foodName, 'Phở bò');
      expect(entry.portionG, 400);
      expect(entry.calorieKcal, 272);
      expect(entry.proteinG, 23.2);
      expect(entry.carbG, 36.8);
      expect(entry.fatG, 4.8);
      expect(entry.loggedAt, DateTime.parse('2026-05-14T12:00:00.000Z'));
    });

    test('dùng giá trị mặc định khi map rỗng', () {
      final entry = MealEntry.fromMap('entry-2', {});

      expect(entry.id, 'entry-2');
      expect(entry.uid, '');
      expect(entry.date, '');
      expect(entry.mealType, MealType.snack);
      expect(entry.foodName, '');
      expect(entry.portionG, 100);
      expect(entry.calorieKcal, 0);
      expect(entry.proteinG, 0);
      expect(entry.carbG, 0);
      expect(entry.fatG, 0);
      expect(entry.loggedAt, isA<DateTime>());
    });

    test('fallback về snack khi mealType không xác định', () {
      final entry = MealEntry.fromMap('entry-3', {
        'mealType': 'invalid_type',
      });

      expect(entry.mealType, MealType.snack);
    });

    test('cast numeric fields về đúng kiểu', () {
      final entry = MealEntry.fromMap('entry-4', {
        'portionG': 350,
        'calorieKcal': 300.7,
        'proteinG': 25,
        'carbG': 40,
        'fatG': 10.3,
        'loggedAt': '2026-05-14T08:30:00.000Z',
      });

      expect(entry.portionG, 350.0);
      expect(entry.calorieKcal, 300.7);
      expect(entry.proteinG, 25.0);
      expect(entry.carbG, 40.0);
      expect(entry.fatG, 10.3);
    });

    test('dùng DateTime.now() khi loggedAt không hợp lệ', () {
      final before = DateTime.now();
      final entry = MealEntry.fromMap('entry-5', {
        'loggedAt': 'không-phải-ngày',
      });
      final after = DateTime.now();

      expect(entry.loggedAt.isBefore(before), isFalse);
      expect(entry.loggedAt.isAfter(after), isFalse);
    });
  });

  group('MealEntry.toMap', () {
    test('xuất đúng tất cả field sang map', () {
      final entry = MealEntry(
        id: 'entry-6',
        uid: 'user-2',
        date: '2026-05-14',
        mealType: MealType.dinner,
        foodName: 'Cơm gà',
        portionG: 350,
        calorieKcal: 490,
        proteinG: 34.3,
        carbG: 64.8,
        fatG: 12.3,
        loggedAt: DateTime.parse('2026-05-14T19:00:00.000Z'),
      );

      final map = entry.toMap();

      expect(map['uid'], 'user-2');
      expect(map['date'], '2026-05-14');
      expect(map['mealType'], 'dinner');
      expect(map['foodName'], 'Cơm gà');
      expect(map['portionG'], 350);
      expect(map['calorieKcal'], 490);
      expect(map['proteinG'], 34.3);
      expect(map['carbG'], 64.8);
      expect(map['fatG'], 12.3);
      expect(map['loggedAt'], '2026-05-14T19:00:00.000Z');
    });

    test('toMap rồi fromMap giữ nguyên giá trị', () {
      final original = MealEntry(
        id: 'entry-7',
        uid: 'user-3',
        date: '2026-05-13',
        mealType: MealType.breakfast,
        foodName: 'Bánh mì ốp la',
        portionG: 200,
        calorieKcal: 350,
        proteinG: 14.0,
        carbG: 42.0,
        fatG: 12.0,
        loggedAt: DateTime.parse('2026-05-13T07:30:00.000Z'),
      );

      final restored = MealEntry.fromMap('entry-7', original.toMap());

      expect(restored.id, original.id);
      expect(restored.uid, original.uid);
      expect(restored.date, original.date);
      expect(restored.mealType, original.mealType);
      expect(restored.foodName, original.foodName);
      expect(restored.portionG, original.portionG);
      expect(restored.calorieKcal, original.calorieKcal);
      expect(restored.proteinG, original.proteinG);
      expect(restored.carbG, original.carbG);
      expect(restored.fatG, original.fatG);
      expect(restored.loggedAt, original.loggedAt);
    });
  });
}
