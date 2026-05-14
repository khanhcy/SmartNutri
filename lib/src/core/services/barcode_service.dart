import 'dart:convert';

import 'package:http/http.dart' as http;
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

typedef BarcodeFetcher = Future<Map<String, dynamic>?> Function(String barcode);

class BarcodeService {
  BarcodeService({
    http.Client? httpClient,
    BarcodeFetcher? fetcher,
  }) : _fetcher = fetcher ?? _defaultFetcher(httpClient ?? http.Client());

  final BarcodeFetcher _fetcher;

  static BarcodeFetcher _defaultFetcher(http.Client client) {
    return (barcode) async {
      final url = Uri.parse(
        'https://world.openfoodfacts.org/api/v2/product/$barcode',
      );
      final res = await client.get(
        url,
        headers: {'User-Agent': 'SmartNutri/1.0'},
      );

      if (res.statusCode != 200) return null;

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      if (json['status'] != 1 || json['product'] == null) return null;

      final p = json['product'] as Map<String, dynamic>;
      final nutriments = (p['nutriments'] ?? {}) as Map<String, dynamic>;

      return {
        'name': (p['product_name'] ?? p['brands'] ?? '').toString(),
        'brand': (p['brands'] ?? '').toString(),
        'calorieKcal': ((nutriments['energy-kcal_100g'] ?? 0) as num).round(),
        'proteinG': double.tryParse((nutriments['proteins_100g'] ?? 0).toString()) ?? 0.0,
        'carbG': double.tryParse((nutriments['carbohydrates_100g'] ?? 0).toString()) ?? 0.0,
        'fatG': double.tryParse((nutriments['fat_100g'] ?? 0).toString()) ?? 0.0,
        'portionG': ((p['product_quantity'] ?? 100) as num).toInt(),
      };
    };
  }

  Future<BarcodeResult?> lookupBarcode(String barcode) async {
    try {
      final product = await _fetcher(barcode);
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
      if (e is BarcodeLookupException) rethrow;
      throw BarcodeLookupException(_barcodeErrorMessage(e), e);
    }
  }

  String _barcodeErrorMessage(Object error) {
    if (error is FormatException) {
      return 'Dữ liệu sản phẩm không hợp lệ. Vui lòng thử lại.';
    }
    return 'Không thể kết nối dịch vụ mã vạch. Vui lòng kiểm tra mạng và thử lại.';
  }

  void dispose() {}
}
