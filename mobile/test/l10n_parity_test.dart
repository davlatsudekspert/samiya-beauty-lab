import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _arb(String code) =>
    jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync()) as Map<String, dynamic>;

Set<String> _keys(Map<String, dynamic> m) =>
    m.keys.where((k) => !k.startsWith('@')).toSet();

void main() {
  const codes = ['en', 'uz', 'ru', 'ar'];

  test('4 tilning hammasida bir xil kalitlar bor (en shablon)', () {
    final en = _keys(_arb('en'));
    for (final c in codes.skip(1)) {
      final k = _keys(_arb(c));
      expect(en.difference(k), isEmpty, reason: '$c da yetishmaydi');
      expect(k.difference(en), isEmpty, reason: '$c da ortiqcha');
    }
  });

  test('hech bir tarjima bo\'sh emas', () {
    for (final c in codes) {
      _arb(c).forEach((k, v) {
        if (!k.startsWith('@')) {
          expect((v as String).trim(), isNotEmpty, reason: '$c/$k bo\'sh');
        }
      });
    }
  });

  test('arab tarjimasi haqiqatan arab yozuvida (ingliz matni qolib ketmagan)', () {
    final arabic = RegExp(r'[؀-ۿ]');
    final ar = _arb('ar');
    for (final k in _keys(ar)) {
      if (k == 'appName' || k == 'proBadge') continue; // brend va tarif nomi lotin yozuvida qoladi
      expect(arabic.hasMatch(ar[k] as String), isTrue, reason: 'ar/$k arabcha emas');
    }
  });
}
