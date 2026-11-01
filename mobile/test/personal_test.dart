import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:samiya_beauty_lab/data/personal_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/pump.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('PersonalStore', () {
    test('saqlanadi va qayta yuklanadi (teri turi, ro\'yxat, reja, kundalik)', () async {
      final s = PersonalStore();
      await s.setSkinType(SkinType.dry);
      expect(await s.addAvoid('  Parfum '), isTrue);
      expect(await s.addAvoid('PARFUM'), isFalse, reason: 'takror (registrdan qat\'i nazar)');
      expect(await s.addAvoid('   '), isFalse);
      await s.addStep('am', 'Yuvish vositasi');
      await s.addJournal(SkinFeeling.good, 'Bugun yaxshi');
      final r = await PersonalStore.load();
      expect(r.skinType, SkinType.dry);
      expect(r.avoid, ['Parfum']);
      expect(r.routine['am']!.single.name, 'Yuvish vositasi');
      expect(r.journal.single.note, 'Bugun yaxshi');
    });

    test('buzilgan saqlangan ma\'lumot ilovani yiqitmaydi', () async {
      SharedPreferences.setMockInitialValues({'personal_v1': '{not json'});
      final r = await PersonalStore.load();
      expect(r.avoid, isEmpty);
    });

    test('"bugun bajarildi" ertasi kuni o\'zi tozalanadi', () async {
      var now = DateTime(2026, 11, 1, 9);
      final s = PersonalStore(clock: () => now, persist: false);
      await s.addStep('am', 'Krem');
      final id = s.routine['am']!.single.id;
      await s.toggleDone(id);
      expect(s.doneToday('am'), 1);
      now = DateTime(2026, 11, 2, 8);
      expect(s.doneToday('am'), 0);
    });

    test('qadamni yuqoriga/pastga surish, chegaradan chiqmaydi', () async {
      final s = PersonalStore(persist: false);
      for (final n in ['A', 'B', 'C']) {
        await s.addStep('pm', n);
      }
      await s.moveStep('pm', 2, -1);
      expect(s.routine['pm']!.map((e) => e.name), ['A', 'C', 'B']);
      await s.moveStep('pm', 0, -1);
      expect(s.routine['pm']!.map((e) => e.name), ['A', 'C', 'B']);
    });

    test('avoidHits: aniq nom bo\'yicha (registr va bo\'shliqlarga e\'tibor bermaydi)', () async {
      final s = PersonalStore(persist: false);
      await s.addAvoid('Parfum');
      await s.addAvoid('Alcohol Denat.');
      expect(s.avoidHits(['Aqua', 'PARFUM', 'alcohol denat.', 'Glycerin']), ['PARFUM', 'alcohol denat.']);
    });

    test('matn uzunligi cheklanadi', () async {
      final s = PersonalStore(persist: false);
      await s.addJournal(SkinFeeling.okay, 'x' * 1000);
      expect(s.journal.single.note.length, PersonalStore.maxText);
    });
  });

  AppState app({PersonalStore? p, String lang = 'uz'}) =>
      AppState(locale: Locale(lang), onboarded: true, ingredients: testRepo(), personal: p ?? PersonalStore(persist: false));

  testWidgets('bosh sahifa plitkalari endi haqiqiy sahifalarni ochadi', (t) async {
    await pumpApp(t, state: app());
    await t.tap(k('tile-skin'));
    await t.pumpAndSettle();
    expect(k('skin-page'), findsOneWidget);
    await t.tap(k('back-chip'));
    await t.pumpAndSettle();
    await t.tap(k('tile-routine'));
    await t.pumpAndSettle();
    expect(k('routine-page'), findsOneWidget);
    await t.tap(k('back-chip'));
    await t.pumpAndSettle();
    await t.tap(k('tile-journal'));
    await t.pumpAndSettle();
    expect(k('journal-page'), findsOneWidget);
  });

  testWidgets('teri afzalliklari: turini tanlash, ro\'yxatga qo\'shish va o\'chirish', (t) async {
    final p = PersonalStore(persist: false);
    await pumpApp(t, state: app(p: p), initial: '/home/skin');
    expect(k('skin-note'), findsOneWidget);
    await t.tap(k('skin-type-sensitive'));
    await t.pumpAndSettle();
    expect(p.skinType, SkinType.sensitive);
    await t.enterText(k('avoid-input'), 'Parfum');
    await t.tap(k('avoid-add'));
    await t.pumpAndSettle();
    expect(k('avoid-item-Parfum'), findsOneWidget);
    await t.tap(find.descendant(of: k('avoid-item-Parfum'), matching: find.byIcon(Icons.close_rounded)));
    await t.pumpAndSettle();
    expect(p.avoid, isEmpty);
  });

  testWidgets('skaner natijasi: foydalanuvchi ro\'yxatidagi modda topilsa ogohlantiradi', (t) async {
    final p = PersonalStore(persist: false);
    await p.addAvoid('Parfum');
    await pumpApp(t, state: app(p: p), initial: '/scanner/manual');
    await t.enterText(k('manual-input'), 'Aqua, Glycerin, Parfum');
    await t.pump();
    await t.tap(k('manual-analyze'));
    await t.pumpAndSettle();
    expect(k('result-avoid'), findsOneWidget);
    expect(find.textContaining('Parfum'), findsWidgets);
  });

  testWidgets('skaner natijasi: ro\'yxatdagi modda yo\'q bo\'lsa ogohlantirish yo\'q', (t) async {
    final p = PersonalStore(persist: false);
    await p.addAvoid('Parfum');
    await pumpApp(t, state: app(p: p), initial: '/scanner/manual');
    await t.enterText(k('manual-input'), 'Aqua, Glycerin');
    await t.pump();
    await t.tap(k('manual-analyze'));
    await t.pumpAndSettle();
    expect(k('result-avoid'), findsNothing);
  });

  testWidgets('parvarish rejasi: qadam qo\'shish, belgilash, hisoblagich', (t) async {
    final p = PersonalStore(persist: false, clock: () => DateTime(2026, 11, 1, 9)); // ertalab: "Ertalab" tanlanadi
    await pumpApp(t, state: app(p: p), initial: '/home/routine');
    expect(k('routine-empty'), findsOneWidget);
    await t.enterText(k('routine-input'), 'Yuvish vositasi');
    await t.tap(k('routine-add'));
    await t.pumpAndSettle();
    final id = p.routine['am']!.single.id;
    expect(k('step-$id'), findsOneWidget);
    expect(find.text('Bugun bajarildi: 0/1'), findsOneWidget);
    await t.tap(k('step-done-$id'));
    await t.pumpAndSettle();
    expect(find.text('Bugun bajarildi: 1/1'), findsOneWidget);
    await t.tap(k('routine-tab-pm'));
    await t.pumpAndSettle();
    expect(k('routine-empty'), findsOneWidget);
  });

  testWidgets('parvarish rejasi: bo\'sh holatdagi tayyor qadam bir bosishda qo\'shiladi', (t) async {
    final p = PersonalStore(persist: false, clock: () => DateTime(2026, 11, 1, 9));
    await pumpApp(t, state: app(p: p), initial: '/home/routine');
    await t.tap(k('routine-suggest-0'));
    await t.pumpAndSettle();
    expect(p.routine['am']!.single.name, 'Tozalash');
    expect(k('routine-empty'), findsNothing);
  });

  testWidgets('akademiya: 6 ta mavzu va "Tez orada" (soxta dars yo\'q)', (t) async {
    await pumpApp(t, state: app(), initial: '/academy');
    for (var i = 0; i < 6; i++) {
      await t.ensureVisible(k('academy-topic-$i'));
      expect(k('academy-topic-$i'), findsOneWidget);
    }
  });

  testWidgets('kundalik: yozuv qo\'shish va o\'chirish', (t) async {
    final p = PersonalStore(persist: false);
    await pumpApp(t, state: app(p: p), initial: '/journal');
    expect(k('journal-empty'), findsOneWidget);
    await t.tap(k('journal-add'));
    await t.pumpAndSettle();
    await t.tap(k('feel-dry'));
    await t.enterText(k('journal-note'), 'Kechqurun tortishish');
    await t.tap(k('journal-save'));
    await t.pumpAndSettle();
    expect(p.journal.single.feeling, SkinFeeling.dry);
    expect(find.text('Kechqurun tortishish'), findsOneWidget);
    await t.tap(k('journal-remove-${p.journal.single.id}'));
    await t.pumpAndSettle();
    expect(p.journal, isEmpty);
  });

  for (final lang in ['uz', 'ru', 'en', 'ar']) {
    testWidgets('320x568, 1.5x, $lang: shaxsiy sahifalar overflow qilmaydi', (t) async {
      final p = PersonalStore(persist: false);
      await p.addAvoid('Alcohol Denat.');
      await p.addStep('am', 'Juda uzun nomli yuvish vositasi bilan ertalabki tozalash');
      await p.addJournal(SkinFeeling.irritated, 'Uzun qayd ' * 10);
      for (final r in ['/home/skin', '/home/routine', '/journal', '/academy']) {
        await pumpApp(t, state: app(p: p, lang: lang), initial: r, size: const Size(320, 568), textScale: 1.5);
        expect(t.takeException(), isNull, reason: '$lang $r');
      }
    });
  }
}
