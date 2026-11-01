import 'ingredient_models.dart';
import 'inci_parser.dart';

/// Ro'yxatdagi bitta ingredient: o'rni (1 dan), nomi va bazadagi yozuvi (bo'lsa).
class AnalysisItem {
  const AnalysisItem({required this.position, required this.name, this.ingredient});
  final int position;
  final String name;
  final Ingredient? ingredient;
}

class AnalysisResult {
  const AnalysisResult(this.items);
  final List<AnalysisItem> items;

  List<AnalysisItem> get recognized => [
    for (final i in items)
      if (i.ingredient != null) i,
  ];
  List<AnalysisItem> get unknown => [
    for (final i in items)
      if (i.ingredient == null) i,
  ];
}

/// Matnni ajratadi va har bir nomni bazadan qidiradi. Xavfsizlik bahosi, foiz yoki "mos keladi"
/// kabi xulosa CHIQARILMAYDI: faqat bazada bor-yo'qligi.
AnalysisResult analyze(String raw, IngredientRepository repo) {
  final names = parseInci(raw);
  final found = <String>{}; // bir moddaning ikki nomi (Vitamin C va Ascorbic Acid) takror hisoblanmasin
  final items = <AnalysisItem>[];
  for (var i = 0; i < names.length; i++) {
    var ing = repo.find(names[i]);
    if (ing != null && !found.add(ing.slug)) continue;
    items.add(AnalysisItem(position: items.length + 1, name: names[i], ingredient: ing));
  }
  return AnalysisResult(items);
}
