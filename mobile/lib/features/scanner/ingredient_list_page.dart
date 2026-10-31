import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/safe_nav.dart';
import '../../ui/widgets.dart';
import 'ingredient_models.dart';

/// Ingredientlar bazasini ko'rish va nom bo'yicha qidirish (faqat ko'rish; moslashtirish qoidalariga aloqasi yo'q).
class IngredientListPage extends StatefulWidget {
  const IngredientListPage({super.key});

  @override
  State<IngredientListPage> createState() => _IngredientListPageState();
}

class _IngredientListPageState extends State<IngredientListPage> {
  String _query = '';

  bool _matches(Ingredient i, String q) {
    if (q.isEmpty) return true;
    final needle = q.trim().toLowerCase();
    return i.inci.toLowerCase().contains(needle) || i.aliases.any((a) => a.toLowerCase().contains(needle));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final items = AppScope.of(context).ingredients.all.where((i) => _matches(i, _query)).toList();
    return Scaffold(
      key: const Key('ingredients-page'),
      body: SamiyaBackground(
        child: SafeArea(
          child: Column(children: [
            PageHeader(title: l.ingredientsTitle, onBack: () => context.canPop() ? context.pop() : context.go('/scanner')),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 8),
              child: TextField(
                key: const Key('ingredient-search'),
                textDirection: TextDirection.ltr,
                autocorrect: false,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: l.ingredientsSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded, color: SamiyaColors.muted),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: SamiyaColors.border)),
                ),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(l.ingredientsNoMatch, key: const Key('ingredient-search-empty'), textAlign: TextAlign.center, style: t.bodyLarge),
                    )
                  : ListView.separated(
                      padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 16),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final ing = items[i];
                        return Semantics(
                          button: true,
                          label: ing.inci,
                          child: Material(
                            key: Key('ingredient-item-${ing.slug}'),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: () => context.safePush('/scanner/ingredient/${ing.slug}'),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: SamiyaColors.border)),
                                child: ExcludeSemantics(
                                  child: Row(children: [
                                    Expanded(
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(ing.inci,
                                            textDirection: TextDirection.ltr,
                                            style: t.titleMedium?.copyWith(fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w700, color: SamiyaColors.heading)),
                                        const SizedBox(height: 4),
                                        Text(ing.summaryFor(lang), maxLines: 2, overflow: TextOverflow.ellipsis, style: t.bodyMedium),
                                      ]),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.chevron_right_rounded, color: SamiyaColors.rose),
                                  ]),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ]),
        ),
      ),
    );
  }
}
