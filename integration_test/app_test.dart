// ============================================================================
// SmartNutri Integration Tests
// ============================================================================
//
// PREREQUISITES per test group:
//
//   Group 1 (Widget Integration) — no backend, runs in CI.
//   Group 2 (Full E2E) — requires Firebase Auth + Firestore emulators.
//     Start with: firebase emulators:start --only firestore,auth
//     Then set environment before running:
//       set FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
//       set FIRESTORE_EMULATOR_HOST=localhost:8080
//       flutter test integration_test/app_test.dart
//
// RUN (all tests):
//   flutter test integration_test/app_test.dart
//
// RUN (only Group 1, skips emulator tests):
//   flutter test integration_test/app_test.dart -N "Full E2E"
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:smartnutri/src/core/providers/app_settings_provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/features/auth/presentation/sign_in_page.dart';
import 'package:smartnutri/src/features/auth/presentation/sign_up_page.dart';
import 'package:smartnutri/src/features/dashboard/presentation/main_shell_page.dart';
import 'package:smartnutri/src/features/onboarding/presentation/onboarding_page.dart';

// ============================================================================
// Helpers — test data
// ============================================================================

/// Standard test user for onboarding / logged-in flows.
AuthUser _testUser() => AuthUser(
      uid: 'test-user-1',
      email: 'test@smartnutri.app',
      displayName: null,
    );

/// Test user with a display name (Facebook / Google login style).
AuthUser _namedTestUser() => AuthUser(
      uid: 'test-user-2',
      email: 'named@smartnutri.app',
      displayName: 'Trinh Quoc Khanh',
    );

/// Paths that match `AppPaths` for the GoRouter redirect test.
abstract final class _P {
  static const splash = '/splash';
  static const signIn = '/sign-in';
  static const onboarding = '/onboarding';
  static const app = '/app';
  static const home = '/app/home';
}

// ============================================================================
// Helpers — GoRouter factories
// ============================================================================

/// Builds a GoRouter whose redirect logic mirrors the production app
/// but reads state from [authState] instead of `AuthFlowNotifier`.
GoRouter _createAuthRedirectRouter(_TestAuthState authState) {
  return GoRouter(
    initialLocation: _P.splash,
    refreshListenable: authState,
    redirect: (context, state) {
      final loc = state.matchedLocation;

      if (authState.isLoading) {
        if (loc == _P.splash) return null;
        return _P.splash;
      }

      if (!authState.isLoggedIn) {
        if (loc == _P.signIn) return null;
        return _P.signIn;
      }

      if (authState.needsOnboarding) {
        if (loc == _P.onboarding) return null;
        return _P.onboarding;
      }

      if (loc == _P.signIn || loc == _P.onboarding || loc == _P.splash) {
        return _P.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: _P.splash,
        builder: (_, _) => const Text('Loading...', key: Key('splash_page')),
      ),
      GoRoute(
        path: _P.signIn,
        builder: (_, _) =>
            const Text('Sign In Page', key: Key('sign_in_page')),
      ),
      GoRoute(
        path: _P.onboarding,
        builder: (_, _) =>
            const Text('Onboarding Page', key: Key('onboarding_page')),
      ),
      GoRoute(
        path: _P.app,
        redirect: (context, state) =>
            state.fullPath == _P.app ? _P.home : null,
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) =>
                MainShellPage(shell: navigationShell),
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'home',
                    builder: (_, _) =>
                        const Text('Home', key: Key('home_page')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'search',
                    builder: (_, _) =>
                        const Text('Search', key: Key('search_page')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'log',
                    builder: (_, _) =>
                        const Text('Log', key: Key('log_page')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'profile',
                    builder: (_, _) =>
                        const Text('Profile', key: Key('profile_page')),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'chat',
            builder: (_, _) =>
                const Text('Chat', key: Key('chat_page')),
          ),
        ],
      ),
    ],
  );
}

