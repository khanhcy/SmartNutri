import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/utils/date_utils.dart';

/// Consecutive calendar days (starting today) where total kcal is in
/// [80%, 110%] of [calorieTarget].
abstract final class CalorieStreak {
  static Future<int> compute({
    required MealService meal,
    required String uid,
    required int calorieTarget,
  }) async {
    if (calorieTarget <= 0) return 0;
    final low = calorieTarget * 0.8;
    final high = calorieTarget * 1.1;
    var streak = 0;
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);
    for (var i = 0; i < 365; i++) {
      final d = base.subtract(Duration(days: i));
      final dateStr = AppDateUtils.toDateStr(d);
      final kcal = await meal.sumCaloriesForDate(uid, dateStr);
      if (kcal >= low && kcal <= high) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
