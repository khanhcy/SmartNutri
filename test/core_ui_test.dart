import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartnutri/src/core/ui/components/section_header.dart';
import 'package:smartnutri/src/core/ui/components/sn_button.dart';
import 'package:smartnutri/src/core/ui/components/sn_text_field.dart';
import 'package:smartnutri/src/core/ui/components/stat_card.dart';
import 'package:smartnutri/src/core/ui/components/state_view.dart';
import 'package:smartnutri/src/core/ui/theme/app_theme.dart';

void main() {
  Widget wrapWithMaterial(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: child),
    );
  }

  testWidgets('SNButton renders label', (tester) async {
    await tester.pumpWidget(
      wrapWithMaterial(
        SNButton(label: 'Save', onPressed: () {}),
      ),
    );

    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('SNButton loading disables press and shows spinner', (tester) async {
    await tester.pumpWidget(
      wrapWithMaterial(
        SNButton(label: 'Save', onPressed: () {}, isLoading: true),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('SNTextField displays label', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      wrapWithMaterial(
        Form(
          child: SNTextField(
            controller: controller,
            label: 'Email',
          ),
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('LoadingView shows message', (tester) async {
    await tester.pumpWidget(
      wrapWithMaterial(const LoadingView(message: 'Loading...')),
    );

    expect(find.text('Loading...'), findsOneWidget);
  });

  testWidgets('ErrorView shows retry button', (tester) async {
    await tester.pumpWidget(
      wrapWithMaterial(
        ErrorView(message: 'Error', onRetry: () {}),
      ),
    );

    expect(find.text('Thử lại'), findsOneWidget);
  });

  testWidgets('SectionHeader renders title and action', (tester) async {
    await tester.pumpWidget(
      wrapWithMaterial(
        const SectionHeader(
          title: 'Recent meals',
          actionLabel: 'View all',
        ),
      ),
    );

    expect(find.text('Recent meals'), findsOneWidget);
    expect(find.text('View all'), findsOneWidget);
  });

  testWidgets('StatCard renders value and helper', (tester) async {
    await tester.pumpWidget(
      wrapWithMaterial(
        const StatCard(
          label: 'Calories',
          value: '1500',
          helper: 'Goal 2100',
        ),
      ),
    );

    expect(find.text('Calories'), findsOneWidget);
    expect(find.text('1500'), findsOneWidget);
    expect(find.text('Goal 2100'), findsOneWidget);
  });
}