/// Builds a GoRouter for MainShellPage tab navigation tests.
/// The router starts at the given [initialTab] (0=home, 1=search, 2=log, 3=profile).
GoRouter _createShellRouter({int initialTab = 0}) {
  const tabPaths = ['home', 'search', 'log', 'profile'];
  return GoRouter(
    initialLocation: '/app/${tabPaths[initialTab.clamp(0, 3)]}',
    routes: [
      GoRoute(
        path: _P.app,
        redirect: (context, state) =>
            state.fullPath == _P.app ? '/app/${tabPaths[0]}' : null,
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) =>
                MainShellPage(shell: navigationShell),
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'home',
                    builder: (_, _) =>
                        const Text('Home Content', key: Key('home_content')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'search',
                    builder: (_, _) => const Text('Search Content',
                        key: Key('search_content')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'log',
                    builder: (_, _) =>
                        const Text('Log Content', key: Key('log_content')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'profile',
                    builder: (_, _) => const Text('Profile Content',
                        key: Key('profile_content')),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'chat',
            builder: (_, _) => const Text('Chat', key: Key('chat_page')),
          ),
        ],
      ),
    ],
  );
}

// ============================================================================
// Helpers — test state for GoRouter redirect tests
// ============================================================================

/// Lightweight ChangeNotifier that drives GoRouter redirect logic in tests.
class _TestAuthState extends ChangeNotifier {
  _TestAuthState({
    this.isLoading = true,
    this.isLoggedIn = false,
    this.needsOnboarding = false,
  });

  bool isLoading;
  bool isLoggedIn;
  bool needsOnboarding;

  /// Convenience: sets all fields and notifies in one call.
  void update({
    bool? isLoading,
    bool? isLoggedIn,
    bool? needsOnboarding,
    AuthUser? user,
  }) {
    if (isLoading != null) this.isLoading = isLoading;
    if (isLoggedIn != null) this.isLoggedIn = isLoggedIn;
    if (needsOnboarding != null) this.needsOnboarding = needsOnboarding;
    notifyListeners();
  }
}

// ============================================================================
// Helpers — widget wrappers
// ============================================================================

/// Wraps [child] in the minimal provider environment needed by app screens
/// that do not call Firestore (SignInPage, OnboardingPage without save).
Widget _wrapWithBasicApp(Widget child) {
  return MaterialApp(
    home: child,
  );
}

/// Wraps a GoRouter in a MaterialApp.router with AppSettingsProvider.
/// Async because AppSettingsProvider.create() initializes SharedPreferences.
Future<Widget> _wrapWithAppRouter(GoRouter router) async {
  final settings = await AppSettingsProvider.create();
  return ChangeNotifierProvider<AppSettingsProvider>.value(
    value: settings,
    child: MaterialApp.router(
      routerConfig: router,
    ),
  );
}

