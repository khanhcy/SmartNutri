import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/app/auth_flow_notifier.dart';
import 'package:smartnutri/src/core/ui/components/state_view.dart';
import 'package:smartnutri/src/features/auth/presentation/sign_in_page.dart';
import 'package:smartnutri/src/features/dashboard/presentation/main_shell_page.dart';
import 'package:smartnutri/src/features/home/presentation/home_page.dart';
import 'package:smartnutri/src/features/meal_log/presentation/meal_log_page.dart';
import 'package:smartnutri/src/features/onboarding/presentation/onboarding_page.dart';
import 'package:smartnutri/src/features/profile/presentation/profile_page.dart';
import 'package:smartnutri/src/features/search/presentation/food_search_page.dart';
import 'package:smartnutri/src/features/scan/presentation/barcode_scan_page.dart';
import 'package:smartnutri/src/features/scan/presentation/photo_scan_page.dart';
import 'package:smartnutri/src/features/stats/presentation/statistics_page.dart';

/// Route paths for deep links & notifications.
abstract final class AppPaths {
  static const splash = '/splash';
  static const signIn = '/sign-in';
  static const onboarding = '/onboarding';
  static const app = '/app';
  static const home = '/app/home';
  static const search = '/app/search';
  static const log = '/app/log';
  static const profile = '/app/profile';
  static const stats = '/app/stats';
  static const scanPhoto = '/app/scan/photo';
  static const scanBarcode = '/app/scan/barcode';
}

GoRouter createAppRouter({required AuthFlowNotifier authFlow}) {
  return GoRouter(
    initialLocation: AppPaths.splash,
    refreshListenable: authFlow,
    redirect: (context, state) {
      final loc = state.matchedLocation;

      if (authFlow.isLoading) {
        if (loc == AppPaths.splash) return null;
        return AppPaths.splash;
      }

      if (!authFlow.isLoggedIn) {
        if (loc == AppPaths.signIn) return null;
        return AppPaths.signIn;
      }

      if (authFlow.needsOnboarding) {
        if (loc == AppPaths.onboarding) return null;
        return AppPaths.onboarding;
      }

      if (loc == AppPaths.signIn ||
          loc == AppPaths.onboarding ||
          loc == AppPaths.splash) {
        return AppPaths.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppPaths.splash,
        builder: (context, _) =>
            const LoadingView(message: 'Đang khởi động...'),
      ),
      GoRoute(
        path: AppPaths.signIn,
        builder: (context, _) => const SignInPage(),
      ),
      GoRoute(
        path: AppPaths.onboarding,
        builder: (context, _) {
          final user = context.read<AuthFlowNotifier>().user;
          return OnboardingPage(user: user!);
        },
      ),
      GoRoute(
        path: AppPaths.app,
        redirect: (context, state) =>
            state.fullPath == AppPaths.app ? AppPaths.home : null,
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) =>
                MainShellPage(shell: navigationShell),
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'home',
                    pageBuilder: (context, state) =>
                        const NoTransitionPage<void>(child: HomePage()),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'search',
                    pageBuilder: (context, state) =>
                        const NoTransitionPage<void>(
                            child: FoodSearchPage()),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'log',
                    pageBuilder: (context, state) =>
                        const NoTransitionPage<void>(child: MealLogPage()),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'profile',
                    pageBuilder: (context, state) =>
                        const NoTransitionPage<void>(child: ProfilePage()),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'stats',
            pageBuilder: (context, state) =>
                const NoTransitionPage<void>(child: StatisticsPage()),
          ),
          GoRoute(
            path: 'scan/photo',
            pageBuilder: (context, state) =>
                const NoTransitionPage<void>(child: PhotoScanPage()),
          ),
          GoRoute(
            path: 'scan/barcode',
            pageBuilder: (context, state) =>
                const NoTransitionPage<void>(child: BarcodeScanPage()),
          ),
        ],
      ),
    ],
  );
}
