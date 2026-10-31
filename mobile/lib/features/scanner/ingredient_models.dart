import 'dart:convert';

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

class Ingredient {
  const Ingredient({
    required this.inci,
    required this.slug,
    required this.status,
    this.category = 'active',
    required this.aliases,
    required this.euVerified,
    required this.summary,
    required this.claims,
  });
  final String inci;
  final String slug;
  final String status; // draft | verified
  final String category; // active | natural
  final List<String> aliases;
  final bool euVerified;
  final Map<String, String> summary;
  final List<Claim> claims;

  /// Tabiiy/o'simlik asosli ingredient (ilovada alohida bo'lim va "tabiiy = xavfsiz emas" izohi bilan).
  bool get isNatural => category == 'natural';

  String summaryFor(String lang) => _pick(summary, lang);

  factory Ingredient.fromJson(Map<String, dynamic> j) => Ingredient(
        inci: j['inci'] as String,
        slug: j['slug'] as String,
        status: j['status'] as String,
        category: j['category'] == 'natural' ? 'natural' : 'active',
        aliases: List<String>.from(j['aliases'] as List),
        euVerified: (j['eu'] as Map)['verified'] as bool,
        summary: Map<String, String>.from(j['summary'] as Map),
        claims: [for (final c in j['claims'] as List) Claim.fromJson(c as Map<String, dynamic>)],
      );
}

/// Ingredient bazasi. Moslashtirish FAQAT aniq INCI nomi yoki tasdiqlangan sinonim bo'yicha:
/// tuzlar, efirlar va hosilalar (masalan Sodium Hyaluronate, Retinyl Palmitate) taxmin bilan bog'lanmaydi.
class IngredientRepository {
  IngredientRepository(this.all)
      : _byKey = {
          for (final i in all) ...{
            inciKey(i.inci): i,
            for (final a in i.aliases) inciKey(a): i,
          }
        };

  final List<Ingredient> all;
  final Map<String, Ingredient> _byKey;

  factory IngredientRepository.fromJson(String source) {
    final data = jsonDecode(source) as Map<String, dynamic>;
    return IngredientRepository([
      for (final i in data['ingredients'] as List) Ingredient.fromJson(i as Map<String, dynamic>),
    ]);
  }

  Ingredient? find(String name) => _byKey[inciKey(name)];
  Ingredient? bySlug(String slug) => all.where((i) => i.slug == slug).firstOrNull;
}
