import 'dart:convert';

import '../academy/lesson_models.dart';
import '../care/care_models.dart';
import 'inci_parser.dart';

/// PubMed manbasi (faqat tekshirilgan metadata).
class EvidenceSource {
  const EvidenceSource({required this.pmid, required this.title, required this.year, required this.url, this.doi});
  final String pmid;
  final String title;
  final int year;
  final String url;
  final String? doi;

  factory EvidenceSource.fromJson(Map<String, dynamic> j) => EvidenceSource(
        pmid: j['pmid'] as String,
        title: j['title'] as String,
        year: j['year'] as int,
        url: j['url'] as String,
        doi: j['doi'] as String?,
      );
}

String _pick(Map<String, String> m, String lang) => m[lang] ?? m['en'] ?? '';

/// Manbaga bog'langan bitta da'vo. `level`: A, B, C yoki insufficient.
class Claim {
  const Claim({required this.id, required this.level, required this.studyType, required this.text, required this.sources});
  final String id;
  final String level;
  final String studyType;
  final Map<String, String> text;
  final List<EvidenceSource> sources;

  String textFor(String lang) => _pick(text, lang);

  factory Claim.fromJson(Map<String, dynamic> j) => Claim(
        id: j['id'] as String,
        level: j['level'] as String,
        studyType: j['studyType'] as String,
        text: Map<String, String>.from(j['text'] as Map),
        sources: [for (final s in j['sources'] as List) EvidenceSource.fromJson(s as Map<String, dynamic>)],
      );
}

/// An'anaviy/tarixiy manbadagi qo'llanish (ilmiy dalil EMAS): matn 4 tilda, PubMed'dagi tarixiy sharhlarga tayanadi.
class TraditionalNote {
  const TraditionalNote({required this.id, this.tradition, required this.text, required this.sources});
  final String id;
  final String? tradition;
  final Map<String, String> text;
  final List<EvidenceSource> sources;

  String textFor(String lang) => _pick(text, lang);

  /// Ibn Sinoning "Tib qonunlari"ga tayanadimi (Ibn Sino sahifasiga havola uchun).
  bool get citesCanon => (tradition ?? '').contains('Canon');

  factory TraditionalNote.fromJson(Map<String, dynamic> j) => TraditionalNote(
        id: j['id'] as String,
        tradition: j['tradition'] as String?,
        text: Map<String, String>.from(j['text'] as Map),
        sources: [for (final s in j['sources'] as List) EvidenceSource.fromJson(s as Map<String, dynamic>)],
      );
}

/// Ibn Sino haqida kirish (tarixiy ma'lumot, manbali).
class TraditionIntro {
  const TraditionIntro({required this.title, required this.items});
  final Map<String, String> title;
  final List<TraditionalNote> items;
  String titleFor(String lang) => _pick(title, lang);

  factory TraditionIntro.fromJson(Map<String, dynamic> j) => TraditionIntro(
        title: Map<String, String>.from(j['title'] as Map),
        items: [for (final i in j['items'] as List) TraditionalNote.fromJson(i as Map<String, dynamic>)],
      );
}

class Ingredient {
  const Ingredient({
    required this.inci,
    required this.slug,
    required this.status,
    this.category = 'active',
    this.names = const {},
    this.traditional = const [],
    required this.aliases,
    required this.euVerified,
    required this.summary,
    required this.claims,
  });
  final String inci;
  final String slug;
  final String status; // draft | verified
  final String category; // active | natural | practice | caution
  final List<TraditionalNote> traditional;
  final Map<String, String> names; // tilga mos tushunarli nom (uz/ru/en/ar); bo'sh bo'lsa INCI
  final List<String> aliases;
  final bool euVerified;
  final Map<String, String> summary;
  final List<Claim> claims;

  /// Tabiiy/o'simlik asosli ingredient (ilovada alohida bo'lim va "tabiiy = xavfsiz emas" izohi bilan).
  bool get isNatural => category == 'natural';

  /// Parvarish usuli (masalan yuz massaji): ingredient emas, tarkib ro'yxatiga moslanmaydi.
  bool get isPractice => category == 'practice';

  /// Uy vositasi haqida ogohlantirish kartochkasi (zarar hodisalari qayd etilgan).
  bool get isCaution => category == 'caution';

