import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smartnutri/src/core/services/barcode_service.dart';
import 'package:smartnutri/src/core/services/cloud_function_client.dart';

void main() {
  group('BarcodeService error states', () {
    test('lookupBarcode returns null when product is not found', () async {
      final service = BarcodeService(
        functions: _FakeFunctions((_, _) => {'product': null}),
      );

      final result = await service.lookupBarcode('8930000000000');

      expect(result, isNull);
    });

    test('lookupBarcode returns result when product is valid', () async {
      final service = BarcodeService(
        functions: _FakeFunctions(
          (_, _) => {
            'product': {
              'name': 'Sữa tươi',
              'brand': 'SmartNutri',
              'calorieKcal': 61,
              'proteinG': 3.2,
              'carbG': 4.8,
              'fatG': 3.3,
              'portionG': 200,
            },
          },
        ),
      );

      final result = await service.lookupBarcode('8930000000000');

      expect(result, isNotNull);
      expect(result!.foodItem.name, 'Sữa tươi');
      expect(result.foodItem.brand, 'SmartNutri');
    });

    test(
      'lookupBarcode shows network error when connection times out',
      () async {
        final service = BarcodeService(
          functions: _FakeFunctions((_, _) {
            throw FunctionsException('network_error');
          }),
        );

        expect(
          () => service.lookupBarcode('8930000000000'),
          throwsA(
            isA<BarcodeLookupException>().having(
              (e) => e.userMessage,
              'userMessage',
              contains('Firebase Emulators'),
            ),
          ),
        );
      },
    );

    test(
      'lookupBarcode throws user-facing exception when function fails',
      () async {
        final service = BarcodeService(
          functions: _FakeFunctions((_, _) {
            throw FunctionsException('internal_error', 500);
          }),
        );

        expect(
          () => service.lookupBarcode('8930000000000'),
          throwsA(
            isA<BarcodeLookupException>().having(
              (e) => e.userMessage,
              'userMessage',
              contains('Máy chủ tra cứu mã vạch'),
            ),
          ),
        );
      },
    );
  });
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
