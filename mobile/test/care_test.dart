import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:samiya_beauty_lab/data/personal_store.dart';
import 'package:samiya_beauty_lab/features/care/care_models.dart';
import 'package:samiya_beauty_lab/features/scanner/ingredient_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/pump.dart';

Map<String, String> loc(String s) => {'uz': '$s uz', 'ru': '$s ru', 'en': '$s en', 'ar': '$s ar'};

final recipe = Recipe.fromJson({
  'id': 'oat-mask', 'photo': 'oat', 'minutes': 15, 'ingredients': ['oat'],
  'title': loc('Suli niqobi'), 'intro': loc('intro'), 'items': [loc('item')], 'steps': [loc('step1'), loc('step2')],
  'safety': [loc('patch')], 'evidence': loc('evidence'),
});
final ritual = Ritual.fromJson({
  'id': 'morning', 'photo': 'deco_jasmine', 'title': loc('Ertalabki massaj'), 'intro': loc('intro'),
  'steps': [
    {'seconds': 3, 'title': loc('S1'), 'text': loc('t1')},
    {'seconds': 2, 'title': loc('S2'), 'text': loc('t2')},
  ],
  'safety': [loc('safe')], 'evidence': loc('evidence'),
});

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('ShelfItem: PAO bo\'yicha muddat va qolgan kun', () {
    final i = ShelfItem(id: 'a', name: 'Krem', openedOn: DateTime(2026, 1, 10), paoMonths: 12);
    expect(i.expiresOn, DateTime(2027, 1, 10));
    expect(i.daysLeft(DateTime(2027, 1, 1)), 9);
    expect(i.daysLeft(DateTime(2027, 2, 1)), lessThan(0));
  });

  test('javon: qo\'shish, tartib, e\'tibor soni, tozalash', () async {
    final s = PersonalStore(persist: false, clock: () => DateTime(2026, 11, 1));
    expect(await s.addShelf('  ', openedOn: DateTime(2026, 1, 1), paoMonths: 12), isFalse);
    expect(await s.addShelf('Krem', openedOn: DateTime(2026, 1, 1), paoMonths: 12), isTrue);
    expect(await s.addShelf('Tonik', openedOn: DateTime(2026, 4, 1), paoMonths: 6), isTrue);
    expect(s.shelfSorted.first.name, 'Tonik'); // 2026-10-01 da tugagan
    expect(s.shelfAttention, 1); // Krem: 2027-01-01 gacha 61 kun
    await s.clear();
    expect(s.shelf, isEmpty);
  });

  AppState state({String lang = 'uz'}) => AppState(
        locale: Locale(lang),
        onboarded: true,
        ingredients: IngredientRepository(const [], recipes: [recipe], rituals: [ritual]),
      );

  testWidgets('javon sahifasi: mahsulot qo\'shiladi', (t) async {
    final st = state();
    await pumpApp(t, state: st, initial: '/home/shelf');
    await t.scrollUntilVisible(find.byKey(const Key('shelf-add')), 300, scrollable: find.byType(Scrollable).first);
    await t.tap(find.byKey(const Key('shelf-add')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('shelf-name')), 'Namlantiruvchi krem');
    await t.tap(find.byKey(const Key('shelf-pao-6')));
    await t.ensureVisible(find.byKey(const Key('shelf-save')));
    await t.tap(find.byKey(const Key('shelf-save')));
    await t.pumpAndSettle();
    expect(find.text('Namlantiruvchi krem'), findsOneWidget);
    expect(st.personal.shelf.single.paoMonths, 6);
  });

  testWidgets('retsept: ro\'yxatdan ochiladi, xavfsizlik bloki bor', (t) async {
    await pumpApp(t, state: state(), initial: '/home/recipes');
    await t.tap(find.byKey(const Key('recipe-0')));
    await t.pumpAndSettle();
    expect(find.text('Suli niqobi uz'), findsOneWidget);
    await t.scrollUntilVisible(find.byKey(const Key('recipe-safety')), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('patch uz'), findsOneWidget);
  });

  testWidgets('ritual taymeri: boshlash -> qadamlar avtomatik -> yakun', (t) async {
    await pumpApp(t, state: state(), initial: '/home/rituals/morning');
    await t.tap(find.byKey(const Key('ritual-start')));
    await t.pump();
    expect(find.byKey(const Key('ritual-time')), findsOneWidget);
    await t.pump(const Duration(seconds: 1));
    expect(find.text('0:02'), findsWidgets);
    await t.pump(const Duration(seconds: 2));
    expect(find.text('2-qadam / 2'), findsOneWidget);
    await t.pump(const Duration(seconds: 2));
    expect(find.byKey(const Key('ritual-done')), findsOneWidget);
  });

  for (final lang in ['uz', 'ru', 'en', 'ar']) {
    testWidgets('320x568, 1.5x shrift, $lang: yangi bo\'limlar overflow qilmaydi', (t) async {
      for (final r in ['/home/shelf', '/home/recipes', '/home/recipes/oat-mask', '/home/rituals', '/home/rituals/morning', '/home']) {
        await pumpApp(t, state: state(lang: lang), initial: r, size: const Size(320, 568), textScale: 1.5);
        expect(t.takeException(), isNull, reason: r);
      }
    });
  }
}
