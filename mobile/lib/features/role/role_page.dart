import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';

class RolePage extends StatefulWidget {
  const RolePage({super.key});

  @override
  State<RolePage> createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
  UserRole? _selected;

  @override
  void initState() {
    super.initState();
    _selected = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selected ??= AppScope.of(context).role;
  }

  Future<void> _continue() async {
    final state = AppScope.of(context);
    await state.setRole(_selected!);
    await state.completeOnboarding();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final roles = <(UserRole, String, String, IconData)>[
      (UserRole.user, l.roleUser, l.roleUserDesc, Icons.favorite_border_rounded),
      (UserRole.student, l.roleStudent, l.roleStudentDesc, Icons.edit_outlined),
      (UserRole.cosmetologist, l.roleCosmetologist, l.roleCosmetologistDesc, Icons.spa_outlined),
      (UserRole.teacher, l.roleTeacher, l.roleTeacherDesc, Icons.menu_book_outlined),
    ];
    return Scaffold(
      key: const Key('role-page'),
      body: SamiyaBackground(
        child: SafeArea(
          child: Column(children: [
            PageHeader(onBack: () => context.canPop() ? context.pop() : context.go('/login')),
            Expanded(
              child: PageBody(
                bottom: GradientButton(
                  key: const Key('role-continue'),
                  label: l.goHome,
                  onPressed: _selected == null ? null : _continue,
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 12),
                  Text(l.roleTitle, style: t.headlineMedium),
                  const SizedBox(height: 8),
                  Text(l.roleSubtitle, style: t.bodyLarge),
                  const SizedBox(height: 20),
                  for (final r in roles) ...[
                    _RoleTile(
                      key: Key('role-${r.$1.name}'),
                      title: r.$2,
                      desc: r.$3,
                      icon: r.$4,
                      selected: _selected == r.$1,
                      onTap: () => setState(() => _selected = r.$1),
                    ),
                    const SizedBox(height: 12),
                  ],
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile(
      {super.key, required this.title, required this.desc, required this.icon, required this.selected, required this.onTap});
  final String title;
  final String desc;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SelectCardFrame(
      selected: selected,
      onTap: onTap,
      radius: 26,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: SamiyaColors.blush, borderRadius: BorderRadius.circular(18)),
            child: Icon(icon, color: SamiyaColors.rose, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(desc, style: t.bodyMedium),
            ]),
          ),
          const SizedBox(width: 8),
          Icon(selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? SamiyaColors.rose : SamiyaColors.roseSoft),
        ]),
      ),
    );
  }
}
