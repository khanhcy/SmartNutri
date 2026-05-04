import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/profile_service.dart';
import 'package:smartnutri/src/core/ui/components/state_view.dart';
import 'package:smartnutri/src/features/auth/presentation/sign_in_page.dart';
import 'package:smartnutri/src/features/dashboard/presentation/main_shell_page.dart';
import 'package:smartnutri/src/features/onboarding/presentation/onboarding_page.dart';
import 'package:smartnutri/src/features/profile/domain/user_profile.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    return StreamBuilder<AuthUser?>(
      stream: auth.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const LoadingView(message: 'Đang khởi động...');
        }

        if (!authSnap.hasData) {
          return const SignInPage();
        }

        final user = authSnap.data!;

        return StreamBuilder<UserProfile?>(
          stream: context.read<ProfileService>().watchProfile(user.uid),
          builder: (context, profileSnap) {
            if (profileSnap.connectionState == ConnectionState.waiting) {
              return const LoadingView(message: 'Đang tải dữ liệu...');
            }

            final profile = profileSnap.data;
            if (profile == null || !profile.onboardingCompleted) {
              return OnboardingPage(user: user);
            }

            return const MainShellPage();
          },
        );
      },
    );
  }
}
