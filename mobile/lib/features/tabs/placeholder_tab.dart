import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';

/// Hali qurilmagan tab uchun halol joy egasi (haqiqiy ekran keyingi bosqichda).
class PlaceholderTab extends StatelessWidget {
  const PlaceholderTab({super.key, required this.pageKey, required this.title});
  final String pageKey;
  final String Function(AppLocalizations) title;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return KeyedSubtree(
      key: Key(pageKey),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title(l), textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 14),
              InfoPill(l.comingSoon),
            ],
          ),
        ),
      ),
    );
  }
}
