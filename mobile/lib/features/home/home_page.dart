import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';

/// Vaqtinchalik bosh sahifa: haqiqiy dizayn (11_home) keyingi bosqichda quriladi.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      key: const Key('home-page'),
      body: SamiyaBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('SAMIYA',
                    style: const TextStyle(
                        fontFamily: 'PlayfairDisplay', fontSize: 44, color: Color(0xFFC23A66), letterSpacing: 2)),
                const SizedBox(height: 12),
                Text(l.welcomeTagline,
                    textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 16),
                InfoPill(l.comingSoon),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
