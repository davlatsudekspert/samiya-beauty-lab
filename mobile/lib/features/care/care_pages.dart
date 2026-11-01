import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/arch_photo.dart';
import '../../ui/honest_note.dart';
import '../../ui/safe_nav.dart';
import '../../ui/widgets.dart';
import '../academy/lesson_models.dart';
import 'care_models.dart';

String _lang(BuildContext c) => Localizations.localeOf(c).languageCode;

Widget _page(BuildContext context, {required Key key, required String title, required String back, required List<Widget> children, Widget? bottom}) {
  return Scaffold(
    key: key,
    body: SamiyaBackground(
      child: SafeArea(
        child: Column(
          children: [
            PageHeader(title: title, onBack: () => context.canPop() ? context.pop() : context.go(back)),
            Expanded(
              child: ListView(padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 28), children: children),
            ),
            ?bottom,
          ],
        ),
      ),
    ),
  );
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 10),
    child: Text(text, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
  );
}

class _Bullets extends StatelessWidget {
  const _Bullets(this.items, {this.numbered = false, this.icon = Icons.circle, this.iconColor = SamiyaColors.gold});
  final List<String> items;
  final bool numbered;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 26,
                  child: numbered
                      ? Text(
                          '${i + 1}'.padLeft(2, '0'),
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                            fontFamily: 'CormorantGaramond',
                            fontWeight: FontWeight.w600,
                            fontSize: 19,
                            color: SamiyaColors.gold,
                            height: 1.2,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Icon(icon, size: icon == Icons.circle ? 6 : 16, color: iconColor),
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(items[i], style: t.bodyLarge?.copyWith(fontSize: 15.5, height: 1.55))),
              ],
            ),
          ),
      ],
    );
  }
}

class _CareTile extends StatelessWidget {
  const _CareTile({super.key, required this.photo, required this.title, required this.meta, required this.onTap});
  final String photo, title, meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x1A3B1E2B)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(40), bottom: Radius.circular(12)),
                  child: Image.asset(photo, width: 74, height: 88, fit: BoxFit.cover),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: t.titleMedium?.copyWith(fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(meta, style: t.bodySmall?.copyWith(color: SamiyaColors.muted)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: SamiyaColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Retseptlar ro'yxati.
class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final lang = _lang(context);
    final list = AppScope.of(context).ingredients.recipes;
    return _page(
      context,
      key: const Key('recipes-page'),
      title: l.recipesTitle,
      back: '/home',
      children: [
        const ArchPhoto('assets/photos/honey.jpg', height: 160),
        const SizedBox(height: 14),
        Text(l.recipesTitle, style: t.headlineMedium?.copyWith(fontSize: 30)),
        const SizedBox(height: 6),
        Text(l.recipesIntro, style: t.bodyMedium?.copyWith(fontSize: 14.5, height: 1.5)),
        const SizedBox(height: 14),
        HonestNote(l.naturalNote),
        const SizedBox(height: 14),
        for (var i = 0; i < list.length; i++)
          _CareTile(
            key: Key('recipe-$i'),
            photo: carePhoto(list[i].photo),
            title: pickLoc(list[i].title, lang),
            meta: l.lessonMinutes(list[i].minutes),
            onTap: () => context.safePush('/home/recipes/${list[i].id}'),
          ),
      ],
    );
  }
}

