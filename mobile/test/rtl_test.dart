import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app.dart';
import 'package:samiya_beauty_lab/app/locale_controller.dart';

Future<TextDirection> _dirFor(WidgetTester t, String code) async {
  final c = LocaleController(Locale(code));
  await t.pumpWidget(SamiyaApp(controller: c));
  await t.pumpAndSettle();
  return Directionality.of(t.element(find.byKey(const Key('welcome-page'))));
}

void main() {
  testWidgets('arab tilida interfeys o\'ngdan chapga (RTL)', (t) async {
    expect(await _dirFor(t, 'ar'), TextDirection.rtl);
  });

  for (final code in ['uz', 'ru', 'en']) {
    testWidgets('$code tilida chapdan o\'ngga (LTR)', (t) async {
      expect(await _dirFor(t, code), TextDirection.ltr);
    });
  }

  testWidgets('til chipini bosish matn va yo\'nalishni darhol almashtiradi', (t) async {
    final c = LocaleController(const Locale('uz'));
    await t.pumpWidget(SamiyaApp(controller: c));
    await t.pumpAndSettle();
    expect(find.text('Boshlash'), findsOneWidget);

    await t.tap(find.byKey(const Key('lang-ar')));
    await t.pumpAndSettle();
    expect(find.text('ابدأ'), findsOneWidget);
    expect(Directionality.of(t.element(find.byKey(const Key('welcome-page')))), TextDirection.rtl);

    await t.tap(find.byKey(const Key('lang-ru')));
    await t.pumpAndSettle();
    expect(find.text('Начать'), findsOneWidget);
  });

  testWidgets('Google, Apple va mehmon tugmalari barcha tillarda bor', (t) async {
    for (final code in ['uz', 'ru', 'en', 'ar']) {
      await t.pumpWidget(SamiyaApp(controller: LocaleController(Locale(code))));
      await t.pumpAndSettle();
      expect(find.byKey(const Key('btn-google')), findsOneWidget, reason: code);
      expect(find.byKey(const Key('btn-apple')), findsOneWidget, reason: code);
      expect(find.byKey(const Key('btn-guest')), findsOneWidget, reason: code);
    }
  });
}
