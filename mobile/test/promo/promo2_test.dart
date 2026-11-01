@Tags(['promo'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:samiya_beauty_lab/data/backend_api.dart';
import 'package:samiya_beauty_lab/data/personal_store.dart';
import 'package:samiya_beauty_lab/features/scanner/ingredient_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_auth.dart';
import '../support/fake_backend.dart';
import '../support/fonts.dart';

/// Ikkinchi rolik: ilovaning har bir bo'limi namuna ma'lumotlar bilan -> ../qa/promo2/`<til>_<n>`.png
class _PromoBackend extends FakeBackendApi {
  _PromoBackend(this.answer);
  final String answer;
  @override
  Future<AiAnswer> askAi(String idToken, {required String requestId, required String question, required String lang, String context = '', List<AiTurn> history = const []}) async =>
      AiAnswer(answer: answer, remaining: 9, limit: 10);
}

const _answers = {
  'uz': 'Ha, ko‘pchilik uchun mumkin. «Birga ishlatmang» degan fikr asosan eski laboratoriya kuzatuvlariga tayanadi.\n\n• Teringiz sezgir bo‘lsa, ularni birin-ketin qo‘shing.\n• C vitaminini ertalab, quyoshdan himoya vositasi bilan ishlating.\n• Qizarish yoki achishish bo‘lsa, to‘xtating.\n\nBu ta’limiy ma’lumot. Muammo bo‘lsa, dermatologga murojaat qiling.',
  'ru': 'Да, большинству можно. Мнение «не сочетать» в основном опирается на старые лабораторные наблюдения.\n\n• Если кожа чувствительная, вводите средства по очереди.\n• Витамин C — утром, вместе с солнцезащитным средством.\n• При покраснении или жжении прекратите.\n\nЭто образовательная информация. При проблемах обратитесь к дерматологу.',
  'en': 'Yes, for most people. The “don’t combine them” idea comes mostly from old laboratory observations.\n\n• If your skin is sensitive, introduce them one at a time.\n• Use vitamin C in the morning, with sunscreen.\n• Stop if you notice redness or stinging.\n\nThis is educational information. For skin problems, see a dermatologist.',
  'ar': 'نعم، لمعظم الناس. فكرة «لا تجمعيهما» تستند غالبًا إلى ملاحظات مخبرية قديمة.\n\n• إذا كانت بشرتكِ حساسة فأدخليهما واحدًا تلو الآخر.\n• استخدمي فيتامين C صباحًا مع واقي الشمس.\n• توقفي إذا لاحظتِ احمرارًا أو لسعًا.\n\nهذه معلومات تثقيفية. عند وجود مشكلة راجعي طبيبة جلدية.',
};

const _shelf = {
  'uz': ['Namlantiruvchi krem', 'C vitaminli serum', 'Quyoshdan himoya SPF 50'],
  'ru': ['Увлажняющий крем', 'Сыворотка с витамином C', 'Солнцезащитный крем SPF 50'],
  'en': ['Moisturiser', 'Vitamin C serum', 'Sunscreen SPF 50'],
  'ar': ['كريم مرطب', 'سيروم فيتامين C', 'واقي شمس SPF 50'],
};
const _journal = {
  'uz': ['Teri tinch, yangi krem yoqdi.', 'Gua sha ritualidan keyin yuz yengil.'],
  'ru': ['Кожа спокойная, новый крем подошёл.', 'После ритуала гуаша лицо лёгкое.'],
  'en': ['Skin feels calm, the new cream suits me.', 'Face feels light after the gua sha ritual.'],
  'ar': ['البشرة هادئة، والكريم الجديد مناسب.', 'الوجه خفيف بعد طقس الغواشا.'],
};

void main() {
  setUpAll(loadAppFonts);

  final routes = {
    '01': '/splash', '02': '/home', '03': '/scanner/manual', '04': '/scanner/ingredient/argan-oil', '05': '/academy',
    '06': '/academy/lesson/spf', '07': '/home/ai', '08': '/home/recipes/honey-oat-mask', '09': '/home/rituals/evening-gua-sha',
    '10': '/home/shelf', '11': '/journal', '12': '/scanner/ibn-sina',
  };

  for (final lang in ['uz', 'ru', 'en', 'ar']) {
    for (final e in routes.entries) {
      testWidgets('promo2 $lang ${e.key}', (t) async {
        SharedPreferences.setMockInitialValues({'ai_consent_v1': true});
        t.view.physicalSize = const Size(1170, 2532);
        t.view.devicePixelRatio = 3;
        addTearDown(t.view.reset);
        final repo = IngredientRepository.fromJson(File('assets/content/ingredients.json').readAsStringSync());
        final p = PersonalStore(persist: false, clock: () => DateTime(2026, 11, 1, 8));
        final names = _shelf[lang]!;
        await p.addShelf(names[0], openedOn: DateTime(2026, 9, 1), paoMonths: 12);
        await p.addShelf(names[1], openedOn: DateTime(2026, 5, 20), paoMonths: 6);
        await p.addShelf(names[2], openedOn: DateTime(2026, 10, 1), paoMonths: 12);
        await p.addJournal(SkinFeeling.great, _journal[lang]![1]);
        await p.addJournal(SkinFeeling.good, _journal[lang]![0]);
        await p.addAvoid('Parfum');
        final key = GlobalKey();
        final state = AppState(
          locale: Locale(lang),
          onboarded: true,
          ingredients: repo,
          personal: p,
          auth: FakeAuthService.signedIn(),
          backend: _PromoBackend(_answers[lang]!),
        );
        await t.pumpWidget(RepaintBoundary(
          key: key,
          child: SamiyaApp(key: UniqueKey(), state: state, initialLocation: e.value, splashDuration: const Duration(minutes: 5)),
        ));
        await t.runAsync(() async {
          final ctx = t.element(find.byType(MaterialApp));
          for (final a in ['hero_welcome', 'logo_square']) {
            await precacheImage(AssetImage('assets/images/$a.${a == 'logo_square' ? 'jpg' : 'png'}'), ctx);
          }
          for (final b in Directory('assets/photos').listSync().whereType<File>().where((f) => f.path.endsWith('.jpg'))) {
            await precacheImage(AssetImage('assets/photos/${b.uri.pathSegments.last}'), ctx);
          }
        });
        await t.pump(const Duration(milliseconds: 1200));
        switch (e.key) {
          case '03':
            await t.enterText(find.byKey(const Key('manual-input')), 'Aqua, Glycerin, Niacinamide, Aloe Barbadensis Leaf Juice, Argania Spinosa Kernel Oil, Parfum');
            await t.pump();
            await t.tap(find.byKey(const Key('manual-analyze')));
            await t.pumpAndSettle();
          case '07':
            await t.tap(find.byKey(const Key('ai-suggest-0')));
            await t.pumpAndSettle();
          case '09':
            await t.tap(find.byKey(const Key('ritual-start')));
            await t.pump(const Duration(seconds: 7));
        }
        await t.pump(const Duration(milliseconds: 600));
        await t.runAsync(() async {
          final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          File('../qa/promo2/${lang}_${e.key}.png')..createSync(recursive: true)..writeAsBytesSync(data!.buffer.asUint8List());
        });
        await t.pumpWidget(const SizedBox());
      });
    }
  }
}