class RecipePage extends StatelessWidget {
  const RecipePage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final lang = _lang(context);
    final repo = AppScope.of(context).ingredients;
    final r = repo.recipes.where((x) => x.id == id).firstOrNull;
    if (r == null) return _page(context, key: const Key('recipe-page'), title: l.recipesTitle, back: '/home/recipes', children: [Text(l.comingSoon)]);
    final ings = [for (final s in r.ingredients) ?repo.bySlug(s)];
    return _page(
      context,
      key: const Key('recipe-page'),
      title: l.recipesTitle,
      back: '/home/recipes',
      children: [
        ArchPhoto(carePhoto(r.photo), height: 200),
        const SizedBox(height: 14),
        Text(
          l.lessonMinutes(r.minutes).toUpperCase(),
          style: t.labelSmall?.copyWith(color: SamiyaColors.gold, letterSpacing: lang == 'ar' ? 0 : 1.6),
        ),
        const SizedBox(height: 6),
        Text(pickLoc(r.title, lang), key: const Key('recipe-title'), style: t.headlineMedium?.copyWith(fontSize: 30)),
        const SizedBox(height: 8),
        Container(height: 1, width: 64, color: SamiyaColors.gold),
        const SizedBox(height: 12),
        Text(pickLoc(r.intro, lang), style: t.bodyLarge?.copyWith(fontSize: 16, height: 1.55)),
        _Heading(l.recipeYouNeed),
        _Bullets([for (final x in r.items) pickLoc(x, lang)]),
        _Heading(l.recipeSteps),
        _Bullets([for (final x in r.steps) pickLoc(x, lang)], numbered: true),
        _Heading(l.recipeSafety),
        Container(
          key: const Key('recipe-safety'),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
          decoration: BoxDecoration(color: SamiyaColors.blush, borderRadius: BorderRadius.circular(18)),
          child: _Bullets([for (final x in r.safety) pickLoc(x, lang)], icon: Icons.shield_outlined, iconColor: SamiyaColors.rose),
        ),
        _Heading(l.recipeEvidence),
        HonestNote(pickLoc(r.evidence, lang)),
        if (ings.isNotEmpty) ...[
          _Heading(l.recipeIngredients),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final i in ings) ActionChip(label: Text(i.nameFor(lang)), onPressed: () => context.safePush('/scanner/ingredient/${i.slug}'))],
          ),
        ],
      ],
    );
  }
}

/// Ritual-darslar ro'yxati.
class RitualsPage extends StatelessWidget {
  const RitualsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final lang = _lang(context);
    final list = AppScope.of(context).ingredients.rituals;
    return _page(
      context,
      key: const Key('rituals-page'),
      title: l.ritualsTitle,
      back: '/home',
      children: [
        const ArchPhoto('assets/photos/deco_lavender.jpg', height: 160),
        const SizedBox(height: 14),
        Text(l.ritualsTitle, style: t.headlineMedium?.copyWith(fontSize: 30)),
        const SizedBox(height: 6),
        Text(l.ritualsIntro, style: t.bodyMedium?.copyWith(fontSize: 14.5, height: 1.5)),
        const SizedBox(height: 16),
        for (var i = 0; i < list.length; i++)
          _CareTile(
            key: Key('ritual-$i'),
            photo: carePhoto(list[i].photo),
            title: pickLoc(list[i].title, lang),
            meta: l.lessonMinutes((list[i].totalSeconds / 60).ceil()),
            onTap: () => context.safePush('/home/rituals/${list[i].id}'),
          ),
      ],
    );
  }
}

/// Taymerli ritual: qadamlar avtomatik almashadi, to'xtatish/davom etish mumkin.
class RitualPage extends StatefulWidget {
  const RitualPage({super.key, required this.id});
  final String id;

  @override
  State<RitualPage> createState() => _RitualPageState();
}

