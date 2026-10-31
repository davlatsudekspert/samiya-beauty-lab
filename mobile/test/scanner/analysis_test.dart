import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/features/scanner/analysis.dart';
import 'package:samiya_beauty_lab/features/scanner/evidence_widgets.dart';
import 'package:samiya_beauty_lab/features/scanner/ingredient_models.dart';

IngredientRepository loadRepo() =>
    IngredientRepository.fromJson(File('assets/content/ingredients.json').readAsStringSync());

void main() {
  final repo = loadRepo();

  group('baza qidiruvi va tahlil', () {
    test('aniq nom bo\'yicha topadi, qolganlari "bazada yo\'q"', () {
      final r = analyze('Aqua, Glycerin, Niacinamide (2%), Parfum', repo);
      expect(r.items.map((e) => e.name), ['Aqua', 'Glycerin', 'Niacinamide', 'Parfum']);
      expect(r.recognized.map((e) => e.ingredient!.slug), ['glycerin', 'niacinamide']);
      expect(r.recognized.map((e) => e.position), [2, 3]);
      expect(r.unknown.map((e) => e.name), ['Aqua', 'Parfum']);
    });

    test('registr va tasdiqlangan sinonimlar (Vitamin C, L-Ascorbic Acid) moslashadi', () {
      final r = analyze('SALICYLIC acid, Vitamin C, L-Ascorbic Acid, Nicotinamide', repo);
      expect(r.recognized.map((e) => e.ingredient!.slug),
          ['salicylic-acid', 'ascorbic-acid', 'niacinamide']); // takror ascorbic yo'q
    });

    test('TAXMIN QILINMAYDI: tuz va efirlar boshqa modda hisoblanadi', () {
      final r = analyze('Sodium Hyaluronate, Retinyl Palmitate, Sodium Ascorbyl Phosphate', repo);
      expect(r.recognized, isEmpty);
      expect(r.unknown.length, 3);
    });

    test('bo\'sh kirish bo\'sh natija beradi', () {
      expect(analyze('  ,, ', repo).items, isEmpty);
    });
  });

  group('kontent ma\'lumot shartnomasi (ilovaga tushadigan fayl)', () {
    const levels = {'A', 'B', 'C', 'insufficient'};
    final banned = RegExp(
        r'(\d+\s*%\s*(safe|xavfsiz|безопас)|halal[\s-]*certif|safe for all|\bcures?\b|\bheals?\b|\bguarantee|davolaydi|гарантир|лечит)',
        caseSensitive: false);

    test('20 ingredient, har biri 4 tilda xulosa bilan, hammasi draft', () {
      expect(repo.all.map((e) => e.slug).toSet(), {
        'niacinamide', 'hyaluronic-acid', 'salicylic-acid', 'ascorbic-acid', 'retinol',
        'glycerin', 'panthenol', 'ceramide-np', 'zinc-oxide', 'urea', 'glycolic-acid',
        'honey', 'aloe-vera', 'coconut-oil', 'nigella-sativa-oil', 'rosehip-oil', 'cucumber', 'banana', 'oat', 'green-tea',
      });
      for (final i in repo.all) {
        expect(i.status, 'draft', reason: i.slug);
        for (final l in ['en', 'uz', 'ru', 'ar']) {
          expect(i.summaryFor(l).trim(), isNotEmpty, reason: '${i.slug}/$l');
        }
      }
    });

    test('har da\'vo: daraja to\'g\'ri, 4 tilda matn, kamida bitta PubMed manba', () {
      for (final i in repo.all) {
        expect(i.claims.length, inInclusiveRange(3, 5), reason: i.slug);
        for (final c in i.claims) {
          expect(levels, contains(c.level), reason: c.id);
          expect(c.sources, isNotEmpty, reason: c.id);
          for (final l in ['en', 'uz', 'ru', 'ar']) {
            final t = c.textFor(l);
            expect(t.trim(), isNotEmpty, reason: '${c.id}/$l');
            expect(banned.hasMatch(t), isFalse, reason: '${c.id}/$l: $t');
          }
          for (final s in c.sources) {
            expect(s.pmid, matches(r'^\d{4,9}$'), reason: c.id);
            expect(s.url, 'https://pubmed.ncbi.nlm.nih.gov/${s.pmid}/', reason: c.id);
          }
        }
      }
    });

    test('har da\'voning tadqiqot turi lokalizatsiya qilingan (xom matn ko\'rinmaydi)', () {
      for (final i in repo.all) {
        for (final c in i.claims) {
          expect(knownStudyTypes, contains(c.studyType), reason: c.id);
        }
      }
    });

    test('EU/CosIng tasdiqlanmagan ingredientlar shunday belgilangan', () {
      for (final i in repo.all) {
        expect(i.euVerified, isFalse, reason: '${i.slug}: tasdiqsiz holda true bo\'lmasin');
      }
    });

    test('noma\'lum til inglizchaga qaytadi', () {
      final i = repo.bySlug('retinol')!;
      expect(i.summaryFor('xx'), i.summaryFor('en'));
    });
  });
}
