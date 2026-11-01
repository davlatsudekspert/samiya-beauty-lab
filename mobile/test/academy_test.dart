import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:samiya_beauty_lab/features/care/care_models.dart';
import 'package:samiya_beauty_lab/features/scanner/ingredient_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/pump.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final repo = IngredientRepository.fromJson(File('assets/content/ingredients.json').readAsStringSync());

  AppState state({String lang = 'uz'}) => AppState(locale: Locale(lang), onboarded: true, ingredients: repo);

  test('6 ta dars: 4 tilda sarlavha, bo\'limlar, 3 savollik test va manbalar', () {
    expect(repo.lessons.map((l) => l.id), ['skin', 'inci', 'spf', 'moist', 'hygiene', 'safety']);
    for (final l in repo.lessons) {
      for (final lang in ['uz', 'ru', 'en', 'ar']) {
        expect(l.title[lang], isNotEmpty, reason: '${l.id} $lang');
        for (final s in l.sections) {
          expect(s.text[lang], isNotEmpty);
        }
      }
      expect(l.sections.length, greaterThanOrEqualTo(4));
      expect(l.quiz.length, 3);
      for (final q in l.quiz) {
        expect(q.correct, inInclusiveRange(0, q.options.length - 1));
      }
      expect(l.sources, isNotEmpty);
    }
  });

  test('retsept va ritual: 8 va 3 ta, 4 tilda, xavfsizlik bilan, rasmlari mavjud', () {
    expect(repo.recipes.length, greaterThanOrEqualTo(14));
    expect(repo.rituals.length, greaterThanOrEqualTo(12));
    for (final r in repo.recipes) {
      expect(r.safety, isNotEmpty);
      expect(File(carePhoto(r.photo)).existsSync(), isTrue, reason: r.id);
      for (final i in r.ingredients) {
        expect(repo.bySlug(i), isNotNull, reason: '${r.id}: $i');
      }
      for (final lang in ['uz', 'ru', 'en', 'ar']) {
        expect(r.title[lang], isNotEmpty);
        expect(r.evidence[lang], isNotEmpty);
      }
    }
    for (final r in repo.rituals) {
      expect(r.totalSeconds, inInclusiveRange(120, 900));
      expect(File(carePhoto(r.photo)).existsSync(), isTrue, reason: r.id);
    }
  });

  test('Ibn Sino bo\'limi kengaytirilgan (kamida 12 band)', () {
    expect(repo.ibnSina!.items.length, greaterThanOrEqualTo(12));
  });

  testWidgets('Akademiya: mavzular qulfsiz, bosilganda dars ochiladi, test javobi tekshiriladi', (t) async {
    await pumpApp(t, state: state(), initial: '/academy');
    expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
    await t.tap(find.byKey(const Key('academy-topic-0')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('lesson-page')), findsOneWidget);
    expect(find.text(repo.lessons.first.title['uz']!), findsWidgets);
    final q = repo.lessons.first.quiz.first;
    await t.scrollUntilVisible(find.byKey(const Key('quiz-0-0')), 300, scrollable: find.byType(Scrollable).last);
    await t.ensureVisible(find.byKey(Key('quiz-0-${q.correct}')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(Key('quiz-0-${q.correct}')));
    await t.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  for (final lang in ['uz', 'ru', 'en', 'ar']) {
    testWidgets('320x568, 1.5x shrift, $lang: Akademiya va barcha darslar overflow qilmaydi', (t) async {
      await pumpApp(t, state: state(lang: lang), initial: '/academy', size: const Size(320, 568), textScale: 1.5);
      expect(t.takeException(), isNull);
      for (final l in repo.lessons) {
        await pumpApp(t, state: state(lang: lang), initial: '/academy/lesson/${l.id}', size: const Size(320, 568), textScale: 1.5);
        expect(t.takeException(), isNull, reason: l.id);
      }
      for (final r in ['/home', '/home/recipes', '/home/rituals', for (final x in repo.recipes) '/home/recipes/${x.id}', for (final x in repo.rituals) '/home/rituals/${x.id}']) {
        await pumpApp(t, state: state(lang: lang), initial: r, size: const Size(320, 568), textScale: 1.5);
        expect(t.takeException(), isNull, reason: r);
      }
    });
  }
}
