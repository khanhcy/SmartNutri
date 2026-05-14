import 'package:flutter_test/flutter_test.dart';
import 'package:smartnutri/src/core/services/barcode_service.dart';

void main() {
  group('BarcodeService error states', () {
    test('lookupBarcode returns null when product is not found', () async {
      final service = BarcodeService(fetcher: (_) async => null);

      final result = await service.lookupBarcode('8930000000000');

      expect(result, isNull);
    });

    test('lookupBarcode returns result when product is valid', () async {
      final service = BarcodeService(
        fetcher: (_) async => {
          'name': 'Sữa tươi',
          'brand': 'SmartNutri',
          'calorieKcal': 61,
          'proteinG': 3.2,
          'carbG': 4.8,
          'fatG': 3.3,
          'portionG': 200,
        },
      );

      final result = await service.lookupBarcode('8930000000000');

      expect(result, isNotNull);
      expect(result!.foodItem.name, 'Sữa tươi');
      expect(result.foodItem.brand, 'SmartNutri');
    });

    test(
      'lookupBarcode throws user-facing exception when network fails',
      () async {
        final service = BarcodeService(
          fetcher: (_) async => throw Exception('Connection refused'),
        );

        expect(
          () => service.lookupBarcode('8930000000000'),
          throwsA(
            isA<BarcodeLookupException>().having(
              (e) => e.userMessage,
              'userMessage',
              contains('kiểm tra mạng'),
            ),
          ),
        );
      },
    );

    test(
      'lookupBarcode throws when product name is empty',
      () async {
        final service = BarcodeService(
          fetcher: (_) async => {
            'name': '',
            'brand': null,
            'calorieKcal': 0,
            'proteinG': 0.0,
            'carbG': 0.0,
            'fatG': 0.0,
            'portionG': 100,
          },
        );

        expect(
          () => service.lookupBarcode('8930000000000'),
          throwsA(isA<BarcodeLookupException>()),
        );
      },
    );
  });
}
