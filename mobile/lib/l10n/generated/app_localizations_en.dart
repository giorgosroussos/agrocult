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
}
