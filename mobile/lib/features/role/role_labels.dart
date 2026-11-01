import '../../app/app_state.dart';
import '../../l10n/app_localizations.dart';

String roleLabel(AppLocalizations l, UserRole role) => switch (role) {
  UserRole.user => l.roleUser,
  UserRole.student => l.roleStudent,
  UserRole.cosmetologist => l.roleCosmetologist,
  UserRole.teacher => l.roleTeacher,
};
