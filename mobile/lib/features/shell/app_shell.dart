import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ui/bottom_nav.dart';
import '../../ui/widgets.dart';

/// Asosiy qobiq: pushti fon, tab tanasi va pastki navigatsiya.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SamiyaBackground(child: SafeArea(bottom: false, child: shell)),
      bottomNavigationBar: SamiyaBottomNav(
        index: shell.currentIndex,
        onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
      ),
    );
  }
}
