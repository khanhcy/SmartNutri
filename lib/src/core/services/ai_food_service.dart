import 'package:cloud_functions/cloud_functions.dart';
import 'package:smartnutri/src/core/services/food_service.dart';
import 'package:smartnutri/src/features/search/domain/food_item.dart';

class AiFoodCandidate {
  AiFoodCandidate({
    required this.foodItem,
    required this.confidence,
    required this.estimatedKcal,
    this.rawName = '',
  });

  final FoodItem foodItem;
  final double confidence;
  final int estimatedKcal;
  final String rawName;
}

class FoodSuggestion {
  FoodSuggestion({required this.foodItem, required this.reason});

  final FoodItem foodItem;
  final String reason;
}

class AiFoodService {
  AiFoodService({
    FirebaseFunctions? functions,
    required FoodService foodService,
  })  : _functions = functions ?? FirebaseFunctions.instance,
        _foodService = foodService;

  final FirebaseFunctions _functions;
  final FoodService _foodService;

  Future<List<AiFoodCandidate>> identifyFood(String imageBase64) async {
    try {
      final callable = _functions.httpsCallable('identifyFoodImage');
      final result = await callable.call<String, dynamic>({
        'imageBase64': imageBase64,
      });

      final items = result.data['items'] as List<dynamic>? ?? [];
      final candidates = <AiFoodCandidate>[];
      final allFoods = await _foodService.getAll();

      for (final item in items) {
        if (item is! Map) continue;
        final name = item['name'] as String? ?? '';
        final confidence = (item['confidence'] as num?)?.toDouble() ?? 0;
        final estimatedKcal = (item['estimatedKcal'] as num?)?.toInt() ?? 0;

        final matched = _fuzzyMatch(name, allFoods);
        if (matched != null) {
          candidates.add(AiFoodCandidate(
            foodItem: matched,
            confidence: confidence,
            estimatedKcal: estimatedKcal,
            rawName: name,
          ));
        }
      }

      return candidates;
    } catch (_) {
      return [];
    }
  }

  Future<List<FoodSuggestion>> suggestMeals({
    required double remainingKcal,
    required double proteinG,
    required double carbG,
    required double fatG,
    required List<String> recentFoodNames,
    required String mealTime,
  }) async {
    try {
      final callable = _functions.httpsCallable('suggestMeals');
      final result = await callable.call<String, dynamic>({
        'remainingKcal': remainingKcal.round(),
        'proteinG': proteinG.round(),
        'carbG': carbG.round(),
        'fatG': fatG.round(),
        'recentFoodNames': recentFoodNames,
        'mealTime': mealTime,
      });

      final suggestions =
          result.data['suggestions'] as List<dynamic>? ?? [];
      final allFoods = await _foodService.getAll();

      return suggestions.map((s) {
        final foodId = s['foodId'] as String? ?? '';
        final reason = s['reason'] as String? ?? '';
        final food = allFoods.cast<FoodItem?>().firstWhere(
              (f) => f?.id == foodId,
              orElse: () => null,
            );
        return FoodSuggestion(foodItem: food!, reason: reason);
      }).where((s) => s.foodItem.id.isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }

  /// Fuzzy match: strip diacritics, lowercase, substring match.
  FoodItem? _fuzzyMatch(String rawName, List<FoodItem> foods) {
    if (rawName.isEmpty || foods.isEmpty) return null;

    // Try exact match first
    final exact = foods.cast<FoodItem?>().firstWhere(
          (f) => f!.name.toLowerCase() == rawName.toLowerCase(),
          orElse: () => null,
        );
    if (exact != null) return exact;

    // Strip diacritics for both
    final q = _stripDiacritics(rawName).toLowerCase();
    for (final food in foods) {
      final fName = _stripDiacritics(food.name).toLowerCase();
      if (fName.contains(q) || q.contains(fName)) return food;
    }
    return null;
  }

  static String _stripDiacritics(String input) {
    const _map = {
      'à': 'a', 'á': 'a', 'ả': 'a', 'ã': 'a', 'ạ': 'a',
      'ă': 'a', 'ằ': 'a', 'ắ': 'a', 'ẳ': 'a', 'ẵ': 'a', 'ặ': 'a',
      'â': 'a', 'ầ': 'a', 'ấ': 'a', 'ẩ': 'a', 'ẫ': 'a', 'ậ': 'a',
      'è': 'e', 'é': 'e', 'ẻ': 'e', 'ẽ': 'e', 'ẹ': 'e',
      'ê': 'e', 'ề': 'e', 'ế': 'e', 'ể': 'e', 'ễ': 'e', 'ệ': 'e',
      'ì': 'i', 'í': 'i', 'ỉ': 'i', 'ĩ': 'i', 'ị': 'i',
      'ò': 'o', 'ó': 'o', 'ỏ': 'o', 'õ': 'o', 'ọ': 'o',
      'ô': 'o', 'ồ': 'o', 'ố': 'o', 'ổ': 'o', 'ỗ': 'o', 'ộ': 'o',
      'ơ': 'o', 'ờ': 'o', 'ớ': 'o', 'ở': 'o', 'ỡ': 'o', 'ợ': 'o',
      'ù': 'u', 'ú': 'u', 'ủ': 'u', 'ũ': 'u', 'ụ': 'u',
      'ư': 'u', 'ừ': 'u', 'ứ': 'u', 'ử': 'u', 'ữ': 'u', 'ự': 'u',
      'ỳ': 'y', 'ý': 'y', 'ỷ': 'y', 'ỹ': 'y', 'ỵ': 'y',
      'đ': 'd',
    };
    return input.split('').map((c) => _map[c] ?? c).join();
  }
}
