import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smartnutri/src/core/services/ai_food_service.dart';
import 'package:smartnutri/src/core/services/cloud_function_client.dart';
import 'package:smartnutri/src/core/services/food_service.dart';
import 'package:smartnutri/src/features/search/domain/food_item.dart';

void main() {
  group('AiFoodService error states', () {
    test(
      'identifyFood returns empty result when AI succeeds with no items',
      () async {
        final service = AiFoodService(
          foodService: _FakeFoodCatalog(_foods),
          functions: _FakeFunctions((_, _) => {'items': []}),
        );

        final result = await service.identifyFood('image-base64');

        expect(result.items, isEmpty);
      },
    );

    test(
      'identifyFood throws user-facing exception when function fails',
      () async {
        final service = AiFoodService(
          foodService: _FakeFoodCatalog(_foods),
          functions: _FakeFunctions((_, _) {
            throw FunctionsException('internal_error', 500);
          }),
        );

        expect(
          () => service.identifyFood('image-base64'),
          throwsA(
            isA<AiFoodServiceException>().having(
              (e) => e.userMessage,
              'userMessage',
              contains('Máy chủ AI'),
            ),
          ),
        );
      },
    );

    test(
      'identifyFood shows network error when connection times out',
      () async {
        final service = AiFoodService(
          foodService: _FakeFoodCatalog(_foods),
          functions: _FakeFunctions((_, _) {
            throw FunctionsException('network_error');
          }),
        );

        expect(
          () => service.identifyFood('image-base64'),
          throwsA(
            isA<AiFoodServiceException>().having(
              (e) => e.userMessage,
              'userMessage',
              contains('Firebase Emulators'),
            ),
          ),
        );
      },
    );

    test('suggestMeals ignores unknown food ids from AI response', () async {
      final service = AiFoodService(
        foodService: _FakeFoodCatalog(_foods),
        functions: _FakeFunctions(
          (_, _) => {
            'suggestions': [
              {'foodId': 'pho_bo', 'reason': 'Phù hợp mục tiêu còn lại'},
              {'foodId': 'missing', 'reason': 'Không có trong catalog'},
            ],
          },
        ),
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

class _FakeFunctions implements FunctionCaller {
  _FakeFunctions(this._handler);

  final FutureOr<Map<String, dynamic>> Function(
    String functionName,
    Map<String, dynamic>? data,
  )
  _handler;

  @override
  Future<Map<String, dynamic>> call(
    String functionName, [
    Map<String, dynamic>? data,
  ]) async => _handler(functionName, data);
}
