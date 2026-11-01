import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../app/links.dart';
import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/arch_photo.dart';
import '../../ui/honest_note.dart';
import '../../ui/widgets.dart';
import 'lesson_models.dart';

/// Har bir dars uchun nafis sarlavha rasmi (CC0, assets/photos).
const lessonPhotos = {
  'skin': 'assets/photos/deco_peony.jpg',
  'inci': 'assets/photos/chamomile.jpg',
  'spf': 'assets/photos/deco_rose.jpg',
  'moist': 'assets/photos/aloe-vera.jpg',
  'hygiene': 'assets/photos/deco_lavender.jpg',
  'safety': 'assets/photos/deco_jasmine.jpg',
};

class LessonPage extends StatelessWidget {
  const LessonPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final lessons = AppScope.of(context).ingredients.lessons;
    final idx = lessons.indexWhere((x) => x.id == id);
    final lesson = idx < 0 ? null : lessons[idx];
    void back() => context.canPop() ? context.pop() : context.go('/academy');
    return Scaffold(
      key: const Key('lesson-page'),
      body: SamiyaBackground(
        child: SafeArea(
          child: Column(
            children: [
              PageHeader(title: l.navAcademy, onBack: back),
              Expanded(
                child: lesson == null
                    ? Center(child: Text(l.comingSoon))
                    : ListView(
                        padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 32),
                        children: [
                          ArchPhoto(lessonPhotos[id] ?? 'assets/photos/deco_peony.jpg', height: 170),
                          const SizedBox(height: 16),
                          Text(
                            '${(idx + 1).toString().padLeft(2, '0')}  ·  ${l.lessonMinutes(lesson.minutesFor(lang))}',
                            style: t.labelSmall?.copyWith(color: SamiyaColors.gold, letterSpacing: lang == 'ar' ? 0 : 1.6),
                          ),
                          const SizedBox(height: 6),
                          Text(pickLoc(lesson.title, lang), key: const Key('lesson-title'), style: t.headlineMedium?.copyWith(fontSize: 30)),
                          const SizedBox(height: 8),
                          Container(height: 1, width: 64, color: SamiyaColors.gold),
                          const SizedBox(height: 14),
                          Text(pickLoc(lesson.summary, lang), style: t.bodyLarge?.copyWith(fontSize: 16, height: 1.55)),
                          const SizedBox(height: 16),
                          HonestNote(l.lessonDraftNote),
                          const SizedBox(height: 8),
                          for (var i = 0; i < lesson.sections.length; i++) _Section(n: i + 1, s: lesson.sections[i], lang: lang),
                          const SizedBox(height: 18),
                          _KeyPoints(points: lesson.keyPoints, lang: lang),
                          if (lesson.quiz.isNotEmpty) ...[
                            const SizedBox(height: 26),
                            Text(l.lessonQuiz, style: t.headlineSmall),
                            const SizedBox(height: 12),
                            QuizBlock(questions: lesson.quiz, lang: lang),
                          ],
                          if (lesson.sources.isNotEmpty) ...[
                            const SizedBox(height: 26),
                            Text(
                              l.lessonSources.toUpperCase(),
                              style: t.labelSmall?.copyWith(color: SamiyaColors.muted, letterSpacing: lang == 'ar' ? 0 : 1.6),
                            ),
                            const SizedBox(height: 8),
                            for (final s in lesson.sources) _SourceRow(s: s),
                          ],
                          if (idx + 1 < lessons.length) ...[
                            const SizedBox(height: 26),
                            OutlinedButton(
                              key: const Key('lesson-next'),
                              onPressed: () => context.pushReplacement('/academy/lesson/${lessons[idx + 1].id}'),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(child: Text(pickLoc(lessons[idx + 1].title, lang), overflow: TextOverflow.ellipsis)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, size: 18),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.n, required this.s, required this.lang});
  final int n;
  final LessonSection s;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                n.toString().padLeft(2, '0'),
                textDirection: TextDirection.ltr,
                style: const TextStyle(fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w600, fontSize: 22, color: SamiyaColors.gold, height: 1.1),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(pickLoc(s.heading, lang), style: t.titleLarge?.copyWith(fontSize: 19))),
            ],
          ),
          const SizedBox(height: 8),
          Text(pickLoc(s.text, lang), style: t.bodyLarge?.copyWith(fontSize: 15.5, height: 1.6)),
        ],
      ),
    );
  }
}

