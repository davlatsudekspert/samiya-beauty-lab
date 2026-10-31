import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fonts.dart';
import 'support/pump.dart';

/// Har bir so'z (bo'g'insiz) bitta qatorda turishi kerak: aks holda u so'z o'rtasidan uzilgan.
void expectNoMidWordBreak(WidgetTester t, Finder f, {required String reason}) {
  final rt = t.renderObject<RenderParagraph>(f);
  final text = rt.text.toPlainText();
  final broken = <String>[];
  for (final m in RegExp(r'[^\s-]+').allMatches(text)) {
    final tops = rt
        .getBoxesForSelection(TextSelection(baseOffset: m.start, extentOffset: m.end))
        .map((b) => b.top.round())
        .toSet();
    if (tops.length > 1) broken.add(m.group(0)!);
  }
  expect(broken, isEmpty, reason: '$reason: so\'z o\'rtasidan uzilgan: $broken ("$text")');
}

void main() {
  setUpAll(loadAppFonts);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final lang in ['uz', 'ru', 'en']) {
    testWidgets('320x568: bosh sahifa banner sarlavhasi so\'zni bo\'lmaydi ($lang)', (t) async {
      await pumpApp(t,
          state: AppState(onboarded: true, ingredients: testRepo(), locale: Locale(lang)),
          size: const Size(320, 568));
      final title = find.descendant(of: k('home-banner'), matching: find.byType(Text)).first;
      expectNoMidWordBreak(t, title, reason: 'home banner $lang');
    });

    testWidgets('320x568: kirish banner sarlavhasi so\'zni bo\'lmaydi ($lang)', (t) async {
      await pumpApp(t,
          state: AppState(ingredients: testRepo(), locale: Locale(lang)),
          initial: '/login', size: const Size(320, 568));
      final title = find.descendant(of: k('login-banner'), matching: find.byType(Text)).last;
      expectNoMidWordBreak(t, title, reason: 'login banner $lang');
    });
  }

  testWidgets('320x568: pastki navigatsiya yorlig\'i qisqartirilmaydi (uz)', (t) async {
    await pumpApp(t, state: AppState(onboarded: true, ingredients: testRepo()), size: const Size(320, 568));
    final label = find.descendant(of: k('nav-home'), matching: find.byType(Text));
    final rt = t.renderObject<RenderParagraph>(label);
    expect(rt.didExceedMaxLines, isFalse);
    // FittedBox bilan kichraytirilgan bo'lsa ham matn ellipsis bo'lmasligi kerak
    expect(find.descendant(of: k('nav-home'), matching: find.byType(FittedBox)), findsOneWidget);
  });
}
