/// Akademiya darsi (assets/content/ingredients.json -> "academy"). Matnlar 4 tilda.
typedef Loc = Map<String, String>;

String pickLoc(Loc m, String lang) => m[lang] ?? m['en'] ?? '';
Loc _loc(Object? o) => Map<String, String>.from(o! as Map);

class LessonSection {
  const LessonSection(this.heading, this.text);
  final Loc heading;
  final Loc text;
}

class QuizQuestion {
  const QuizQuestion(this.question, this.options, this.correct);
  final Loc question;
  final List<Loc> options;
  final int correct;
}

class LessonSource {
  const LessonSource({required this.title, this.publisher, this.year, this.url, this.pmid});
  final String title;
  final String? publisher;
  final int? year;
  final String? url;
  final String? pmid;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.status,
    required this.title,
    required this.summary,
    required this.sections,
    required this.keyPoints,
    required this.quiz,
    required this.sources,
  });
  final String id;
  final String status;
  final Loc title;
  final Loc summary;
  final List<LessonSection> sections;
  final List<Loc> keyPoints;
  final List<QuizQuestion> quiz;
  final List<LessonSource> sources;

  /// Taxminiy o'qish vaqti (daqiqa), ~180 so'z/daqiqa.
  int minutesFor(String lang) {
    final words = sections.fold<int>(0, (n, s) => n + pickLoc(s.text, lang).split(RegExp(r'\s+')).length);
    return (words / 180).ceil().clamp(1, 60);
  }

  factory Lesson.fromJson(Map<String, dynamic> j) => Lesson(
    id: j['id'] as String,
    status: (j['status'] as String?) ?? 'draft',
    title: _loc(j['title']),
    summary: _loc(j['summary']),
    sections: [for (final s in j['sections'] as List) LessonSection(_loc(s['heading']), _loc(s['text']))],
    keyPoints: [for (final k in j['keyPoints'] as List) _loc(k)],
    quiz: [
      for (final q in (j['quiz'] as List? ?? const [])) QuizQuestion(_loc(q['question']), [for (final o in q['options'] as List) _loc(o)], q['correct'] as int),
    ],
    sources: [
      for (final s in (j['sources'] as List? ?? const []))
        LessonSource(
          title: s['title'] as String,
          publisher: s['publisher'] as String?,
          year: s['year'] as int?,
          url: s['url'] as String?,
          pmid: s['pmid'] as String?,
        ),
    ],
  );
}
