import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'SAMIYA BEAUTY LAB'**
  String get appName;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Beauty, science and care — always with you'**
  String get welcomeTagline;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get start;

  /// No description provided for @campaignPill.
  ///
  /// In en, this message translates to:
  /// **'90 days free · coming soon'**
  String get campaignPill;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get chooseLanguage;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageTitle;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Beauty begins with science'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Body.
  ///
  /// In en, this message translates to:
  /// **'Understand ingredients and choose products with confidence.'**
  String get onboarding1Body;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Your personal care'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Body.
  ///
  /// In en, this message translates to:
  /// **'Build morning and evening routines that suit you.'**
  String get onboarding2Body;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Learn and grow'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Body.
  ///
  /// In en, this message translates to:
  /// **'The Academy, quizzes and the SAMIYA AI assistant in one app.'**
  String get onboarding3Body;

  /// No description provided for @loginBanner.
  ///
  /// In en, this message translates to:
  /// **'Beauty, science and care'**
  String get loginBanner;

  /// No description provided for @campaignNoCard.
  ///
  /// In en, this message translates to:
  /// **'90 days free · no card needed'**
  String get campaignNoCard;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcomeTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Continue your care and learning journey with SAMIYA.'**
  String get loginSubtitle;

  /// No description provided for @legalNotice.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to the Terms of Use and Privacy Policy.'**
  String get legalNotice;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @roleTitle.
  ///
  /// In en, this message translates to:
  /// **'Who are you?'**
  String get roleTitle;

  /// No description provided for @roleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We will show the learning and care sections that fit your role.'**
  String get roleSubtitle;

  /// No description provided for @roleUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get roleUser;

  /// No description provided for @roleUserDesc.
  ///
  /// In en, this message translates to:
  /// **'Personal care and ingredients'**
  String get roleUserDesc;

  /// No description provided for @roleStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get roleStudent;

  /// No description provided for @roleStudentDesc.
  ///
  /// In en, this message translates to:
  /// **'Academy and quizzes'**
  String get roleStudentDesc;

  /// No description provided for @roleCosmetologist.
  ///
  /// In en, this message translates to:
  /// **'Cosmetologist'**
  String get roleCosmetologist;

  /// No description provided for @roleCosmetologistDesc.
  ///
  /// In en, this message translates to:
  /// **'Professional reference'**
  String get roleCosmetologistDesc;

  /// No description provided for @roleTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get roleTeacher;

  /// No description provided for @roleTeacherDesc.
  ///
  /// In en, this message translates to:
  /// **'Learning materials and groups'**
  String get roleTeacherDesc;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go to home'**
  String get goHome;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get homeGreeting;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Product, ingredient or question...'**
  String get searchHint;

  /// No description provided for @homeBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Science-based care'**
  String get homeBannerTitle;

  /// No description provided for @homeBannerTag.
  ///
  /// In en, this message translates to:
  /// **'With evidence and sources'**
  String get homeBannerTag;

  /// No description provided for @tileScanner.
  ///
  /// In en, this message translates to:
  /// **'Ingredient scanner'**
  String get tileScanner;

  /// No description provided for @tileSkin.
  ///
  /// In en, this message translates to:
  /// **'Skin preferences'**
  String get tileSkin;

  /// No description provided for @tileRoutine.
  ///
  /// In en, this message translates to:
  /// **'Care routine'**
  String get tileRoutine;

  /// No description provided for @tileAcademy.
  ///
  /// In en, this message translates to:
  /// **'Cosmetology Academy'**
  String get tileAcademy;

  /// No description provided for @tileAi.
  ///
  /// In en, this message translates to:
  /// **'SAMIYA AI'**
  String get tileAi;

  /// No description provided for @tileJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get tileJournal;

  /// No description provided for @popularIngredients.
  ///
  /// In en, this message translates to:
  /// **'Popular ingredients'**
  String get popularIngredients;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAcademy.
  ///
  /// In en, this message translates to:
  /// **'Academy'**
  String get navAcademy;

  /// No description provided for @navScanner.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get navScanner;

  /// No description provided for @navJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get navJournal;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
