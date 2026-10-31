@Tags(['promo'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:samiya_beauty_lab/data/personal_store.dart';
import 'package:samiya_beauty_lab/features/scanner/ingredient_models.dart';
import 'package:samiya_beauty_lab/ui/botanical_assets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fonts.dart';

/// Reklama roligi uchun haqiqiy ekranlar (namuna ma'lumotlar bilan): ../qa/promo/<til>_<n>.png
void main() {
  setUpAll(loadAppFonts);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final steps = {
    'uz': ['Yumshoq yuvish vositasi', 'Namlantiruvchi krem', 'Quyoshdan himoya'],
    'ru': ['Мягкое очищение', 'Увлажняющий крем', 'Защита от солнца'],
    'en': ['Gentle cleanser', 'Moisturiser', 'Sunscreen'],
    'ar': ['غسول لطيف', 'كريم مرطب', 'واقي الشمس'],
  };
  final scenes = <String, Future<void> Function(WidgetTester)?>{
    '1': null,
    '2': null,
    '3': null,
    '4': (t) async {
      await t.enterText(find.byKey(const Key('manual-input')), 'Aqua, Glycerin, Niacinamide, Aloe Barbadensis Leaf Juice, Parfum');
      await t.pump();
      await t.tap(find.byKey(const Key('manual-analyze')));
      await t.pumpAndSettle();
    },
    '5': null,
    '6': null,
  };
  final routes = {'1': '/welcome', '2': '/home', '3': '/scanner/ingredient/banana', '4': '/scanner/manual', '5': '/scanner/ibn-sina', '6': '/home/routine'};

  for (final lang in ['uz', 'ru', 'en', 'ar']) {
    for (final e in scenes.entries) {
      testWidgets('promo $lang ${e.key}', (t) async {
        t.view.physicalSize = const Size(1170, 2532); // 390x844 @3x
        t.view.devicePixelRatio = 3;
        addTearDown(t.view.reset);
        final repo = IngredientRepository.fromJson(File('assets/content/ingredients.json').readAsStringSync());
        final p = PersonalStore(persist: false, clock: () => DateTime(2026, 11, 1, 8));
        await p.addAvoid('Parfum');
        for (final s in steps[lang]!) {
          await p.addStep('am', s);
        }
        await p.toggleDone(p.routine['am']!.first.id);
        final key = GlobalKey();
        await t.pumpWidget(RepaintBoundary(
          key: key,
          child: SamiyaApp(key: UniqueKey(), state: AppState(locale: Locale(lang), onboarded: true, ingredients: repo, personal: p), initialLocation: routes[e.key]!),
        ));
        await t.runAsync(() async {
          final ctx = t.element(find.byType(MaterialApp));
          for (final a in ['hero_welcome', 'ob2_routine', 'logo_icon']) {
            await precacheImage(AssetImage('assets/images/$a.png'), ctx);
          }
          for (final b in photoSlugs) {
            await precacheImage(AssetImage('assets/photos/$b.jpg'), ctx);
          }
        });
        await t.pump(const Duration(milliseconds: 1200));
        if (e.value != null) await e.value!(t);
        await t.pump(const Duration(milliseconds: 600));
        await t.runAsync(() async {
          final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          File('../qa/promo/${lang}_${e.key}.png')..createSync(recursive: true)..writeAsBytesSync(data!.buffer.asUint8List());
        });
      });
    }
  }
}
