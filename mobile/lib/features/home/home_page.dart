import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../scanner/ingredient_models.dart';
import '../academy/lesson_models.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../ui/ingredient_palette.dart';
import '../../ui/safe_nav.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/portrait_banner.dart';

/// 11 Bosh sahifa. Tavsiya bloki hozircha faqat ingredient NOMLARI (da'vosiz);
/// tavsif va dalillar kontent bazasi tayyor bo'lgach ulanadi.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _soon(BuildContext context) {
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.comingSoon), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final tiles = <(String, String, IconData, VoidCallback)>[
      ('scanner', l.tileScanner, Icons.document_scanner_rounded, () => context.go('/scanner')),
      ('skin', l.tileSkin, Icons.face_retouching_natural_rounded, () => context.safePush('/home/skin')),
      ('routine', l.tileRoutine, Icons.spa_rounded, () => context.safePush('/home/routine')),
      ('academy', l.tileAcademy, Icons.school_rounded, () => context.go('/academy')),
      ('ai', l.tileAi, Icons.auto_awesome_rounded, () => context.safePush('/home/ai')),
      ('journal', l.tileJournal, Icons.edit_note_rounded, () => context.go('/journal')),
      ('recipes', l.tileRecipes, Icons.local_florist_outlined, () => context.safePush('/home/recipes')),
      ('rituals', l.tileRituals, Icons.self_improvement_rounded, () => context.safePush('/home/rituals')),
      ('shelf', l.tileShelf, Icons.inventory_2_outlined, () => context.safePush('/home/shelf')),
    ];
    final repo = AppScope.of(context).ingredients;
    final actives = repo.all.where((i) => !i.isNatural && !i.isPractice && !i.isCaution).take(8).toList();
    final natural = repo.all.where((i) => i.isNatural).take(8).toList();
    final practices = repo.all.where((i) => i.isPractice).take(8).toList();
    final lang = Localizations.localeOf(context).languageCode;
    return KeyedSubtree(
      key: const Key('home-page'),
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(l.homeGreeting,
                  style: t.headlineMedium?.copyWith(fontSize: 32, color: SamiyaColors.heading)),
            ),
            Semantics(
              button: true,
              label: l.comingSoon,
              child: Material(
                color: Colors.white.withValues(alpha: 0.85),
                shape: const CircleBorder(),
                child: InkWell(
                  key: const Key('home-bell'),
                  customBorder: const CircleBorder(),
                  onTap: () => _soon(context),
                  child: const SizedBox(width: 48, height: 48, child: Icon(Icons.notifications_none_rounded, color: SamiyaColors.rose)),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            elevation: 0,
            child: InkWell(
              key: const Key('home-search'),
              borderRadius: BorderRadius.circular(28),
              onTap: () => context.safePush('/scanner/ingredients'),
              child: Container(
                constraints: const BoxConstraints(minHeight: 54),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: SamiyaColors.border),
                ),
                child: Row(children: [
                  const Icon(Icons.search_rounded, color: SamiyaColors.muted),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l.searchHint, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.bodyMedium)),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 16),
          PortraitBanner(key: const Key('home-banner'), title: l.homeBannerTitle, tag: l.homeBannerTag, minHeight: 150, image: 'assets/photos/deco_rose.jpg'),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tiles.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 74 + 44 * scale,
            ),
            itemBuilder: (context, i) => _Tile(
              key: Key('tile-${tiles[i].$1}'),
              label: tiles[i].$2,
              icon: tiles[i].$3,
              onTap: tiles[i].$4,
            ),
          ),
          if (repo.lessons.isNotEmpty) ...[
            const SizedBox(height: 22),
            _DailyTip(repo: repo, lang: lang),
          ],
          const SizedBox(height: 24),
          Text(l.collectionsTitle, style: t.headlineSmall?.copyWith(fontSize: 24)),
          const SizedBox(height: 10),
          SizedBox(
            key: const Key('home-collections'),
            height: 190,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              _Collection(key: const Key('col-natural'), photo: 'assets/photos/honey.jpg', title: l.colNatural, body: l.colNaturalBody, onTap: () => context.safePush('/home/recipes')),
              _Collection(key: const Key('col-heat'), photo: 'assets/photos/deco_rose.jpg', title: l.colHeat, body: l.colHeatBody, onTap: () => context.safePush('/academy/lesson/spf')),
              _Collection(key: const Key('col-winter'), photo: 'assets/photos/oat.jpg', title: l.colWinter, body: l.colWinterBody, onTap: () => context.safePush('/academy/lesson/moist')),
            ]),
          ),
          if (natural.isNotEmpty) ...[
            const SizedBox(height: 26),
            Row(children: [
              Expanded(child: Text(l.naturalSectionTitle, style: t.headlineSmall?.copyWith(fontSize: 24))),
              TextButton(
                key: const Key('home-natural-all'),
                onPressed: () => context.safePush('/scanner/ingredients?filter=natural'),
                child: Text(l.seeAll, style: t.titleMedium?.copyWith(color: SamiyaColors.rose, fontWeight: FontWeight.w500)),
              ),
            ]),
            const SizedBox(height: 8),
            SizedBox(
              key: const Key('home-natural-section'),
              height: 176,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: natural.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) => _IngredientCard(
                  name: natural[i].nameFor(lang),
                  slug: natural[i].slug,
                  icon: Icons.spa_outlined,
                  latin: !natural[i].hasFriendlyName,
                  onTap: () => context.safePush('/scanner/ingredient/${natural[i].slug}'),
                ),
              ),
            ),
          ],
          const SizedBox(height: 22),
          Row(children: [
            Expanded(child: Text(l.popularIngredients, style: t.headlineSmall?.copyWith(fontSize: 24))),
            TextButton(
              key: const Key('home-see-all'),
              onPressed: () => context.safePush('/scanner/ingredients'),
              child: Text(l.seeAll, style: t.titleMedium?.copyWith(color: SamiyaColors.rose, fontWeight: FontWeight.w500)),
            ),
          ]),
          const SizedBox(height: 8),
          SizedBox(
            height: 176,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: actives.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _IngredientCard(
                name: actives[i].nameFor(lang),
                slug: actives[i].slug,
                icon: Icons.science_outlined,
                latin: !actives[i].hasFriendlyName,
                onTap: () => context.safePush('/scanner/ingredient/${actives[i].slug}'),
              ),
            ),
          ),
          if (repo.ibnSina != null) ...[
            const SizedBox(height: 26),
            Semantics(
              button: true,
              label: repo.ibnSina!.titleFor(lang),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                child: InkWell(
                  key: const Key('home-ibn-sina'),
                  borderRadius: BorderRadius.circular(26),
                  onTap: () => context.safePush('/scanner/ibn-sina'),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: SamiyaColors.gold.withValues(alpha: 0.6)),
                    ),
                    child: ExcludeSemantics(
                      child: Row(children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: SamiyaColors.gold),
                            gradient: const LinearGradient(colors: [Color(0xFFFBF6F2), Color(0xFFEBDCD3)]),
                          ),
                          child: const Icon(Icons.menu_book_rounded, color: SamiyaColors.heading),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(repo.ibnSina!.titleFor(lang), style: t.headlineSmall?.copyWith(fontSize: 21)),
                            const SizedBox(height: 4),
                            Text(l.ibnSinaCardBody, style: t.bodyMedium),
                          ]),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: SamiyaColors.gold),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (practices.isNotEmpty) ...[
            const SizedBox(height: 22),
            Row(children: [
              Expanded(child: Text(l.practiceSectionTitle, style: t.headlineSmall?.copyWith(fontSize: 24))),
              TextButton(
                key: const Key('home-practice-all'),
                onPressed: () => context.safePush('/scanner/ingredients?filter=practice'),
                child: Text(l.seeAll, style: t.titleMedium?.copyWith(color: SamiyaColors.rose, fontWeight: FontWeight.w500)),
              ),
            ]),
            const SizedBox(height: 8),
            SizedBox(
              key: const Key('home-practice-section'),
              height: 176,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: practices.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) => _IngredientCard(
                  name: practices[i].nameFor(lang),
                  slug: practices[i].slug,
                  icon: Icons.self_improvement_outlined,
                  latin: !practices[i].hasFriendlyName,
                  onTap: () => context.safePush('/scanner/ingredient/${practices[i].slug}'),
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({super.key, required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: ExcludeSemantics(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // Ikki rangli belgi: marvarid-atirgul gradient, ingichka oltin halqa va yengil yorug'lik.
            Container(
              width: 60,
              height: 60,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(colors: [
                  SamiyaColors.gold.withValues(alpha: 0.9),
                  const Color(0xFFE9D9C4),
                  SamiyaColors.gold.withValues(alpha: 0.6),
                  const Color(0xFFF4E9DC),
                  SamiyaColors.gold.withValues(alpha: 0.9),
                ]),
                boxShadow: SamiyaShadows.soft,
              ),
              child: Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFFBF8), Color(0xFFF0DFD9), Color(0xFFE2C6C4)],
                  ),
                ),
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (r) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF6B3D50), SamiyaColors.heading],
                  ).createShader(r),
                  child: Icon(icon, size: 27),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 12.5, fontWeight: FontWeight.w500, height: 1.25)),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Ravoq (arka) shaklidagi kartochka: Sharq me'morchiligi va lyuks atelye uslubi; ingichka oltin chiziq.
