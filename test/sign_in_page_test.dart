import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartnutri/src/features/auth/presentation/sign_in_page.dart';

void main() {
  Widget buildTestApp() {
    return const MaterialApp(
      home: SignInPage(),
    );
  }

  testWidgets('Hiển thị lỗi khi submit form đăng nhập rỗng', (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.ensureVisible(find.text('Đăng nhập'));
    await tester.tap(find.text('Đăng nhập'));
    await tester.pump();

    expect(find.text('Nhập email'), findsOneWidget);
    expect(find.text('Mật khẩu tối thiểu 6 ký tự'), findsOneWidget);
  });

  testWidgets('Hiển thị lỗi email không hợp lệ', (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.enterText(find.byType(TextFormField).at(0), 'abc');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');

    await tester.ensureVisible(find.text('Đăng nhập'));
    await tester.tap(find.text('Đăng nhập'));
    await tester.pump();

    expect(find.text('Email không hợp lệ'), findsOneWidget);
  });

  testWidgets('Hiển thị lỗi khi mật khẩu ngắn hơn 6 ký tự', (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.enterText(find.byType(TextFormField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), '12345');

    await tester.ensureVisible(find.text('Đăng nhập'));
    await tester.tap(find.text('Đăng nhập'));
    await tester.pump();

    expect(find.text('Mật khẩu tối thiểu 6 ký tự'), findsOneWidget);
  });

  testWidgets('Bật tắt hiển thị mật khẩu', (tester) async {
    await tester.pumpWidget(buildTestApp());

    EditableText passwordField() {
      return tester.widget<EditableText>(find.byType(EditableText).at(1));
    }

    expect(passwordField().obscureText, isTrue);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    expect(passwordField().obscureText, isFalse);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    expect(passwordField().obscureText, isTrue);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
  });
}
