import 'package:smartnutri/src/core/services/cloud_function_client.dart';
import 'package:smartnutri/src/features/scan/domain/barcode_result.dart';
import 'package:smartnutri/src/features/search/domain/food_item.dart';
import 'package:uuid/uuid.dart';

class BarcodeLookupException implements Exception {
  BarcodeLookupException(this.userMessage, this.cause);

  final String userMessage;
  final Object cause;

  @override
  String toString() => 'BarcodeLookupException: $userMessage';
}

class BarcodeService {
  BarcodeService({FunctionCaller? functions})
    : _functions = functions ?? CloudFunctionClient();

  final FunctionCaller _functions;

  Future<BarcodeResult?> lookupBarcode(String barcode) async {
    try {
      final result = await _functions.call('barcodeLookup', {
        'barcode': barcode,
      });

      final product = result['product'] as Map<String, dynamic>?;
      if (product == null) return null;

      final name = product['name'] as String? ?? '';
      if (name.trim().isEmpty) {
        throw const FormatException('Barcode product name is empty');
      }

      final food = FoodItem(
        id: 'barcode_${const Uuid().v4().substring(0, 8)}',
        name: name,
        calorieKcal: (product['calorieKcal'] as num?)?.toDouble() ?? 0,
        proteinG: (product['proteinG'] as num?)?.toDouble() ?? 0,
        carbG: (product['carbG'] as num?)?.toDouble() ?? 0,
        fatG: (product['fatG'] as num?)?.toDouble() ?? 0,
        category: 'Đồ đóng gói',
        defaultPortionG: (product['portionG'] as num?)?.toDouble() ?? 100,
        brand: product['brand'] as String?,
      );

      return BarcodeResult(
        barcode: barcode,
        foodItem: food,
        scannedAt: DateTime.now(),
      );
    } catch (e) {
      throw BarcodeLookupException(_barcodeErrorMessage(e), e);
    }
  }

  String _barcodeErrorMessage(Object error) {
    if (error is FunctionsException) {
      if (error.message == 'invalid_response') {
        return 'Dữ liệu mã vạch trả về không hợp lệ. Vui lòng thử lại.';
      }
      if (error.statusCode == 401 || error.statusCode == 403) {
        return 'Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.';
      }
      if ((error.statusCode ?? 0) >= 500) {
        return 'Máy chủ tra cứu mã vạch đang gặp sự cố. Vui lòng thử lại sau.';
      }
      return 'Không thể tra cứu mã vạch lúc này. Vui lòng thử lại.';
    }
    if (error is FormatException) {
      return 'Dữ liệu sản phẩm không hợp lệ. Vui lòng thử lại.';
    }
    return 'Không thể kết nối dịch vụ mã vạch. Vui lòng kiểm tra mạng và thử lại.';
  }
}
