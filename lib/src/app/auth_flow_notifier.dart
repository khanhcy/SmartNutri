import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/profile_service.dart';
import 'package:smartnutri/src/features/profile/domain/user_profile.dart';

/// Drives GoRouter redirect based on auth state + onboarding status.
class AuthFlowNotifier extends ChangeNotifier {
  AuthFlowNotifier(this._authService, this._profileService) {
    _authSub = _authService.authStateChanges().listen(_onAuthChanged);
  }

  final AuthService _authService;
  final ProfileService _profileService;
  StreamSubscription<AuthUser?>? _authSub;
  StreamSubscription<UserProfile?>? _profileSub;

  AuthUser? _user;
  UserProfile? _userProfile;
  bool _initialAuthResolved = false;
  bool _profileLoading = false;

  AuthUser? get user => _user;

  bool get isLoading => !_initialAuthResolved || (_user != null && _profileLoading);
  bool get isLoggedIn => _user != null;
  bool get needsOnboarding =>
      _user != null &&
      !_profileLoading &&
      (_userProfile == null || !_userProfile!.onboardingCompleted);

  void _onAuthChanged(AuthUser? user) {
    _profileSub?.cancel();
    _profileSub = null;
    _user = user;
    _userProfile = null;

    if (user == null) {
      _profileLoading = false;
      _initialAuthResolved = true;
      notifyListeners();
      return;
    }

    _profileLoading = true;
    _initialAuthResolved = true;
    notifyListeners();

    _profileSub = _profileService.watchProfile(user.uid).listen((p) {
      _userProfile = p;
      _profileLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
