import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:samiya_beauty_lab/data/backend_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_auth.dart';
import 'support/fake_backend.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

  test('mehmon: admin ham, Pro ham emas; backend\'ga /me so\'rovi yuborilmaydi', () async {
    final b = FakeBackendApi(meInfo: const MeInfo(isAdmin: true, pro: true));
    final s = AppState(auth: FakeAuthService(), backend: b);
    await settle();
    expect(s.isAdmin, isFalse);
    expect(s.isPro, isFalse);
    expect(b.meTokens, isEmpty);
  });

  test('admin kirganda: serverdan isAdmin va isPro true bo\'ladi, token yuboriladi', () async {
    final auth = FakeAuthService();
    final b = FakeBackendApi(meInfo: const MeInfo(isAdmin: true, pro: true));
    final s = AppState(auth: auth, backend: b);
    auth.emit(FakeAuthService.user('google.com'));
    await settle();
    expect(s.isAdmin, isTrue);
    expect(s.isPro, isTrue);
    expect(b.meTokens, ['fake-token']);
  });

  test('oddiy foydalanuvchi: admin emas; Pro serverda belgilangan bo\'lsa Pro', () async {
    final auth = FakeAuthService();
    final b = FakeBackendApi(meInfo: const MeInfo(isAdmin: false, pro: true));
    final s = AppState(auth: auth, backend: b);
    auth.emit(FakeAuthService.user('google.com'));
    await settle();
    expect(s.isAdmin, isFalse);
    expect(s.isPro, isTrue);
  });

  test('chiqishda admin/Pro holati tozalanadi', () async {
    final auth = FakeAuthService();
    final s = AppState(auth: auth, backend: FakeBackendApi(meInfo: const MeInfo(isAdmin: true, pro: true)));
    auth.emit(FakeAuthService.user('google.com'));
    await settle();
    expect(s.isAdmin, isTrue);
    auth.emit(null);
    await settle();
    expect(s.isAdmin, isFalse);
    expect(s.isPro, isFalse);
  });

  test('backend xatosi: admin/Pro berilmaydi (xavfsiz tomonga), ilova yiqilmaydi', () async {
    final auth = FakeAuthService();
    final b = FakeBackendApi(meInfo: const MeInfo(isAdmin: true, pro: true))..meFails = true;
    final s = AppState(auth: auth, backend: b);
    auth.emit(FakeAuthService.user('google.com'));
    await settle();
    expect(s.isAdmin, isFalse);
    expect(s.isPro, isFalse);
  });

  test('backend sozlanmagan: so\'rov yo\'q, admin yo\'q', () async {
    final auth = FakeAuthService();
    final b = FakeBackendApi(configured: false, meInfo: const MeInfo(isAdmin: true, pro: true));
    final s = AppState(auth: auth, backend: b);
    auth.emit(FakeAuthService.user('google.com'));
    await settle();
    expect(s.isAdmin, isFalse);
    expect(b.meTokens, isEmpty);
  });

  test('foydalanuvchi allaqachon kirgan holda ilova ochilsa ham holat yuklanadi', () async {
    final auth = FakeAuthService()..emit(FakeAuthService.user('google.com'));
    final s = AppState(auth: auth, backend: FakeBackendApi(meInfo: const MeInfo(isAdmin: true, pro: true)));
    await settle();
    expect(s.isAdmin, isTrue);
  });

  test('admin amallari: statistika, Pro berish, ro\'yxat, qaytarib olish', () async {
    final auth = FakeAuthService();
    final b = FakeBackendApi(meInfo: const MeInfo(isAdmin: true, pro: true));
    final s = AppState(auth: auth, backend: b);
    auth.emit(FakeAuthService.user('google.com'));
    await settle();
    expect((await s.adminStats()).installsTotal, 11);
    await s.grantPro('friend@gmail.com', days: 30);
    expect((await s.listGrants()).map((g) => g.email), ['friend@gmail.com']);
    await s.revokePro('friend@gmail.com');
    expect(await s.listGrants(), isEmpty);
    expect(b.actions, ['grant:friend@gmail.com:30', 'revoke:friend@gmail.com']);
  });

  test('admin bo\'lmasa admin amallari rad etiladi (backend\'ga so\'rov yuborilmaydi)', () async {
    final b = FakeBackendApi();
    final s = AppState(auth: FakeAuthService(), backend: b);
    await expectLater(s.adminStats(), throwsA(isA<StateError>()));
    await expectLater(s.grantPro('a@b.co'), throwsA(isA<StateError>()));
    expect(b.actions, isEmpty);
  });
}
