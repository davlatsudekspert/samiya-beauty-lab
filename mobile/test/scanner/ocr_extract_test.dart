import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/features/scanner/ocr_extract.dart';
import 'package:samiya_beauty_lab/features/scanner/inci_parser.dart';

void main() {
  test('"Ingredients:" dan keyingi matn olinadi, oldingi marketing matni tashlanadi', () {
    const ocr = 'HYDRA GLOW SERUM\n30 ml e 1.0 fl oz\nIngredients: Aqua, Glycerin, Niacinamide,\nPhenoxyethanol';
    expect(extractInciText(ocr), 'Aqua, Glycerin, Niacinamide, Phenoxyethanol');
  });

  test('qatorlarga bo\'lingan ro\'yxat bitta qatorga birlashadi, vergullar saqlanadi', () {
    const ocr = 'INGREDIENTS:\nAqua,\nSodium Hyaluronate,\nRetinol';
    expect(parseInci(extractInciText(ocr)).map((e) => e.toLowerCase()), ['aqua', 'sodium hyaluronate', 'retinol']);
  });

  test('so\'z defis bilan qatorda uzilgan bo\'lsa qayta tiklanadi (Niacina-\\nmide)', () {
    const ocr = 'Ingredients: Aqua, Niacina-\nmide, Glycerin';
    expect(extractInciText(ocr), 'Aqua, Niacinamide, Glycerin');
  });

  test('rus va boshqa tillardagi sarlavhalar tanib olinadi', () {
    expect(extractInciText('Состав: Aqua, Glycerin'), 'Aqua, Glycerin');
    expect(extractInciText('Composition: Aqua, Glycerin'), 'Aqua, Glycerin');
    expect(extractInciText('Inhaltsstoffe: Aqua, Glycerin'), 'Aqua, Glycerin');
    expect(extractInciText('Ingrédients : Aqua, Glycerin'), 'Aqua, Glycerin');
  });

  test('ro\'yxatdan keyingi ogohlantirish/ishlatish matni kesiladi', () {
    const ocr = 'Ingredients: Aqua, Glycerin, Retinol.\nWarning: avoid contact with eyes.\nDirections: apply at night';
    expect(extractInciText(ocr), 'Aqua, Glycerin, Retinol');
  });

  test('sarlavha yo\'q bo\'lsa butun matn (tozalangan) qaytadi', () {
    expect(extractInciText('Aqua, Glycerin,\nNiacinamide'), 'Aqua, Glycerin, Niacinamide');
  });

  test('bo\'sh yoki bo\'sh joydan iborat matn: bo\'sh qator', () {
    expect(extractInciText(''), '');
    expect(extractInciText('  \n \t '), '');
  });

  test('katta-kichik harf farqi yo\'q; ikkita sarlavhada birinchisidan keyingisi olinadi', () {
    expect(extractInciText('ingredients: Aqua'), 'Aqua');
    expect(extractInciText('Ingredients: Aqua, Glycerin\nIngredients: Water'), startsWith('Aqua, Glycerin'));
  });

  test('uzunligi inci_parser chegarasidan oshmaydi', () {
    final long = 'Ingredients: ${List.filled(2000, 'Aqua').join(', ')}';
    expect(extractInciText(long).length <= maxInciChars, isTrue);
  });
}
