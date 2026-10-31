import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/pump.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('"Davom etish"ga ikki marta tez bosish: sahifa ikki marta ochilmaydi', (t) async {
    await pumpApp(t);
    final btn = t.getCenter(k('language-continue'));
    // Haqiqiy qo'sh bosish: ikkala bosish navigatsiya tugamasdan oldin keladi.
    await t.tapAt(btn);
    await t.tapAt(btn);
    await t.pumpAndSettle();
    expect(k('welcome-page'), findsOneWidget);
    await t.tap(k('back-chip'));
    await t.pumpAndSettle();
    expect(k('language-page'), findsOneWidget, reason: 'bitta orqaga bosish til sahifasiga qaytarishi kerak');
  });

  testWidgets('welcome -> "Boshlash" ikki marta tez bosish: bitta orqaga welcome ga qaytaradi', (t) async {
    await pumpApp(t);
    await t.tap(k('language-continue'));
    await t.pumpAndSettle();
    final btn = t.getCenter(k('welcome-start'));
    await t.tapAt(btn);
    await t.tapAt(btn);
    await t.pumpAndSettle();
    expect(k('onboarding-page'), findsOneWidget);
    await t.tap(k('back-chip'));
    await t.pumpAndSettle();
    expect(k('welcome-page'), findsOneWidget);
  });
}
