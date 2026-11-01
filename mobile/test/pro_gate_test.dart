import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:samiya_beauty_lab/app/pro_gate.dart';
import 'package:samiya_beauty_lab/data/backend_api.dart';
import 'package:samiya_beauty_lab/features/scanner/ingredient_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_backend.dart';
import 'support/pump.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final repo = IngredientRepository.fromJson(File('assets/content/ingredients.json').readAsStringSync());
  const after = CampaignInfo(phase: 'free_plus_optional_pro', daysRemaining: 0);
  const during = CampaignInfo(phase: 'free_campaign', daysRemaining: 10);

  AppState st(CampaignInfo c, {String lang = 'uz'}) => AppState(locale: Locale(lang), onboarded: true, ingredients: repo, campaign: c);

  test('ProGate: kampaniya davomida hammasi ochiq, keyin faqat bepul qism', () {
    expect(st(during).unlocked, isTrue);
    expect(st(CampaignInfo.open).unlocked, isTrue);
    expect(st(after).unlocked, isFalse);
    expect(ProGate.open(unlocked: false, index: 1, freeCount: 2), isTrue);
    expect(ProGate.open(unlocked: false, index: 2, freeCount: 2), isFalse);
  });

  test('server kampaniya bosqichini oladi va saqlaydi (oflaynda chetlab o\'tilmaydi)', () async {
    final b = FakeBackendApi()..campaignInfo = after;
    final s = AppState(backend: b);
    expect(s.unlocked, isTrue);
    await s.refreshCampaign();
    expect(s.unlocked, isFalse);
    expect((await SharedPreferences.getInstance()).getString('campaign_phase'), 'free_plus_optional_pro');
  });

  testWidgets('kampaniyadan keyin: 3-dars qulf, bosilsa Pro sahifasi; 1-dars ochiq', (t) async {
    await pumpApp(t, state: st(after), initial: '/academy');
    expect(find.text('Pro'), findsWidgets);
    await t.ensureVisible(find.byKey(const Key('academy-topic-2')));
    await t.drag(find.byType(Scrollable).first, const Offset(0, -250));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('academy-topic-2')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('pro-page')), findsOneWidget);
    await pumpApp(t, state: st(after), initial: '/academy/lesson/${repo.lessons[0].id}');
    expect(find.byKey(const Key('pro-locked')), findsNothing);
    await pumpApp(t, state: st(after), initial: '/academy/lesson/${repo.lessons[3].id}');
    await t.scrollUntilVisible(find.byKey(const Key('pro-locked')), 400, scrollable: find.byType(Scrollable).first);
    expect(find.byKey(const Key('pro-locked')), findsOneWidget);
  });

  testWidgets('kampaniya davomida: qulf yo\'q, bosh sahifada 15 kunlik eslatma', (t) async {
    await pumpApp(t, state: st(during), initial: '/academy/lesson/${repo.lessons[5].id}');
    expect(find.byKey(const Key('pro-locked')), findsNothing);
    await pumpApp(t, state: st(during), initial: '/home');
    expect(find.byKey(const Key('home-pro-countdown')), findsOneWidget);
  });

  testWidgets('kampaniyadan keyin retsept va Ibn Sino qisman qulf', (t) async {
    await pumpApp(t, state: st(after), initial: '/home/recipes/${repo.recipes.last.id}');
    await t.scrollUntilVisible(find.byKey(const Key('pro-locked')), 400, scrollable: find.byType(Scrollable).first);
    expect(find.byKey(const Key('pro-locked')), findsOneWidget);
    await pumpApp(t, state: st(after), initial: '/scanner/ibn-sina');
    await t.scrollUntilVisible(find.byKey(const Key('pro-locked')), 400, scrollable: find.byType(Scrollable).first);
    expect(find.byKey(const Key('pro-locked')), findsOneWidget);
  });

  for (final lang in ['uz', 'ru', 'en', 'ar']) {
    testWidgets('320x568, 1.5x, $lang: Pro sahifasi va qulflar overflow qilmaydi', (t) async {
      for (final r in ['/pro', '/academy', '/home/recipes', '/home/rituals/${repo.rituals.last.id}', '/academy/lesson/${repo.lessons.last.id}']) {
        await pumpApp(t, state: st(after, lang: lang), initial: r, size: const Size(320, 568), textScale: 1.5);
        expect(t.takeException(), isNull, reason: r);
      }
      await pumpApp(t, state: st(during, lang: lang), initial: '/pro', size: const Size(320, 568), textScale: 1.5);
      expect(t.takeException(), isNull);
    });
  }
}
