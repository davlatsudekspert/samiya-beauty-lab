import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'auth_service.dart';

/// Firebase Authentication orqali Google va Apple bilan kirish (provayder oqimi).
/// Android/iOS konfiguratsiya fayllari (google-services.json, GoogleService-Info.plist) build vaqtida kerak.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService([fb.FirebaseAuth? auth]) : _auth = auth ?? fb.FirebaseAuth.instance;
  final fb.FirebaseAuth _auth;

  static const _cancelCodes = {
    'canceled', 'cancelled', 'web-context-canceled', 'web-context-cancelled', 'popup-closed-by-user', 'user-cancelled',
  };

  AuthUser? _map(fb.User? u, [String? provider]) => u == null
      ? null
      : AuthUser(
          uid: u.uid,
          email: u.email,
          displayName: u.displayName,
          provider: provider ?? (u.providerData.isEmpty ? 'unknown' : u.providerData.first.providerId),
        );

  Future<AuthUser> _signIn(fb.AuthProvider provider) async {
    try {
      final cred = await _auth.signInWithProvider(provider);
      final user = _map(cred.user, cred.credential?.providerId);
      if (user == null) throw const AuthException(AuthFailure.failed);
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_cancelCodes.contains(e.code) ? AuthFailure.cancelled : AuthFailure.failed);
    }
  }

  @override
  AuthUser? get currentUser => _map(_auth.currentUser);

  @override
  Stream<AuthUser?> get changes => _auth.authStateChanges().map(_map);

  @override
  Future<AuthUser> signInWithGoogle() => _signIn(fb.GoogleAuthProvider()..addScope('email'));

  @override
  Future<AuthUser> signInWithApple() =>
      _signIn(fb.AppleAuthProvider()..addScope('email')..addScope('name'));

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.code == 'requires-recent-login' ? AuthFailure.requiresRecentLogin : AuthFailure.failed);
    }
  }

  @override
  Future<String?> idToken() async => _auth.currentUser?.getIdToken();
}
