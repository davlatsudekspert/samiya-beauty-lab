import 'package:flutter/material.dart';
import '../../ui/safe_nav.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';
import 'inci_parser.dart';

/// 19 Tarkibni tasdiqlash/kiritish: foydalanuvchi matnni o'zi ko'radi va tuzatadi (OCR ham shu yerga keladi).
class ManualInputPage extends StatefulWidget {
  const ManualInputPage({super.key});

  @override
  State<ManualInputPage> createState() => _ManualInputPageState();
}

class _ManualInputPageState extends State<ManualInputPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final count = parseInci(_controller.text).length;
    return KeyedSubtree(
      key: const Key('manual-page'),
      child: Column(children: [
        PageHeader(title: l.manualTitle, onBack: () => context.canPop() ? context.pop() : context.go('/scanner')),
        Expanded(
          child: PageBody(
            bottom: GradientButton(
              key: const Key('manual-analyze'),
              label: l.analyzeAction,
              trailing: Icons.arrow_forward_rounded,
              onPressed: count == 0 ? null : () => context.safePush('/scanner/result', extra: _controller.text),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 8),
              Text(l.manualHelp, style: t.bodyLarge),
              const SizedBox(height: 16),
              TextField(
                key: const Key('manual-input'),
                controller: _controller,
                onChanged: (_) => setState(() {}),
                minLines: 6,
                maxLines: 12,
                maxLength: maxInciChars,
                textDirection: TextDirection.ltr, // INCI lotin yozuvida
                keyboardType: TextInputType.multiline,
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                decoration: InputDecoration(
                  hintText: l.manualHint,
                  hintTextDirection: TextDirection.ltr,
                  hintStyle: t.bodyLarge,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: SamiyaColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: SamiyaColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: SamiyaColors.rose, width: 1.6)),
                ),
              ),
              const SizedBox(height: 14),
              Center(child: KeyedSubtree(key: const Key('manual-count'), child: InfoPill(l.foundCount(count), upper: false))),
            ]),
          ),
        ),
      ]),
    );
  }
}