  /// Tushunarli nom (foydalanuvchi tilida); berilmagan bo'lsa INCI nomi.
  String nameFor(String lang) => names[lang] ?? names['en'] ?? inci;

  bool get hasFriendlyName => names.isNotEmpty;

  String summaryFor(String lang) => _pick(summary, lang);

  factory Ingredient.fromJson(Map<String, dynamic> j) => Ingredient(
        inci: j['inci'] as String,
        slug: j['slug'] as String,
        status: j['status'] as String,
        category: const {'natural', 'practice', 'caution'}.contains(j['category']) ? j['category'] as String : 'active',
        names: j['names'] is Map ? Map<String, String>.from(j['names'] as Map) : const {},
        traditional: [
          for (final n in (j['traditional'] as List?) ?? const []) TraditionalNote.fromJson(n as Map<String, dynamic>),
        ],
        aliases: List<String>.from(j['aliases'] as List),
        euVerified: (j['eu'] as Map)['verified'] as bool,
        summary: Map<String, String>.from(j['summary'] as Map),
        claims: [for (final c in j['claims'] as List) Claim.fromJson(c as Map<String, dynamic>)],
      );
}

/// Ingredient bazasi. Moslashtirish FAQAT aniq INCI nomi yoki tasdiqlangan sinonim bo'yicha:
/// tuzlar, efirlar va hosilalar (masalan Sodium Hyaluronate, Retinyl Palmitate) taxmin bilan bog'lanmaydi.
class IngredientRepository {
  IngredientRepository(this.all, {this.ibnSina, this.lessons = const [], this.recipes = const [], this.rituals = const []})
      : _byKey = {
          for (final i in all.where((i) => !i.isPractice)) ...{
            inciKey(i.inci): i,
            for (final a in i.aliases) inciKey(a): i,
          }
        };

  final List<Ingredient> all;
  final TraditionIntro? ibnSina;
  final List<Lesson> lessons;
  final List<Recipe> recipes;
  final List<Ritual> rituals;
  final Map<String, Ingredient> _byKey;

  factory IngredientRepository.fromJson(String source) {
    final data = jsonDecode(source) as Map<String, dynamic>;
    return IngredientRepository(
      [for (final i in data['ingredients'] as List) Ingredient.fromJson(i as Map<String, dynamic>)],
      ibnSina: data['ibnSina'] is Map ? TraditionIntro.fromJson(data['ibnSina'] as Map<String, dynamic>) : null,
      lessons: [for (final l in (data['academy'] as List? ?? const [])) Lesson.fromJson(l as Map<String, dynamic>)],
      recipes: [for (final r in (data['recipes'] as List? ?? const [])) Recipe.fromJson(r as Map<String, dynamic>)],
      rituals: [for (final r in (data['rituals'] as List? ?? const [])) Ritual.fromJson(r as Map<String, dynamic>)],
    );
  }

  Ingredient? find(String name) => _byKey[inciKey(name)];
  Ingredient? bySlug(String slug) => all.where((i) => i.slug == slug).firstOrNull;
  /// AI uchun kontekst: savolda tilga olingan ingredientlar (INCI, sinonim yoki 4 tildagi nomi) xulosasi va da'volari (inglizcha).
  String aiContextFor(String question, {int maxChars = 5500}) {
    final q = question.toLowerCase();
    final buf = StringBuffer();
    for (final i in all) {
      final keys = {i.inci, ...i.aliases, ...i.names.values, i.slug.replaceAll('-', ' ')}.map((k) => k.toLowerCase().trim()).where((k) => k.length >= 3);
      if (!keys.any(q.contains)) continue;
      final part = StringBuffer('## ${i.inci}${i.names['en'] != null ? ' (${i.names['en']})' : ''}\n${i.summary['en'] ?? ''}\n');
      for (final c in i.claims) {
        part.write('- [${c.level}] ${c.text['en'] ?? ''}${c.sources.isEmpty ? '' : ' (PMID ${c.sources.map((s) => s.pmid).join(', ')})'}\n');
      }
      if (buf.length + part.length > maxChars) break;
      buf.write(part);
    }
    return buf.toString();
  }

  Lesson? lesson(String id) => lessons.where((l) => l.id == id).firstOrNull;
}
