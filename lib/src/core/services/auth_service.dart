import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthUser {
  AuthUser({
    required this.uid,
    required this.email,
    this.displayName,
  });

  final String uid;
  final String email;
  final String? displayName;
}

class AuthService {
  AuthService({fb.FirebaseAuth? auth, GoogleSignIn? googleSignIn})
      : _auth = auth ?? fb.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final fb.FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  Stream<AuthUser?> authStateChanges() {
    return _auth.authStateChanges().map(_mapFirebaseUser);
  }

  AuthUser? get currentUser => _mapFirebaseUser(_auth.currentUser);

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
      }
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    }
  }

  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    } catch (_) {
      throw Exception('Đăng nhập Google thất bại. Vui lòng thử lại.');
    }
  }

  Future<void> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = fb.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      await _auth.signInWithCredential(oauthCredential);
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    } catch (_) {
      throw Exception('Đăng nhập Apple thất bại. Vui lòng thử lại.');
    }
  }

  Future<void> signInWithFacebook() async {
    throw Exception('Facebook Sign-In chưa được cấu hình trong bản này.');
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  AuthUser? _mapFirebaseUser(fb.User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  String _friendlyAuthError(fb.FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Sai email hoặc mật khẩu';
      case 'email-already-in-use':
      case 'account-exists-with-different-credential':
        return 'Email đã được sử dụng';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
      case 'too-many-requests':
        return 'Bạn thử quá nhiều lần. Vui lòng thử lại sau';
      default:
        return error.message ?? 'Đăng nhập thất bại';
    }
  }
}
