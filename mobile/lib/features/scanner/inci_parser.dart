/// INCI (ingredient) matnini ro'yxatga ajratadi. OCR chiqishi yoki qo'lda kiritilgan matn uchun.
/// Toza funksiyalar: tarmoq va diskka bog'liq emas.
library;

const maxInciChars = 6000;
const maxInciItems = 300;
const _maxItemLength = 80;

// Tilga xos "Ingredients:" prefikslari (uz, ru, ar, en, fr, de, it, es).
final _prefix = RegExp(
  r'^\s*(ingredients?|ingr[eé]dients?|состав|tarkibi?|المكونات|المكوّنات|zutaten|ingredienti|ingredientes)\s*[:：]\s*',
  caseSensitive: false,
  unicode: true,
);
final _hardSeparators = RegExp(r'[\n\r;|•·]');
final _decimalComma = RegExp(r'(\d),(\d+\s*%)');
final _parenthetical = RegExp(r'\([^)]*(\)|$)');
final _percent = RegExp(r'\d+([.,]\d+)?\s*%');
final _edgePunct = RegExp(r'^[\s.,;:*•·\-_/]+|[\s.,;:*•·\-_/]+$');

/// Matnni ingredient nomlariga ajratadi: tartib saqlanadi, takrorlar (registrsiz) olib tashlanadi,
/// foiz va qavs ichidagi izohlar tashlanadi, haddan uzun elementlar (OCR chiqindisi) tashlanadi.
List<String> parseInci(String raw) {
  var text = raw.length > maxInciChars ? raw.substring(0, maxInciChars) : raw;
  text = text.replaceFirst(_prefix, '');
  text = text.replaceAllMapped(_decimalComma, (m) => '${m[1]}.${m[2]}');
  text = text.replaceAll(_hardSeparators, '\u0001');

  final parts = <String>[];
  final buf = StringBuffer();
  var depth = 0;
  void flush() {
    parts.add(buf.toString());
    buf.clear();
    depth = 0;
  }

  for (final ch in text.runes.map(String.fromCharCode)) {
    if (ch == '\u0001') {
      flush(); // qattiq ajratgich qavs holatini ham tiklaydi (yopilmagan qavsga qarshi)
    } else if (ch == ',' && depth == 0) {
      flush();
    } else {
      if (ch == '(') depth++;
      if (ch == ')' && depth > 0) depth--;
      buf.write(ch);
    }
  }
  flush();

  final seen = <String>{};
  final out = <String>[];
  for (final part in parts) {
    final item = part.replaceAll(_parenthetical, ' ').replaceAll(_percent, ' ').replaceAll(RegExp(r'\s+'), ' ').replaceAll(_edgePunct, '');
    if (item.isEmpty || item.length > _maxItemLength) continue;
    if (!seen.add(inciKey(item))) continue;
    out.add(item);
    if (out.length >= maxInciItems) break;
  }
  return out;
}

const _fold = {
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ä': 'a',
  'ã': 'a',
  'å': 'a',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'ö': 'o',
  'õ': 'o',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ç': 'c',
  'ñ': 'n',
  'ß': 'ss',
};

/// Ingredient nomini moslashtirish uchun kalit: registr, diakritik, defis va ortiqcha bo'shliqlarsiz.
String inciKey(String name) {
  final lower = name.toLowerCase();
  final folded = StringBuffer();
  for (final ch in lower.runes.map(String.fromCharCode)) {
    folded.write(_fold[ch] ?? ch);
  }
  return folded.toString().replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ').trim();
}
