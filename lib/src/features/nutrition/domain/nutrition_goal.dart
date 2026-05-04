class NutritionGoal {
  const NutritionGoal({
    required this.uid,
    required this.calorieTarget,
    required this.proteinG,
    required this.carbG,
    required this.fatG,
    this.targetWeightKg,
    required this.updatedAt,
  });

  final String uid;
  final int calorieTarget;
  final int proteinG;
  final int carbG;
  final int fatG;
  final double? targetWeightKg;
  final DateTime updatedAt;

  /// Auto-calculate TDEE using Mifflin-St Jeor equation.
  static NutritionGoal fromProfile({
    required String uid,
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String activityLevel,
  }) {
    final bmr = gender == 'female'
        ? 10 * weightKg + 6.25 * heightCm - 5 * age - 161
        : 10 * weightKg + 6.25 * heightCm - 5 * age + 5;

    final multiplier = switch (activityLevel) {
      'sedentary' => 1.2,
      'light' => 1.375,
      'moderate' => 1.55,
      'active' => 1.725,
      _ => 1.375,
    };

    final tdee = (bmr * multiplier).round();
    final protein = (weightKg * 1.6).round();
    final fat = (tdee * 0.25 / 9).round();
    final carb = ((tdee - protein * 4 - fat * 9) / 4).round().clamp(50, 999);

    return NutritionGoal(
      uid: uid,
      calorieTarget: tdee,
      proteinG: protein,
      carbG: carb,
      fatG: fat,
      updatedAt: DateTime.now(),
    );
  }

  static NutritionGoal defaultGoal(String uid) {
    return NutritionGoal(
      uid: uid,
      calorieTarget: 2000,
      proteinG: 120,
      carbG: 250,
      fatG: 65,
      updatedAt: DateTime.now(),
    );
  }

  NutritionGoal copyWith({
    int? calorieTarget,
    int? proteinG,
    int? carbG,
    int? fatG,
    double? targetWeightKg,
  }) {
    return NutritionGoal(
      uid: uid,
      calorieTarget: calorieTarget ?? this.calorieTarget,
      proteinG: proteinG ?? this.proteinG,
      carbG: carbG ?? this.carbG,
      fatG: fatG ?? this.fatG,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      updatedAt: DateTime.now(),
    );
  }

  factory NutritionGoal.fromMap(String uid, Map<String, dynamic> map) {
    return NutritionGoal(
      uid: uid,
      calorieTarget: (map['calorieTarget'] as num?)?.toInt() ?? 2000,
      proteinG: (map['proteinG'] as num?)?.toInt() ?? 120,
      carbG: (map['carbG'] as num?)?.toInt() ?? 250,
      fatG: (map['fatG'] as num?)?.toInt() ?? 65,
      targetWeightKg: (map['targetWeightKg'] as num?)?.toDouble(),
      updatedAt:
          DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'calorieTarget': calorieTarget,
      'proteinG': proteinG,
      'carbG': carbG,
      'fatG': fatG,
      if (targetWeightKg != null) 'targetWeightKg': targetWeightKg,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
