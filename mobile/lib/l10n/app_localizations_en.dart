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

  @override
  String get honestLead => 'In all honesty:';

  @override
  String get academySubtitle =>
      'Cosmetology essentials: short, evidence-based lessons.';

  @override
  String get academyT1 => 'Skin anatomy and physiology';

  @override
  String get academyT2 => 'INCI and cosmetic ingredients';

  @override
  String get academyT3 => 'Sun protection';

  @override
  String get academyT4 => 'Moisturising and the skin barrier';

  @override
  String get academyT5 => 'Hygiene and infection control';

  @override
  String get academyT6 => 'Cosmetic safety and labels';

  @override
  String get routineEmptyTitle => 'Your first step';

  @override
  String get journalEmptyTitle => 'Your skin journal';

  @override
  String get routineSuggestCleanse => 'Cleanse';

  @override
  String get routineSuggestMoisturise => 'Moisturise';

  @override
  String get routineSuggestSun => 'Sun protection';

  @override
  String get lessonKeyPoints => 'Key points';

  @override
  String get lessonQuiz => 'Test yourself';

  @override
  String get lessonSources => 'Sources';

  @override
  String get lessonDraftNote =>
      'this lesson is an evidence-based draft awaiting review by an expert cosmetologist. It is not medical advice.';

  @override
  String lessonMinutes(int n) {
    return '$n min';
  }

  @override
  String get quizRight => 'Correct!';

  @override
  String get quizWrong => 'Not quite — the right answer is marked.';

  @override
  String quizScore(int score, int total) {
    return 'Score: $score / $total';
  }

  @override
  String get quizRetry => 'Try again';

  @override
  String lessonCount(int n) {
    return '$n lessons · with quizzes';
  }

  @override
  String get lessonDone => 'Read';

  @override
  String get aiSubtitle =>
      'Your personal beauty assistant: clear explanations grounded in scientific sources.';

  @override
  String get aiDisclaimer =>
      'SAMIYA AI provides educational information, does not diagnose and does not recommend medicines. It can make mistakes — for important questions, see a dermatologist.';

  @override
  String get aiConsent =>
      'To prepare an answer, your question is sent to the Google Gemini service. Please don’t include your name, phone number or medical documents.';

  @override
  String get aiAccept => 'Got it, start';

  @override
  String get aiHint => 'Type your question…';

  @override
  String get aiThinking => 'SAMIYA is thinking…';

  @override
  String get aiSignIn => 'Sign in to use SAMIYA AI — it’s free.';

  @override
  String get aiSignInBtn => 'Sign in';

  @override
  String get aiNotReady =>
      'SAMIYA AI is launching soon. Meanwhile, explore the ingredient library, the Ibn Sina section and the Academy.';

  @override
  String get aiQuota =>
      'You’ve used today’s free questions. You can ask again tomorrow.';

  @override
  String get aiError =>
      'Couldn’t get an answer. Check your connection and try again.';

  @override
  String get aiRetry => 'Try again';

  @override
  String aiRemaining(int n) {
    return '$n questions left today';
  }

  @override
  String get aiTry => 'Try asking:';

  @override
  String get aiS1 => 'Can I use niacinamide and vitamin C together?';

  @override
  String get aiS2 => 'What is a good evening routine for dry skin?';

  @override
  String get aiS3 => 'How do I do gua sha correctly?';

  @override
  String get aiS4 => 'What did Ibn Sina write about skin care?';

  @override
  String get tileShelf => 'My shelf';

  @override
  String get tileRecipes => 'Make at home';

  @override
  String get tileRituals => 'Rituals';

  @override
  String get shelfTitle => 'My beauty shelf';

  @override
  String get shelfIntro =>
      'Log the products you have opened — when one is close to its limit, you’ll see it here. The number in the open-jar symbol on the pack (e.g. 12M) shows how many months a product can be used after opening.';

  @override
  String get shelfEmptyTitle => 'Your shelf is empty for now';

  @override
  String get shelfEmptyBody =>
      'Add your first product: its name, the date you opened it and its PAO symbol.';

  @override
  String get shelfAdd => 'Add product';

  @override
  String get shelfName => 'Product name';

  @override
  String get shelfOpened => 'Opened on';

  @override
  String get shelfPao => 'After opening (PAO)';

  @override
  String shelfMonths(int n) {
    return '$n months';
  }

  @override
  String shelfDaysLeft(int n) {
    return '$n days left';
  }

  @override
  String get shelfExpired => 'Past its date';

  @override
  String get shelfOk => 'Good';

  @override
  String get shelfSave => 'Save';

  @override
  String shelfAttention(int n) {
    return '$n products need attention';
  }

  @override
  String get recipesTitle => 'Make at home';

  @override
  String get recipesIntro =>
      'Simple, elegant care from natural ingredients in your kitchen. Every recipe comes with safety rules and an honest note on the science.';

  @override
  String get recipeYouNeed => 'You will need';

  @override
  String get recipeSteps => 'Method';

  @override
  String get recipeSafety => 'Safety';

  @override
  String get recipeEvidence => 'What science says';

  @override
  String get recipeIngredients => 'Ingredient cards';

  @override
  String get ritualsTitle => 'Rituals';

  @override
  String get ritualsIntro =>
      'Step-by-step, timed rituals for facial massage and gua sha. Take your time and press gently.';

  @override
  String get ritualStart => 'Start';

  @override
  String get ritualPause => 'Pause';

  @override
  String get ritualResume => 'Resume';

  @override
  String get ritualNext => 'Next';

  @override
  String get ritualDone =>
      'Ritual complete. Thank you for taking time for yourself!';

  @override
  String ritualStep(int i, int n) {
    return 'Step $i of $n';
  }

  @override
  String get tipTitle => 'Tip of the day';

  @override
  String get collectionsTitle => 'Collections';

  @override
  String get colHeat => 'Care in a hot climate';

  @override
  String get colHeatBody => 'Sun, humidity and light textures';

  @override
  String get colWinter => 'Winter dryness';

  @override
  String get colWinterBody => 'Protecting the skin barrier';

  @override
  String get colNatural => 'Natural beauty';

  @override
  String get colNaturalBody => 'Elegant recipes to make at home';

  @override
  String get proSubtitle =>
      'The complete collection of beauty knowledge — deeper and more personal.';

  @override
  String get proFreeTitle => 'Always free';

  @override
  String get proFree1 => 'Scanner and ingredient library';

  @override
  String get proFree2 => 'The first Academy lessons';

  @override
  String get proFree3 => 'Selected recipes and a ritual';

  @override
  String get proFree4 => 'SAMIYA AI — a few questions a day';

  @override
  String get proPlusTitle => 'With Pro';

  @override
  String get proB1 => 'SAMIYA AI — up to 50 questions a day';

  @override
  String get proB2 => 'Every Academy lesson, plus new ones';

  @override
  String get proB3 => 'All recipes and rituals, updated regularly';

  @override
  String get proB4 => 'The full Ibn Sina section';

  @override
  String get proB5 => 'Unlimited “My shelf”';

  @override
  String get proB6 => 'No ads';

  @override
  String get proCampaign =>
      'During the 90-day launch everything is free — no card needed.';

  @override
  String get proSoon =>
      'Pro is coming soon. No automatic charges and no hidden fees.';

  @override
  String get proEarly => 'A special offer for early members is on its way.';

  @override
  String get proLocked => 'This section unlocks with Pro';

  @override
  String get proUnlock => 'About Pro';

  @override
  String proDaysLeft(int n) {
    return '$n days left in the free period';
  }

  @override
  String get proActive => 'Pro is active — every section is open';
}
