import 'package:flutter_test/flutter_test.dart';
import 'package:smartnutri/src/features/profile/domain/user_profile.dart';

void main() {
  group('UserProfile.fromMap', () {
    test('đọc đầy đủ các trường từ Firestore map', () {
      final profile = UserProfile.fromMap('user-1', {
        'email': 'an@example.com',
        'displayName': 'Nguyễn Văn An',
        'age': 30,
        'heightCm': 175.5,
        'weightKg': 70.2,
        'gender': 'male',
        'activityLevel': 'moderate',
        'onboardingCompleted': true,
        'updatedAt': '2026-05-01T08:00:00.000Z',
      });

      expect(profile.uid, 'user-1');
      expect(profile.email, 'an@example.com');
      expect(profile.displayName, 'Nguyễn Văn An');
      expect(profile.age, 30);
      expect(profile.heightCm, 175.5);
      expect(profile.weightKg, 70.2);
      expect(profile.gender, 'male');
      expect(profile.activityLevel, 'moderate');
      expect(profile.onboardingCompleted, isTrue);
      expect(profile.updatedAt, DateTime.parse('2026-05-01T08:00:00.000Z'));
    });

    test('dùng giá trị mặc định khi map rỗng', () {
      final profile = UserProfile.fromMap('user-2', {});

      expect(profile.uid, 'user-2');
      expect(profile.email, '');
      expect(profile.displayName, '');
      expect(profile.age, 0);
      expect(profile.heightCm, 0);
      expect(profile.weightKg, 0);
      expect(profile.gender, 'unknown');
      expect(profile.activityLevel, 'light');
      expect(profile.onboardingCompleted, isFalse);
      expect(profile.updatedAt, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('cast numeric fields về đúng kiểu', () {
      final profile = UserProfile.fromMap('user-3', {
        'age': 25.9,
        'heightCm': 168,
        'weightKg': 65,
        'updatedAt': '2026-04-15T12:30:00.000Z',
      });

      expect(profile.age, 25);
      expect(profile.heightCm, 168.0);
      expect(profile.weightKg, 65.0);
    });

    test('xử lý updatedAt không hợp lệ bằng epoch 0', () {
      final profile = UserProfile.fromMap('user-4', {
        'updatedAt': 'không-phải-ngày',
      });

      expect(profile.updatedAt, DateTime.fromMillisecondsSinceEpoch(0));
    });
  });

  group('UserProfile.toMap', () {
    test('xuất đúng tất cả field sang map', () {
      final profile = UserProfile(
        uid: 'user-5',
        email: 'binh@example.com',
        displayName: 'Trần Văn Bình',
        age: 28,
        heightCm: 180.0,
        weightKg: 75.5,
        gender: 'male',
        activityLevel: 'active',
        onboardingCompleted: true,
        updatedAt: DateTime.parse('2026-05-10T10:00:00.000Z'),
      );

      final map = profile.toMap();

      expect(map['email'], 'binh@example.com');
      expect(map['displayName'], 'Trần Văn Bình');
      expect(map['age'], 28);
      expect(map['heightCm'], 180.0);
      expect(map['weightKg'], 75.5);
      expect(map['gender'], 'male');
      expect(map['activityLevel'], 'active');
      expect(map['onboardingCompleted'], isTrue);
      expect(map['updatedAt'], '2026-05-10T10:00:00.000Z');
    });

    test('toMap rồi fromMap giữ nguyên giá trị', () {
      final original = UserProfile(
        uid: 'user-6',
        email: 'cuc@example.com',
        displayName: 'Lê Thị Cúc',
        age: 22,
        heightCm: 158.0,
        weightKg: 52.3,
        gender: 'female',
        activityLevel: 'light',
        onboardingCompleted: false,
        updatedAt: DateTime.parse('2026-03-20T09:00:00.000Z'),
      );

      final restored = UserProfile.fromMap('user-6', original.toMap());

      expect(restored.uid, original.uid);
      expect(restored.email, original.email);
      expect(restored.displayName, original.displayName);
      expect(restored.age, original.age);
      expect(restored.heightCm, original.heightCm);
      expect(restored.weightKg, original.weightKg);
      expect(restored.gender, original.gender);
      expect(restored.activityLevel, original.activityLevel);
      expect(restored.onboardingCompleted, original.onboardingCompleted);
      expect(restored.updatedAt, original.updatedAt);
    });
  });
}
