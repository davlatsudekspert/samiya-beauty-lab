/// Kirish xizmati abstraksiyasi: Firebase'ga bog'lanmagan holda sinash va halol "mavjud emas" holati uchun.
library;

class AuthUser {
  const AuthUser({required this.uid, required this.provider, this.email, this.displayName});
  final String uid;
  final String provider; // google.com | apple.com
  final String? email;
  final String? displayName;
}

enum AuthFailure { cancelled, unavailable, requiresRecentLogin, failed }

class AuthException implements Exception {
  const AuthException(this.kind);
  final AuthFailure kind;
  @override
  String toString() => 'AuthException($kind)';
}

abstract class AuthService {
  AuthUser? get currentUser;
  Stream<AuthUser?> get changes;
  Future<AuthUser> signInWithGoogle();
  Future<AuthUser> signInWithApple();
  Future<void> signOut();

  /// Hisobni o'chirish (Apple/Google talabi). Yaqinda kirmagan bo'lsa [AuthFailure.requiresRecentLogin].
  Future<void> deleteAccount();

  /// Backend'ga yuboriladigan ID token (Authorization: Bearer).
  Future<String?> idToken();
}

/// Firebase sozlanmagan paytda (konfiguratsiya fayllari yo'q) ishlatiladi: hech narsa buzilmaydi,
/// foydalanuvchiga halol xabar ko'rsatiladi.
class UnavailableAuthService implements AuthService {
  const UnavailableAuthService();
  @override
  AuthUser? get currentUser => null;
  @override
  Stream<AuthUser?> get changes => const Stream.empty();
  @override
  Future<AuthUser> signInWithGoogle() => Future.error(const AuthException(AuthFailure.unavailable));
  @override
  Future<AuthUser> signInWithApple() => Future.error(const AuthException(AuthFailure.unavailable));
  @override
  Future<void> signOut() async {}
  @override
  Future<void> deleteAccount() => Future.error(const AuthException(AuthFailure.unavailable));
  @override
  Future<String?> idToken() async => null;
}
