import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
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
      ('scanner', l.tileScanner, Icons.qr_code_scanner_rounded, () => context.go('/scanner')),
      ('skin', l.tileSkin, Icons.face_retouching_natural_outlined, () => _soon(context)),
      ('routine', l.tileRoutine, Icons.event_available_outlined, () => _soon(context)),
      ('academy', l.tileAcademy, Icons.school_outlined, () => context.go('/academy')),
      ('ai', l.tileAi, Icons.auto_awesome_outlined, () => _soon(context)),
      ('journal', l.tileJournal, Icons.event_note_outlined, () => context.go('/journal')),
    ];
    const ingredients = ['Niacinamide', 'Retinol', 'Salicylic Acid', 'Hyaluronic Acid', 'Ascorbic Acid'];
    return KeyedSubtree(
      key: const Key('home-page'),
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(l.homeGreeting,
                  style: t.headlineSmall?.copyWith(fontFamily: t.titleMedium?.fontFamily, fontWeight: FontWeight.w700, color: const Color(0xFFC21E56))),
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
              onTap: () => _soon(context),
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
          PortraitBanner(key: const Key('home-banner'), title: l.homeBannerTitle, tag: l.homeBannerTag, minHeight: 150),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tiles.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 78 + 46 * scale,
            ),
            itemBuilder: (context, i) => _Tile(
              key: Key('tile-${tiles[i].$1}'),
              label: tiles[i].$2,
              icon: tiles[i].$3,
              onTap: tiles[i].$4,
            ),
          ),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(child: Text(l.popularIngredients, style: t.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w700))),
            TextButton(
              onPressed: () => _soon(context),
              child: Text(l.seeAll, style: t.titleMedium?.copyWith(color: SamiyaColors.rose, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 8),
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ingredients.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _IngredientCard(name: ingredients[i], onTap: () => _soon(context)),
            ),
          ),
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
      child: Material(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: SamiyaColors.border),
            ),
            child: ExcludeSemantics(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon, size: 32, color: const Color(0xFFC21E56)),
                const SizedBox(height: 10),
                Flexible(
                  child: Text(label,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w600, height: 1.25)),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _IngredientCard extends StatelessWidget {
  const _IngredientCard({required this.name, required this.onTap});
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: name,
      child: Material(
        borderRadius: BorderRadius.circular(24),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Ink(
            width: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFE3EC), Color(0xFFF7B6C9)],
              ),
              boxShadow: SamiyaShadows.soft,
            ),
            padding: const EdgeInsets.all(14),
            child: ExcludeSemantics(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), shape: BoxShape.circle),
                  child: const Icon(Icons.science_outlined, color: SamiyaColors.rose),
                ),
                const Spacer(),
                // INCI nomi har tilda lotin yozuvida qoladi; matn LTR.
                Text(name,
                    textDirection: TextDirection.ltr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 15, height: 1.2, color: SamiyaColors.heading)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
