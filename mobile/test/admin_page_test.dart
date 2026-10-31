import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:samiya_beauty_lab/data/backend_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_auth.dart';
import 'support/fake_backend.dart';
import 'support/fonts.dart';
import 'support/pump.dart';

void main() {
  setUpAll(loadAppFonts);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  late FakeBackendApi backend;

  Future<AppState> make(WidgetTester t, {bool admin = true, bool pro = true, String lang = 'uz', bool signedIn = true}) async {
    backend = FakeBackendApi(meInfo: MeInfo(isAdmin: admin, pro: pro));
    final auth = FakeAuthService();
    if (signedIn) auth.emit(FakeAuthService.user('google.com'));
    final s = AppState(locale: Locale(lang), onboarded: true, auth: auth, backend: backend, ingredients: testRepo());
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    return s;
  }

  testWidgets('profil: admin "Admin paneli" qatorini va Pro belgisini ko\'radi', (t) async {
    await pumpApp(t, state: await make(t), initial: '/profile');
    expect(k('profile-admin'), findsOneWidget);
    expect(k('profile-pro'), findsOneWidget);
  });

  testWidgets('profil: oddiy foydalanuvchi admin qatorini ko\'rmaydi; Pro bo\'lmasa belgi yo\'q', (t) async {
    await pumpApp(t, state: await make(t, admin: false, pro: false), initial: '/profile');
    expect(k('profile-admin'), findsNothing);
    expect(k('profile-pro'), findsNothing);
  });

  testWidgets('profil: mehmon admin qatorini ko\'rmaydi', (t) async {
    await pumpApp(t, state: await make(t, signedIn: false), initial: '/profile');
    expect(k('profile-admin'), findsNothing);
  });

  testWidgets('oddiy foydalanuvchi /profile/admin ga to\'g\'ridan-to\'g\'ri kirolmaydi', (t) async {
    await pumpApp(t, state: await make(t, admin: false, pro: false), initial: '/profile/admin');
    expect(k('admin-page'), findsNothing);
  });

  testWidgets('admin panel: statistika sonlari ko\'rinadi', (t) async {
    await pumpApp(t, state: await make(t), initial: '/profile');
    await t.tap(k('profile-admin'));
    await t.pumpAndSettle();
    expect(k('admin-page'), findsOneWidget);
    expect(find.descendant(of: k('admin-stat-total'), matching: find.text('11')), findsOneWidget);
    expect(find.descendant(of: k('admin-stat-android'), matching: find.text('7')), findsOneWidget);
    expect(find.descendant(of: k('admin-stat-ios'), matching: find.text('3')), findsOneWidget);
    expect(find.descendant(of: k('admin-stat-web'), matching: find.text('1')), findsOneWidget);
    expect(find.descendant(of: k('admin-stat-active7d'), matching: find.text('6')), findsOneWidget);
    expect(find.descendant(of: k('admin-stat-users'), matching: find.text('5')), findsOneWidget);
    // halollik: bu do'kon yuklab olishlari emasligi aytilgan
    expect(k('admin-installs-note'), findsOneWidget);
  });

  testWidgets('emailga Pro berish: backend\'ga ketadi, ro\'yxatda ko\'rinadi, maydon tozalanadi', (t) async {
    await pumpApp(t, state: await make(t), initial: '/profile/admin');
    await t.enterText(k('admin-email'), '  Friend@Gmail.com ');
    await t.ensureVisible(k('admin-days-90'));
    await t.tap(k('admin-days-90'));
    await t.pump();
    await t.ensureVisible(k('admin-grant'));
    await t.tap(k('admin-grant'));
    await t.pumpAndSettle();
    expect(backend.actions, ['grant:friend@gmail.com:90']);
    await t.ensureVisible(k('admin-grant-friend@gmail.com'));
    expect(k('admin-grant-friend@gmail.com'), findsOneWidget);
    expect(k('admin-message'), findsOneWidget);
    expect(tester(t).text, isEmpty);
  });

  testWidgets('"Cheksiz" tanlansa days yuborilmaydi', (t) async {
    await pumpApp(t, state: await make(t), initial: '/profile/admin');
    await t.enterText(k('admin-email'), 'a@b.co');
    await t.ensureVisible(k('admin-days-forever'));
    await t.tap(k('admin-days-forever'));
    await t.pump();
    await t.ensureVisible(k('admin-grant'));
    await t.tap(k('admin-grant'));
    await t.pumpAndSettle();
    expect(backend.actions, ['grant:a@b.co:forever']);
  });

  testWidgets('noto\'g\'ri email: xabar chiqadi, backend\'ga so\'rov yuborilmaydi', (t) async {
    await pumpApp(t, state: await make(t), initial: '/profile/admin');
    for (final bad in ['', 'abc', 'a@b', 'a b@c.co']) {
      await t.enterText(k('admin-email'), bad);
      await t.ensureVisible(k('admin-grant'));
      await t.tap(k('admin-grant'));
      await t.pumpAndSettle();
      expect(find.text('Email manzil noto‘g‘ri.'), findsOneWidget, reason: 'email: "$bad"');
    }
    expect(backend.actions, isEmpty);
  });

  testWidgets('qaytarib olish: ro\'yxatdan yo\'qoladi', (t) async {
    final s = await make(t);
    backend.grants.add(const ProGrant(email: 'x@y.co'));
    await pumpApp(t, state: s, initial: '/profile/admin');
    await t.ensureVisible(k('admin-grant-x@y.co'));
    expect(k('admin-grant-x@y.co'), findsOneWidget);
    await t.ensureVisible(k('admin-revoke-x@y.co'));
    await t.tap(k('admin-revoke-x@y.co'));
    await t.pumpAndSettle();
    expect(backend.actions, ['revoke:x@y.co']);
    expect(k('admin-grant-x@y.co'), findsNothing);
  });

  testWidgets('server xatosi: halol xabar va "Qayta urinish"; muvaffaqiyat soxtalashtirilmaydi', (t) async {
    final s = await make(t);
    backend.adminFails = true;
    await pumpApp(t, state: s, initial: '/profile/admin');
    expect(k('admin-load-error'), findsOneWidget);
    expect(k('admin-retry'), findsOneWidget);
    backend.adminFails = false;
    await t.tap(k('admin-retry'));
    await t.pumpAndSettle();
    expect(k('admin-load-error'), findsNothing);
    expect(find.descendant(of: k('admin-stat-total'), matching: find.text('11')), findsOneWidget);
  });

  testWidgets('Pro berishda server xatosi: "Pro berildi" DEMAYDI, xato ko\'rsatadi', (t) async {
    final s = await make(t);
    await pumpApp(t, state: s, initial: '/profile/admin');
    backend.adminFails = true;
    await t.enterText(k('admin-email'), 'a@b.co');
    await t.ensureVisible(k('admin-grant'));
    await t.tap(k('admin-grant'));
    await t.pumpAndSettle();
    expect(find.text('Pro berildi.'), findsNothing);
    expect(find.text('Ma‘lumotni yuklab bo‘lmadi.'), findsWidgets);
  });

  for (final lang in ['uz', 'ru', 'en', 'ar']) {
    testWidgets('320x568, 1.5x shrift, $lang: admin panelda overflow yo\'q', (t) async {
      final s = await make(t, lang: lang);
      backend.grants.add(const ProGrant(email: 'a-rather-long-address-for-layout-check@example-domain.com'));
      await pumpApp(t, state: s, initial: '/profile/admin', size: const Size(320, 568), textScale: 1.5);
      expect(k('admin-page'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }
}

TextEditingController tester(WidgetTester t) => t.widget<TextField>(k('admin-email')).controller!;
