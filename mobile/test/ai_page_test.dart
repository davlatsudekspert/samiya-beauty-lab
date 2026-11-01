import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:samiya_beauty_lab/data/backend_api.dart';
import 'package:samiya_beauty_lab/features/scanner/ingredient_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_auth.dart';
import 'support/fake_backend.dart';
import 'support/pump.dart';

Ingredient _ing(String slug, String inci, Map<String, String> names) => Ingredient.fromJson({
      'inci': inci, 'slug': slug, 'status': 'draft', 'names': names, 'aliases': <String>[],
      'eu': {'verified': false},
      'summary': {'en': 'EN summary of $inci', 'uz': 'x', 'ru': 'x', 'ar': 'x'},
      'claims': <Map<String, dynamic>>[],
    });

void main() {
  final repo = IngredientRepository([
    _ing('niacinamide', 'Niacinamide', {'uz': 'Niatsinamid', 'en': 'Niacinamide'}),
    _ing('honey', 'Mel', {'uz': 'Asal', 'en': 'Honey'}),
  ]);

  test('AI konteksti: savolda tilga olingan ingredient (o\'zbekcha nomi bilan ham) qo\'shiladi', () {
    final c = repo.aiContextFor('Asal yuzga foydalimi?');
    expect(c, contains('EN summary of Mel'));
    expect(c, isNot(contains('Niacinamide')));
    expect(repo.aiContextFor('salom'), isEmpty);
  });

  testWidgets('kirmagan foydalanuvchi: kirish taklifi, AI chaqirilmaydi', (t) async {
    SharedPreferences.setMockInitialValues({});
    final b = FakeBackendApi();
    await pumpApp(t, state: AppState(onboarded: true, ingredients: repo, backend: b), initial: '/home/ai');
    expect(find.byKey(const Key('ai-signin')), findsOneWidget);
    expect(b.aiAsks, isEmpty);
  });

  testWidgets('kirgan: rozilik -> tavsiya savoli -> javob va qolgan son', (t) async {
    SharedPreferences.setMockInitialValues({});
    final b = FakeBackendApi();
    final auth = FakeAuthService.signedIn();
    await pumpApp(t, state: AppState(onboarded: true, ingredients: repo, backend: b, auth: auth), initial: '/home/ai');
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('Tushundim, boshlash'));
    await t.pumpAndSettle();
    await t.tap(find.text('Tushundim, boshlash'));
    await t.pumpAndSettle();
    await t.ensureVisible(find.byKey(const Key('ai-suggest-0')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('ai-suggest-0')));
    await t.pumpAndSettle();
    expect(b.aiAsks.single.lang, 'uz');
    expect(b.aiAsks.single.context, contains('Niacinamide'));
    expect(find.textContaining('AI javobi:'), findsOneWidget);
    expect(find.text('Bugun yana 4 ta savol'), findsOneWidget);
  });

  testWidgets('server kaliti sozlanmagan: chiroyli "tez orada" xabari', (t) async {
    SharedPreferences.setMockInitialValues({'ai_consent_v1': true});
    final b = FakeBackendApi()..aiError = const BackendException(503, 'ai_not_configured');
    await pumpApp(t, state: AppState(onboarded: true, ingredients: repo, backend: b, auth: FakeAuthService.signedIn()), initial: '/home/ai');
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('ai-input')), 'Retinol nima?');
    await t.tap(find.byKey(const Key('ai-send')));
    await t.pumpAndSettle();
    expect(find.textContaining('SAMIYA AI tez orada ishga tushadi'), findsOneWidget);
  });

  for (final lang in ['uz', 'ru', 'en', 'ar']) {
    testWidgets('320x568, 1.5x shrift, $lang: AI sahifasi overflow qilmaydi', (t) async {
      SharedPreferences.setMockInitialValues({'ai_consent_v1': true});
      await pumpApp(t,
          state: AppState(locale: Locale(lang), onboarded: true, ingredients: repo, backend: FakeBackendApi(), auth: FakeAuthService.signedIn()),
          initial: '/home/ai', size: const Size(320, 568), textScale: 1.5);
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });
  }
}
