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

  /// No description provided for @scannerHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Check the ingredients'**
  String get scannerHeroTitle;

  /// No description provided for @scannerHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Enter a product\'s ingredient list. We show sourced information about each ingredient.'**
  String get scannerHeroBody;

  /// No description provided for @scanCamera.
  ///
  /// In en, this message translates to:
  /// **'Scan with camera'**
  String get scanCamera;

  /// No description provided for @scanManual.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get scanManual;

  /// No description provided for @manualTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter ingredients'**
  String get manualTitle;

  /// No description provided for @manualHelp.
  ///
  /// In en, this message translates to:
  /// **'Copy the INCI list from the packaging (Latin letters).'**
  String get manualHelp;

  /// No description provided for @manualHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Aqua, Glycerin, Niacinamide...'**
  String get manualHint;

  /// No description provided for @foundCount.
  ///
  /// In en, this message translates to:
  /// **'Ingredients found: {n}'**
  String foundCount(int n);

  /// No description provided for @analyzeAction.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get analyzeAction;

  /// No description provided for @resultTitle.
  ///
  /// In en, this message translates to:
  /// **'Analysis result'**
  String get resultTitle;

  /// No description provided for @inDatabase.
  ///
  /// In en, this message translates to:
  /// **'In our database'**
  String get inDatabase;

  /// No description provided for @notInDatabase.
  ///
  /// In en, this message translates to:
  /// **'Not in our database yet'**
  String get notInDatabase;

  /// No description provided for @resultNoneFound.
  ///
  /// In en, this message translates to:
  /// **'None of the entered ingredients are in our database yet. The database keeps growing.'**
  String get resultNoneFound;

  /// No description provided for @resultNote.
  ///
  /// In en, this message translates to:
  /// **'This is not medical advice. Information is based on published studies and does not indicate whether a product suits you.'**
  String get resultNote;

  /// No description provided for @detailClaims.
  ///
  /// In en, this message translates to:
  /// **'What studies found'**
  String get detailClaims;

  /// No description provided for @detailSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get detailSource;

  /// No description provided for @openSource.
  ///
  /// In en, this message translates to:
  /// **'Open source'**
  String get openSource;

  /// No description provided for @draftNote.
  ///
  /// In en, this message translates to:
  /// **'Draft: the translation has not been reviewed yet.'**
  String get draftNote;

  /// No description provided for @euUnverified.
  ///
  /// In en, this message translates to:
  /// **'EU regulation and CosIng data have not been verified yet.'**
  String get euUnverified;

  /// No description provided for @evidenceLegendTitle.
  ///
  /// In en, this message translates to:
  /// **'Evidence levels'**
  String get evidenceLegendTitle;

  /// No description provided for @evidenceA.
  ///
  /// In en, this message translates to:
  /// **'A: systematic review or regulatory opinion'**
  String get evidenceA;

  /// No description provided for @evidenceB.
  ///
  /// In en, this message translates to:
  /// **'B: randomised trial in people'**
  String get evidenceB;

  /// No description provided for @evidenceC.
  ///
  /// In en, this message translates to:
  /// **'C: limited evidence'**
  String get evidenceC;

  /// No description provided for @evidenceInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Insufficient evidence'**
  String get evidenceInsufficient;

  /// No description provided for @studyTypeSystematicReview.
  ///
  /// In en, this message translates to:
  /// **'Systematic review'**
  String get studyTypeSystematicReview;

  /// No description provided for @studyTypeMetaAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Meta-analysis'**
  String get studyTypeMetaAnalysis;

  /// No description provided for @studyTypeRct.
  ///
  /// In en, this message translates to:
  /// **'Randomised trial'**
  String get studyTypeRct;

  /// No description provided for @studyTypeObservational.
  ///
  /// In en, this message translates to:
  /// **'Observational study'**
  String get studyTypeObservational;

  /// No description provided for @studyTypeInVitro.
  ///
  /// In en, this message translates to:
  /// **'Laboratory study'**
  String get studyTypeInVitro;

  /// No description provided for @studyTypeRegulatory.
  ///
  /// In en, this message translates to:
  /// **'Regulatory opinion'**
  String get studyTypeRegulatory;

  /// No description provided for @studyTypeNarrative.
  ///
  /// In en, this message translates to:
  /// **'Narrative review'**
  String get studyTypeNarrative;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Please try again.'**
  String get authFailed;

  /// No description provided for @authUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sign-in is not available right now.'**
  String get authUnavailable;

  /// No description provided for @guestName.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestName;

  /// No description provided for @actionSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get actionSignIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Your account and its data will be permanently deleted. This cannot be undone.'**
  String get deleteConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @deleteDone.
  ///
  /// In en, this message translates to:
  /// **'Account deleted.'**
  String get deleteDone;

  /// No description provided for @deleteNeedsRelogin.
  ///
  /// In en, this message translates to:
  /// **'For security, sign in again and then delete your account.'**
  String get deleteNeedsRelogin;

  /// No description provided for @actionFailed.
  ///
  /// In en, this message translates to:
  /// **'The action failed. Please try again.'**
  String get actionFailed;

  /// No description provided for @roleSection.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleSection;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin panel'**
  String get adminPanel;

  /// No description provided for @adminInstalls.
  ///
  /// In en, this message translates to:
  /// **'Installs'**
  String get adminInstalls;

  /// No description provided for @adminInstallsNote.
  ///
  /// In en, this message translates to:
  /// **'This is not the store download count: it counts devices where the app was opened at least once.'**
  String get adminInstallsNote;

  /// No description provided for @adminTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get adminTotal;

  /// No description provided for @adminWeb.
  ///
  /// In en, this message translates to:
  /// **'Web'**
  String get adminWeb;

  /// No description provided for @adminNew7d.
  ///
  /// In en, this message translates to:
  /// **'New in 7 days'**
  String get adminNew7d;

  /// No description provided for @adminActive7d.
  ///
  /// In en, this message translates to:
  /// **'Active in 7 days'**
  String get adminActive7d;

  /// No description provided for @adminActive30d.
  ///
  /// In en, this message translates to:
  /// **'Active in 30 days'**
  String get adminActive30d;

  /// No description provided for @adminUsers.
  ///
  /// In en, this message translates to:
  /// **'Signed-in users'**
  String get adminUsers;

  /// No description provided for @adminProPaid.
  ///
  /// In en, this message translates to:
  /// **'Pro (paid)'**
  String get adminProPaid;

  /// No description provided for @adminProGranted.
  ///
  /// In en, this message translates to:
  /// **'Pro (granted by admin)'**
  String get adminProGranted;

  /// No description provided for @adminGrantTitle.
  ///
  /// In en, this message translates to:
  /// **'Give Pro to an email'**
  String get adminGrantTitle;

  /// No description provided for @adminEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get adminEmailHint;

  /// No description provided for @adminForever.
  ///
  /// In en, this message translates to:
  /// **'Forever'**
  String get adminForever;

  /// No description provided for @adminDays.
  ///
  /// In en, this message translates to:
  /// **'{n} days'**
  String adminDays(int n);

  /// No description provided for @adminGrantAction.
  ///
  /// In en, this message translates to:
  /// **'Give Pro'**
  String get adminGrantAction;

  /// No description provided for @adminRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get adminRevoke;

  /// No description provided for @adminGrantsList.
  ///
  /// In en, this message translates to:
  /// **'Pro granted'**
  String get adminGrantsList;

  /// No description provided for @adminGrantsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nobody yet.'**
  String get adminGrantsEmpty;

  /// No description provided for @adminGranted.
  ///
  /// In en, this message translates to:
  /// **'Pro granted.'**
  String get adminGranted;

  /// No description provided for @adminRevoked.
  ///
  /// In en, this message translates to:
  /// **'Pro revoked.'**
  String get adminRevoked;

  /// No description provided for @adminInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address is not valid.'**
  String get adminInvalidEmail;

  /// No description provided for @adminLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the data.'**
  String get adminLoadFailed;

  /// No description provided for @adminRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get adminRetry;

  /// No description provided for @adminUntil.
  ///
  /// In en, this message translates to:
  /// **'until {date}'**
  String adminUntil(String date);

  /// No description provided for @proBadge.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get proBadge;
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
