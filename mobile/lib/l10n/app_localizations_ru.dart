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

  @override
  String get languageTitle => 'Выберите язык';

  @override
  String get continueLabel => 'Продолжить';

  @override
  String get skip => 'Пропустить';

  @override
  String get onboarding1Title => 'Красота начинается с науки';

  @override
  String get onboarding1Body =>
      'Разбирайтесь в составе и осознанно выбирайте средства.';

  @override
  String get onboarding2Title => 'Личный уход';

  @override
  String get onboarding2Body =>
      'Составляйте удобные утренние и вечерние ритуалы.';

  @override
  String get onboarding3Title => 'Учитесь и развивайтесь';

  @override
  String get onboarding3Body =>
      'Академия, тесты и помощник SAMIYA AI в одном приложении.';

  @override
  String get loginBanner => 'Красота, наука и забота';

  @override
  String get campaignNoCard => '90 дней бесплатно · карта не нужна';

  @override
  String get welcomeTitle => 'Добро пожаловать!';

  @override
  String get loginSubtitle =>
      'Продолжайте путь ухода и знаний вместе с SAMIYA.';

  @override
  String get legalNotice =>
      'Продолжая, вы принимаете Условия использования и Политику конфиденциальности.';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get roleTitle => 'Кто вы?';

  @override
  String get roleSubtitle =>
      'Мы покажем разделы обучения и ухода, подходящие вашей роли.';

  @override
  String get roleUser => 'Пользователь';

  @override
  String get roleUserDesc => 'Личный уход и ингредиенты';

  @override
  String get roleStudent => 'Студент';

  @override
  String get roleStudentDesc => 'Академия и тесты';

  @override
  String get roleCosmetologist => 'Косметолог';

  @override
  String get roleCosmetologistDesc => 'Профессиональный справочник';

  @override
  String get roleTeacher => 'Преподаватель';

  @override
  String get roleTeacherDesc => 'Учебные материалы и группы';

  @override
  String get goHome => 'Перейти на главную';

  @override
  String get homeGreeting => 'Здравствуйте!';

  @override
  String get searchHint => 'Продукт, ингредиент или вопрос...';

  @override
  String get homeBannerTitle => 'Уход на основе науки';

  @override
  String get homeBannerTag => 'С доказательствами и источниками';

  @override
  String get tileScanner => 'Сканер состава';

  @override
  String get tileSkin => 'Предпочтения кожи';

  @override
  String get tileRoutine => 'План ухода';

  @override
  String get tileAcademy => 'Академия косметологии';

  @override
  String get tileAi => 'SAMIYA AI';

  @override
  String get tileJournal => 'Дневник';

  @override
  String get popularIngredients => 'Популярные ингредиенты';

  @override
  String get seeAll => 'Все';

  @override
  String get navHome => 'Главная';

  @override
  String get navAcademy => 'Академия';

  @override
  String get navScanner => 'Сканер';

  @override
  String get navJournal => 'Дневник';

  @override
  String get navProfile => 'Профиль';

  @override
  String get scannerHeroTitle => 'Проверка состава';

  @override
  String get scannerHeroBody =>
      'Введите состав продукта. Мы покажем информацию об ингредиентах с источниками.';

  @override
  String get scanCamera => 'Сканировать камерой';

  @override
  String get scanManual => 'Ввести вручную';

  @override
  String get manualTitle => 'Введите состав';

  @override
  String get manualHelp => 'Скопируйте список INCI с упаковки (латиницей).';

  @override
  String get manualHint => 'Например: Aqua, Glycerin, Niacinamide...';

  @override
  String foundCount(int n) {
    return 'Найдено ингредиентов: $n';
  }

  @override
  String get analyzeAction => 'Анализировать';

  @override
  String get resultTitle => 'Результат анализа';

  @override
  String get inDatabase => 'Есть в базе';

  @override
  String get notInDatabase => 'Пока нет в базе';

  @override
  String get resultNoneFound =>
      'В введённом списке нет ингредиентов из нашей базы. База постепенно расширяется.';

  @override
  String get resultNote =>
      'Это не медицинская рекомендация. Информация основана на опубликованных исследованиях и не показывает, подойдёт ли продукт вам.';

  @override
  String get detailClaims => 'Что показали исследования';

  @override
  String get detailSource => 'Источник';

  @override
  String get openSource => 'Открыть источник';

  @override
  String get draftNote => 'Черновик: перевод ещё не проверен.';

  @override
  String get euUnverified =>
      'Данные по законодательству ЕС и CosIng ещё не проверены.';

  @override
  String get evidenceLegendTitle => 'Уровни доказательности';

  @override
  String get evidenceA => 'A: систематический обзор или заключение регулятора';

  @override
  String get evidenceB => 'B: рандомизированное исследование на людях';

  @override
  String get evidenceC => 'C: ограниченные данные';

  @override
  String get evidenceInsufficient => 'Доказательств недостаточно';

  @override
  String get studyTypeSystematicReview => 'Систематический обзор';

  @override
  String get studyTypeMetaAnalysis => 'Метаанализ';

  @override
  String get studyTypeRct => 'Рандомизированное исследование';

  @override
  String get studyTypeObservational => 'Наблюдательное исследование';

  @override
  String get studyTypeInVitro => 'Лабораторное исследование';

  @override
  String get studyTypeRegulatory => 'Заключение регулятора';

  @override
  String get studyTypeNarrative => 'Нарративный обзор';

  @override
  String get authFailed => 'Не удалось войти. Попробуйте ещё раз.';

  @override
  String get authUnavailable => 'Вход пока недоступен.';

  @override
  String get guestName => 'Гость';

  @override
  String get actionSignIn => 'Войти';

  @override
  String get signOut => 'Выйти';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteConfirmTitle => 'Удалить аккаунт?';

  @override
  String get deleteConfirmBody =>
      'Ваш аккаунт и связанные с ним данные будут удалены безвозвратно. Это действие нельзя отменить.';

  @override
  String get cancel => 'Отмена';

  @override
  String get deleteAction => 'Удалить';

  @override
  String get deleteDone => 'Аккаунт удалён.';

  @override
  String get deleteNeedsRelogin =>
      'В целях безопасности войдите снова и повторите удаление.';

  @override
  String get actionFailed =>
      'Не удалось выполнить действие. Попробуйте ещё раз.';

  @override
  String get roleSection => 'Роль';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get termsOfUse => 'Условия использования';
}