class _KeyPoints extends StatelessWidget {
  const _KeyPoints({required this.points, required this.lang});
  final List<Loc> points;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Container(
      key: const Key('lesson-key-points'),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      decoration: BoxDecoration(
        color: SamiyaColors.blush,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SamiyaColors.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.lessonKeyPoints, style: t.titleLarge?.copyWith(fontSize: 19)),
          const SizedBox(height: 10),
          for (final p in points)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(Icons.auto_awesome, size: 14, color: SamiyaColors.gold),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(pickLoc(p, lang), style: t.bodyMedium?.copyWith(fontSize: 15, height: 1.5))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({required this.s});
  final LessonSource s;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final meta = [if (s.publisher != null) s.publisher!, if (s.year != null) '${s.year}', if (s.pmid != null) 'PMID ${s.pmid}'].join(' · ');
    return InkWell(
      onTap: s.url == null ? null : () => openExternalUrl(Uri.parse(s.url!)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.menu_book_outlined, size: 16, color: SamiyaColors.rose),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.title, textDirection: TextDirection.ltr, style: t.bodyMedium?.copyWith(fontSize: 13.5)),
                  if (meta.isNotEmpty)
                    Text(
                      meta,
                      textDirection: TextDirection.ltr,
                      style: t.bodySmall?.copyWith(color: SamiyaColors.muted),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Uch savollik test: javob tanlanganda to'g'ri/xato ko'rsatiladi, oxirida natija.
class QuizBlock extends StatefulWidget {
  const QuizBlock({super.key, required this.questions, required this.lang});
  final List<QuizQuestion> questions;
  final String lang;

  @override
  State<QuizBlock> createState() => _QuizBlockState();
}

class _QuizBlockState extends State<QuizBlock> {
  late List<int?> picked = List.filled(widget.questions.length, null);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final done = picked.every((p) => p != null);
    final score = [
      for (var i = 0; i < picked.length; i++)
        if (picked[i] == widget.questions[i].correct) 1,
    ].length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var qi = 0; qi < widget.questions.length; qi++) ...[
          Container(
            key: Key('quiz-q-$qi'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0x1A3B1E2B)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(pickLoc(widget.questions[qi].question, widget.lang), style: t.titleMedium?.copyWith(fontSize: 15.5)),
                const SizedBox(height: 10),
                for (var oi = 0; oi < widget.questions[qi].options.length; oi++)
                  _Option(
                    key: Key('quiz-$qi-$oi'),
                    text: pickLoc(widget.questions[qi].options[oi], widget.lang),
                    state: picked[qi] == null
                        ? 0
                        : oi == widget.questions[qi].correct
                        ? 1
                        : oi == picked[qi]
                        ? 2
                        : 0,
                    onTap: picked[qi] == null ? () => setState(() => picked[qi] = oi) : null,
                  ),
                if (picked[qi] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      picked[qi] == widget.questions[qi].correct ? l.quizRight : l.quizWrong,
                      style: t.bodySmall?.copyWith(color: picked[qi] == widget.questions[qi].correct ? const Color(0xFF4E7A5A) : SamiyaColors.rose),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (done)
          Row(
            children: [
              Expanded(
                child: Text(
                  l.quizScore(score, widget.questions.length),
                  key: const Key('quiz-score'),
                  style: t.titleLarge?.copyWith(color: SamiyaColors.gold),
                ),
              ),
              TextButton(onPressed: () => setState(() => picked = List.filled(widget.questions.length, null)), child: Text(l.quizRetry)),
            ],
          ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({super.key, required this.text, required this.state, this.onTap});
  final String text;
  final int state; // 0 neytral, 1 to'g'ri, 2 xato tanlov
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = state == 1
        ? const Color(0xFF4E7A5A)
        : state == 2
        ? SamiyaColors.rose
        : const Color(0x333B1E2B);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: state == 1
                ? const Color(0x144E7A5A)
                : state == 2
                ? const Color(0x148E4A5E)
                : SamiyaColors.ivory,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c),
          ),
          child: Row(
            children: [
              Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.5))),
              if (state == 1) const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF4E7A5A)),
              if (state == 2) const Icon(Icons.cancel_rounded, size: 18, color: SamiyaColors.rose),
            ],
          ),
        ),
      ),
    );
  }
}
