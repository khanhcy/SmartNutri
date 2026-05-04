import 'package:flutter/material.dart';

enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeX on MealType {
  String get label => switch (this) {
        MealType.breakfast => 'Bữa sáng',
        MealType.lunch => 'Bữa trưa',
        MealType.dinner => 'Bữa tối',
        MealType.snack => 'Bữa phụ',
      };

  IconData get icon => switch (this) {
        MealType.breakfast => Icons.breakfast_dining,
        MealType.lunch => Icons.lunch_dining,
        MealType.dinner => Icons.dinner_dining,
        MealType.snack => Icons.cookie_outlined,
      };
}

class MealEntry {
  const MealEntry({
    required this.id,
    required this.uid,
    required this.date,
    required this.mealType,
    required this.foodName,
    required this.portionG,
    required this.calorieKcal,
    required this.proteinG,
    required this.carbG,
    required this.fatG,
    required this.loggedAt,
  });

  final String id;
  final String uid;

  /// Stored as "YYYY-MM-DD" for Firestore equality queries.
  final String date;
  final MealType mealType;
  final String foodName;
  final double portionG;
  final double calorieKcal;
  final double proteinG;
  final double carbG;
  final double fatG;
  final DateTime loggedAt;

  factory MealEntry.fromMap(String id, Map<String, dynamic> map) {
    return MealEntry(
      id: id,
      uid: map['uid'] as String? ?? '',
      date: map['date'] as String? ?? '',
      mealType: MealType.values.firstWhere(
        (t) => t.name == (map['mealType'] as String?),
        orElse: () => MealType.snack,
      ),
      foodName: map['foodName'] as String? ?? '',
      portionG: (map['portionG'] as num?)?.toDouble() ?? 100,
      calorieKcal: (map['calorieKcal'] as num?)?.toDouble() ?? 0,
      proteinG: (map['proteinG'] as num?)?.toDouble() ?? 0,
      carbG: (map['carbG'] as num?)?.toDouble() ?? 0,
      fatG: (map['fatG'] as num?)?.toDouble() ?? 0,
      loggedAt:
          DateTime.tryParse(map['loggedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'date': date,
      'mealType': mealType.name,
      'foodName': foodName,
      'portionG': portionG,
      'calorieKcal': calorieKcal,
      'proteinG': proteinG,
      'carbG': carbG,
      'fatG': fatG,
      'loggedAt': loggedAt.toIso8601String(),
    };
  }
}
