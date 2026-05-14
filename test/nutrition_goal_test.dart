import 'package:flutter_test/flutter_test.dart';
import 'package:smartnutri/src/features/nutrition/domain/nutrition_goal.dart';

void main() {
  group('NutritionGoal.fromProfile', () {
    test('calculates daily calories and macros from profile inputs', () {
      final goal = NutritionGoal.fromProfile(
        uid: 'user-1',
        weightKg: 70,
        heightCm: 175,
        age: 30,
        gender: 'male',
        activityLevel: 'light',
      );

      expect(goal.uid, 'user-1');
      expect(goal.calorieTarget, 2267);
      expect(goal.proteinG, 112);
      expect(goal.fatG, 63);
      expect(goal.carbG, 313);
      expect(goal.waterTargetMl, 2500);
    });

    test('uses female profile inputs when calculating goal targets', () {
      final goal = NutritionGoal.fromProfile(
        uid: 'user-2',
        weightKg: 60,
        heightCm: 165,
        age: 28,
        gender: 'female',
        activityLevel: 'moderate',
      );

      expect(goal.uid, 'user-2');
      expect(goal.calorieTarget, 2062);
      expect(goal.proteinG, 96);
      expect(goal.fatG, 57);
      expect(goal.carbG, 291);
      expect(goal.waterTargetMl, 2500);
    });

    test('falls back to light activity multiplier when activityLevel is unknown', () {
      final goal = NutritionGoal.fromProfile(
        uid: 'user-3',
        weightKg: 70,
        heightCm: 175,
        age: 30,
        gender: 'male',
        activityLevel: 'unknown',
      );

      expect(goal.uid, 'user-3');
      expect(goal.calorieTarget, 2267);
      expect(goal.proteinG, 112);
      expect(goal.fatG, 63);
      expect(goal.carbG, 313);
      expect(goal.waterTargetMl, 2500);
    });

    test('keeps values when converting between toMap and fromMap', () {
      final original = NutritionGoal(
        uid: 'user-4',
        calorieTarget: 1900,
        proteinG: 130,
        carbG: 210,
        fatG: 60,
        targetWeightKg: 58.5,
        waterTargetMl: 2200,
        updatedAt: DateTime.parse('2026-01-15T08:30:00.000Z'),
      );

      final map = original.toMap();
      final restored = NutritionGoal.fromMap('user-4', map);

      expect(restored.uid, 'user-4');
      expect(restored.calorieTarget, 1900);
      expect(restored.proteinG, 130);
      expect(restored.carbG, 210);
      expect(restored.fatG, 60);
      expect(restored.targetWeightKg, 58.5);
      expect(restored.waterTargetMl, 2200);
      expect(restored.updatedAt, DateTime.parse('2026-01-15T08:30:00.000Z'));
    });

    test('uses defaults when fromMap input is missing fields', () {
      final before = DateTime.now();
      final restored = NutritionGoal.fromMap('user-5', {});
      final after = DateTime.now();

      expect(restored.uid, 'user-5');
      expect(restored.calorieTarget, 2000);
      expect(restored.proteinG, 120);
      expect(restored.carbG, 250);
      expect(restored.fatG, 65);
      expect(restored.targetWeightKg, isNull);
      expect(restored.waterTargetMl, 2500);
      expect(restored.updatedAt.isBefore(before), isFalse);
      expect(restored.updatedAt.isAfter(after), isFalse);
    });

    test('casts numeric map values to expected goal field types', () {
      final restored = NutritionGoal.fromMap('user-6', {
        'calorieTarget': 1900.9,
        'proteinG': 120.8,
        'carbG': 250.2,
        'fatG': 65.7,
        'targetWeightKg': 57,
        'waterTargetMl': 2300.4,
        'updatedAt': '2026-02-01T10:00:00.000Z',
      });

      expect(restored.uid, 'user-6');
      expect(restored.calorieTarget, 1900);
      expect(restored.proteinG, 120);
      expect(restored.carbG, 250);
      expect(restored.fatG, 65);
      expect(restored.targetWeightKg, 57.0);
      expect(restored.waterTargetMl, 2300.4);
      expect(restored.updatedAt, DateTime.parse('2026-02-01T10:00:00.000Z'));
    });

    test('copyWith updates provided fields and keeps other values', () {
      final original = NutritionGoal(
        uid: 'user-7',
        calorieTarget: 2000,
        proteinG: 120,
        carbG: 250,
        fatG: 65,
        targetWeightKg: 62.0,
        waterTargetMl: 2400,
        updatedAt: DateTime.parse('2026-03-01T00:00:00.000Z'),
      );

      final before = DateTime.now();
      final updated = original.copyWith(calorieTarget: 2100, waterTargetMl: 2600);
      final after = DateTime.now();

      expect(updated.uid, 'user-7');
      expect(updated.calorieTarget, 2100);
      expect(updated.waterTargetMl, 2600);
      expect(updated.proteinG, 120);
      expect(updated.carbG, 250);
      expect(updated.fatG, 65);
      expect(updated.targetWeightKg, 62.0);
      expect(updated.updatedAt.isBefore(before), isFalse);
      expect(updated.updatedAt.isAfter(after), isFalse);
    });

    test('defaultGoal returns expected baseline targets', () {
      final before = DateTime.now();
      final goal = NutritionGoal.defaultGoal('user-8');
      final after = DateTime.now();

      expect(goal.uid, 'user-8');
      expect(goal.calorieTarget, 2000);
      expect(goal.proteinG, 120);
      expect(goal.carbG, 250);
      expect(goal.fatG, 65);
      expect(goal.targetWeightKg, isNull);
      expect(goal.waterTargetMl, 2500);
      expect(goal.updatedAt.isBefore(before), isFalse);
      expect(goal.updatedAt.isAfter(after), isFalse);
    });

    test('falls back to now when fromMap updatedAt is invalid', () {
      final before = DateTime.now();
      final restored = NutritionGoal.fromMap('user-9', {
        'calorieTarget': 1800,
        'proteinG': 110,
        'carbG': 220,
        'fatG': 55,
        'updatedAt': 'not-a-date',
      });
      final after = DateTime.now();

      expect(restored.uid, 'user-9');
      expect(restored.calorieTarget, 1800);
      expect(restored.proteinG, 110);
      expect(restored.carbG, 220);
      expect(restored.fatG, 55);
      expect(restored.updatedAt.isBefore(before), isFalse);
      expect(restored.updatedAt.isAfter(after), isFalse);
    });
  });

  group('NutritionGoal.resolveForDisplay', () {
    test('keeps stored goal when all values are reasonable', () {
      final storedGoal = NutritionGoal(
        uid: 'user-10',
        calorieTarget: 1900,
        proteinG: 110,
        carbG: 220,
        fatG: 55,
        waterTargetMl: 2300,
        updatedAt: DateTime.parse('2026-04-01T00:00:00.000Z'),
      );

      final resolved = NutritionGoal.resolveForDisplay(
        uid: 'user-10',
        storedGoal: storedGoal,
        weightKg: 70,
        heightCm: 175,
        age: 30,
        gender: 'male',
        activityLevel: 'moderate',
      );

      expect(resolved, same(storedGoal));
    });

    test('recalculates unreasonable stored goal from profile inputs', () {
      final storedGoal = NutritionGoal(
        uid: 'user-11',
        calorieTarget: 153440,
        proteinG: 120,
        carbG: 250,
        fatG: 65,
        waterTargetMl: 2400,
        updatedAt: DateTime.parse('2026-04-01T00:00:00.000Z'),
      );

      final resolved = NutritionGoal.resolveForDisplay(
        uid: 'user-11',
        storedGoal: storedGoal,
        weightKg: 70,
        heightCm: 175,
        age: 30,
        gender: 'male',
        activityLevel: 'light',
      );

      expect(resolved.uid, 'user-11');
      expect(resolved.calorieTarget, 2267);
      expect(resolved.proteinG, 112);
      expect(resolved.fatG, 63);
      expect(resolved.carbG, 313);
      expect(resolved.waterTargetMl, 2400);
    });

    test('uses default goal when stored goal is unreasonable and profile inputs are missing', () {
      final storedGoal = NutritionGoal(
        uid: 'user-12',
        calorieTarget: 500,
        proteinG: 120,
        carbG: 250,
        fatG: 65,
        updatedAt: DateTime.parse('2026-04-01T00:00:00.000Z'),
      );

      final before = DateTime.now();
      final resolved = NutritionGoal.resolveForDisplay(
        uid: 'user-12',
        storedGoal: storedGoal,
      );
      final after = DateTime.now();

      expect(resolved.uid, 'user-12');
      expect(resolved.calorieTarget, 2000);
      expect(resolved.proteinG, 120);
      expect(resolved.carbG, 250);
      expect(resolved.fatG, 65);
      expect(resolved.waterTargetMl, 2500);
      expect(resolved.updatedAt.isBefore(before), isFalse);
      expect(resolved.updatedAt.isAfter(after), isFalse);
    });
  });
}
