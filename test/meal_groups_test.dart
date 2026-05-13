import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartnutri/src/features/meal_log/domain/meal_entry.dart';
import 'package:smartnutri/src/features/meal_log/presentation/widgets/meal_groups.dart';

void main() {
  Widget buildTestApp(List<MealEntry> entries) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: MealGroups(entries: entries, uid: 'user-1'),
        ),
      ),
    );
  }

  MealEntry entry({
    required String id,
    required MealType mealType,
    required String foodName,
    required double portionG,
    required double calorieKcal,
    required double proteinG,
    required double carbG,
    required double fatG,
  }) {
    return MealEntry(
      id: id,
      uid: 'user-1',
      date: '2026-05-13',
      mealType: mealType,
      foodName: foodName,
      portionG: portionG,
      calorieKcal: calorieKcal,
      proteinG: proteinG,
      carbG: carbG,
      fatG: fatG,
      loggedAt: DateTime(2026, 5, 13, 8),
    );
  }

  testWidgets('Hiển thị món đã ghi theo từng loại bữa ăn', (tester) async {
    final entries = [
      entry(
        id: 'pho',
        mealType: MealType.breakfast,
        foodName: 'Phở bò',
        portionG: 400,
        calorieKcal: 272,
        proteinG: 23,
        carbG: 37,
        fatG: 5,
      ),
      entry(
        id: 'rice',
        mealType: MealType.dinner,
        foodName: 'Cơm gà',
        portionG: 300,
        calorieKcal: 540,
        proteinG: 32,
        carbG: 70,
        fatG: 14,
      ),
    ];

    await tester.pumpWidget(buildTestApp(entries));

    expect(find.text('Bữa sáng'), findsOneWidget);
    expect(find.text('Bữa tối'), findsOneWidget);
    expect(find.text('Bữa trưa'), findsNothing);
    expect(find.text('Bữa phụ'), findsNothing);

    expect(find.text('Phở bò'), findsOneWidget);
    expect(find.text('400g'), findsOneWidget);
    expect(find.text('272 kcal'), findsNWidgets(2));
    expect(find.text('P 23g'), findsOneWidget);
    expect(find.text('C 37g'), findsOneWidget);
    expect(find.text('F 5g'), findsOneWidget);

    expect(find.text('Cơm gà'), findsOneWidget);
    expect(find.text('300g'), findsOneWidget);
    expect(find.text('540 kcal'), findsNWidgets(2));
    expect(find.text('P 32g'), findsOneWidget);
    expect(find.text('C 70g'), findsOneWidget);
    expect(find.text('F 14g'), findsOneWidget);
  });
}
