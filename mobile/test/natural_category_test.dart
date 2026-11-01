import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:samiya_beauty_lab/features/scanner/ingredient_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/pump.dart';

Ingredient _ing(String slug, String inci, {String? category}) => Ingredient.fromJson({
      'inci': inci,
      'slug': slug,
      'status': 'draft',
      'category': ?category,
      'aliases': <String>[],
      'eu': {'verified': false},
      'summary': {'en': 'summary', 'uz': 'xulosa', 'ru': 'resume', 'ar': 'mulakhas'},
      'claims': <Map<String, dynamic>>[],
    });

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  AppState state({String lang = 'uz'}) => AppState(
        locale: Locale(lang),
        onboarded: true,
        ingredients: IngredientRepository([
          _ing('niacinamide', 'Niacinamide'),
          _ing('retinol', 'Retinol', category: 'active'),
          _ing('honey', 'Mel', category: 'natural'),
          _ing('aloe-vera', 'Aloe Barbadensis Leaf Juice', category: 'natural'),
        ]),
      );

  test('kategoriya berilmasa "active" deb olinadi', () {
    expect(_ing('a', 'A').category, 'active');
    expect(_ing('a', 'A', category: 'natural').isNatural, isTrue);
    expect(_ing('a', 'A', category: 'noma\'lum').category, 'active'); // noma'lum qiymat faol modda hisoblanadi
  });

  testWidgets('ro\'yxatda 3 filtr: Barchasi, Faol moddalar, Tabiiy va o\'simlik', (t) async {
    await pumpApp(t, state: state(), initial: '/scanner/ingredients');
    for (final id in ['all', 'active', 'natural']) {
      expect(k('filter-$id'), findsOneWidget, reason: id);
    }
    expect(k('ingredient-item-niacinamide'), findsOneWidget);
    expect(k('ingredient-item-honey'), findsOneWidget);
  });

  testWidgets('"Tabiiy" filtri faqat tabiiylarni, "Faol" faqat faollarni ko\'rsatadi', (t) async {
    await pumpApp(t, state: state(), initial: '/scanner/ingredients');
    await t.ensureVisible(k('filter-natural'));
    await t.tap(k('filter-natural'));
    await t.pumpAndSettle();
    expect(k('ingredient-item-honey'), findsOneWidget);
    expect(k('ingredient-item-aloe-vera'), findsOneWidget);
    expect(k('ingredient-item-niacinamide'), findsNothing);
    expect(k('natural-note'), findsOneWidget, reason: 'tabiiy ro\'yxatda "tabiiy = xavfsiz emas" izohi');
    await t.ensureVisible(k('filter-active'));
    await t.tap(k('filter-active'));
    await t.pumpAndSettle();
    expect(k('ingredient-item-niacinamide'), findsOneWidget);
    expect(k('ingredient-item-honey'), findsNothing);
    expect(k('natural-note'), findsNothing);
  });

  testWidgets('filtr va qidiruv birga ishlaydi', (t) async {
    await pumpApp(t, state: state(), initial: '/scanner/ingredients');
    await t.ensureVisible(k('filter-natural'));
    await t.tap(k('filter-natural'));
    await t.pumpAndSettle();
    await t.enterText(k('ingredient-search'), 'aloe');
    await t.pumpAndSettle();
    expect(k('ingredient-item-aloe-vera'), findsOneWidget);
    expect(k('ingredient-item-honey'), findsNothing);
  });

  testWidgets('filtr bilan ochilgan manzil (?filter=natural) tabiiy filtrni tanlaydi', (t) async {
    await pumpApp(t, state: state(), initial: '/scanner/ingredients?filter=natural');
    expect(k('ingredient-item-honey'), findsOneWidget);
    expect(k('ingredient-item-niacinamide'), findsNothing);
  });

  testWidgets('bosh sahifa: "Tabiiy va o\'simlik asosli" qatori tabiiy ingredientlarni ko\'rsatadi', (t) async {
    await pumpApp(t, state: state());
    await t.ensureVisible(k('home-natural-section'));
    expect(k('home-natural-section'), findsOneWidget);
    expect(find.descendant(of: k('home-natural-section'), matching: find.text('Mel')), findsOneWidget);
    expect(find.descendant(of: k('home-natural-section'), matching: find.text('Niacinamide')), findsNothing);
  });

  testWidgets('bosh sahifa: tabiiy ingredient bo\'lmasa bo\'lim ko\'rinmaydi', (t) async {
    await pumpApp(t, state: AppState(onboarded: true, ingredients: IngredientRepository([_ing('niacinamide', 'Niacinamide')])));
    expect(k('home-natural-section'), findsNothing);
  });

  testWidgets('tabiiy ingredient sahifasida "tabiiy = xavfsiz emas" izohi bor, faol modda sahifasida yo\'q', (t) async {
    await pumpApp(t, state: state(), initial: '/scanner/ingredient/honey');
    expect(k('note-natural'), findsOneWidget);
    await pumpApp(t, state: state(), initial: '/scanner/ingredient/niacinamide');
    expect(k('note-natural'), findsNothing);
  });

  for (final lang in ['uz', 'ru', 'en', 'ar']) {
    testWidgets('320x568, 1.5x shrift, $lang: filtrlar va tabiiy qator overflow qilmaydi', (t) async {
      await pumpApp(t, state: state(lang: lang), initial: '/scanner/ingredients?filter=natural', size: const Size(320, 568), textScale: 1.5);
      expect(t.takeException(), isNull);
      await pumpApp(t, state: state(lang: lang), size: const Size(320, 568), textScale: 1.5);
      expect(t.takeException(), isNull);
    });
  }
}
