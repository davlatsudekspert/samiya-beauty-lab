import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:samiya_beauty_lab/features/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_shell_test.dart' show allText;
import 'support/fake_auth.dart';
import 'support/fake_backend.dart';
import 'support/pump.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  late List<String> order;
  late FakeAuthService auth;
  late FakeBackendApi backend;

  AppState signedIn({String lang = 'uz', UserRole? role = UserRole.student}) {
    order = [];
    auth = FakeAuthService(order: order);
    backend = FakeBackendApi(order: order);
    auth.emit(FakeAuthService.user('google.com'));
    return AppState(
        locale: Locale(lang), onboarded: true, role: role, auth: auth, backend: backend, ingredients: testRepo());
  }

  AppState guest({String lang = 'uz'}) =>
      AppState(locale: Locale(lang), onboarded: true, ingredients: testRepo());

  testWidgets('mehmon: "Mehmon" ko\'rinadi, Kirish tugmasi bor, chiqish/o\'chirish YO\'Q', (t) async {
    await pumpApp(t, state: guest(), initial: '/profile');
    expect(k('profile-page'), findsOneWidget);
    expect(find.text('Mehmon'), findsOneWidget);
    expect(k('profile-signin'), findsOneWidget);
    expect(k('profile-signout'), findsNothing);
    expect(k('profile-delete'), findsNothing);
  });

  testWidgets('kirgan foydalanuvchi: ism va email, Chiqish va O\'chirish bor, Kirish yo\'q', (t) async {
    await pumpApp(t, state: signedIn(), initial: '/profile');
    expect(find.text('Test'), findsOneWidget);
    expect(find.text('a@b.co'), findsOneWidget);
    expect(k('profile-signout'), findsOneWidget);
    expect(k('profile-delete'), findsOneWidget);
    expect(k('profile-signin'), findsNothing);
  });

  testWidgets('chiqish: auth.signOut chaqiriladi va kirish ekraniga o\'tadi', (t) async {
    await pumpApp(t, state: signedIn(), initial: '/profile');
    await t.tap(k('profile-signout'));
    await t.pumpAndSettle();
    expect(auth.signOutCalls, 1);
    expect(k('login-page'), findsOneWidget);
  });

  testWidgets('hisobni o\'chirish: tasdiq oynasi, "Bekor qilish" hech narsa qilmaydi', (t) async {
    await pumpApp(t, state: signedIn(), initial: '/profile');
    await t.tap(k('profile-delete'));
    await t.pumpAndSettle();
    expect(k('delete-confirm'), findsOneWidget);
    await t.tap(k('delete-cancel'));
    await t.pumpAndSettle();
    expect(order, isEmpty);
    expect(k('profile-page'), findsOneWidget);
  });

  testWidgets('tasdiqlansa: AVVAL backend (token bilan), KEYIN auth hisobi; so\'ng kirish ekrani va xabar', (t) async {
    final s = await pumpApp(t, state: signedIn(), initial: '/profile');
    await t.tap(k('profile-delete'));
    await t.pumpAndSettle();
    await t.tap(k('delete-confirm'));
    await t.pumpAndSettle();
    expect(order, ['backend', 'auth']);
    expect(backend.deleteTokens, ['fake-token']);
    expect(s.user, isNull);
    expect(s.role, isNull, reason: 'mahalliy rol ham tozalanadi');
    expect(k('login-page'), findsOneWidget);
    expect(find.text('Hisob o‘chirildi.'), findsOneWidget);
  });

  testWidgets('backend o\'chira olmasa auth hisobi O\'CHIRILMAYDI va xato ko\'rsatiladi', (t) async {
    final s = await pumpApp(t, state: signedIn(), initial: '/profile');
    backend.fail = true;
    await t.tap(k('profile-delete'));
    await t.pumpAndSettle();
    await t.tap(k('delete-confirm'));
    await t.pumpAndSettle();
    expect(order, ['backend']);
    expect(s.user, isNotNull);
    expect(k('profile-page'), findsOneWidget);
    expect(find.text('Kirish bajarilmadi. Qayta urinib ko‘ring.'), findsNothing);
    expect(find.text('Amal bajarilmadi. Qayta urinib ko‘ring.'), findsOneWidget);
  });

  testWidgets('"yaqinda kirish talab qilinadi": maxsus xabar, ekranda qolinadi', (t) async {
    final s = await pumpApp(t, state: signedIn(), initial: '/profile');
    auth.deleteError = const AuthException(AuthFailure.requiresRecentLogin);
    await t.tap(k('profile-delete'));
    await t.pumpAndSettle();
    await t.tap(k('delete-confirm'));
    await t.pumpAndSettle();
    expect(find.text('Xavfsizlik uchun qayta kiring, so‘ng hisobni o‘chiring.'), findsOneWidget);
    expect(s.user, isNotNull);
    expect(k('profile-page'), findsOneWidget);
  });

  testWidgets('backend sozlanmagan (hozirgi holat): faqat auth hisobi o\'chiriladi', (t) async {
    final s = signedIn();
    backend.configured = false;
    await pumpApp(t, state: s, initial: '/profile');
    await t.tap(k('profile-delete'));
    await t.pumpAndSettle();
    await t.tap(k('delete-confirm'));
    await t.pumpAndSettle();
    expect(order, ['auth']);
  });

  testWidgets('til chipi tilni almashtiradi va arabda RTL', (t) async {
    final s = await pumpApp(t, state: guest(), initial: '/profile');
    await t.tap(k('profile-lang-ar'));
    await t.pumpAndSettle();
    expect(s.locale.languageCode, 'ar');
    expect(dirOf(t, 'profile-page'), TextDirection.rtl);
  });

  testWidgets('rol qatori joriy rolni ko\'rsatadi va rol ekraniga olib boradi', (t) async {
    await pumpApp(t, state: signedIn(role: UserRole.teacher), initial: '/profile');
    expect(find.descendant(of: k('profile-role'), matching: find.text('Ustoz')), findsOneWidget);
    await t.tap(k('profile-role'));
    await t.pumpAndSettle();
    expect(k('role-page'), findsOneWidget);
  });

  testWidgets('huquqiy qatorlar URL tayyor emasligini halol aytadi (soxta havola yo\'q)', (t) async {
    await pumpApp(t, state: guest(), initial: '/profile');
    await t.tap(k('profile-privacy'));
    await t.pump();
    expect(find.text('Tez orada'), findsOneWidget);
  });

  testWidgets('siyosat: profilda dalilsiz da\'vo yo\'q (4 tilda)', (t) async {
    final banned = RegExp(r'halal|halol|حلال|88\s*%|xavfsiz\b|безопас|آمن', caseSensitive: false);
    for (final lang in ['uz', 'ru', 'en', 'ar']) {
      await pumpApp(t, state: guest(lang: lang), initial: '/profile');
      expect(banned.hasMatch(allText(t)), isFalse, reason: lang);
    }
  });

  group('profil 4 tilda 320x568 va 1.5x shriftda overflow bermaydi', () {
    for (final lang in ['uz', 'ru', 'en', 'ar']) {
      for (final kind in ['guest', 'signedIn']) {
        testWidgets('$lang $kind', (t) async {
          await pumpApp(t,
              state: kind == 'guest' ? guest(lang: lang) : signedIn(lang: lang),
              initial: '/profile',
              size: const Size(320, 568),
              textScale: 1.5);
          expect(t.takeException(), isNull);
        });
      }
    }
  });
}
