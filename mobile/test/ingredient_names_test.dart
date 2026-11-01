import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:samiya_beauty_lab/features/scanner/analysis.dart';
import 'package:samiya_beauty_lab/features/scanner/ingredient_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/pump.dart';

Ingredient _ing(String slug, String inci, {String? category, Map<String, String>? names}) => Ingredient.fromJson({
      'inci': inci,
      'slug': slug,
      'status': 'draft',
      'category': ?category,
      'names': ?names,
      'aliases': <String>[],
      'eu': {'verified': false},
      'summary': {'en': 'summary', 'uz': 'xulosa', 'ru': 'resume', 'ar': 'mulakhas'},
      'claims': <Map<String, dynamic>>[],
    });

final _cucumber = _ing('cucumber', 'Cucumis Sativus Fruit Extract',
    category: 'natural', names: {'uz': 'Bodring', 'ru': 'Огурец', 'en': 'Cucumber', 'ar': 'الخيار'});
final _massage = _ing('facial-massage', 'Facial massage',
    category: 'practice', names: {'uz': 'Yuz massaji', 'ru': 'Массаж лица', 'en': 'Facial massage', 'ar': 'تدليك الوجه'});
final _lemon = _ing('lemon-juice', 'Citrus Limon Fruit Juice',
    category: 'caution', names: {'uz': 'Limon sharbati', 'ru': 'Лимонный сок', 'en': 'Lemon juice', 'ar': 'عصير الليمون'});
final _niacin = _ing('niacinamide', 'Niacinamide');

AppState _state({String lang = 'uz'}) => AppState(
      locale: Locale(lang),
      onboarded: true,
      ingredients: IngredientRepository([_niacin, _cucumber, _massage, _lemon]),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('nomi: tilga mos; yo\'q bo\'lsa INCI; kategoriyalar tanib olinadi', () {
    expect(_cucumber.nameFor('uz'), 'Bodring');
    expect(_cucumber.nameFor('ru'), 'Огурец');
    expect(_cucumber.nameFor('xx'), 'Cucumber'); // noma'lum til: inglizcha nom
    expect(_niacin.nameFor('uz'), 'Niacinamide'); // nom berilmagan: INCI
    expect(_niacin.hasFriendlyName, isFalse);
    expect(_cucumber.hasFriendlyName, isTrue);
    expect(_massage.isPractice, isTrue);
    expect(_lemon.isCaution, isTrue);
    expect(_cucumber.isNatural, isTrue);
    expect(_niacin.isNatural || _niacin.isPractice || _niacin.isCaution, isFalse);
  });

  test('parvarish usuli INCI ro\'yxatidagi so\'zga moslanmaydi', () {
    final repo = IngredientRepository([_niacin, _massage]);
    expect(repo.find('Facial massage'), isNull);
    expect(analyze('Aqua, Facial massage, Niacinamide', repo).recognized.map((e) => e.ingredient!.slug), ['niacinamide']);
  });

  testWidgets('ro\'yxat: tushunarli nom sarlavha, INCI pastida (lotin, LTR)', (t) async {
    await pumpApp(t, state: _state(), initial: '/scanner/ingredients');
    final tile = k('ingredient-item-cucumber');
    expect(find.descendant(of: tile, matching: find.text('Bodring')), findsOneWidget);
    expect(find.descendant(of: tile, matching: find.text('Cucumis Sativus Fruit Extract')), findsOneWidget);
    // nom berilmagan ingredientda faqat INCI
    expect(find.descendant(of: k('ingredient-item-niacinamide'), matching: find.text('Niacinamide')), findsOneWidget);
  });

  testWidgets('filtrlar: usullar va ehtiyot; har birida o\'z izohi', (t) async {
    await pumpApp(t, state: _state(), initial: '/scanner/ingredients');
    await t.ensureVisible(k('filter-practice'));
    await t.tap(k('filter-practice'));
    await t.pumpAndSettle();
    expect(k('ingredient-item-facial-massage'), findsOneWidget);
    expect(k('ingredient-item-cucumber'), findsNothing);
    expect(k('practice-note'), findsOneWidget);
    await t.ensureVisible(k('filter-caution'));
    await t.tap(k('filter-caution'));
    await t.pumpAndSettle();
    expect(k('ingredient-item-lemon-juice'), findsOneWidget);
    expect(k('ingredient-item-facial-massage'), findsNothing);
    expect(k('caution-note'), findsOneWidget);
    await t.ensureVisible(k('filter-active'));
    await t.tap(k('filter-active'));
    await t.pumpAndSettle();
    expect(k('ingredient-item-niacinamide'), findsOneWidget);
    expect(k('ingredient-item-cucumber'), findsNothing);
    expect(k('ingredient-item-lemon-juice'), findsNothing);
  });

  testWidgets('qidiruv tushunarli nom bo\'yicha ham ishlaydi (Bodring)', (t) async {
    await pumpApp(t, state: _state(), initial: '/scanner/ingredients');
    await t.enterText(k('ingredient-search'), 'bodr');
    await t.pumpAndSettle();
    expect(k('ingredient-item-cucumber'), findsOneWidget);
    expect(k('ingredient-item-niacinamide'), findsNothing);
  });

  testWidgets('ingredient sahifasi: sarlavha tushunarli nom, INCI sarlavha ostida; kategoriya izohi', (t) async {
    await pumpApp(t, state: _state(), initial: '/scanner/ingredient/cucumber');
    expect(find.text('Bodring'), findsWidgets);
    expect(find.text('Cucumis Sativus Fruit Extract'), findsWidgets);
    expect(k('note-natural'), findsOneWidget);
    await pumpApp(t, state: _state(), initial: '/scanner/ingredient/facial-massage');
    expect(k('note-practice'), findsOneWidget);
    expect(k('note-natural'), findsNothing);
    await pumpApp(t, state: _state(), initial: '/scanner/ingredient/lemon-juice');
    expect(k('note-caution'), findsOneWidget);
  });

  testWidgets('bosh sahifa: "Parvarish usullari" qatori faqat usullarni ko\'rsatadi; tabiiy qatorda ehtiyot/usul yo\'q', (t) async {
    await pumpApp(t, state: _state());
    await t.ensureVisible(k('home-practice-section'));
    expect(find.descendant(of: k('home-practice-section'), matching: find.text('Yuz massaji')), findsOneWidget);
    expect(find.descendant(of: k('home-natural-section'), matching: find.text('Yuz massaji')), findsNothing);
    expect(find.descendant(of: k('home-natural-section'), matching: find.text('Bodring')), findsOneWidget);
  });

  for (final lang in ['uz', 'ru', 'en', 'ar']) {
    testWidgets('320x568, 1.5x shrift, $lang: yangi filtrlar va nomlar overflow qilmaydi', (t) async {
      await pumpApp(t, state: _state(lang: lang), initial: '/scanner/ingredients?filter=caution', size: const Size(320, 568), textScale: 1.5);
      expect(t.takeException(), isNull);
      await pumpApp(t, state: _state(lang: lang), initial: '/scanner/ingredient/facial-massage', size: const Size(320, 568), textScale: 1.5);
      expect(t.takeException(), isNull);
      await pumpApp(t, state: _state(lang: lang), size: const Size(320, 568), textScale: 1.5);
      expect(t.takeException(), isNull);
    });
  }
}
