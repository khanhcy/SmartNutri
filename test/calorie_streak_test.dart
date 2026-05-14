import 'package:flutter_test/flutter_test.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/utils/calorie_streak.dart';
import 'package:smartnutri/src/core/utils/date_utils.dart';
import 'package:smartnutri/src/features/meal_log/domain/meal_entry.dart';

void main() {
  group('CalorieStreak.compute', () {
    test('returns 0 and does not query meals when calorie target is invalid', () async {
      final meal = _FakeMealService({});

      final streak = await CalorieStreak.compute(
        meal: meal,
        uid: 'user-1',
        calorieTarget: 0,
      );

      expect(streak, 0);
      expect(meal.queriedDates, isEmpty);
    });

    test('counts consecutive days within 80 to 110 percent of target from today', () async {
      final today = _today();
      final meal = _FakeMealService({
        AppDateUtils.toDateStr(today): 2000,
        AppDateUtils.toDateStr(today.subtract(const Duration(days: 1))): 1600,
        AppDateUtils.toDateStr(today.subtract(const Duration(days: 2))): 2200,
        AppDateUtils.toDateStr(today.subtract(const Duration(days: 3))): 1599,
      });

      final streak = await CalorieStreak.compute(
        meal: meal,
        uid: 'user-2',
        calorieTarget: 2000,
      );

      expect(streak, 3);
      expect(meal.queriedDates, [
        AppDateUtils.toDateStr(today),
        AppDateUtils.toDateStr(today.subtract(const Duration(days: 1))),
        AppDateUtils.toDateStr(today.subtract(const Duration(days: 2))),
        AppDateUtils.toDateStr(today.subtract(const Duration(days: 3))),
      ]);
    });

    test('returns 0 when today is outside the target range', () async {
      final today = _today();
      final meal = _FakeMealService({
        AppDateUtils.toDateStr(today): 2300,
        AppDateUtils.toDateStr(today.subtract(const Duration(days: 1))): 2000,
      });

      final streak = await CalorieStreak.compute(
        meal: meal,
        uid: 'user-3',
        calorieTarget: 2000,
      );

      expect(streak, 0);
      expect(meal.queriedDates, [AppDateUtils.toDateStr(today)]);
    });
  });
}

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

class _FakeMealService implements MealService {
  _FakeMealService(this.caloriesByDate);

  final Map<String, double> caloriesByDate;
  final queriedDates = <String>[];

  @override
  Future<double> sumCaloriesForDate(String uid, String date) async {
    queriedDates.add(date);
    return caloriesByDate[date] ?? 0;
  }

  @override
  Future<void> addEntry(String uid, MealEntry entry) async {}

  @override
  Future<void> deleteEntry(String uid, String entryId) async {}

  @override
  Future<List<MealEntry>> getEntriesForDate(String uid, String date) async {
    return const [];
  }

  @override
  Future<void> updateEntry(String uid, MealEntry entry) async {}

  @override
  Stream<List<MealEntry>> watchEntriesForDate(String uid, String date) {
    return const Stream.empty();
  }
}
