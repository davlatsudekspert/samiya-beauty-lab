import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/pump.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  AppState home({String lang = 'uz'}) =>
      AppState(locale: Locale(lang), onboarded: true, ingredients: testRepo());

  testWidgets('bosh sahifa: "Mashhur ingredientlar" kartasi ingredient sahifasini ochadi, orqaga -> bosh sahifa', (t) async {
    await pumpApp(t, state: home());
    await t.ensureVisible(find.text('Niacinamide').first);
    await t.pumpAndSettle();
    await t.tap(find.text('Niacinamide').first);
    await t.pumpAndSettle();
    expect(k('ingredient-page'), findsOneWidget);
    await t.tap(k('back-chip'));
    await t.pumpAndSettle();
    expect(k('home-page'), findsOneWidget, reason: 'orqaga bosh sahifaga qaytarishi kerak');
  });

  testWidgets('"Barchasi" ingredientlar bazasi ro\'yxatini ochadi: 5 ta ingredient', (t) async {
    await pumpApp(t, state: home());
    await t.ensureVisible(k('home-see-all'));
    await t.tap(k('home-see-all'));
    await t.pumpAndSettle();
    expect(k('ingredients-page'), findsOneWidget);
    // Ro'yxat sekin yaratiladi (lazy): yuqoridagi elementlar darhol ko'rinadi, qolganlari qidiruv/filtr bilan topiladi.
    expect(k('ingredient-item-niacinamide'), findsOneWidget);
    expect(k('ingredient-item-hyaluronic-acid'), findsOneWidget);
    await t.tap(k('filter-active'));
    await t.pumpAndSettle();
    await t.enterText(k('ingredient-search'), 'reti');
    await t.pumpAndSettle();
    expect(k('ingredient-item-retinol'), findsOneWidget);
  });

  testWidgets('bosh sahifa qidiruvi ham ro\'yxatni ochadi', (t) async {
    await pumpApp(t, state: home());
    await t.tap(k('home-search'));
    await t.pumpAndSettle();
    expect(k('ingredients-page'), findsOneWidget);
  });

  testWidgets('ro\'yxatda qidirish: nom bo\'yicha filtrlaydi, katta-kichik harfga e\'tibor bermaydi', (t) async {
    await pumpApp(t, state: home(), initial: '/scanner/ingredients');
    await t.enterText(k('ingredient-search'), 'RETI');
    await t.pumpAndSettle();
    expect(k('ingredient-item-retinol'), findsOneWidget);
    expect(k('ingredient-item-niacinamide'), findsNothing);
  });

  testWidgets('qidiruv topmasa: halol xabar', (t) async {
    await pumpApp(t, state: home(), initial: '/scanner/ingredients');
    await t.enterText(k('ingredient-search'), 'zzzz');
    await t.pumpAndSettle();
    expect(k('ingredient-search-empty'), findsOneWidget);
    expect(find.text('Hech narsa topilmadi. Baza kengayib boradi.'), findsOneWidget);
  });

  testWidgets('ro\'yxatdan ingredient sahifasi ochiladi va orqaga ro\'yxatga qaytadi', (t) async {
    await pumpApp(t, state: home(), initial: '/scanner/ingredients');
    await t.tap(k('ingredient-item-niacinamide'));
    await t.pumpAndSettle();
    expect(k('ingredient-page'), findsOneWidget);
    await t.tap(k('back-chip'));
    await t.pumpAndSettle();
    expect(k('ingredients-page'), findsOneWidget);
  });

  for (final lang in ['uz', 'ru', 'en', 'ar']) {
    testWidgets('320x568, 1.5x shrift, $lang: ro\'yxat sahifasida overflow yo\'q', (t) async {
      await pumpApp(t, state: home(lang: lang), initial: '/scanner/ingredients', size: const Size(320, 568), textScale: 1.5);
      expect(k('ingredients-page'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }
}
