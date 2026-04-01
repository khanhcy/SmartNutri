import 'dart:async';

class AuthUser {
  AuthUser({
    required this.uid,
    required this.email,
  });

  final String uid;
  final String email;
}

class AuthService {
  AuthService() {
    _authStateController = StreamController<AuthUser?>.broadcast(
      onListen: () => _authStateController.add(_currentUser),
    );
  }

  late final StreamController<AuthUser?> _authStateController;
  AuthUser? _currentUser;

  Stream<AuthUser?> authStateChanges() => _authStateController.stream;

  AuthUser? get currentUser => _currentUser;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    final normalizedPassword = password.trim();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw Exception('Email khong hop le');
    }
    if (normalizedPassword.length < 6) {
      throw Exception('Mat khau toi thieu 6 ky tu');
    }

    _currentUser = AuthUser(
      uid: _uidFromEmail(normalizedEmail),
      email: normalizedEmail,
    );
    _authStateController.add(_currentUser);
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    await signIn(email: email, password: password);
  }

  Future<void> signOut() async {
    _currentUser = null;
    _authStateController.add(null);
  }

  String _uidFromEmail(String email) {
    final sanitized = email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return sanitized.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : sanitized;
  }
}