// ============================================================================
// MAIN
// ============================================================================

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ==========================================================================
  // Group 1 — Widget Integration (no Firebase required)
  // ==========================================================================

  group('SignInPage — UI & form validation', () {
    testWidgets('renders title, email field, password field, and CTA button',
        (tester) async {
      await tester.pumpWidget(_wrapWithBasicApp(const SignInPage()));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Hero title
      expect(find.text('Chào mừng\ntrở lại!'), findsOneWidget);
      // Subtitle
      expect(
        find.text('Tiếp tục hành trình dinh dưỡng của bạn.'),
        findsOneWidget,
      );
      // Email field label
      expect(find.text('Email'), findsOneWidget);
      // Password field label
      expect(find.text('Mật khẩu'), findsOneWidget);
      // Primary button
      expect(find.text('Đăng nhập'), findsAtLeast(1));
      // Alternative sign-in options
      expect(find.text('hoặc'), findsOneWidget);
      expect(find.text('Tiếp tục với Google'), findsOneWidget);
      // Sign-up link
      expect(find.text('Chưa có tài khoản?'), findsOneWidget);
      expect(find.text('Đăng ký ngay'), findsOneWidget);
    });

    testWidgets('shows validation errors when submitting empty form',
        (tester) async {
      await tester.pumpWidget(_wrapWithBasicApp(const SignInPage()));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      await tester.tap(find.text('Đăng nhập'));
      await tester.pump();

      expect(find.text('Nhập email'), findsOneWidget);
      expect(find.text('Mật khẩu tối thiểu 6 ký tự'), findsOneWidget);
    });

    testWidgets('shows email validation error for invalid email format',
        (tester) async {
      await tester.pumpWidget(_wrapWithBasicApp(const SignInPage()));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
      await tester.enterText(find.byType(TextFormField).last, '123456');

      await tester.tap(find.text('Đăng nhập'));
      await tester.pump();

      expect(find.text('Email không hợp lệ'), findsOneWidget);
    });

    testWidgets('shows password validation error when password is too short',
        (tester) async {
      await tester.pumpWidget(_wrapWithBasicApp(const SignInPage()));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      await tester.enterText(
          find.byType(TextFormField).first, 'user@example.com');
      await tester.enterText(find.byType(TextFormField).last, '12345');
      await tester.tap(find.text('Đăng nhập'));
      await tester.pump();

      expect(find.text('Mật khẩu tối thiểu 6 ký tự'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(_wrapWithBasicApp(const SignInPage()));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Password is obscured by default
      final passwordField = tester.widget<EditableText>(
        find.byType(EditableText).last,
      );
      expect(passwordField.obscureText, isTrue);

      // Tap eye icon to reveal
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      final revealedField = tester.widget<EditableText>(
        find.byType(EditableText).last,
      );
      expect(revealedField.obscureText, isFalse);

      // Tap again to hide
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      final hiddenField = tester.widget<EditableText>(
        find.byType(EditableText).last,
      );
      expect(hiddenField.obscureText, isTrue);
    });

    testWidgets('navigates to sign-up page when tapping Đăng ký ngay',
        (tester) async {
      await tester.pumpWidget(_wrapWithBasicApp(const SignInPage()));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      await tester.tap(find.text('Đăng ký ngay'));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Verify we navigated to SignUpPage
      expect(find.byType(SignUpPage), findsOneWidget);
    });
  });

  group('OnboardingPage — multi-step flow', () {
    testWidgets('step 0 shows name input pre-filled from email when no displayName',
        (tester) async {
      final user = _testUser();
      await tester.pumpWidget(
        _wrapWithBasicApp(OnboardingPage(user: user)),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      expect(find.text('Chào bạn mới!'), findsOneWidget);
      final TextField nameField = tester.widget(find.byType(TextField));
      expect(nameField.controller?.text, 'test');
      // Button says "Tiếp tục" (not "Bắt đầu ngay")
      expect(find.text('Tiếp tục'), findsOneWidget);
    });

    testWidgets('step 0 prefers displayName over email prefix', (tester) async {
      final user = _namedTestUser();
      await tester.pumpWidget(
        _wrapWithBasicApp(OnboardingPage(user: user)),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      final TextField nameField = tester.widget(find.byType(TextField));
      expect(nameField.controller?.text, 'Trinh Quoc Khanh');
    });

    testWidgets('step 0 shows error when name is empty', (tester) async {
      final user = _testUser();
      await tester.pumpWidget(
        _wrapWithBasicApp(OnboardingPage(user: user)),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Clear the pre-filled name
      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.text('Tiếp tục'));
      await tester.pump();

      expect(find.text('Vui lòng nhập tên'), findsOneWidget);
    });

    testWidgets('navigates through all 6 steps and shows Bắt đầu ngay on last step',
        (tester) async {
      final user = _testUser();
      await tester.pumpWidget(
        _wrapWithBasicApp(OnboardingPage(user: user)),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Step 0: Name
      expect(find.text('Chào bạn mới!'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Khanh');
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Step 1: Age
      expect(find.text('Bạn bao nhiêu tuổi?'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '25');
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Step 2: Height
      expect(find.text('Chiều cao của bạn?'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '170');
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Step 3: Weight
      expect(find.text('Cân nặng hiện tại?'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '65');
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Step 4: Gender
      expect(find.text('Giới tính sinh học'), findsOneWidget);
      // Tap "Nữ" to change selection
      await tester.tap(find.text('Nữ'));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Step 5: Activity level — last step
      expect(find.text('Mức độ vận động'), findsOneWidget);
      // Button text changes on final step
      expect(find.text('Bắt đầu ngay'), findsOneWidget);
      expect(find.text('Tiếp tục'), findsNothing);
    });

    testWidgets('shows error when age is invalid', (tester) async {
      final user = _testUser();
      await tester.pumpWidget(
        _wrapWithBasicApp(OnboardingPage(user: user)),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Step 0 → Step 1
      await tester.enterText(find.byType(TextField), 'Khanh');
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Step 1: Enter invalid age
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.tap(find.text('Tiếp tục'));
      await tester.pump();

      expect(find.text('Nhập tuổi hợp lệ'), findsOneWidget);
    });

    testWidgets('shows error when height is invalid', (tester) async {
      final user = _testUser();
      await tester.pumpWidget(
        _wrapWithBasicApp(OnboardingPage(user: user)),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Step 0 → 1
      await tester.enterText(find.byType(TextField), 'Khanh');
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));
      // Step 1 → 2
      await tester.enterText(find.byType(TextField), '25');
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Step 2: Enter invalid height
      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.tap(find.text('Tiếp tục'));
      await tester.pump();

      expect(find.text('Nhập chiều cao hợp lệ'), findsOneWidget);
    });

    testWidgets('shows error when weight is invalid', (tester) async {
      final user = _testUser();
      await tester.pumpWidget(
        _wrapWithBasicApp(OnboardingPage(user: user)),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Step 0 → 1 → 2 → 3
      await tester.enterText(find.byType(TextField), 'Khanh');
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));
      await tester.enterText(find.byType(TextField), '25');
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));
      await tester.enterText(find.byType(TextField), '170');
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Step 3: Enter invalid weight
      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.text('Tiếp tục'));
      await tester.pump();

      expect(find.text('Nhập cân nặng hợp lệ'), findsOneWidget);
    });
  });

  group('MainShellPage — bottom navigation & tabs', () {
    testWidgets('renders all 4 bottom navigation tabs', (tester) async {
      final router = _createShellRouter(initialTab: 0);
      final app = await _wrapWithAppRouter(router);
      await tester.pumpWidget(app);
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // All 4 tabs present (bottom nav labels)
      expect(find.text('Tổng quan'), findsAtLeast(1));
      expect(find.text('Tìm món'), findsOneWidget);
      expect(find.text('Nhật ký'), findsOneWidget);
      expect(find.text('Hồ sơ'), findsOneWidget);

      // NavigationBar exists
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('switching tabs updates content', (tester) async {
      final router = _createShellRouter(initialTab: 0);
      final app = await _wrapWithAppRouter(router);
      await tester.pumpWidget(app);
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Start on Home
      expect(find.byKey(const Key('home_content')), findsOneWidget);

      // Switch to Search tab
      await tester.tap(find.text('Tìm món'));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));
      expect(find.byKey(const Key('search_content')), findsOneWidget);

      // Switch to Log tab
      await tester.tap(find.text('Nhật ký'));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));
      expect(find.byKey(const Key('log_content')), findsOneWidget);

      // Switch to Profile tab
      await tester.tap(find.text('Hồ sơ'));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));
      expect(find.byKey(const Key('profile_content')), findsOneWidget);

      // Switch back to Home
      await tester.tap(find.text('Tổng quan'));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));
      expect(find.byKey(const Key('home_content')), findsOneWidget);
    });

    testWidgets('app bar title updates when switching tabs', (tester) async {
      final router = _createShellRouter(initialTab: 0);
      final app = await _wrapWithAppRouter(router);
      await tester.pumpWidget(app);
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Home tab AppBar shows "Tổng quan"
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Tổng quan'),
        ),
        findsOneWidget,
      );

      // Switch to Profile tab
      await tester.tap(find.text('Hồ sơ'));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Verify AppBar updated
      // Note: there's already one "Hồ sơ" in the bottom nav,
      // and the AppBar title. So we expect >= 2 matches.
      expect(find.text('Hồ sơ'), findsAtLeast(2));
    });
  });

  group('GoRouter — auth redirect logic', () {
    testWidgets('redirects to sign-in when user is not authenticated',
        (tester) async {
      final authState = _TestAuthState(
        isLoading: false,
        isLoggedIn: false,
      );
      final router = _createAuthRedirectRouter(authState);

      final app = await _wrapWithAppRouter(router);
      await tester.pumpWidget(app);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Should redirect to sign-in
      expect(find.byKey(const Key('sign_in_page')), findsOneWidget);
    });

    testWidgets('shows splash while loading auth state', (tester) async {
      final authState = _TestAuthState(isLoading: true);
      final router = _createAuthRedirectRouter(authState);

      final app = await _wrapWithAppRouter(router);
      await tester.pumpWidget(app);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Should stay on splash
      expect(find.byKey(const Key('splash_page')), findsOneWidget);
    });

    testWidgets('redirects to onboarding when logged in but not onboarded',
        (tester) async {
      final authState = _TestAuthState(
        isLoading: false,
        isLoggedIn: true,
        needsOnboarding: true,
      );
      final router = _createAuthRedirectRouter(authState);

      final app = await _wrapWithAppRouter(router);
      await tester.pumpWidget(app);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      expect(find.byKey(const Key('onboarding_page')), findsOneWidget);
    });

    testWidgets('redirects to dashboard when logged in and onboarded',
        (tester) async {
      final authState = _TestAuthState(
        isLoading: false,
        isLoggedIn: true,
        needsOnboarding: false,
      );
      final router = _createAuthRedirectRouter(authState);

      final app = await _wrapWithAppRouter(router);
      await tester.pumpWidget(app);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Should redirect to home
      expect(find.byKey(const Key('home_page')), findsOneWidget);
    });

    testWidgets('reacts to auth state changes in real time', (tester) async {
      final authState = _TestAuthState(
        isLoading: true,
        isLoggedIn: false,
      );
      final router = _createAuthRedirectRouter(authState);

      final app = await _wrapWithAppRouter(router);
      await tester.pumpWidget(app);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Start: loading → splash
      expect(find.byKey(const Key('splash_page')), findsOneWidget);

      // Auth resolves: user not logged in → redirect to sign-in
      authState.update(isLoading: false, isLoggedIn: false);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('sign_in_page')), findsOneWidget);

      // User logs in but needs onboarding
      authState.update(isLoggedIn: true, needsOnboarding: true);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('onboarding_page')), findsOneWidget);

      // Onboarding completed → dashboard
      authState.update(needsOnboarding: false);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('home_page')), findsOneWidget);
    });
  });

  // ==========================================================================
  // Group 2 — Full E2E (Firebase Emulator Required)
  // ==========================================================================
  //
  // Prerequisites:
  //   firebase emulators:start --only firestore,auth
  //   (or start all with: firebase emulators:start)
  //
  // Environment variables (Windows PowerShell):
  //   $env:FIREBASE_AUTH_EMULATOR_HOST="localhost:9099"
  //   $env:FIRESTORE_EMULATOR_HOST="localhost:8080"
  //
  // Then run:
  //   flutter test integration_test/app_test.dart -N "Full E2E"
  //
  // The tests below use a pre-created test account:
  //   Email:    e2e-test@smartnutri.dev
  //   Password: password123
  //
  // If the account does not exist, the sign-up test will create it first.

  group('Full E2E — auth flow', () {
    testWidgets(
      'sign in with email/password, complete onboarding, reach dashboard',
      (tester) async {
        // ── SETUP ──────────────────────────────────────────────────────
        // These tests require a running Firebase emulator.
        // Skip gracefully when emulator is not available.
        //
        // To run the full app, we call the real main().
        // The app connects to the default Firebase project or emulator
        // depending on the environment variables set above.
        //
        // For now this test is a documented scaffold — unblock the lines
        // below and point Firebase at the emulator before running.

        // app.main();
        // await tester.pumpAndSettle(const Duration(seconds: 5));

        // // ── STEP 1: Sign in ────────────────────────────────────────
        // expect(find.text('Chào mừng'), findsOneWidget);
        // await tester.enterText(
        //   find.byType(TextFormField).first,
        //   'e2e-test@smartnutri.dev',
        // );
        // await tester.enterText(
        //   find.byType(TextFormField).last,
        //   'password123',
        // );
        // await tester.tap(find.text('Đăng nhập'));
        // await tester.pumpAndSettle(const Duration(seconds: 5));

        // // ── STEP 2: Onboarding ─────────────────────────────────────
        // expect(find.text('Chào bạn mới!'), findsOneWidget);
        // // … fill all 6 steps and tap "Bắt đầu ngay"
        // await tester.pumpAndSettle(const Duration(seconds: 3));

        // // ── STEP 3: Dashboard ──────────────────────────────────────
        // expect(find.text('Tổng quan'), findsWidgets);
        // expect(find.byType(NavigationBar), findsOneWidget);

        // Placeholder assertion so the test runner does not treat this as
        // a passing or failing test — it is intentionally skipped.
        expect(true, isTrue);
      },
      // Mark as skipped until emulator is configured.
      // Remove this line to run the E2E test locally.
      // Requires Firebase Auth + Firestore emulator running locally.
      skip: true,
    );
  });
}
