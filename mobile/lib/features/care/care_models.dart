import '../academy/lesson_models.dart';

Loc _l(Object? o) => Map<String, String>.from(o! as Map);
List<Loc> _ls(Object? o) => [for (final x in (o as List? ?? const [])) _l(x)];

/// Uyda tayyorlanadigan tabiiy retsept (xavfsizlik va dalil izohi bilan).
class Recipe {
  const Recipe({
    required this.id,
    required this.photo,
    required this.title,
    required this.intro,
    required this.items,
    required this.steps,
    required this.safety,
    required this.evidence,
    required this.ingredients,
    required this.minutes,
  });
  final String id;
  final String? photo;
  final Loc title, intro, evidence;
  final List<Loc> items, steps, safety;
  final List<String> ingredients;
  final int minutes;

  factory Recipe.fromJson(Map<String, dynamic> j) => Recipe(
    id: j['id'] as String,
    photo: j['photo'] as String?,
    title: _l(j['title']),
    intro: _l(j['intro']),
    items: _ls(j['items']),
    steps: _ls(j['steps']),
    safety: _ls(j['safety']),
    evidence: _l(j['evidence']),
    ingredients: List<String>.from(j['ingredients'] as List? ?? const []),
    minutes: (j['minutes'] as num?)?.toInt() ?? 10,
  );
}

class RitualStep {
  const RitualStep(this.seconds, this.title, this.text);
  final int seconds;
  final Loc title, text;
}

/// Taymerli parvarish rituali (yuz massaji, gua sha).
class Ritual {
  const Ritual({
    required this.id,
    required this.photo,
    required this.title,
    required this.intro,
    required this.steps,
    required this.safety,
    required this.evidence,
  });
  final String id;
  final String? photo;
  final Loc title, intro, evidence;
  final List<RitualStep> steps;
  final List<Loc> safety;

  int get totalSeconds => steps.fold(0, (a, s) => a + s.seconds);

  factory Ritual.fromJson(Map<String, dynamic> j) => Ritual(
    id: j['id'] as String,
    photo: j['photo'] as String?,
    title: _l(j['title']),
    intro: _l(j['intro']),
    steps: [for (final s in j['steps'] as List) RitualStep((s['seconds'] as num).toInt(), _l(s['title']), _l(s['text']))],
    safety: _ls(j['safety']),
    evidence: _l(j['evidence']),
  );
}

/// Rasm: ingredient slug yoki deco_* nomi -> asset yo'li.
String carePhoto(String? p) => p == null
    ? 'assets/tiles/rituals.jpg'
    : p.startsWith('tiles/')
        ? 'assets/$p.jpg'
        : 'assets/photos/$p.jpg';
