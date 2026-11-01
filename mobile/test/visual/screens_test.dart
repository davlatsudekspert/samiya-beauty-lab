@Tags(['visual'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:samiya_beauty_lab/features/auth/auth_service.dart';
import 'package:samiya_beauty_lab/features/scanner/ingredient_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:samiya_beauty_lab/ui/botanical_assets.dart';

import '../support/fonts.dart';

/// Vizual tekshiruv: haqiqiy shrift va rasmlar bilan ekranlarni qa/visual/ ga PNG qilib yozadi.
/// Ishga tushirish: flutter test --tags visual
void main() {
  setUpAll(loadAppFonts);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final shots = <String, String>{
    '01_splash': '/splash',
    '01b_greeting': '/splash',
    '02_language': '/language',
    '03_welcome': '/welcome',
    '04_onboarding1': '/onboarding',
    '07_login': '/login',
    '10_role': '/role',
    '11_home': '/home',
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
            state: AppState(locale: Locale(lang), onboarded: e.key == '01b_greeting'),
            initialLocation: e.value,
            splashDuration: const Duration(minutes: 5),
          ),
        ));
        await t.runAsync(() async {
          final ctx = t.element(find.byType(MaterialApp));
          for (final a in ['logo_icon', 'hero_welcome', 'ob1_ingredients', 'ob2_routine', 'ob3_learn']) {
            await precacheImage(AssetImage('assets/images/$a.png'), ctx);
          }
          await precacheImage(const AssetImage('assets/images/logo_square.jpg'), ctx);
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

  // To'liq bosh sahifa va bazali sahifalar (haqiqiy kontent bilan, uzun ekran).
  final full = <String, (String, Size)>{
    '11_home_full': ('/home', const Size(780, 3200)),
    '15_ingredients': ('/scanner/ingredients?filter=natural', const Size(780, 1688)),
    '21_natural_detail': ('/scanner/ingredient/honey', const Size(780, 1688)),
    '22_ibn_sina': ('/scanner/ibn-sina', const Size(780, 1688)),
    '24_banana': ('/scanner/ingredient/banana', const Size(780, 1688)),
    '25_skin': ('/home/skin', const Size(780, 1688)),
    '26_routine': ('/home/routine', const Size(780, 1688)),
    '27_journal': ('/journal', const Size(780, 1688)),
    '28_academy': ('/academy', const Size(780, 1688)),
    '28b_lesson': ('/academy/lesson/spf', const Size(780, 4200)),
    '31_ai': ('/home/ai', const Size(780, 1688)),
    '32_recipes': ('/home/recipes', const Size(780, 1688)),
    '33_recipe': ('/home/recipes/honey-oat-mask', const Size(780, 3600)),
    '34_ritual': ('/home/rituals/evening-gua-sha', const Size(780, 1688)),
    '35_shelf': ('/home/shelf', const Size(780, 1688)),
    '29_scanner': ('/scanner', const Size(780, 1688)),
    '30_profile': ('/profile', const Size(780, 1688)),
    '23_honey_full': ('/scanner/ingredient/honey', const Size(780, 4200)),
  };
  for (final lang in ['uz', 'ar']) {
    for (final e in full.entries) {
      testWidgets('$lang ${e.key}', (t) async {
        t.view.physicalSize = e.value.$2;
        t.view.devicePixelRatio = 2;
        addTearDown(t.view.reset);
        final key = GlobalKey();
        final repo = IngredientRepository.fromJson(File('assets/content/ingredients.json').readAsStringSync());
        await t.pumpWidget(RepaintBoundary(
          key: key,
          child: SamiyaApp(key: UniqueKey(), state: AppState(locale: Locale(lang), onboarded: true, ingredients: repo), initialLocation: e.value.$1),
        ));
        await t.runAsync(() async {
          final ctx = t.element(find.byType(MaterialApp));
          for (final a in ['ob2_routine']) {
            await precacheImage(AssetImage('assets/images/$a.png'), ctx);
          }
          for (final b in botanicalSlugs) {
            await precacheImage(AssetImage('assets/botanical/$b.jpg'), ctx);
          }
          for (final b in Directory('assets/photos').listSync().whereType<File>().where((f) => f.path.endsWith('.jpg'))) {
            await precacheImage(AssetImage('assets/photos/${b.uri.pathSegments.last}'), ctx);
          }
        });
        await t.pump(const Duration(milliseconds: 1200));
        await t.pump(const Duration(milliseconds: 400));
        await t.runAsync(() async {
          final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          File('../qa/visual/${lang}_${e.key}.png')..createSync(recursive: true)..writeAsBytesSync(data!.buffer.asUint8List());
        });
      });
    }
  }
  // Skaner oqimi: haqiqiy baza bilan, kiritish va natija bosqichlari.
  final scan = <String, (String, Future<void> Function(WidgetTester)?)>{
    '16_scanner': ('/scanner', null),
    '19_manual': ('/scanner/manual', (t) async {
      await t.enterText(find.byKey(const Key('manual-input')), 'Aqua, Glycerin, Niacinamide (2%), Retinol, Parfum');
      await t.pump(const Duration(milliseconds: 300));
    }),
    '20_result': ('/scanner/manual', (t) async {
      await t.enterText(find.byKey(const Key('manual-input')), 'Aqua, Glycerin, Niacinamide (2%), Retinol, Parfum');
      await t.pump();
      await t.tap(find.byKey(const Key('manual-analyze')));
      await t.pumpAndSettle();
    }),
    '21_ingredient': ('/scanner/ingredient/niacinamide', null),
    '59_profile': ('/profile', null),
  };
  for (final lang in ['uz', 'ar']) {
    testWidgets('$lang 59_profile_signedin', (t) async {
      t.view.physicalSize = const Size(780, 1688);
      t.view.devicePixelRatio = 2;
      addTearDown(t.view.reset);
      final key = GlobalKey();
      final auth = _FakeAuth();
      await t.pumpWidget(RepaintBoundary(
        key: key,
        child: SamiyaApp(
          key: UniqueKey(),
          state: AppState(locale: Locale(lang), onboarded: true, role: UserRole.student, auth: auth),
          initialLocation: '/profile',
          splashDuration: const Duration(minutes: 5),
        ),
      ));
      await t.pump(const Duration(milliseconds: 600));
      await t.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        File('../qa/visual/${lang}_59_profile_signedin.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data!.buffer.asUint8List());
      });
      await t.pumpWidget(const SizedBox());
    });
    for (final e in scan.entries) {
      testWidgets('$lang ${e.key}', (t) async {
        t.view.physicalSize = const Size(780, 1688);
        t.view.devicePixelRatio = 2;
        addTearDown(t.view.reset);
        final key = GlobalKey();
        final repo = IngredientRepository.fromJson(File('assets/content/ingredients.json').readAsStringSync());
        await t.pumpWidget(RepaintBoundary(
          key: key,
          child: SamiyaApp(
            key: UniqueKey(),
            state: AppState(locale: Locale(lang), onboarded: true, ingredients: repo),
            initialLocation: e.value.$1,
            splashDuration: const Duration(minutes: 5),
          ),
        ));
        await t.runAsync(() async {
          final ctx = t.element(find.byType(MaterialApp));
          for (final a in ['logo_icon', 'hero_welcome', 'ob1_ingredients', 'ob2_routine', 'ob3_learn']) {
            await precacheImage(AssetImage('assets/images/$a.png'), ctx);
          }
        });
        await t.pump(const Duration(milliseconds: 600));
        if (e.value.$2 != null) await e.value.$2!(t);
        await t.pump(const Duration(milliseconds: 400));
        await t.runAsync(() async {
          final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          File('../qa/visual/${lang}_${e.key}.png')
            ..createSync(recursive: true)
            ..writeAsBytesSync(data!.buffer.asUint8List());
        });
        await t.pumpWidget(const SizedBox());
      });
    }
  }
}

class _FakeAuth implements AuthService {
  @override
  AuthUser? get currentUser => const AuthUser(uid: 'u', provider: 'google.com', email: 'samiya@example.com', displayName: 'Samiya A.');
  @override
  Stream<AuthUser?> get changes => const Stream.empty();
  @override
  Future<AuthUser> signInWithGoogle() => throw UnimplementedError();
  @override
  Future<AuthUser> signInWithApple() => throw UnimplementedError();
  @override
  Future<void> signOut() async {}
  @override
  Future<void> deleteAccount() async {}
  @override
  Future<String?> idToken() async => 't';
}
