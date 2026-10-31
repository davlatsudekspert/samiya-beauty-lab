import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:samiya_beauty_lab/features/scanner/ingredient_models.dart';

/// Haqiqiy kontent fayli (assets/content/ingredients.json) bilan baza.
IngredientRepository testRepo() =>
    IngredientRepository.fromJson(File('assets/content/ingredients.json').readAsStringSync());

/// Ilovani berilgan ekran o'lchami va shrift masshtabida ishga tushiradi.
Future<AppState> pumpApp(
  WidgetTester t, {
  AppState? state,
  String initial = '/splash',
  Size size = const Size(390, 844),
  double textScale = 1.0,
}) async {
  t.view.physicalSize = size * 2;
  t.view.devicePixelRatio = 2;
  t.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    t.view.reset();
    t.platformDispatcher.clearAllTestValues();
  });
  final s = state ?? AppState(ingredients: testRepo());
  await t.pumpWidget(SamiyaApp(
    key: UniqueKey(),
    state: s,
    initialLocation: initial,
    splashDuration: const Duration(milliseconds: 100),
  ));
  await t.pumpAndSettle();
  return s;
}

TextDirection dirOf(WidgetTester t, String pageKey) =>
    Directionality.of(t.element(find.byKey(Key(pageKey))));

Finder k(String key) => find.byKey(Key(key));