class _RitualPageState extends State<RitualPage> {
  Timer? _timer;
  int _step = -1; // -1: boshlanmagan; steps.length: tugagan
  int _left = 0;
  bool _paused = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _go(Ritual r, int step) {
    _timer?.cancel();
    setState(() {
      _step = step;
      _paused = false;
      _left = step < r.steps.length ? r.steps[step].seconds : 0;
    });
    if (step >= r.steps.length) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _paused) return;
      if (_left <= 1) {
        _go(r, _step + 1);
      } else {
        setState(() => _left--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final lang = _lang(context);
    final r = AppScope.of(context).ingredients.rituals.where((x) => x.id == widget.id).firstOrNull;
    if (r == null) return _page(context, key: const Key('ritual-page'), title: l.ritualsTitle, back: '/home/rituals', children: [Text(l.comingSoon)]);
    final running = _step >= 0 && _step < r.steps.length;
    final done = _step >= r.steps.length;
    String mmss(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
    return _page(
      context,
      key: const Key('ritual-page'),
      title: l.ritualsTitle,
      back: '/home/rituals',
      children: [
        ArchPhoto(carePhoto(r.photo), height: 170),
        const SizedBox(height: 14),
        Text(pickLoc(r.title, lang), style: t.headlineMedium?.copyWith(fontSize: 30)),
        const SizedBox(height: 8),
        Text(pickLoc(r.intro, lang), style: t.bodyLarge?.copyWith(fontSize: 15.5, height: 1.55)),
        const SizedBox(height: 16),
        if (running)
          Container(
            key: const Key('ritual-now'),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: SamiyaColors.gold.withValues(alpha: 0.45)),
            ),
            child: Column(
              children: [
                Text(l.ritualStep(_step + 1, r.steps.length), style: t.labelMedium?.copyWith(color: SamiyaColors.gold)),
                const SizedBox(height: 6),
                Text(
                  mmss(_left),
                  key: const Key('ritual-time'),
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(fontFamily: 'CormorantGaramond', fontSize: 56, fontWeight: FontWeight.w600, color: SamiyaColors.heading),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(value: 1 - _left / r.steps[_step].seconds, minHeight: 3, backgroundColor: SamiyaColors.blush, color: SamiyaColors.gold),
                const SizedBox(height: 14),
                Text(pickLoc(r.steps[_step].title, lang), textAlign: TextAlign.center, style: t.titleLarge),
                const SizedBox(height: 8),
                Text(pickLoc(r.steps[_step].text, lang), textAlign: TextAlign.center, style: t.bodyLarge?.copyWith(fontSize: 15.5, height: 1.55)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        key: const Key('ritual-pause'),
                        onPressed: () => setState(() => _paused = !_paused),
                        child: Text(_paused ? l.ritualResume : l.ritualPause),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(key: const Key('ritual-next'), onPressed: () => _go(r, _step + 1), child: Text(l.ritualNext)),
                    ),
                  ],
                ),
              ],
            ),
          )
        else if (done)
          Container(
            key: const Key('ritual-done'),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: SamiyaColors.blush, borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: SamiyaColors.gold),
                const SizedBox(width: 12),
                Expanded(child: Text(l.ritualDone, style: t.titleMedium)),
              ],
            ),
          ),
        _Heading(l.recipeSteps),
        for (var i = 0; i < r.steps.length; i++)
          Opacity(
            opacity: running && i < _step ? 0.5 : 1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 54,
                    child: Text(
                      mmss(r.steps[i].seconds),
                      textDirection: TextDirection.ltr,
                      style: t.labelMedium?.copyWith(color: i == _step ? SamiyaColors.rose : SamiyaColors.gold),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pickLoc(r.steps[i].title, lang), style: t.titleMedium?.copyWith(fontSize: 15.5)),
                        Text(pickLoc(r.steps[i].text, lang), style: t.bodyMedium?.copyWith(height: 1.45)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        _Heading(l.recipeSafety),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
          decoration: BoxDecoration(color: SamiyaColors.blush, borderRadius: BorderRadius.circular(18)),
          child: _Bullets([for (final x in r.safety) pickLoc(x, lang)], icon: Icons.shield_outlined, iconColor: SamiyaColors.rose),
        ),
        _Heading(l.recipeEvidence),
        HonestNote(pickLoc(r.evidence, lang)),
      ],
      bottom: running
          ? null
          : Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 14),
              child: GradientButton(key: const Key('ritual-start'), label: l.ritualStart, trailing: Icons.play_arrow_rounded, onPressed: () => _go(r, 0)),
            ),
    );
  }
}
