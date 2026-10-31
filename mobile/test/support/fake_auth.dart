import 'dart:async';

import 'package:samiya_beauty_lab/features/auth/auth_service.dart';

/// Sinov uchun soxta kirish xizmati: natijani, xatoni yoki kutishni (Completer) boshqarish mumkin.
class FakeAuthService implements AuthService {
  FakeAuthService({this.error});
  AuthException? error;
  Completer<AuthUser>? gate;
  int googleCalls = 0, appleCalls = 0, signOutCalls = 0;
  final _changes = StreamController<AuthUser?>.broadcast();
  AuthUser? _user;

  static AuthUser user(String provider) =>
      AuthUser(uid: 'uid-1', email: 'a@b.co', displayName: 'Test', provider: provider);

  void emit(AuthUser? u) {
    _user = u;
    _changes.add(u);
  }

  Future<AuthUser> _run(String provider) async {
    if (gate != null) return gate!.future;
    if (error != null) throw error!;
    final u = user(provider);
    emit(u);
    return u;
  }

  @override
  AuthUser? get currentUser => _user;
  @override
  Stream<AuthUser?> get changes => _changes.stream;
  @override
  Future<AuthUser> signInWithGoogle() { googleCalls++; return _run('google.com'); }
  @override
  Future<AuthUser> signInWithApple() { appleCalls++; return _run('apple.com'); }
  @override
  Future<void> signOut() async { signOutCalls++; emit(null); }
  @override
  Future<void> deleteAccount() async => emit(null);
  @override
  Future<String?> idToken() async => _user == null ? null : 'fake-token';
}
