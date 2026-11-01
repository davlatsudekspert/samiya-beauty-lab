import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../data/personal_store.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/arch_photo.dart';
import '../../ui/empty_state.dart';
import '../../ui/widgets.dart';

/// "Mening kosmetikam": ochilgan mahsulotlar va PAO bo'yicha muddat (faqat telefonda saqlanadi).
class ShelfPage extends StatelessWidget {
  const ShelfPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final store = AppScope.of(context).personal;
    return Scaffold(
      key: const Key('shelf-page'),
      body: SamiyaBackground(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: store,
            builder: (context, _) {
              final items = store.shelfSorted;
              final now = store.now();
              return Column(
                children: [
                  PageHeader(title: l.shelfTitle, onBack: () => context.canPop() ? context.pop() : context.go('/home')),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 24),
                      children: [
                        const ArchPhoto('assets/photos/deco_rose.jpg', height: 150),
                        const SizedBox(height: 14),
                        Text(l.shelfTitle, style: t.headlineMedium?.copyWith(fontSize: 30)),
                        const SizedBox(height: 6),
                        Text(l.shelfIntro, style: t.bodyMedium?.copyWith(fontSize: 14.5, height: 1.5)),
                        const SizedBox(height: 16),
                        if (items.isEmpty)
                          ElegantEmpty(title: l.shelfEmptyTitle, body: l.shelfEmptyBody)
                        else
                          for (final i in items) _Row(item: i, now: now, onDelete: () => store.removeShelf(i.id)),
                        const SizedBox(height: 12),
                        GradientButton(key: const Key('shelf-add'), label: l.shelfAdd, trailing: Icons.add_rounded, onPressed: () => _add(context)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _add(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SamiyaColors.ivory,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => const _AddSheet(),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item, required this.now, required this.onDelete});
  final ShelfItem item;
  final DateTime now;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final left = item.daysLeft(now);
    final (label, color) = left < 0
        ? (l.shelfExpired, SamiyaColors.rose)
        : left < 30
        ? (l.shelfDaysLeft(left), const Color(0xFF8C6A3A))
        : (l.shelfOk, const Color(0xFF4E7A5A));
    final total = item.expiresOn.difference(item.openedOn).inDays.clamp(1, 100000);
    final progress = (1 - left / total).clamp(0.0, 1.0);
    String d(DateTime x) => '${x.day.toString().padLeft(2, '0')}.${x.month.toString().padLeft(2, '0')}.${x.year}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 6, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x1A3B1E2B)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: t.titleMedium?.copyWith(fontSize: 15.5)),
                const SizedBox(height: 4),
                Text(
                  '${d(item.openedOn)} → ${d(item.expiresOn)} · ${l.shelfMonths(item.paoMonths)}',
                  textDirection: TextDirection.ltr,
                  style: t.bodySmall?.copyWith(color: SamiyaColors.muted),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: SamiyaColors.blush, color: color),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: t.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, color: SamiyaColors.muted),
          ),
        ],
      ),
    );
  }
}

class _AddSheet extends StatefulWidget {
  const _AddSheet();

  @override
  State<_AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<_AddSheet> {
  final _name = TextEditingController();
  int _pao = 12;
  DateTime? _opened;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final store = AppScope.of(context).personal;
    final opened = _opened ?? store.now();
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.shelfAdd, style: t.headlineSmall),
            const SizedBox(height: 14),
            TextField(
              key: const Key('shelf-name'),
              controller: _name,
              maxLength: 80,
              decoration: InputDecoration(labelText: l.shelfName, counterText: ''),
            ),
            const SizedBox(height: 14),
            Text(l.shelfPao, style: t.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in const [3, 6, 12, 18, 24, 36])
                  ChoiceChip(key: Key('shelf-pao-$m'), label: Text(l.shelfMonths(m)), selected: _pao == m, onSelected: (_) => setState(() => _pao = m)),
              ],
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              key: const Key('shelf-date'),
              icon: const Icon(Icons.event_outlined, size: 18),
              label: Text('${l.shelfOpened}: ${opened.day.toString().padLeft(2, '0')}.${opened.month.toString().padLeft(2, '0')}.${opened.year}'),
              onPressed: () async {
                final now = store.now();
                final p = await showDatePicker(context: context, initialDate: opened, firstDate: DateTime(now.year - 5), lastDate: now);
                if (p != null) setState(() => _opened = p);
              },
            ),
            const SizedBox(height: 16),
            GradientButton(
              key: const Key('shelf-save'),
              label: l.shelfSave,
              onPressed: () async {
                final ok = await store.addShelf(_name.text, openedOn: opened, paoMonths: _pao);
                if (ok && context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
