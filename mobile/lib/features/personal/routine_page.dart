import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../data/personal_store.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';
import 'personal_widgets.dart';

/// Parvarish rejasi: ertalabki va kechki qadamlar, kunlik belgilash (faqat qurilmada).
class RoutinePage extends StatefulWidget {
  const RoutinePage({super.key});
  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  final _input = TextEditingController();
  String? _slotChoice;
  String _slotFor(PersonalStore p) => _slotChoice ?? (p.now().hour < 15 ? 'am' : 'pm');

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _add(PersonalStore p) async {
    if (await p.addStep(_slotFor(p), _input.text)) _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final p = AppScope.of(context).personal;
    return Scaffold(
      key: const Key('routine-page'),
      body: SamiyaBackground(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: p,
            builder: (context, _) {
              final slot = _slotFor(p);
              final steps = p.routine[slot]!;
              return Column(children: [
                PageHeader(title: l.tileRoutine, onBack: () => context.canPop() ? context.pop() : context.go('/home')),
                Expanded(
                  child: PageBody(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final (id, label, icon) in [
                          ('am', l.routineMorning, Icons.wb_sunny_outlined),
                          ('pm', l.routineEvening, Icons.nightlight_outlined),
                        ])
                          ChoiceChip(
                            key: Key('routine-tab-$id'),
                            avatar: Icon(icon, size: 18, color: slot == id ? Colors.white : SamiyaColors.heading),
                            label: Text(label),
                            selected: slot == id,
                            onSelected: (_) => setState(() => _slotChoice = id),
                          ),
                      ]),
                      const SizedBox(height: 14),
                      if (steps.isNotEmpty) ...[
                        Text(l.routineDoneToday(p.doneToday(slot), steps.length),
                            key: const Key('routine-progress'), style: t.titleMedium?.copyWith(color: SamiyaColors.heading)),
                        const SizedBox(height: 10),
                      ],
                      if (steps.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(l.routineEmpty, key: const Key('routine-empty'), style: t.bodyLarge),
                        )
                      else
                        for (var i = 0; i < steps.length; i++) ...[
                          _StepTile(index: i, step: steps[i], slot: slot, store: p, total: steps.length),
                          const SizedBox(height: 10),
                        ],
                      const SizedBox(height: 10),
                      AddRow(
                        controller: _input,
                        hint: l.routineStepHint,
                        label: l.avoidAdd,
                        onAdd: () => _add(p),
                        inputKey: const Key('routine-input'),
                        buttonKey: const Key('routine-add'),
                      ),
                      const SizedBox(height: 18),
                      Text(l.personalDataNote, style: t.bodyMedium?.copyWith(fontSize: 12)),
                    ]),
                  ),
                ),
              ]);
            },
          ),
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.index, required this.step, required this.slot, required this.store, required this.total});
  final int index;
  final RoutineStep step;
  final String slot;
  final PersonalStore store;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final done = store.isDoneToday(step.id);
    return Container(
      key: Key('step-${step.id}'),
      padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: done ? SamiyaColors.gold : SamiyaColors.border),
      ),
      child: Row(children: [
        IconButton(
          key: Key('step-done-${step.id}'),
          tooltip: step.name,
          onPressed: () => store.toggleDone(step.id),
          icon: Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: done ? SamiyaColors.gold : SamiyaColors.muted),
        ),
        Expanded(
          child: Text(step.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  decoration: done ? TextDecoration.lineThrough : null, color: done ? SamiyaColors.muted : SamiyaColors.ink)),
        ),
        PopupMenuButton<String>(
          key: Key('step-menu-${step.id}'),
          icon: const Icon(Icons.more_horiz_rounded),
          onSelected: (v) => switch (v) {
            'up' => store.moveStep(slot, index, -1),
            'down' => store.moveStep(slot, index, 1),
            _ => store.removeStep(slot, step.id),
          },
          itemBuilder: (_) => [
            if (index > 0) PopupMenuItem(value: 'up', child: Text(l.moveUp)),
            if (index < total - 1) PopupMenuItem(value: 'down', child: Text(l.moveDown)),
            PopupMenuItem(value: 'remove', child: Text(l.removeAction)),
          ],
        ),
      ]),
    );
  }
}