class _IngredientCard extends StatelessWidget {
  const _IngredientCard({required this.name, required this.slug, required this.onTap, this.latin = true, this.icon = Icons.science_outlined});
  final String name;
  final String slug;
  final IconData icon;

  /// Lotin INCI nomi bo'lsa matn chapdan o'ngga; tushunarli (mahalliy) nom bo'lsa til yo'nalishida.
  final bool latin;
  final VoidCallback onTap;

  static const _shape = BorderRadius.vertical(top: Radius.circular(70), bottom: Radius.circular(18));

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: name,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: _shape,
          onTap: onTap,
          child: Ink(
            width: 140,
            decoration: BoxDecoration(
              borderRadius: _shape,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color.lerp(Colors.white, ingredientTint(slug), 0.32)!, Colors.white, Colors.white],
                stops: const [0, 0.62, 1],
              ),
              border: Border.all(color: SamiyaColors.gold.withValues(alpha: 0.6)),
              boxShadow: SamiyaShadows.soft,
            ),
            padding: const EdgeInsetsDirectional.fromSTEB(14, 26, 14, 16),
            child: ExcludeSemantics(
              child: Column(children: [
                IngredientMonogram(slug: slug, name: name, size: 56),
                const Spacer(),
                Text(name,
                    textDirection: latin ? TextDirection.ltr : null,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: latin
                        ? const TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w500, fontSize: 14.5, height: 1.2, color: SamiyaColors.heading)
                        : t.headlineSmall?.copyWith(fontSize: 19, height: 1.15)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kun maslahati: Akademiya darslarining asosiy fikrlaridan, har kuni boshqasi.
class _DailyTip extends StatelessWidget {
  const _DailyTip({required this.repo, required this.lang});
  final IngredientRepository repo;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final all = [for (final les in repo.lessons) for (final k in les.keyPoints) (les, k)];
    final now = AppScope.of(context).personal.now();
    final day = DateTime.utc(now.year, now.month, now.day).difference(DateTime.utc(2026)).inDays;
    final (lesson, tip) = all[day.abs() % all.length];
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('home-tip'),
        borderRadius: BorderRadius.circular(22),
        onTap: () => context.safePush('/academy/lesson/${lesson.id}'),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF4E2738), SamiyaColors.heading]),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.auto_awesome, size: 16, color: Color(0xFFE9D3A8)),
              const SizedBox(width: 8),
              Text(l.tipTitle.toUpperCase(),
                  style: t.labelSmall?.copyWith(color: const Color(0xFFE9D3A8), letterSpacing: lang == 'ar' ? 0 : 1.8)),
            ]),
            const SizedBox(height: 10),
            Text(pickLoc(tip, lang), style: t.titleMedium?.copyWith(color: Colors.white, fontSize: 16.5, height: 1.45, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Text(pickLoc(lesson.title, lang), style: t.bodySmall?.copyWith(color: const Color(0xCCEAD7BF))),
          ]),
        ),
      ),
    );
  }
}

class _Collection extends StatelessWidget {
  const _Collection({super.key, required this.photo, required this.title, required this.body, required this.onTap});
  final String photo, title, body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 12),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(80), bottom: Radius.circular(20)),
          child: SizedBox(
            width: 160,
            child: Stack(fit: StackFit.expand, children: [
              Image.asset(photo, fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x003B1E2B), Color(0xDD3B1E2B)], stops: [0.35, 1]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.titleMedium?.copyWith(color: Colors.white, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(body, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.bodySmall?.copyWith(color: const Color(0xDDFFFFFF))),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
