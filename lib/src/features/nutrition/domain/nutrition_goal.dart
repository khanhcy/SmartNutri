class NutritionGoal {
  const NutritionGoal({
    required this.uid,
    required this.calorieTarget,
    required this.proteinG,
    required this.carbG,
    required this.fatG,
    this.targetWeightKg,
    this.waterTargetMl = 2500,
    required this.updatedAt,
  });

  final String uid;
  final int calorieTarget;
  final int proteinG;
  final int carbG;
  final int fatG;
  final double? targetWeightKg;
  final double waterTargetMl;
  final DateTime updatedAt;

  bool get isReasonable {
    return calorieTarget >= 800 &&
        calorieTarget <= 6000 &&
        proteinG >= 20 &&
        proteinG <= 400 &&
        carbG >= 20 &&
        carbG <= 800 &&
        fatG >= 10 &&
        fatG <= 300 &&
        waterTargetMl >= 500 &&
        waterTargetMl <= 7000;
  }

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

  static NutritionGoal resolveForDisplay({
    required String uid,
    NutritionGoal? storedGoal,
    double? weightKg,
    double? heightCm,
    int? age,
    String? gender,
    String? activityLevel,
  }) {
    if (storedGoal != null && storedGoal.isReasonable) return storedGoal;

    final hasProfileInputs =
        weightKg != null && weightKg > 0 &&
        heightCm != null && heightCm > 0 &&
        age != null && age > 0 &&
        gender != null && gender.isNotEmpty &&
        activityLevel != null && activityLevel.isNotEmpty;

    if (hasProfileInputs) {
      final recalculated = NutritionGoal.fromProfile(
        uid: uid,
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        gender: gender,
        activityLevel: activityLevel,
      );
      return recalculated.copyWith(
        waterTargetMl: (storedGoal != null &&
                storedGoal.waterTargetMl >= 500 &&
                storedGoal.waterTargetMl <= 7000)
            ? storedGoal.waterTargetMl
            : recalculated.waterTargetMl,
      );
    }

    return defaultGoal(uid);
  }

  NutritionGoal copyWith({
    int? calorieTarget,
    int? proteinG,
    int? carbG,
    int? fatG,
    double? targetWeightKg,
    double? waterTargetMl,
  }) {
    return NutritionGoal(
      uid: uid,
      calorieTarget: calorieTarget ?? this.calorieTarget,
      proteinG: proteinG ?? this.proteinG,
      carbG: carbG ?? this.carbG,
      fatG: fatG ?? this.fatG,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      waterTargetMl: waterTargetMl ?? this.waterTargetMl,
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
      waterTargetMl: (map['waterTargetMl'] as num?)?.toDouble() ?? 2500,
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
      'waterTargetMl': waterTargetMl,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
