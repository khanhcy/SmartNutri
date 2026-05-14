import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:smartnutri/src/core/services/cloud_function_client.dart';
import 'package:smartnutri/src/core/services/food_service.dart';
import 'package:smartnutri/src/features/scan/domain/scan_result.dart';
import 'package:smartnutri/src/features/search/domain/food_item.dart';
import 'package:uuid/uuid.dart';

class FoodSuggestion {
  FoodSuggestion({required this.foodItem, required this.reason});
  final FoodItem foodItem;
  final String reason;
}

class AiFoodServiceException implements Exception {
  AiFoodServiceException(this.userMessage, this.cause);

  final String userMessage;
  final Object cause;

  @override
  String toString() => 'AiFoodServiceException: $userMessage';
}

class AiFoodService {
  AiFoodService({required FoodCatalog foodService, FunctionCaller? functions})
    : _foodService = foodService,
      _functions = functions ?? CloudFunctionClient();

  final FoodCatalog _foodService;
  final FunctionCaller _functions;

  Future<ScanResult> identifyFood(String imageBase64) async {
    try {
      // Send known food names so Gemini can match against our database
      final knownNames = _foodService.foods.map((f) => f.name).toList();
      final result = await _functions.call('identifyFoodImage', {
        'imageBase64': imageBase64,
        'knownFoodNames': knownNames,
      });

      final items = result['items'] as List<dynamic>? ?? [];
      final allFoods = await _foodService.getAll();
      final scanned = <ScannedFoodItem>[];

      for (final item in items) {
        if (item is! Map) continue;
        final name = item['name'] as String? ?? '';
        final confidence = (item['confidence'] as num?)?.toDouble() ?? 0;
        final aiKcal = (item['estimatedKcal'] as num?)?.toInt() ?? 0;
        final aiProtein = (item['estimatedProteinG'] as num?)?.toDouble() ?? 0;
        final aiCarb = (item['estimatedCarbG'] as num?)?.toDouble() ?? 0;
        final aiFat = (item['estimatedFatG'] as num?)?.toDouble() ?? 0;
        final aiPortion = (item['estimatedPortionG'] as num?)?.toInt() ?? 100;

        final matched = _fuzzyMatch(name, allFoods);
        if (matched != null) {
          scanned.add(
            ScannedFoodItem(
              foodItem: matched,
              confidence: confidence,
              rawName: name,
            ),
          );
        } else if (name.isNotEmpty && aiKcal > 0) {
          final aiFood = FoodItem(
            id: 'ai_${const Uuid().v4().substring(0, 8)}',
            name: name,
            calorieKcal: aiKcal.toDouble(),
            proteinG: aiProtein,
            carbG: aiCarb,
            fatG: aiFat,
            category: 'AI ước tính',
            defaultPortionG: aiPortion.toDouble(),
          );
          scanned.add(
            ScannedFoodItem(
              foodItem: aiFood,
              confidence: confidence,
              rawName: name,
              isAiEstimated: true,
            ),
          );
        }
      }

      return ScanResult(
        id: const Uuid().v4(),
        items: scanned,
        source: ScanSource.photo,
        scannedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ identifyFood error: $e');
      throw AiFoodServiceException(_aiErrorMessage(e), e);
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
      // Send food catalog as fallback in case Firestore is empty
      final foodCatalog = _foodService.foods
          .map(
            (f) => <String, dynamic>{
              'id': f.id,
              'name': f.name,
              'calorieKcal': f.calorieKcal,
              'proteinG': f.proteinG,
              'carbG': f.carbG,
              'fatG': f.fatG,
              'category': f.category,
            },
          )
          .toList();

      final result = await _functions.call('suggestMeals', {
        'remainingKcal': remainingKcal.round(),
        'proteinG': proteinG.round(),
        'carbG': carbG.round(),
        'fatG': fatG.round(),
        'recentFoodNames': recentFoodNames,
        'mealTime': mealTime,
        'foodCatalog': foodCatalog,
      });

      final suggestions = result['suggestions'] as List<dynamic>? ?? [];
      final allFoods = await _foodService.getAll();

      return suggestions
          .whereType<Map>()
          .map((s) {
            final foodId = s['foodId'] as String? ?? '';
            final reason = s['reason'] as String? ?? '';
            final food = allFoods.cast<FoodItem?>().firstWhere(
              (f) => f?.id == foodId,
              orElse: () => null,
            );
            if (food == null || food.id.isEmpty) return null;
            return FoodSuggestion(foodItem: food, reason: reason);
          })
          .whereType<FoodSuggestion>()
          .toList();
    } catch (e) {
      debugPrint('❌ suggestMeals error: $e');
      throw AiFoodServiceException(_aiErrorMessage(e), e);
    }
  }

  String _aiErrorMessage(Object error) {
    if (error is FunctionsException) {
      if (error.message == 'network_error') {
        return 'Không thể kết nối máy chủ AI. '
            'Kiểm tra Firebase Emulators đã chạy chưa, '
            'hoặc thử lại sau.';
      }
      if (error.message == 'invalid_response') {
        return 'Dữ liệu AI trả về không hợp lệ. Vui lòng thử lại.';
      }
      if (error.message == 'quota_exceeded') {
        return 'Bạn đã dùng hết lượt AI scan miễn phí trong tháng. '
            'Nâng cấp Premium để tiếp tục sử dụng.';
      }
      if (error.statusCode == 401 || error.statusCode == 403) {
        return 'Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.';
      }
      if ((error.statusCode ?? 0) >= 500) {
        return 'Máy chủ AI đang gặp sự cố. Vui lòng thử lại sau.';
      }
      return 'Không thể xử lý yêu cầu AI lúc này. Vui lòng thử lại.';
    }
    return 'Không thể kết nối dịch vụ AI. Vui lòng kiểm tra mạng và thử lại.';
  }

  /// Levenshtein-based fuzzy match with diacritics stripping.
  FoodItem? _fuzzyMatch(String rawName, List<FoodItem> foods) {
    if (rawName.isEmpty || foods.isEmpty) return null;

    final q = _stripDiacritics(rawName).toLowerCase();
    final qWords = q.split(RegExp(r'\s+'));

    // Exact match first
    for (final food in foods) {
      if (food.name.toLowerCase() == rawName.toLowerCase()) return food;
      if (_stripDiacritics(food.name).toLowerCase() == q) return food;
    }

    // Score each food: best = most word overlap + shortest edit distance
    FoodItem? best;
    int bestScore = 999;

    for (final food in foods) {
      final fName = _stripDiacritics(food.name).toLowerCase();
      final fWords = fName.split(RegExp(r'\s+'));

      // Count matching words
      int matchedWords = 0;
      for (final qw in qWords) {
        for (final fw in fWords) {
          if (fw == qw || _levenshtein(fw, qw) <= 2) {
            matchedWords++;
            break;
          }
        }
      }

      if (matchedWords == 0) continue;

      final dist = _levenshtein(fName, q);
      // Lower score = better match
      final score = dist - (matchedWords * 10);

      if (score < bestScore) {
        bestScore = score;
        best = food;
      }
    }

    // Threshold: must have at least 1 matching word and reasonable distance
    if (best != null && bestScore <= 10) return best;

    // Fallback: substring containment
    for (final food in foods) {
      final fName = _stripDiacritics(food.name).toLowerCase();
      if (fName.contains(q) || q.contains(fName)) return food;
    }

    return null;
  }

  static int _levenshtein(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    var prev = List<int>.generate(b.length + 1, (i) => i);
    var curr = List<int>.filled(b.length + 1, 0);

    for (var i = 0; i < a.length; i++) {
      curr[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final cost = a[i] == b[j] ? 0 : 1;
        curr[j + 1] = min(min(curr[j] + 1, prev[j + 1] + 1), prev[j] + cost);
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }

    return prev[b.length];
  }

  /// Rule-based meal suggestions — works offline, always returns results.
  List<FoodSuggestion> suggestMealsLocal({
    required double remainingKcal,
    required double proteinG,
    required double carbG,
    required double fatG,
    required List<String> recentFoodNames,
    required String mealTime,
  }) {
    final allFoods = _foodService.foods;
    if (allFoods.isEmpty) return [];

    final avoidSet = recentFoodNames.map((n) => n.toLowerCase()).toSet();
    final available = allFoods
        .where((f) => !avoidSet.contains(f.name.toLowerCase()))
        .toList();
    if (available.isEmpty) return [];

    // Score each food based on how well it fits remaining macros
    final scored = available.map((food) {
      double score = 0;

      // Calorie fit (closer to remaining = better, but don't exceed)
      final kcalRatio = food.calorieKcal / max(remainingKcal, 1);
      if (kcalRatio <= 1.0) {
        score += (1.0 - kcalRatio) * 40; // up to 40 points
      } else if (kcalRatio <= 1.5) {
        score += (1.5 - kcalRatio) * 10; // slight penalty for going over
      }

      // Protein fit
      if (proteinG > 0) {
        final pRatio = food.proteinG / max(proteinG, 1);
        score += min(pRatio, 1.0) * 30; // up to 30 points
      }

      // Meal time relevance
      final isLight = mealTime == 'bữa sáng' || mealTime == 'bữa phụ';
      final isHeavy = mealTime == 'bữa trưa' || mealTime == 'bữa tối';
      if (isLight && food.calorieKcal < 200) score += 15;
      if (isHeavy && food.calorieKcal >= 150) score += 15;

      // Higher protein foods are generally good suggestions
      if (food.proteinG >= 10) score += 10;

      return (food: food, score: score);
    }).toList();

    // Sort by score descending, take top 5
    scored.sort((a, b) => b.score.compareTo(a.score));
    final top = scored.take(5).where((s) => s.score > 0);

    return top.map((s) {
      final reason = _localReason(s.food, mealTime);
      return FoodSuggestion(foodItem: s.food, reason: reason);
    }).toList();
  }

  String _localReason(FoodItem food, String mealTime) {
    if (food.proteinG >= 15) return 'Giàu protein, phù hợp $mealTime';
    if (food.calorieKcal < 150) return 'Nhẹ nhàng cho $mealTime';
    if (food.carbG >= 30) return 'Bổ sung năng lượng cho $mealTime';
    return 'Phù hợp $mealTime';
  }

  static String _stripDiacritics(String input) {
    const diacritics = {
      'à': 'a',
      'á': 'a',
      'ả': 'a',
      'ã': 'a',
      'ạ': 'a',
      'ă': 'a',
      'ằ': 'a',
      'ắ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'ặ': 'a',
      'â': 'a',
      'ầ': 'a',
      'ấ': 'a',
      'ẩ': 'a',
      'ẫ': 'a',
      'ậ': 'a',
      'è': 'e',
      'é': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ẹ': 'e',
      'ê': 'e',
      'ề': 'e',
      'ế': 'e',
      'ể': 'e',
      'ễ': 'e',
      'ệ': 'e',
      'ì': 'i',
      'í': 'i',
      'ỉ': 'i',
      'ĩ': 'i',
      'ị': 'i',
      'ò': 'o',
      'ó': 'o',
      'ỏ': 'o',
      'õ': 'o',
      'ọ': 'o',
      'ô': 'o',
      'ồ': 'o',
      'ố': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ộ': 'o',
      'ơ': 'o',
      'ờ': 'o',
      'ớ': 'o',
      'ở': 'o',
      'ỡ': 'o',
      'ợ': 'o',
      'ù': 'u',
      'ú': 'u',
      'ủ': 'u',
      'ũ': 'u',
      'ụ': 'u',
      'ư': 'u',
      'ừ': 'u',
      'ứ': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ự': 'u',
      'ỳ': 'y',
      'ý': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'ỵ': 'y',
      'đ': 'd',
    };
    return input.split('').map((c) => diacritics[c] ?? c).join();
  }
}
