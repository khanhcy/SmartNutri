import 'package:flutter_test/flutter_test.dart';
import 'package:smartnutri/src/core/services/favorites_service.dart';
import 'package:smartnutri/src/core/services/food_service.dart';
import 'package:smartnutri/src/features/search/domain/food_item.dart';

class _FakeFoodCatalog implements FoodCatalog {
  _FakeFoodCatalog(this._foods);
  final List<FoodItem> _foods;

  @override
  List<FoodItem> get foods => _foods;

  @override
  Future<List<FoodItem>> getAll() async => _foods;
}

void main() {
  group('FavoriteFoodsService', () {
    test('favorites trả về list trống khi chưa init', () {
      final service = FavoriteFoodsService(
        foodCatalog: _FakeFoodCatalog([]),
      );
      expect(service.favorites, isEmpty);
    });

    test('disposeFor xoá danh sách favorites', () {
      final service = FavoriteFoodsService(
        foodCatalog: _FakeFoodCatalog([]),
      );
      service.disposeFor('user-1');
      expect(service.favorites, isEmpty);
    });

    test('favorites trả về list không thể chỉnh sửa', () {
      final service = FavoriteFoodsService(
        foodCatalog: _FakeFoodCatalog([]),
      );
      expect(
        () => service.favorites.add(
          const FoodItem(
            id: 'test', name: 'Test', calorieKcal: 0,
            proteinG: 0, carbG: 0, fatG: 0,
            category: '', defaultPortionG: 100,
          ),
        ),
        throwsUnsupportedError,
      );
    });

    test('khởi tạo thành công với FoodCatalog', () {
      final service = FavoriteFoodsService(
        foodCatalog: _FakeFoodCatalog([
          const FoodItem(
            id: 'pho_bo', name: 'Phở bò', calorieKcal: 68,
            proteinG: 5.8, carbG: 9.2, fatG: 1.2,
            category: 'Món nước', defaultPortionG: 100,
          ),
        ]),
      );
      expect(service, isNotNull);
      expect(service.favorites, isEmpty);
    });
  });
}
