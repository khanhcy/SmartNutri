import 'package:cloud_functions/cloud_functions.dart';
import 'package:smartnutri/src/features/search/domain/food_item.dart';
import 'package:uuid/uuid.dart';

class BarcodeService {
  BarcodeService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  Future<FoodItem?> lookupBarcode(String barcode) async {
    try {
      final callable = _functions.httpsCallable('barcodeLookup');
      final result = await callable.call<String, dynamic>({
        'barcode': barcode,
      });

      final product = result.data['product'] as Map<String, dynamic>?;
      if (product == null) return null;

      return FoodItem(
        id: 'barcode_${const Uuid().v4()}',
        name: product['name'] as String? ?? '',
        calorieKcal: (product['calorieKcal'] as num?)?.toDouble() ?? 0,
        proteinG: (product['proteinG'] as num?)?.toDouble() ?? 0,
        carbG: (product['carbG'] as num?)?.toDouble() ?? 0,
        fatG: (product['fatG'] as num?)?.toDouble() ?? 0,
        category: 'Đồ đóng gói',
        defaultPortionG: (product['portionG'] as num?)?.toDouble() ?? 100,
        brand: product['brand'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}
