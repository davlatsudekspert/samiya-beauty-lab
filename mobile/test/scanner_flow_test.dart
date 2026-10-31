import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_shell_test.dart' show allText;
import 'support/pump.dart';

Future<void> analyzeText(WidgetTester t, String text) async {
  await t.tap(k('scan-manual'));
  await t.pumpAndSettle();
  expect(k('manual-page'), findsOneWidget);
  await t.enterText(k('manual-input'), text);
  await t.pump();
  await t.tap(k('manual-analyze'));
  await t.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  AppState onboarded([String lang = 'uz']) =>
      AppState(locale: Locale(lang), onboarded: true, ingredients: testRepo());

  testWidgets('tarkib kiritilmaguncha "Tahlil qilish" o\'chiq, matn yozilgach yoqiladi va soni ko\'rinadi', (t) async {
    await pumpApp(t, state: onboarded(), initial: '/scanner');
    await t.tap(k('scan-manual'));
    await t.pumpAndSettle();
    ElevatedButton btn() => t.widget<ElevatedButton>(find.descendant(of: k('manual-analyze'), matching: find.byType(ElevatedButton)));
    expect(btn().onPressed, isNull);
    await t.enterText(k('manual-input'), 'Aqua, Glycerin, Niacinamide (2%)');
    await t.pump();
    expect(btn().onPressed, isNotNull);
    expect(find.text('Topilgan ingredientlar: 3'), findsOneWidget);
  });

  testWidgets('natija: topilgan ingredient kartasi va "bazada yo\'q" yorliqlari, hisoblagichlar', (t) async {
    await pumpApp(t, state: onboarded(), initial: '/scanner');
    await analyzeText(t, 'Aqua, Glycerin, Niacinamide, Parfum');
    expect(k('result-page'), findsOneWidget);
    expect(k('result-card-niacinamide'), findsOneWidget);
    expect(find.descendant(of: k('stat-found'), matching: find.text('1')), findsOneWidget);
    expect(find.descendant(of: k('stat-unknown'), matching: find.text('3')), findsOneWidget);
    expect(find.descendant(of: k('result-unknown-chips'), matching: find.text('Glycerin')), findsOneWidget);
  });

  testWidgets('bazada hech narsa topilmasa halol xabar, kartalar yo\'q', (t) async {
    await pumpApp(t, state: onboarded(), initial: '/scanner');
    await analyzeText(t, 'Aqua, Glycerin');
    expect(k('result-none'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w.key.toString().contains('result-card-')), findsNothing);
  });

  testWidgets('ingredient sahifasi: manbali da\'volar, PMID, draft va EU-tasdiqlanmagan eslatmalari', (t) async {
    await pumpApp(t, state: onboarded(), initial: '/scanner');
    await analyzeText(t, 'Niacinamide');
    await t.tap(k('result-card-niacinamide'));
    await t.pumpAndSettle();
    expect(k('ingredient-page'), findsOneWidget);
    expect(k('note-draft'), findsOneWidget);
    expect(k('note-eu'), findsOneWidget);
    expect(k('evidence-legend'), findsOneWidget);
    // Barcha da'volar ro'yxatda, har birida kamida bitta PubMed manbasi
    for (final id in ['niacinamide-1', 'niacinamide-2', 'niacinamide-3', 'niacinamide-4']) {
      await t.scrollUntilVisible(k('claim-$id'), 300, scrollable: find.byType(Scrollable).first);
      expect(k('claim-$id'), findsOneWidget);
    }
    await t.scrollUntilVisible(k('source-34525885'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.textContaining('PMID 34525885'), findsOneWidget);
  });

  testWidgets('siyosat: natija va ingredient sahifalarida dalilsiz da\'vo yo\'q (4 tilda)', (t) async {
    final banned = RegExp(r'halal|halol|حلال|88\s*%|\bsafe\b|xavfsiz|безопас|آمن|suits you|sizga mos|подходит вам', caseSensitive: false);
    // Eslatma: "does not indicate whether a product suits you" kabi INKOR gaplar ruxsat; shuning uchun faqat da'vo shakllari tekshiriladi.
    final claimForms = RegExp(r'is safe|are safe|xavfsiz\s+(?:hisoblanadi|ingredient)|безопасн\w+ для|آمن للاستخدام|halal certified|halol sertifikat', caseSensitive: false);
    for (final lang in ['uz', 'ru', 'en', 'ar']) {
      await pumpApp(t, state: onboarded(lang), initial: '/scanner');
      await analyzeText(t, 'Aqua, Retinol');
      expect(claimForms.hasMatch(allText(t)), isFalse, reason: '$lang natija');
      await t.tap(k('result-card-retinol'));
      await t.pumpAndSettle();
      expect(claimForms.hasMatch(allText(t)), isFalse, reason: '$lang ingredient');
      // "88%", "halal/halol" so'zlari hech bir sahifada ko'rinmasligi kerak
      expect(RegExp(r'88\s*%|halal|halol|حلال', caseSensitive: false).hasMatch(allText(t)), isFalse, reason: lang);
    }
    expect(banned.pattern, isNotEmpty);
  });

  testWidgets('arabda ingredient sahifasi RTL, INCI nomi LTR matn yo\'nalishida', (t) async {
    await pumpApp(t, state: onboarded('ar'), initial: '/scanner/ingredient/retinol');
    expect(dirOf(t, 'ingredient-page'), TextDirection.rtl);
    // Sahifa sarlavhasi (headline) INCI nomini aniq LTR yo'nalishida ko'rsatadi.
    final texts = find.descendant(of: k('ingredient-page'), matching: find.text('Retinol')).evaluate().map((e) => e.widget as Text);
    expect(texts.any((w) => w.textDirection == TextDirection.ltr), isTrue);
  });

  testWidgets('kamera tugmasi halol "Tez orada" xabarini beradi', (t) async {
    await pumpApp(t, state: onboarded(), initial: '/scanner');
    await t.tap(k('scan-camera'));
    await t.pump();
    expect(find.text('Tez orada'), findsOneWidget);
  });

  group('skaner ekranlari 4 tilda 320x568 va 1.5x shriftda overflow bermaydi', () {
    for (final lang in ['uz', 'ru', 'en', 'ar']) {
      for (final route in ['/scanner', '/scanner/manual', '/scanner/result', '/scanner/ingredient/niacinamide', '/scanner/ingredient/retinol']) {
        testWidgets('$lang $route', (t) async {
          await pumpApp(t, state: onboarded(lang), initial: route, size: const Size(320, 568), textScale: 1.5);
          expect(t.takeException(), isNull);
        });
      }
    }
  });
}
