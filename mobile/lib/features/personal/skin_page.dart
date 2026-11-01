import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ui/arch_photo.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../data/personal_store.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';
import 'personal_widgets.dart';

String skinTypeLabel(AppLocalizations l, SkinType t) => switch (t) {
  SkinType.dry => l.skinDry,
  SkinType.oily => l.skinOily,
  SkinType.combination => l.skinCombination,
  SkinType.normal => l.skinNormal,
  SkinType.sensitive => l.skinSensitive,
};

/// Teri afzalliklari: o'zi belgilagan teri turi va "chetlab o'tish" ro'yxati (skanerda ogohlantirish uchun).
class SkinPage extends StatefulWidget {
  const SkinPage({super.key});
  @override
  State<SkinPage> createState() => _SkinPageState();
}

class _SkinPageState extends State<SkinPage> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _add(PersonalStore p) async {
    if (await p.addAvoid(_input.text)) _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final p = AppScope.of(context).personal;
    return Scaffold(
      key: const Key('skin-page'),
      body: SamiyaBackground(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: p,
            builder: (context, _) => Column(
              children: [
                PageHeader(title: l.tileSkin, onBack: () => context.canPop() ? context.pop() : context.go('/home')),
                Expanded(
                  child: PageBody(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const ArchPhoto('assets/tiles/skin.jpg', height: 180),
                        const SizedBox(height: 14),
                        SoftNote(key: const Key('skin-note'), icon: Icons.info_outline_rounded, text: l.skinNote),
                        const SizedBox(height: 18),
                        SectionTitle(l.skinTypeTitle),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final s in SkinType.values)
                              ChoiceChip(
                                key: Key('skin-type-${s.name}'),
                                label: Text(skinTypeLabel(l, s)),
                                selected: p.skinType == s,
                                onSelected: (on) => p.setSkinType(on ? s : null),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SectionTitle(l.avoidTitle),
                        const SizedBox(height: 10),
                        AddRow(
                          controller: _input,
                          hint: l.avoidHint,
                          label: l.avoidAdd,
                          onAdd: () => _add(p),
                          inputKey: const Key('avoid-input'),
                          buttonKey: const Key('avoid-add'),
                        ),
                        const SizedBox(height: 12),
                        if (p.avoid.isEmpty)
                          Text(l.avoidEmpty, style: t.bodyMedium)
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final a in p.avoid)
                                InputChip(
                                  key: Key('avoid-item-$a'),
                                  label: Text(a, textDirection: TextDirection.ltr),
                                  deleteIcon: const Icon(Icons.close_rounded, size: 18),
                                  deleteButtonTooltipMessage: l.removeAction,
                                  onDeleted: () => p.removeAvoid(a),
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: SamiyaColors.border),
                                ),
                            ],
                          ),
                        const SizedBox(height: 20),
                        Text(l.personalDataNote, style: t.bodyMedium?.copyWith(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
