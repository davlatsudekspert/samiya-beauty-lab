@Tags(['visual'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Vizual tekshiruv: haqiqiy shrift va rasmlar bilan ekranlarni qa/visual/ ga PNG qilib yozadi.
/// Ishga tushirish: flutter test --tags visual
Future<void> _loadFonts() async {
  const families = {
    'Inter': ['Regular', 'Medium', 'SemiBold', 'Bold'],
    'PlayfairDisplay': ['Medium', 'SemiBold', 'Bold'],
    'IBMPlexSansArabic': ['Regular', 'Medium', 'SemiBold', 'Bold'],
    'Amiri': ['Regular', 'Bold'],
  };
  for (final e in families.entries) {
    final loader = FontLoader(e.key);
    for (final w in e.value) {
      final bytes = File('assets/fonts/${e.key}-$w.ttf').readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root != null) {
    final icons = File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    if (icons.existsSync()) {
      final l = FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
      await l.load();
    }
  }
}

void main() {
  setUpAll(_loadFonts);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final shots = <String, String>{
    '01_splash': '/splash',
    '02_language': '/language',
    '03_welcome': '/welcome',
    '04_onboarding1': '/onboarding',
    '07_login': '/login',
    '10_role': '/role',
  };

  for (final lang in ['uz', 'ar', 'ru']) {
    for (final e in shots.entries) {
      testWidgets('$lang ${e.key}', (t) async {
        t.view.physicalSize = const Size(780, 1688);
        t.view.devicePixelRatio = 2;
        addTearDown(t.view.reset);
        final key = GlobalKey();
        await t.pumpWidget(RepaintBoundary(
          key: key,
          child: SamiyaApp(
            key: UniqueKey(),
            state: AppState(locale: Locale(lang)),
            initialLocation: e.value,
            splashDuration: const Duration(minutes: 5),
          ),
        ));
        await t.runAsync(() async {
          final ctx = t.element(find.byType(MaterialApp));
          for (final a in ['logo_icon', 'hero_welcome', 'ob1_ingredients', 'ob2_routine', 'ob3_learn']) {
            await precacheImage(AssetImage('assets/images/$a.png'), ctx);
          }
        });
        await t.pump(const Duration(milliseconds: 1200));
        await t.pump(const Duration(milliseconds: 400));
        await t.runAsync(() async {
          final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          final out = File('../qa/visual/${lang}_${e.key}.png')..createSync(recursive: true);
          out.writeAsBytesSync(data!.buffer.asUint8List());
        });
        // Dastlabki taymerni tozalash (splash 5 daqiqalik taymeri)
        await t.pumpWidget(const SizedBox());
      });
    }
  }
}
