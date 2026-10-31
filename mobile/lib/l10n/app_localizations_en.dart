// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SAMIYA BEAUTY LAB';

  @override
  String get welcomeTagline => 'Beauty, science and care — always with you';

  @override
  String get start => 'Get started';

  @override
  String get campaignPill => '90 days free · coming soon';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get chooseLanguage => 'Language';

  @override
  String get languageTitle => 'Choose your language';

  @override
  String get continueLabel => 'Continue';

  @override
  String get skip => 'Skip';

  @override
  String get onboarding1Title => 'Beauty begins with science';

  @override
  String get onboarding1Body =>
      'Understand ingredients and choose products with confidence.';

  @override
  String get onboarding2Title => 'Your personal care';

  @override
  String get onboarding2Body =>
      'Build morning and evening routines that suit you.';

  @override
  String get onboarding3Title => 'Learn and grow';

  @override
  String get onboarding3Body =>
      'The Academy, quizzes and the SAMIYA AI assistant in one app.';

  @override
  String get loginBanner => 'Beauty, science and care';

  @override
  String get campaignNoCard => '90 days free · no card needed';

  @override
  String get welcomeTitle => 'Welcome!';

  @override
  String get loginSubtitle =>
      'Continue your care and learning journey with SAMIYA.';

  @override
  String get legalNotice =>
      'By continuing, you agree to the Terms of Use and Privacy Policy.';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get roleTitle => 'Who are you?';

  @override
  String get roleSubtitle =>
      'We will show the learning and care sections that fit your role.';

  @override
  String get roleUser => 'User';

  @override
  String get roleUserDesc => 'Personal care and ingredients';

  @override
  String get roleStudent => 'Student';

  @override
  String get roleStudentDesc => 'Academy and quizzes';

  @override
  String get roleCosmetologist => 'Cosmetologist';

  @override
  String get roleCosmetologistDesc => 'Professional reference';

  @override
  String get roleTeacher => 'Teacher';

  @override
  String get roleTeacherDesc => 'Learning materials and groups';

  @override
  String get goHome => 'Go to home';

  @override
  String get homeGreeting => 'Hello!';

  @override
  String get searchHint => 'Product, ingredient or question...';

  @override
  String get homeBannerTitle => 'Science-based care';

  @override
  String get homeBannerTag => 'With evidence and sources';

  @override
  String get tileScanner => 'Ingredient scanner';

  @override
  String get tileSkin => 'Skin preferences';

  @override
  String get tileRoutine => 'Care routine';

  @override
  String get tileAcademy => 'Cosmetology Academy';

  @override
  String get tileAi => 'SAMIYA AI';

  @override
  String get tileJournal => 'Journal';

  @override
  String get popularIngredients => 'Popular ingredients';

  @override
  String get seeAll => 'See all';

  @override
  String get navHome => 'Home';

  @override
  String get navAcademy => 'Academy';

  @override
  String get navScanner => 'Scanner';

  @override
  String get navJournal => 'Journal';

  @override
  String get navProfile => 'Profile';

  @override
  String get scannerHeroTitle => 'Check the ingredients';

  @override
  String get scannerHeroBody =>
      'Enter a product\'s ingredient list. We show sourced information about each ingredient.';

  @override
  String get scanCamera => 'Scan with camera';

  @override
  String get scanManual => 'Enter manually';

  @override
  String get manualTitle => 'Enter ingredients';

  @override
  String get manualHelp =>
      'Copy the INCI list from the packaging (Latin letters).';

  @override
  String get manualHint => 'E.g. Aqua, Glycerin, Niacinamide...';

  @override
  String foundCount(int n) {
    return 'Ingredients found: $n';
  }

  @override
  String get analyzeAction => 'Analyze';

  @override
  String get resultTitle => 'Analysis result';

  @override
  String get inDatabase => 'In our database';

  @override
  String get notInDatabase => 'Not in our database yet';

  @override
  String get resultNoneFound =>
      'None of the entered ingredients are in our database yet. The database keeps growing.';

  @override
  String get resultNote =>
      'This is not medical advice. Information is based on published studies and does not indicate whether a product suits you.';

  @override
  String get detailClaims => 'What studies found';

  @override
  String get detailSource => 'Source';

  @override
  String get openSource => 'Open source';

  @override
  String get draftNote => 'Draft: the translation has not been reviewed yet.';

  @override
  String get euUnverified =>
      'EU regulation and CosIng data have not been verified yet.';

  @override
  String get evidenceLegendTitle => 'Evidence levels';

  @override
  String get evidenceA => 'A: systematic review or regulatory opinion';

  @override
  String get evidenceB => 'B: randomised trial in people';

  @override
  String get evidenceC => 'C: limited evidence';

  @override
  String get evidenceInsufficient => 'Insufficient evidence';

  @override
  String get studyTypeSystematicReview => 'Systematic review';

  @override
  String get studyTypeMetaAnalysis => 'Meta-analysis';

  @override
  String get studyTypeRct => 'Randomised trial';

  @override
  String get studyTypeObservational => 'Observational study';

  @override
  String get studyTypeInVitro => 'Laboratory study';

  @override
  String get studyTypeRegulatory => 'Regulatory opinion';

  @override
  String get studyTypeNarrative => 'Narrative review';

  @override
  String get authFailed => 'Sign-in failed. Please try again.';

  @override
  String get authUnavailable => 'Sign-in is not available right now.';

  @override
  String get guestName => 'Guest';

  @override
  String get actionSignIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteConfirmTitle => 'Delete your account?';

  @override
  String get deleteConfirmBody =>
      'Your account and its data will be permanently deleted. This cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteAction => 'Delete';

  @override
  String get deleteDone => 'Account deleted.';

  @override
  String get deleteNeedsRelogin =>
      'For security, sign in again and then delete your account.';

  @override
  String get actionFailed => 'The action failed. Please try again.';

  @override
  String get roleSection => 'Role';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';
}
