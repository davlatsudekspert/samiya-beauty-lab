import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/pump.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('yangi foydalanuvchi: splash -> til tanlash', (t) async {
    await pumpApp(t);
    expect(k('language-page'), findsOneWidget);
  });

  testWidgets('onboarding tugatgan foydalanuvchi: splash -> bosh sahifa', (t) async {
    await pumpApp(t, state: AppState(onboarded: true));
    expect(k('home-page'), findsOneWidget);
  });

  testWidgets('til tanlash: arab RTL ga o\'tadi, matn almashadi, davom etish -> welcome', (t) async {
    final s = await pumpApp(t);
    expect(dirOf(t, 'language-page'), TextDirection.ltr);
    await t.tap(k('lang-ar'));
    await t.pumpAndSettle();
    expect(dirOf(t, 'language-page'), TextDirection.rtl);
    expect(find.text('اختاري لغتك'), findsOneWidget);
    expect(s.locale.languageCode, 'ar');
    await t.tap(k('language-continue'));
    await t.pumpAndSettle();
    expect(k('welcome-page'), findsOneWidget);
    expect(dirOf(t, 'welcome-page'), TextDirection.rtl);
  });

  testWidgets('welcome -> onboarding 01/03 -> 03/03 -> login', (t) async {
    await pumpApp(t, initial: '/welcome');
    await t.tap(k('welcome-start'));
    await t.pumpAndSettle();
    expect(k('onboarding-page'), findsOneWidget);
    expect(find.text('Go‘zallik ilm bilan boshlanadi'), findsOneWidget);
    await t.tap(k('onboarding-next'));
    await t.pumpAndSettle();
    await t.tap(k('onboarding-next'));
    await t.pumpAndSettle();
    expect(find.text('O‘rganing, rivojlaning'), findsOneWidget);
    await t.tap(k('onboarding-next'));
    await t.pumpAndSettle();
    expect(k('login-page'), findsOneWidget);
  });

  testWidgets('onboarding: o\'tkazib yuborish -> login', (t) async {
    await pumpApp(t, initial: '/onboarding');
    await t.tap(k('onboarding-skip'));
    await t.pumpAndSettle();
    expect(k('login-page'), findsOneWidget);
  });

  testWidgets('orqaga tugmasi oldingi ekranga qaytaradi', (t) async {
    await pumpApp(t, initial: '/welcome');
    await t.tap(k('welcome-start'));
    await t.pumpAndSettle();
    await t.tap(k('back-chip'));
    await t.pumpAndSettle();
    expect(k('welcome-page'), findsOneWidget);
  });

  testWidgets('login: faqat Google, Apple va mehmon. Email/parol maydoni YO\'Q', (t) async {
    await pumpApp(t, initial: '/login');
    expect(find.byType(TextField), findsNothing);
    expect(k('btn-google'), findsOneWidget);
    expect(k('btn-apple'), findsOneWidget);
    expect(k('btn-guest'), findsOneWidget);
    // Firebase sozlanmagan holat: halol xabar, ekran o'zgarmaydi (haqiqiy kirish: auth_flow_test).
    await t.tap(k('btn-google'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Kirish hozircha mavjud emas.'), findsOneWidget);
    expect(k('login-page'), findsOneWidget);
  });

  testWidgets('mehmon -> rol tanlash; rol tanlab davom etish holatni saqlaydi', (t) async {
    final s = await pumpApp(t, initial: '/login');
    await t.tap(k('btn-guest'));
    await t.pumpAndSettle();
    expect(k('role-page'), findsOneWidget);
    expect(s.role, isNull);
    await t.tap(k('role-teacher'));
    await t.pumpAndSettle();
    await t.tap(k('role-continue'));
    await t.pumpAndSettle();
    expect(k('home-page'), findsOneWidget);
    expect(s.role, UserRole.teacher);
    expect(s.onboarded, isTrue);
  });

  testWidgets('rol tanlanmaguncha davom etish tugmasi o\'chiq', (t) async {
    await pumpApp(t, initial: '/role');
    final btn = t.widget<ElevatedButton>(
        find.descendant(of: k('role-continue'), matching: find.byType(ElevatedButton)));
    expect(btn.onPressed, isNull);
  });

  testWidgets('saqlangan holat (til, onboarding, rol) qayta ishga tushganda tiklanadi', (t) async {
    SharedPreferences.setMockInitialValues(
        {'locale': 'ar', 'onboarded': true, 'role': 'student'});
    // Asset o'qish haqiqiy asinxron operatsiya: soxta vaqt zonasida runAsync kerak.
    final s = (await t.runAsync(AppState.load))!;
    expect(s.role, UserRole.student);
    await pumpApp(t, state: s);
    expect(k('home-page'), findsOneWidget);
    expect(dirOf(t, 'home-page'), TextDirection.rtl);
  });

  testWidgets('til o\'zgarishi diskka yoziladi', (t) async {
    final s = AppState();
    await s.setLocale('ru');
    expect((await SharedPreferences.getInstance()).getString('locale'), 'ru');
  });

  testWidgets('asosiy tugmalar kamida 48 px balandlikda (qulay bosish)', (t) async {
    for (final e in {
      '/language': 'language-continue',
      '/welcome': 'welcome-start',
      '/onboarding': 'onboarding-next',
      '/login': 'btn-google',
      '/role': 'role-continue',
    }.entries) {
      await pumpApp(t, initial: e.key);
      expect(t.getSize(k(e.value)).height, greaterThanOrEqualTo(48), reason: e.value);
    }
    await pumpApp(t, initial: '/login');
    for (final key in ['btn-apple', 'btn-guest']) {
      expect(t.getSize(k(key)).height, greaterThanOrEqualTo(48), reason: key);
    }
  });

  group('maket mustahkamligi: 320x568 ekran va 1.5x shrift, 4 tilda overflow yo\'q', () {
    for (final lang in ['uz', 'ru', 'en', 'ar']) {
      for (final route in ['/language', '/welcome', '/onboarding', '/login', '/role', '/home']) {
        testWidgets('$lang $route', (t) async {
          await pumpApp(t,
              state: AppState(locale: Locale(lang), onboarded: true),
              initial: route,
              size: const Size(320, 568),
              textScale: 1.5);
          expect(t.takeException(), isNull);
        });
      }
    }
  });
}
