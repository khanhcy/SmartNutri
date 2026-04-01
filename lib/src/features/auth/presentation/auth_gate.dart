import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/profile_service.dart';
import 'package:smartnutri/src/features/auth/presentation/sign_in_page.dart';
import 'package:smartnutri/src/features/dashboard/presentation/dashboard_page.dart';
import 'package:smartnutri/src/features/onboarding/presentation/onboarding_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    return StreamBuilder<AuthUser?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SignInPage();
        }

        final user = snapshot.data!;
        return FutureBuilder<bool>(
          future: _shouldShowOnboarding(context, user.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final shouldShowOnboarding = profileSnapshot.data ?? true;
            if (shouldShowOnboarding) {
              return OnboardingPage(user: user);
            }
            return DashboardPage(user: user);
          },
        );
      },
    );
  }

  Future<bool> _shouldShowOnboarding(BuildContext context, String uid) async {
    final profileService = context.read<ProfileService>();
    final profile = await profileService.getProfile(uid);
    return profile == null || !profile.onboardingCompleted;
  }
}
