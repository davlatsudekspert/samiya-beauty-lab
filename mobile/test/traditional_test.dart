import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/pump.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  AppState s([String lang = 'uz']) => AppState(locale: Locale(lang), onboarded: true, ingredients: testRepo());

  test('kontent: Ibn Sino kirishi va an\'anaviy yozuvlar 4 tilda, har biri manbali', () {
    final repo = testRepo();
    expect(repo.ibnSina, isNotNull);
    expect(repo.ibnSina!.items.length, greaterThanOrEqualTo(3));
    for (final l in ['en', 'uz', 'ru', 'ar']) {
      expect(repo.ibnSina!.titleFor(l), isNotEmpty);
    }
    final withTrad = repo.all.where((i) => i.traditional.isNotEmpty).toList();
    expect(withTrad, isNotEmpty);
    for (final i in withTrad) {
      for (final n in i.traditional) {
        expect(n.sources, isNotEmpty, reason: n.id);
        for (final l in ['en', 'uz', 'ru', 'ar']) {
          expect(n.textFor(l).trim(), isNotEmpty, reason: '${n.id}/$l');
          expect(RegExp(r'\b(proven|isbotlangan|доказан)', caseSensitive: false).hasMatch(n.textFor(l)), isFalse, reason: n.id);
        }
      }
    }
    // faol moddalarda an'anaviy blok yo'q
    expect(repo.bySlug('niacinamide')!.traditional, isEmpty);
  });

  testWidgets('tabiiy ingredient sahifasida "An\'anaviy qo\'llanish" bloki va "ilmiy dalil emas" izohi', (t) async {
    await pumpApp(t, state: s(), initial: '/scanner/ingredient/honey');
    await t.scrollUntilVisible(k('traditional-section'), 400, scrollable: find.descendant(of: k('ingredient-page'), matching: find.byType(Scrollable)).first);
    expect(k('traditional-section'), findsOneWidget);
    expect(k('note-traditional'), findsOneWidget);
    expect(find.textContaining('ilmiy dalil emas'), findsWidgets);
  });

  testWidgets('faol modda sahifasida an\'anaviy blok yo\'q', (t) async {
    await pumpApp(t, state: s(), initial: '/scanner/ingredient/niacinamide');
    expect(k('traditional-section'), findsNothing);
  });

  testWidgets('bosh sahifadagi Ibn Sino kartochkasi uning sahifasini ochadi', (t) async {
    await pumpApp(t, state: s());
    await t.ensureVisible(k('home-ibn-sina'));
    await t.tap(k('home-ibn-sina'));
    await t.pumpAndSettle();
    expect(k('ibn-sina-page'), findsOneWidget);
    expect(find.text('Ibn Sino va “Tib qonunlari”'), findsWidgets);
    expect(k('note-traditional'), findsOneWidget);
    await t.tap(k('back-chip'));
    await t.pumpAndSettle();
    expect(k('home-page'), findsOneWidget);
  });

  testWidgets('"Tib qonunlari"ga tayangan yozuvda Ibn Sino sahifasiga havola bor', (t) async {
    await pumpApp(t, state: s(), initial: '/scanner/ingredient/facial-massage');
    await t.scrollUntilVisible(k('trad-ibn-sina-link'), 400, scrollable: find.descendant(of: k('ingredient-page'), matching: find.byType(Scrollable)).first);
    await t.tap(k('trad-ibn-sina-link'));
    await t.pumpAndSettle();
    expect(k('ibn-sina-page'), findsOneWidget);
  });

  for (final lang in ['uz', 'ru', 'en', 'ar']) {
    testWidgets('320x568, 1.5x, $lang: Ibn Sino sahifasi va an\'anaviy blok overflow qilmaydi', (t) async {
      await pumpApp(t, state: s(lang), initial: '/scanner/ibn-sina', size: const Size(320, 568), textScale: 1.5);
      expect(t.takeException(), isNull);
      await pumpApp(t, state: s(lang), initial: '/scanner/ingredient/turmeric', size: const Size(320, 568), textScale: 1.5);
      expect(t.takeException(), isNull);
    });
  }
}
