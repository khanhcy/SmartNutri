import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartnutri/src/features/search/domain/food_item.dart';
import 'package:smartnutri/src/features/search/presentation/widgets/food_tile.dart';

void main() {
  const food = FoodItem(
    id: 'pho_bo',
    name: 'Phở bò',
    calorieKcal: 68,
    proteinG: 5.8,
    carbG: 9.2,
    fatG: 1.2,
    category: 'Món nước',
    defaultPortionG: 400,
  );

  Widget buildTestApp() {
    return const MaterialApp(
      home: Scaffold(
        body: FoodTile(food: food),
      ),
    );
  }

  testWidgets('Hiển thị tên món và dinh dưỡng mỗi 100g', (tester) async {
    await tester.pumpWidget(buildTestApp());

    expect(find.text('Phở bò'), findsOneWidget);
    expect(find.text('68 kcal / 100g  •  P:6g  C:9g  F:1g'), findsOneWidget);
  });

  testWidgets('Hiển thị nút thêm vào nhật ký', (tester) async {
    await tester.pumpWidget(buildTestApp());

    expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
  });
}
