import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/pump.dart';

/// Ekrandagi barcha matnlarni yig'adi (siyosat tekshiruvi uchun).
String allText(WidgetTester t) => t
    .widgetList<Text>(find.byType(Text))
    .map((w) => w.data ?? w.textSpan?.toPlainText() ?? '')
    .join(' | ');

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('bosh sahifa: salom, qidiruv, 6 plitka, ingredientlar, 5 bandli navigatsiya', (t) async {
    await pumpApp(t, state: AppState(onboarded: true), initial: '/home');
    expect(k('home-page'), findsOneWidget);
    expect(k('home-search'), findsOneWidget);
    for (final id in ['scanner', 'skin', 'routine', 'academy', 'ai', 'journal']) {
      expect(k('tile-$id'), findsOneWidget, reason: id);
    }
    expect(find.text('Niacinamide'), findsOneWidget);
    for (final id in ['home', 'academy', 'scanner', 'journal', 'profile']) {
      expect(k('nav-$id'), findsOneWidget, reason: id);
    }
  });

  testWidgets('navigatsiya: tab almashadi va akademiya plitkasi akademiya tabiga olib boradi', (t) async {
    await pumpApp(t, state: AppState(onboarded: true), initial: '/home');
    await t.tap(k('nav-profile'));
    await t.pumpAndSettle();
    expect(k('tab-profile'), findsOneWidget);
    await t.tap(k('nav-home'));
    await t.pumpAndSettle();
    await t.tap(k('tile-academy'));
    await t.pumpAndSettle();
    expect(k('tab-academy'), findsOneWidget);
  });

  testWidgets('arabda navigatsiya tartibi teskari (Bosh sahifa o\'ngda)', (t) async {
    await pumpApp(t, state: AppState(locale: const Locale('ar'), onboarded: true), initial: '/home');
    expect(t.getCenter(k('nav-home')).dx, greaterThan(t.getCenter(k('nav-profile')).dx));
    await pumpApp(t, state: AppState(onboarded: true), initial: '/home');
    expect(t.getCenter(k('nav-home')).dx, lessThan(t.getCenter(k('nav-profile')).dx));
  });

  testWidgets('navigatsiya bandlari kamida 48x48', (t) async {
    await pumpApp(t, state: AppState(onboarded: true), initial: '/home');
    for (final id in ['home', 'academy', 'scanner', 'journal', 'profile']) {
      final s = t.getSize(k('nav-$id'));
      expect(s.height, greaterThanOrEqualTo(48), reason: id);
      expect(s.width, greaterThanOrEqualTo(48), reason: id);
    }
  });

  testWidgets('siyosat: bosh sahifada dalilsiz da\'vo yo\'q (4 tilda)', (t) async {
    final banned = RegExp(r'halal|halol|حلال|88\s*%|\bsafe\b|xavfsiz|безопас|آمن', caseSensitive: false);
    for (final lang in ['uz', 'ru', 'en', 'ar']) {
      await pumpApp(t, state: AppState(locale: Locale(lang), onboarded: true), initial: '/home');
      expect(banned.hasMatch(allText(t)), isFalse, reason: '$lang: ${allText(t)}');
    }
  });

  group('tablar 4 tilda kichik ekran va 1.5x shriftda overflow bermaydi', () {
    for (final lang in ['uz', 'ru', 'en', 'ar']) {
      for (final route in ['/home', '/academy', '/scanner', '/journal', '/profile']) {
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
