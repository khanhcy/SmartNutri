class UserProfile {
  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.gender,
    required this.activityLevel,
    required this.onboardingCompleted,
    required this.updatedAt,
  });

  final String uid;
  final String email;
  final String displayName;
  final int age;
  final double heightCm;
  final double weightKg;
  final String gender;
  final String activityLevel;
  final bool onboardingCompleted;
  final DateTime updatedAt;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      age: (map['age'] as num?)?.toInt() ?? 0,
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 0,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0,
      gender: map['gender'] as String? ?? 'unknown',
      activityLevel: map['activityLevel'] as String? ?? 'light',
      onboardingCompleted: map['onboardingCompleted'] as bool? ?? false,
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'age': age,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'gender': gender,
      'activityLevel': activityLevel,
      'onboardingCompleted': onboardingCompleted,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
