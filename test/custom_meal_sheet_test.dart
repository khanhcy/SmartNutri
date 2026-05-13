import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/features/meal_log/domain/meal_entry.dart';
import 'package:smartnutri/src/features/meal_log/presentation/custom_meal_sheet.dart';

void main() {
  late _FakeAuthService authService;
  late _FakeMealService mealService;

  Widget buildTestApp() {
    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<MealService>.value(value: mealService),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: FilledButton(
                  onPressed: () => showCustomMealSheet(
                    context,
                    initialMealType: MealType.dinner,
                    logDate: DateTime(2026, 5, 13),
                  ),
                  child: const Text('Mở nhập món'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  setUp(() {
    authService = _FakeAuthService();
    mealService = _FakeMealService();
  });

  testWidgets('Báo lỗi khi lưu món thủ công thiếu thông tin bắt buộc',
      (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.text('Mở nhập món'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lưu vào nhật ký'));
    await tester.pump();

    expect(find.text('Vui lòng nhập tên món'), findsOneWidget);
    expect(find.text('Bắt buộc'), findsOneWidget);
    expect(mealService.addedEntries, isEmpty);
  });

  testWidgets('Lưu món thủ công với calo tự tính từ macro', (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.text('Mở nhập món'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Bún thịt nướng');
    await tester.enterText(find.byType(TextFormField).at(3), '20');
    await tester.enterText(find.byType(TextFormField).at(4), '50');
    await tester.enterText(find.byType(TextFormField).at(5), '10');
    await tester.pump();

    expect(find.text('370'), findsOneWidget);

    await tester.tap(find.text('Lưu vào nhật ký'));
    await tester.pumpAndSettle();

    expect(mealService.addedEntries, hasLength(1));
    final entry = mealService.addedEntries.single;
    expect(mealService.addedUid, 'user-1');
    expect(entry.foodName, 'Bún thịt nướng');
    expect(entry.date, '2026-05-13');
    expect(entry.mealType, MealType.dinner);
    expect(entry.portionG, 100);
    expect(entry.calorieKcal, 370);
    expect(entry.proteinG, 20);
    expect(entry.carbG, 50);
    expect(entry.fatG, 10);
    expect(find.text('Đã thêm "Bún thịt nướng" vào nhật ký'), findsOneWidget);
  });

  testWidgets('Hiển thị lỗi khi lưu món thủ công thất bại', (tester) async {
    mealService.shouldThrowOnAdd = true;
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.text('Mở nhập món'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Cháo gà');
    await tester.enterText(find.byType(TextFormField).at(1), '250');
    await tester.enterText(find.byType(TextFormField).at(2), '320');

    await tester.tap(find.text('Lưu vào nhật ký'));
    await tester.pumpAndSettle();

    expect(mealService.addedEntries, isEmpty);
    expect(find.text('Không thể lưu lúc này. Vui lòng thử lại.'), findsOneWidget);
    expect(find.text('Nhập món thủ công'), findsOneWidget);
  });
}

class _FakeAuthService implements AuthService {
  @override
  AuthUser? get currentUser => AuthUser(
        uid: 'user-1',
        email: 'user@example.com',
      );

  @override
  Stream<AuthUser?> authStateChanges() => Stream.value(currentUser);

  @override
  Future<void> sendPasswordReset({required String email}) async {}

  @override
  Future<void> signIn({required String email, required String password}) async {}

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signInWithFacebook() async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {}
}

class _FakeMealService implements MealService {
  final addedEntries = <MealEntry>[];
  String? addedUid;
  bool shouldThrowOnAdd = false;

  @override
  Future<void> addEntry(String uid, MealEntry entry) async {
    if (shouldThrowOnAdd) {
      throw Exception('save failed');
    }
    addedUid = uid;
    addedEntries.add(entry);
  }

  @override
  Future<void> deleteEntry(String uid, String entryId) async {}

  @override
  Future<List<MealEntry>> getEntriesForDate(String uid, String date) async {
    return const [];
  }

  @override
  Future<double> sumCaloriesForDate(String uid, String date) async => 0;

  @override
  Future<void> updateEntry(String uid, MealEntry entry) async {}

  @override
  Stream<List<MealEntry>> watchEntriesForDate(String uid, String date) {
    return const Stream.empty();
  }
}
