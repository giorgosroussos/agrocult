// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Agrocult';

  @override
  String get welcome => 'Welcome';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signUpTitle => 'Create account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get repeatPasswordLabel => 'Repeat new password';

  @override
  String get passwordHint => 'At least 8 characters';

  @override
  String get ageConfirmation => 'I confirm that I am at least 15 years old';

  @override
  String get signUpButton => 'Create account';

  @override
  String get signInButton => 'Sign in';

  @override
  String get signOutButton => 'Sign out';

  @override
  String get forgotPasswordLink => 'Forgot your password?';

  @override
  String get noAccountLink => 'No account yet? Create one';

  @override
  String get haveAccountLink => 'Already have an account? Sign in';

  @override
  String get verifyEmailTitle => 'Confirm your email';

  @override
  String verifyEmailBody(String email) {
    return 'If $email can be used for a new account, we have sent a confirmation link to it. Open the link, then sign in.';
  }

  @override
  String get verifyEmailAlreadyRegistered =>
      'Already have an account with this email? Sign in, or reset your password if you have forgotten it.';

  @override
  String get resendVerificationButton => 'Send the link again';

  @override
  String get verificationResent =>
      'If this email address needs confirmation, a new link has been sent to it.';

  @override
  String get forgotPasswordTitle => 'Reset password';

  @override
  String get forgotPasswordIntro =>
      'Enter the email address of your account. We will send you a link to set a new password.';

  @override
  String get sendResetLinkButton => 'Send reset link';

  @override
  String get resetLinkSent =>
      'If an account exists for this email address, we have sent a reset link to it. The link works only once.';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get resetPasswordTitle => 'Set a new password';

  @override
  String get resetPasswordButton => 'Save new password';

  @override
  String get passwordChanged =>
      'Your password has been changed. Sign in again on your devices.';

  @override
  String get requestNewResetLink => 'Request a new link';

  @override
  String get signedOut => 'You have signed out.';

  @override
  String get errorInvalidCredentials => 'The email or password is not correct.';

  @override
  String get errorEmailNotVerified =>
      'Confirm your email address before signing in.';

  @override
  String get errorInvalidResetLink =>
      'This reset link is not valid or has already been used.';

  @override
  String get errorInvalidInput => 'Check the details you entered.';

  @override
  String get errorRateLimited =>
      'Too many attempts. Wait a minute and try again.';

  @override
  String get errorNetwork =>
      'Could not reach the server. Check your connection and try again.';

  @override
  String get errorServer => 'Something went wrong. Try again later.';

  @override
  String get validationEmail => 'Enter a valid email address.';

  @override
  String get validationPasswordRequired => 'Enter your password.';

  @override
  String get validationPasswordLength => 'Use at least 8 characters.';

  @override
  String get validationPasswordsDiffer => 'The passwords do not match.';

  @override
  String get validationAgeRequired =>
      'You must be at least 15 years old to create an account.';

  @override
  String get catalogueTitle => 'Plant catalogue';

  @override
  String get catalogueSearchHint => 'Search by name, in Greek or English';

  @override
  String get catalogueInSeasonFilter => 'In season now';

  @override
  String get catalogueAllCategories => 'All';

  @override
  String get catalogueNoResults => 'No plants found';

  @override
  String get catalogueLoadError => 'The plant catalogue could not be opened.';

  @override
  String get plantNotFound => 'This plant is not in the catalogue.';

  @override
  String get notTranslated => 'Not translated';

  @override
  String get plantOtherNames => 'Also known as';

  @override
  String get plantCategory => 'Category';

  @override
  String get plantSectionConditions => 'Growing conditions';

  @override
  String get plantSectionCalendar => 'Calendar';

  @override
  String get plantSectionPlanting => 'Planting';

  @override
  String get plantSectionDescription => 'Description';

  @override
  String get plantSectionCare => 'Care';

  @override
  String get plantSectionSeedSaving => 'Seed saving';

  @override
  String get plantSectionTips => 'Tips';

  @override
  String get plantSectionCompanions => 'Companions';

  @override
  String get plantTempMin => 'Minimum temperature';

  @override
  String get plantTempOpt => 'Ideal temperature';

  @override
  String get plantTempMax => 'Maximum temperature';

  @override
  String get plantWaterNeed => 'Water need';

  @override
  String plantWaterNeedValue(int value) {
    return '$value of 5';
  }

  @override
  String get plantSun => 'Sun';

  @override
  String get sunFullSun => 'Full sun';

  @override
  String get sunPartialShade => 'Partial shade';

  @override
  String get sunShade => 'Shade';

  @override
  String get plantSoil => 'Soil';

  @override
  String get plantPh => 'Soil pH';

  @override
  String get plantFrost => 'Frost hardiness';

  @override
  String get frostTender => 'Tender';

  @override
  String get frostHalfHardy => 'Half hardy';

  @override
  String get frostHardy => 'Hardy';

  @override
  String get plantPropagation => 'Propagation';

  @override
  String get plantSowDepth => 'Sowing depth';

  @override
  String get plantSpacing => 'Spacing between plants';

  @override
  String get plantRowSpacing => 'Spacing between rows';

  @override
  String get plantDaysToHarvest => 'Days to harvest';

  @override
  String get activitySowIndoors => 'Sow in trays';

  @override
  String get activitySowOutdoors => 'Sow in the garden';

  @override
  String get activityTransplant => 'Transplant';

  @override
  String get activityHarvest => 'Harvest';

  @override
  String get calendarYourZone => 'Your garden\'s zone';

  @override
  String get calendarEmpty => 'No calendar yet.';

  @override
  String get careWater => 'Watering';

  @override
  String get careFertilise => 'Fertilising';

  @override
  String get carePrune => 'Pruning';

  @override
  String get careWeed => 'Weeding';

  @override
  String get careSpray => 'Spraying';

  @override
  String get careOther => 'Other care';

  @override
  String careEvery(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'every $days days',
      one: 'every day',
    );
    return '$_temp0';
  }

  @override
  String get companionsGood => 'Good neighbours';

  @override
  String get companionsBad => 'Bad neighbours';

  @override
  String get plantNoInformation => 'No information yet.';
}
