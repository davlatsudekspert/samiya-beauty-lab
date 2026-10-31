import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/features/scanner/inci_parser.dart';

void main() {
  group('parseInci', () {
    test('oddiy vergulli ro\'yxat tartibni saqlaydi', () {
      expect(parseInci('Aqua, Glycerin, Niacinamide, Parfum'),
          ['Aqua', 'Glycerin', 'Niacinamide', 'Parfum']);
    });

    test('"Ingredients:" prefiksi har tilda olib tashlanadi', () {
      expect(parseInci('INGREDIENTS: Aqua, Glycerin'), ['Aqua', 'Glycerin']);
      expect(parseInci('Состав: Aqua, Glycerin'), ['Aqua', 'Glycerin']);
      expect(parseInci('Tarkibi: Aqua, Glycerin'), ['Aqua', 'Glycerin']);
      expect(parseInci('Ingrédients : Aqua, Glycerin'), ['Aqua', 'Glycerin']);
    });

    test('yangi qator, nuqtali vergul va o\'rta nuqta ajratgich sifatida ishlaydi', () {
      expect(parseInci('Aqua\nGlycerin; Niacinamide · Parfum.'),
          ['Aqua', 'Glycerin', 'Niacinamide', 'Parfum']);
    });

    test('foiz va qavs ichidagi izoh olib tashlanadi, ingredient nomi qoladi', () {
      expect(parseInci('Niacinamide (2%), Aqua (Water), Retinol 0.3%'),
          ['Niacinamide', 'Aqua', 'Retinol']);
    });

    test('qavs ichidagi vergul ro\'yxatni buzmaydi (Parfum (Fragrance, Aroma))', () {
      expect(parseInci('Aqua, Parfum (Fragrance, Aroma), Glycerin'),
          ['Aqua', 'Parfum', 'Glycerin']);
    });

    test('OCR shovqini: ortiqcha bo\'shliq, defis, tire, bo\'sh elementlar', () {
      expect(parseInci('  Aqua ,, Sodium   Hyaluronate ,  ,Cetearyl-Alcohol  '),
          ['Aqua', 'Sodium Hyaluronate', 'Cetearyl-Alcohol']);
    });

    test('takrorlar olib tashlanadi (birinchisi saqlanadi), registrga e\'tibor berilmaydi', () {
      expect(parseInci('Aqua, aqua, AQUA, Glycerin'), ['Aqua', 'Glycerin']);
    });

    test('rang indekslari (CI 77891) bitta element sifatida saqlanadi', () {
      expect(parseInci('Aqua, CI 77891, CI 77491'), ['Aqua', 'CI 77891', 'CI 77491']);
    });

    test('bo\'sh yoki faqat belgidan iborat kirish bo\'sh ro\'yxat beradi', () {
      expect(parseInci(''), isEmpty);
      expect(parseInci('   \n  ,,, ;; '), isEmpty);
    });

    test('juda uzun kirish kesiladi (xotira va suiiste\'molga qarshi)', () {
      final big = List.generate(5000, (i) => 'Ingredient$i').join(', ');
      expect(parseInci(big).length, lessThanOrEqualTo(maxInciItems));
    });

    test('juda uzun bitta element tashlab yuboriladi (OCR chiqindisi)', () {
      expect(parseInci('Aqua, ${'x' * 200}, Glycerin'), ['Aqua', 'Glycerin']);
    });
  });

  group('inciKey (moslashtirish kaliti)', () {
    test('registr, bo\'shliq, defis va diakritiklar farqi yo\'qoladi', () {
      expect(inciKey('Sodium  Hyaluronate'), inciKey('sodium hyaluronate'));
      expect(inciKey('Cetearyl-Alcohol'), inciKey('Cetearyl Alcohol'));
      expect(inciKey('Acide Salicylique'), inciKey('acide salicylique'));
    });

    test('turli moddalar farqlanadi', () {
      expect(inciKey('Salicylic Acid') == inciKey('Ascorbic Acid'), isFalse);
    });
  });
}
