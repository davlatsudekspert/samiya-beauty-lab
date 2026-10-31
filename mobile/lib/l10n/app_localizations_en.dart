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

  @override
  String get adminPanel => 'Admin panel';

  @override
  String get adminInstalls => 'Installs';

  @override
  String get adminInstallsNote =>
      'This is not the store download count: it counts devices where the app was opened at least once.';

  @override
  String get adminTotal => 'Total';

  @override
  String get adminWeb => 'Web';

  @override
  String get adminNew7d => 'New in 7 days';

  @override
  String get adminActive7d => 'Active in 7 days';

  @override
  String get adminActive30d => 'Active in 30 days';

  @override
  String get adminUsers => 'Signed-in users';

  @override
  String get adminProPaid => 'Pro (paid)';

  @override
  String get adminProGranted => 'Pro (granted by admin)';

  @override
  String get adminGrantTitle => 'Give Pro to an email';

  @override
  String get adminEmailHint => 'Email address';

  @override
  String get adminForever => 'Forever';

  @override
  String adminDays(int n) {
    return '$n days';
  }

  @override
  String get adminGrantAction => 'Give Pro';

  @override
  String get adminRevoke => 'Revoke';

  @override
  String get adminGrantsList => 'Pro granted';

  @override
  String get adminGrantsEmpty => 'Nobody yet.';

  @override
  String get adminGranted => 'Pro granted.';

  @override
  String get adminRevoked => 'Pro revoked.';

  @override
  String get adminInvalidEmail => 'The email address is not valid.';

  @override
  String get adminLoadFailed => 'Could not load the data.';

  @override
  String get adminRetry => 'Retry';

  @override
  String adminUntil(String date) {
    return 'until $date';
  }

  @override
  String get proBadge => 'Pro';

  @override
  String get ingredientsTitle => 'Ingredient database';

  @override
  String get ingredientsSearchHint => 'Ingredient name...';

  @override
  String get ingredientsNoMatch => 'Nothing found. The database keeps growing.';

  @override
  String get scanSourceCamera => 'Take a photo';

  @override
  String get scanSourceGallery => 'Choose from gallery';

  @override
  String get scanReading => 'Reading the text...';

  @override
  String get scanNoText =>
      'No ingredient list found. Take a closer, sharper photo of the ingredients in good light.';

  @override
  String get scanFailed =>
      'Could not read the image. Try again or enter the ingredients manually.';

  @override
  String get scanUnavailable =>
      'Camera scanning is not available on this device. Enter the ingredients manually.';

  @override
  String get scanReviewHint =>
      'The text was read from the photo. Check it and fix any mistakes.';

  @override
  String get filterAll => 'All';

  @override
  String get filterActive => 'Active ingredients';

  @override
  String get filterNatural => 'Natural & plant-based';

  @override
  String get naturalSectionTitle => 'Natural & plant-based';

  @override
  String get naturalNote =>
      '“Natural” does not automatically mean “safe”: allergy and irritation are possible. Test a new product on a small area of skin first.';

  @override
  String get filterPractice => 'Care techniques';

  @override
  String get filterCaution => 'Home remedies: caution';

  @override
  String get practiceNote =>
      'This is a care technique, not an ingredient: the evidence is often limited. If your skin is inflamed or damaged, talk to a professional first.';

  @override
  String get cautionNote =>
      'Information about a common home remedy: for some, cases of skin harm have been recorded; for others, evidence of safety and benefit is insufficient. Read it before using.';

  @override
  String get practiceSectionTitle => 'Care techniques';

  @override
  String get traditionalTitle => 'Traditional use';

  @override
  String get traditionalNote =>
      'Historical and traditional sources: this is not scientific evidence and does not indicate effectiveness or safety.';

  @override
  String get ibnSinaCardBody => 'What historical sources say about skin care';

  @override
  String get ibnSinaMore => 'About Ibn Sina';

  @override
  String get tradPersian => 'Persian traditional medicine';

  @override
  String get tradCanon => 'Ibn Sina, Canon of Medicine';

  @override
  String get tradUnani => 'Unani medicine';

  @override
  String get tradAyurveda => 'Ayurveda';

  @override
  String get tradChinese => 'Traditional Chinese medicine';

  @override
  String get tradKorean => 'Traditional Korean medicine';

  @override
  String get tradFolk => 'Folk medicine and ethnobotany';

  @override
  String get skinTypeTitle => 'Your skin type (self-reported)';

  @override
  String get skinDry => 'Dry';

  @override
  String get skinOily => 'Oily';

  @override
  String get skinCombination => 'Combination';

  @override
  String get skinNormal => 'Normal';

  @override
  String get skinSensitive => 'Sensitive';

  @override
  String get skinNote =>
      'The app does not determine your skin type or diagnose anything: this is a note for you.';

  @override
  String get avoidTitle => 'Ingredients you want to avoid';

  @override
  String get avoidHint => 'INCI name, e.g. Parfum';

  @override
  String get avoidAdd => 'Add';

  @override
  String get avoidEmpty =>
      'The list is empty. If a scan finds these ingredients, we will flag them.';

  @override
  String avoidFound(String names) {
    return 'Found ingredients from your avoid list: $names';
  }

  @override
  String get removeAction => 'Remove';

  @override
  String get routineMorning => 'Morning';

  @override
  String get routineEvening => 'Evening';

  @override
  String get routineAddStep => 'Add a step';

  @override
  String get routineStepHint => 'For example: cleanser';

  @override
  String get routineEmpty => 'No steps yet. Add your own care routine.';

  @override
  String routineDoneToday(int done, int total) {
    return 'Done today: $done/$total';
  }

  @override
  String get moveUp => 'Move up';

  @override
  String get moveDown => 'Move down';

  @override
  String get journalAdd => 'Add entry';

  @override
  String get journalEmpty =>
      'No entries yet. Leave a short note about your skin and care.';

  @override
  String get journalFeeling => 'How does your skin feel today?';

  @override
  String get feelGreat => 'Great';

  @override
  String get feelGood => 'Good';

  @override
  String get feelOkay => 'Okay';

  @override
  String get feelDry => 'Dry';

  @override
  String get feelIrritated => 'Irritated';

  @override
  String get journalNoteHint => 'Note (optional)';

  @override
  String get saveAction => 'Save';

  @override
  String get personalDataNote =>
      'This information is stored only on this phone.';

  @override
  String get botanicalCredit =>
      'Botanical plate: F. E. Köhler, “Köhler\'s Medizinal-Pflanzen”, 1887 (public domain)';

  @override
  String get photoCredit =>
      'Photo: iNaturalist community, CC0 (no rights reserved)';
}
