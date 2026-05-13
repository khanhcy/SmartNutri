import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/features/onboarding/presentation/onboarding_page.dart';

void main() {
  final user = AuthUser(
    uid: 'user-1',
    email: 'khanh@example.com',
    displayName: null,
  );

  Widget buildTestApp({AuthUser? testUser}) {
    return MaterialApp(
      home: OnboardingPage(user: testUser ?? user),
    );
  }

  testWidgets('Hiển thị bước nhập tên và điền sẵn tên từ email', (tester) async {
    await tester.pumpWidget(buildTestApp());

    expect(find.text('Chào bạn mới!'), findsOneWidget);
    expect(find.text('Chúng tôi nên gọi bạn là gì?'), findsOneWidget);
    expect(find.text('khanh'), findsOneWidget);
  });

  testWidgets('Báo lỗi khi bỏ trống tên', (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.enterText(find.byType(TextField).first, '');
    await tester.tap(find.text('Tiếp tục'));
    await tester.pump();

    expect(find.text('Vui lòng nhập tên'), findsOneWidget);
  });

  testWidgets('Ưu tiên tên hiển thị từ tài khoản khi có sẵn', (tester) async {
    final namedUser = AuthUser(
      uid: 'user-2',
      email: 'user@example.com',
      displayName: 'Trịnh Quốc Khánh',
    );

    await tester.pumpWidget(buildTestApp(testUser: namedUser));

    expect(find.text('Trịnh Quốc Khánh'), findsOneWidget);
    expect(find.text('user'), findsNothing);
  });
}
