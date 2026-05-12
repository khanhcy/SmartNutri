import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:smartnutri/src/features/search/domain/food_item.dart';
import 'package:uuid/uuid.dart';

String _functionUrl(String name) {
  if (kDebugMode) {
    final host = defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : '127.0.0.1';
    return 'http://$host:5001/smartnutri-dev-2e67b/us-central1/$name';
  }
  return 'https://us-central1-smartnutri-dev-2e67b.cloudfunctions.net/$name';
}

class BarcodeService {
  Future<FoodItem?> lookupBarcode(String barcode) async {
    try {
      final url = Uri.parse(_functionUrl('barcodeLookup'));
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': {'barcode': barcode},
        }),
      );

      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final result = body['result'] as Map<String, dynamic>? ?? {};
      final product = result['product'] as Map<String, dynamic>?;
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
