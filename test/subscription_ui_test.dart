import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/app/auth_flow_notifier.dart';
import 'package:smartnutri/src/app/go_router_config.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/profile_service.dart';
import 'package:smartnutri/src/core/services/subscription_service.dart';
import 'package:smartnutri/src/core/ui/theme/app_theme.dart';
import 'package:smartnutri/src/features/profile/domain/user_profile.dart';
import 'package:smartnutri/src/features/subscription/domain/subscription_status.dart';
import 'package:smartnutri/src/features/subscription/presentation/paywall_page.dart';
import 'package:smartnutri/src/features/subscription/presentation/subscription_page.dart';
import 'package:smartnutri/src/features/subscription/presentation/widgets/subscription_summary_card.dart';

void main() {
  testWidgets('SubscriptionSummaryCard hiển thị cảnh báo khi hết lượt', (
    tester,
  ) async {
    final overview = SubscriptionOverview(
      subscription: const SubscriptionStatus(
        plan: 'free',
        status: 'none',
        source: 'default',
      ),
      aiScanUsage: const AiScanUsage(used: 5, limit: 5, monthKey: '2026-05'),
    );

    await tester.pumpWidget(
      _wrapWithProviders(
        child: const SubscriptionSummaryCard(uid: 'u-1'),
        authService: _FakeAuthService(),
        subscriptionService: _FakeSubscriptionService(
          stream: Stream.value(overview),
          fallback: overview,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gói Free'), findsOneWidget);
    expect(
      find.textContaining('Đã hết lượt AI scan tháng này (5/5)'),
      findsOneWidget,
    );
  });

  testWidgets('SubscriptionPage hiển thị loading khi chưa có dữ liệu', (
    tester,
  ) async {
    final fallback = SubscriptionOverview(
      subscription: const SubscriptionStatus(
        plan: 'free',
        status: 'none',
        source: 'default',
      ),
      aiScanUsage: const AiScanUsage(used: 0, limit: 5, monthKey: '2026-05'),
    );

    await tester.pumpWidget(
      _wrapWithProviders(
        child: const SubscriptionPage(),
        authService: _FakeAuthService(),
        subscriptionService: _FakeSubscriptionService(
          stream: const Stream<SubscriptionOverview>.empty(),
          fallback: fallback,
        ),
      ),
    );

    expect(find.text('Đang tải thông tin gói...'), findsOneWidget);
  });

  testWidgets('SubscriptionPage free hiển thị CTA nâng cấp', (tester) async {
    final overview = SubscriptionOverview(
      subscription: const SubscriptionStatus(
        plan: 'free',
        status: 'none',
        source: 'default',
      ),
      aiScanUsage: const AiScanUsage(used: 2, limit: 5, monthKey: '2026-05'),
    );

    await tester.pumpWidget(
      _wrapWithProviders(
        child: const SubscriptionPage(),
        authService: _FakeAuthService(),
        subscriptionService: _FakeSubscriptionService(
          stream: Stream.value(overview),
          fallback: overview,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gói hiện tại'), findsOneWidget);
    expect(find.text('AI scan tháng 2026-05'), findsOneWidget);
    expect(find.text('Xem Premium'), findsOneWidget);
  });

  testWidgets('PaywallPage hiển thị copy theo ngữ cảnh quota', (tester) async {
    await tester.pumpWidget(_wrap(const PaywallPage()));

    expect(
      find.textContaining('Tích hợp thanh toán thật sẽ được bổ sung'),
      findsOneWidget,
    );
    expect(find.text('Xem trang gói'), findsNothing);

    await tester.pumpWidget(
      _wrap(
        const PaywallPage(
          source: 'scan_photo',
          reason: 'quota_exhausted',
        ),
      ),
    );

    expect(
      find.text('Bạn đã dùng hết lượt AI scan miễn phí tháng này.'),
      findsOneWidget,
    );
    expect(find.text('Xem trang gói'), findsOneWidget);
  });

  testWidgets('Router truyền query source/reason vào PaywallPage', (
    tester,
  ) async {
    final authFlow = _ReadyAuthFlowNotifier();
    final router = createAppRouter(authFlow: authFlow)
      ..go('${AppPaths.paywall}?source=scan_photo&reason=quota_exhausted');

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Bạn đã dùng hết lượt AI scan miễn phí tháng này.'),
      findsOneWidget,
    );
    expect(find.text('Xem trang gói'), findsOneWidget);

    authFlow.dispose();
  });
}

Widget _wrapWithProviders({
  required Widget child,
  required AuthService authService,
  required SubscriptionService subscriptionService,
}) {
  return MultiProvider(
    providers: [
      Provider<AuthService>.value(value: authService),
      Provider<SubscriptionService>.value(value: subscriptionService),
    ],
    child: _wrap(child),
  );
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: child),
  );
}

class _FakeSubscriptionService implements SubscriptionService {
  _FakeSubscriptionService({
    required this.stream,
    required this.fallback,
  });

  final Stream<SubscriptionOverview> stream;
  final SubscriptionOverview fallback;

  @override
  Future<SubscriptionOverview> getOverview(String uid) async => fallback;

  @override
  Stream<SubscriptionOverview> watchOverview(String uid) => stream;
}

class _ReadyAuthFlowNotifier extends AuthFlowNotifier {
  _ReadyAuthFlowNotifier() : super(_FakeAuthService(), _FakeProfileService());

  @override
  AuthUser? get user => AuthUser(uid: 'u-1', email: 'user@test.dev');

  @override
  bool get isLoading => false;

  @override
  bool get isLoggedIn => true;

  @override
  bool get needsOnboarding => false;
}

class _FakeAuthService implements AuthService {
  @override
  Stream<AuthUser?> authStateChanges() => Stream.value(currentUser);

  @override
  AuthUser? get currentUser => AuthUser(uid: 'u-1', email: 'user@test.dev');

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

class _FakeProfileService implements ProfileService {
  @override
  Future<UserProfile?> getProfile(String uid) async => _profile(uid);

  @override
  Future<void> upsertProfile(UserProfile profile) async {}

  @override
  Stream<UserProfile?> watchProfile(String uid) => Stream.value(_profile(uid));

  UserProfile _profile(String uid) {
    return UserProfile(
      uid: uid,
      email: 'user@test.dev',
      displayName: 'Người dùng',
      age: 30,
      heightCm: 170,
      weightKg: 65,
      gender: 'unknown',
      activityLevel: 'light',
      onboardingCompleted: true,
      updatedAt: DateTime(2026, 5, 14),
    );
  }
}
