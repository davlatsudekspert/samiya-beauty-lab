// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'SAMIYA BEAUTY LAB';

  @override
  String get welcomeTagline => 'Красота, наука и забота — всегда с вами';

  @override
  String get start => 'Начать';

  @override
  String get campaignPill => '90 дней бесплатно · скоро';

  @override
  String get continueWithGoogle => 'Продолжить через Google';

  @override
  String get continueWithApple => 'Продолжить через Apple';

  @override
  String get continueAsGuest => 'Продолжить как гость';

  @override
  String get chooseLanguage => 'Язык';
}
