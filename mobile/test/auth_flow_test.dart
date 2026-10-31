import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:samiya_beauty_lab/features/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_auth.dart';
import 'support/pump.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  AppState stateWith(FakeAuthService a, {bool onboarded = false, UserRole? role}) =>
      AppState(auth: a, ingredients: testRepo(), onboarded: onboarded, role: role);

  testWidgets('Google bilan kirish muvaffaqiyatli: foydalanuvchi holatga yoziladi, rol tanlashga o\'tadi', (t) async {
    final auth = FakeAuthService();
    final s = await pumpApp(t, state: stateWith(auth), initial: '/login');
    await t.tap(k('btn-google'));
    await t.pumpAndSettle();
    expect(auth.googleCalls, 1);
    expect(s.user?.uid, 'uid-1');
    expect(k('role-page'), findsOneWidget);
  });

  testWidgets('Apple bilan kirish ham rol tanlashga olib boradi', (t) async {
    final auth = FakeAuthService();
    await pumpApp(t, state: stateWith(auth), initial: '/login');
    await t.tap(k('btn-apple'));
    await t.pumpAndSettle();
    expect(auth.appleCalls, 1);
    expect(k('role-page'), findsOneWidget);
  });

  testWidgets('rol allaqachon tanlangan bo\'lsa to\'g\'ridan-to\'g\'ri bosh sahifaga', (t) async {
    await pumpApp(t, state: stateWith(FakeAuthService(), onboarded: true, role: UserRole.student), initial: '/login');
    await t.tap(k('btn-google'));
    await t.pumpAndSettle();
    expect(k('home-page'), findsOneWidget);
  });

  testWidgets('foydalanuvchi bekor qilsa: xabar yo\'q, ekran o\'zgarmaydi, tugmalar yana ishlaydi', (t) async {
    final auth = FakeAuthService(error: const AuthException(AuthFailure.cancelled));
    await pumpApp(t, state: stateWith(auth), initial: '/login');
    await t.tap(k('btn-google'));
    await t.pumpAndSettle();
    expect(k('login-page'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    await t.tap(k('btn-apple'));
    await t.pumpAndSettle();
    expect(auth.appleCalls, 1);
  });

  testWidgets('kirish xatosi: halol xabar (4 tilda), ekran o\'zgarmaydi', (t) async {
    const msgs = {
      'uz': 'Kirish bajarilmadi. Qayta urinib ko‘ring.',
      'ru': 'Не удалось войти. Попробуйте ещё раз.',
      'en': 'Sign-in failed. Please try again.',
      'ar': 'تعذّر تسجيل الدخول. حاول مرة أخرى.',
    };
    for (final e in msgs.entries) {
      final auth = FakeAuthService(error: const AuthException(AuthFailure.failed));
      await pumpApp(t, state: AppState(locale: Locale(e.key), auth: auth, ingredients: testRepo()), initial: '/login');
      await t.tap(k('btn-google'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text(e.value), findsOneWidget, reason: e.key);
      expect(k('login-page'), findsOneWidget);
    }
  });

  testWidgets('Firebase sozlanmagan (UnavailableAuthService): "hozircha mavjud emas" xabari', (t) async {
    await pumpApp(t, initial: '/login');
    await t.tap(k('btn-google'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Kirish hozircha mavjud emas.'), findsOneWidget);
    expect(k('login-page'), findsOneWidget);
  });

  testWidgets('kirish davomida tugmalar o\'chadi: ikki marta bosish ikkinchi so\'rov yubormaydi', (t) async {
    final auth = FakeAuthService()..gate = Completer<AuthUser>();
    await pumpApp(t, state: stateWith(auth), initial: '/login');
    await t.tap(k('btn-google'));
    await t.pump();
    expect(k('login-busy'), findsOneWidget);
    await t.tap(k('btn-apple'), warnIfMissed: false);
    await t.tap(k('btn-google'), warnIfMissed: false);
    await t.pump();
    expect(auth.googleCalls + auth.appleCalls, 1);
    auth.gate!.complete(FakeAuthService.user('google.com'));
    await t.pumpAndSettle();
    expect(k('role-page'), findsOneWidget);
  });

  testWidgets('mehmon rejimi hisobsiz davom etadi (user bo\'sh)', (t) async {
    final s = await pumpApp(t, state: stateWith(FakeAuthService()), initial: '/login');
    await t.tap(k('btn-guest'));
    await t.pumpAndSettle();
    expect(k('role-page'), findsOneWidget);
    expect(s.user, isNull);
  });

  testWidgets('auth oqimi (masalan boshqa qurilmadan chiqish) holatga ta\'sir qiladi', (t) async {
    final auth = FakeAuthService();
    final s = await pumpApp(t, state: stateWith(auth), initial: '/login');
    auth.emit(FakeAuthService.user('apple.com'));
    await t.pump();
    expect(s.user?.provider, 'apple.com');
    auth.emit(null);
    await t.pump();
    expect(s.user, isNull);
  });
}
