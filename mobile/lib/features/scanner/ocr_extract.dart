import 'inci_parser.dart';

// Sarlavhalar (har xil tilda). Unicode harflarga mos `\p{L}` ishlatiladi.
final _header = RegExp(
  r'(?:ingredients?|ingr[eé]dients?|composition|inhaltsstoffe|zutaten|ingredientes|ingredienti|состав|ингредиенты|ingredientlar|tarkibi|tarkib|المكونات|مكونات)\s*[:：]',
  caseSensitive: false,
  unicode: true,
);

// Ro'yxatdan keyin keladigan bo'lim sarlavhalari: shu yerda ro'yxat tugaydi.
final _stop = RegExp(
  r'\b(?:warning|warnings|caution|directions?|how to use|usage|made in|manufactured|distributed|expiry|exp\b|best before|batch|lot\b|pao|store|keep out)\b\s*[:.]?|(?:предупреждение|способ применения|применение|срок годности|произведено)\s*[:.]?',
  caseSensitive: false,
  unicode: true,
);

/// Kameradan o'qilgan (OCR) matndan INCI ro'yxatini ajratadi. Tahlil foydalanuvchi tekshirgandan keyin bajariladi.
String extractInciText(String ocr) {
  var text = ocr.trim();
  if (text.isEmpty) return '';
  final m = _header.firstMatch(text);
  if (m != null) text = text.substring(m.end);
  final stop = _stop.firstMatch(text);
  if (stop != null && stop.start > 0) text = text.substring(0, stop.start);
  text = text
      .replaceAll(RegExp(r'(?<=\p{L})-\s*\n\s*(?=\p{L})', unicode: true), '') // defis bilan uzilgan so'z
      .replaceAll(RegExp(r'\s*\n\s*'), ' ')
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .trim();
  text = text.replaceAll(RegExp(r'[\s.;:]+$'), '');
  if (text.length > maxInciChars) text = text.substring(0, maxInciChars);
  return text;
}
