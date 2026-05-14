import 'package:flutter_test/flutter_test.dart';
import 'package:smartnutri/src/core/services/ai_food_service.dart';
import 'package:smartnutri/src/core/services/food_service.dart';
import 'package:smartnutri/src/core/services/gemini_service.dart' show AiService;
import 'package:smartnutri/src/features/search/domain/food_item.dart';

void main() {
  group('AiFoodService error states', () {
    test(
      'identifyFood returns empty result when AI succeeds with no items',
      () async {
        final service = AiFoodService(
          foodService: _FakeFoodCatalog(_foods),
          ai: _FakeGeminiService(identifyResult: []),
        );

        final result = await service.identifyFood('image-base64');

        expect(result.items, isEmpty);
      },
    );

    test(
      'identifyFood throws user-facing exception when gemini not configured',
      () async {
        final service = AiFoodService(
          foodService: _FakeFoodCatalog(_foods),
          ai: null,
        );

        expect(
          () => service.identifyFood('image-base64'),
          throwsA(
            isA<AiFoodServiceException>().having(
              (e) => e.userMessage,
              'userMessage',
              contains('chưa được cấu hình'),
            ),
          ),
        );
      },
    );

    test(
      'identifyFood throws user-facing exception when function fails',
      () async {
        final service = AiFoodService(
          foodService: _FakeFoodCatalog(_foods),
          ai: _FakeGeminiService(throwError: Exception('internal_error')),
        );

        expect(
          () => service.identifyFood('image-base64'),
          throwsA(
            isA<AiFoodServiceException>().having(
              (e) => e.userMessage,
              'userMessage',
              contains('kiểm tra mạng'),
            ),
          ),
        );
      },
    );

    test(
      'identifyFood matches known foods from catalog',
      () async {
        final service = AiFoodService(
          foodService: _FakeFoodCatalog(_foods),
          ai: _FakeGeminiService(identifyResult: [
            {
              'name': 'Phở bò',
              'estimatedKcal': 68,
              'estimatedProteinG': 5.8,
              'estimatedCarbG': 9.2,
              'estimatedFatG': 1.2,
              'estimatedPortionG': 300,
              'confidence': 0.9,
            },
          ]),
        );

        final result = await service.identifyFood('image-base64');

        expect(result.items, hasLength(1));
        expect(result.items.first.foodItem.id, 'pho_bo');
        expect(result.items.first.confidence, 0.9);
      },
    );

    test('suggestMeals throws when gemini not configured', () async {
      final service = AiFoodService(
        foodService: _FakeFoodCatalog(_foods),
        ai: null,
      );

      expect(
        () => service.suggestMeals(
          remainingKcal: 500,
          proteinG: 20,
          carbG: 60,
          fatG: 10,
          recentFoodNames: const [],
          mealTime: 'bữa trưa',
        ),
        throwsA(
          isA<AiFoodServiceException>().having(
            (e) => e.userMessage,
            'userMessage',
            contains('chưa được cấu hình'),
          ),
        ),
      );
    });

    test('suggestMeals ignores unknown food ids from AI response', () async {
      final service = AiFoodService(
        foodService: _FakeFoodCatalog(_foods),
        ai: _FakeGeminiService(suggestResult: [
          {'foodId': 'pho_bo', 'reason': 'Phù hợp mục tiêu còn lại'},
          {'foodId': 'missing', 'reason': 'Không có trong catalog'},
        ]),
      );

      final suggestions = await service.suggestMeals(
        remainingKcal: 500,
        proteinG: 20,
        carbG: 60,
        fatG: 10,
        recentFoodNames: const [],
        mealTime: 'bữa trưa',
      );

      expect(suggestions, hasLength(1));
      expect(suggestions.single.foodItem.id, 'pho_bo');
    });
  });
}

const _foods = [
  FoodItem(
    id: 'pho_bo',
    name: 'Phở bò',
    calorieKcal: 68,
    proteinG: 5.8,
    carbG: 9.2,
    fatG: 1.2,
    category: 'Món nước',
  ),
];

class _FakeFoodCatalog implements FoodCatalog {
  _FakeFoodCatalog(this.foods);

  @override
  final List<FoodItem> foods;

  @override
  Future<List<FoodItem>> getAll() async => foods;
}

class _FakeGeminiService implements AiService {
  _FakeGeminiService({this.identifyResult, this.suggestResult, this.throwError});

  final List<Map<String, dynamic>>? identifyResult;
  final List<Map<String, dynamic>>? suggestResult;
  final Object? throwError;

  @override
  Future<Map<String, dynamic>> chat({
    required String message,
    required List<Map<String, dynamic>> conversationHistory,
    required Map<String, dynamic> context,
  }) async {
    if (throwError != null) throw throwError!;
    return {'reply': 'test reply'};
  }

  @override
  Future<List<Map<String, dynamic>>> identifyFoodImage({
    required String imageBase64,
    required List<String> knownFoodNames,
  }) async {
    if (throwError != null) throw throwError!;
    return identifyResult ?? [];
  }

  @override
  Future<List<Map<String, dynamic>>> suggestMeals({
    required int remainingKcal,
    required int proteinG,
    required int carbG,
    required int fatG,
    required List<String> recentFoodNames,
    required String mealTime,
    required List<Map<String, dynamic>> foodCatalog,
  }) async {
    if (throwError != null) throw throwError!;
    return suggestResult ?? [];
  }
}
