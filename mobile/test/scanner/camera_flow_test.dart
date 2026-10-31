import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:samiya_beauty_lab/features/scanner/text_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_text_scanner.dart';
import '../support/pump.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  AppState make(FakeTextScanner s, {String lang = 'uz'}) =>
      AppState(locale: Locale(lang), onboarded: true, ingredients: testRepo(), scanner: s);

  Future<void> openSheet(WidgetTester t) async {
    await t.ensureVisible(k('scan-camera'));
    await t.tap(k('scan-camera'));
    await t.pumpAndSettle();
  }

  testWidgets('kamera tugmasi: manba tanlash oynasi (kamera / galereya) ochiladi', (t) async {
    await pumpApp(t, state: make(FakeTextScanner(text: 'x')), initial: '/scanner');
    await openSheet(t);
    expect(k('scan-source-camera'), findsOneWidget);
    expect(k('scan-source-gallery'), findsOneWidget);
  });

  testWidgets('rasm o\'qildi: tarkib ajratilib, tekshirish sahifasiga to\'ldirilgan holda o\'tadi', (t) async {
    final fake = FakeTextScanner(text: 'Ingredients: Aqua, Glycerin,\nNiacinamide');
    await pumpApp(t, state: make(fake), initial: '/scanner');
    await openSheet(t);
    await t.tap(k('scan-source-camera'));
    await t.pumpAndSettle();
    expect(fake.calls, [ScanSource.camera]);
    expect(k('manual-page'), findsOneWidget);
    expect(find.text('Aqua, Glycerin, Niacinamide'), findsOneWidget);
    expect(k('manual-ocr-hint'), findsOneWidget);
    // foydalanuvchi tekshirib tahlil qiladi
    await t.tap(k('manual-analyze'));
    await t.pumpAndSettle();
    expect(k('result-page'), findsOneWidget);
    expect(k('result-card-niacinamide'), findsOneWidget);
  });

  testWidgets('galereya manbasi ham ishlaydi', (t) async {
    final fake = FakeTextScanner(text: 'Aqua, Retinol');
    await pumpApp(t, state: make(fake), initial: '/scanner');
    await openSheet(t);
    await t.tap(k('scan-source-gallery'));
    await t.pumpAndSettle();
    expect(fake.calls, [ScanSource.gallery]);
    expect(k('manual-page'), findsOneWidget);
  });

  testWidgets('foydalanuvchi bekor qilsa: jim, sahifada qoladi, xabar yo\'q', (t) async {
    await pumpApp(t, state: make(FakeTextScanner(text: null)), initial: '/scanner');
    await openSheet(t);
    await t.tap(k('scan-source-camera'));
    await t.pumpAndSettle();
    expect(k('scanner-page'), findsOneWidget);
    expect(k('scan-message'), findsNothing);
  });

  testWidgets('matn topilmasa: sahifa ichida halol xabar, qo\'lda kiritishga o\'tilmaydi', (t) async {
    await pumpApp(t, state: make(FakeTextScanner(text: '   \n ')), initial: '/scanner');
    await openSheet(t);
    await t.tap(k('scan-source-camera'));
    await t.pumpAndSettle();
    expect(k('scanner-page'), findsOneWidget);
    expect(k('scan-message'), findsOneWidget);
    expect(find.textContaining('Tarkib topilmadi'), findsOneWidget);
  });

  testWidgets('o\'qish xatosi (ruxsat yo\'q va h.k.): xabar, ilova yiqilmaydi', (t) async {
    await pumpApp(t, state: make(FakeTextScanner(error: const ScanException(ScanFailure.failed))), initial: '/scanner');
    await openSheet(t);
    await t.tap(k('scan-source-camera'));
    await t.pumpAndSettle();
    expect(find.textContaining('Rasmni o‘qib bo‘lmadi'), findsOneWidget);
  });

  testWidgets('kamera mavjud bo\'lmagan qurilma: "mavjud emas" xabari', (t) async {
    await pumpApp(t, state: make(FakeTextScanner(available: false, error: const ScanException(ScanFailure.unavailable))), initial: '/scanner');
    await t.ensureVisible(k('scan-camera'));
    await t.tap(k('scan-camera'));
    await t.pumpAndSettle();
    expect(find.textContaining('mavjud emas'), findsOneWidget);
    expect(k('scan-source-camera'), findsNothing);
  });

  testWidgets('o\'qish davomida progress ko\'rinadi va tugmalar qayta bosilmaydi', (t) async {
    final fake = FakeTextScanner()..gate = Completer<String?>();
    await pumpApp(t, state: make(fake), initial: '/scanner');
    await openSheet(t);
    await t.tap(k('scan-source-camera'));
    await t.pump();
    expect(k('scan-busy'), findsOneWidget);
    fake.gate!.complete('Aqua, Retinol');
    await t.pumpAndSettle();
    expect(k('scan-busy'), findsNothing);
    expect(k('manual-page'), findsOneWidget);
  });

  for (final lang in ['uz', 'ru', 'en', 'ar']) {
    testWidgets('320x568, 1.5x shrift, $lang: skaner va xabar overflow qilmaydi', (t) async {
      await pumpApp(t, state: make(FakeTextScanner(text: '  '), lang: lang), initial: '/scanner', size: const Size(320, 568), textScale: 1.5);
      await openSheet(t);
      await t.tap(k('scan-source-camera'));
      await t.pumpAndSettle();
      expect(k('scan-message'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }
}
