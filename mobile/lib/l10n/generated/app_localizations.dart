import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_el.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('el'),
    Locale('en'),
  ];

  /// App name shown in the title bar and task switcher
  ///
  /// In en, this message translates to:
  /// **'Agrocult'**
  String get appTitle;

  /// Greeting on the start screen of the app skeleton
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Shown when the app is asked to open a screen that does not exist
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// Title of the sign-in screen
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// Title of the sign-up screen
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpTitle;

  /// Label of the email address field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Label of the password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Label of the new password field on the reset screen
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// Label of the field that repeats the new password
  ///
  /// In en, this message translates to:
  /// **'Repeat new password'**
  String get repeatPasswordLabel;

  /// Helper text under a new password field
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordHint;

  /// Checkbox on the sign-up screen (SEC-004)
  ///
  /// In en, this message translates to:
  /// **'I confirm that I am at least 15 years old'**
  String get ageConfirmation;

  /// Button that submits the sign-up form
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpButton;

  /// Button that submits the sign-in form, also used as a link to the sign-in screen
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// Button that signs this device out
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutButton;

  /// Link to the password reset request screen
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPasswordLink;

  /// Link from sign-in to sign-up
  ///
  /// In en, this message translates to:
  /// **'No account yet? Create one'**
  String get noAccountLink;

  /// Link from sign-up to sign-in
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get haveAccountLink;

  /// Title of the notice shown after sign-up
  ///
  /// In en, this message translates to:
  /// **'Confirm your email'**
  String get verifyEmailTitle;

  /// Notice after sign-up; must not reveal whether the email is registered
  ///
  /// In en, this message translates to:
  /// **'If {email} can be used for a new account, we have sent a confirmation link to it. Open the link, then sign in.'**
  String verifyEmailBody(String email);

  /// Offer for visitors who sign up with an email that already has an account (UC-012)
  ///
  /// In en, this message translates to:
  /// **'Already have an account with this email? Sign in, or reset your password if you have forgotten it.'**
  String get verifyEmailAlreadyRegistered;

  /// Button that requests a new email confirmation link
  ///
  /// In en, this message translates to:
  /// **'Send the link again'**
  String get resendVerificationButton;

  /// Shown after a new confirmation link was requested
  ///
  /// In en, this message translates to:
  /// **'If this email address needs confirmation, a new link has been sent to it.'**
  String get verificationResent;

  /// Title of the password reset request screen
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get forgotPasswordTitle;

  /// Explanation on the password reset request screen
  ///
  /// In en, this message translates to:
  /// **'Enter the email address of your account. We will send you a link to set a new password.'**
  String get forgotPasswordIntro;

  /// Button that requests a password reset link
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLinkButton;

  /// Shown after a reset request; identical for known and unknown emails
  ///
  /// In en, this message translates to:
  /// **'If an account exists for this email address, we have sent a reset link to it. The link works only once.'**
  String get resetLinkSent;

  /// Link back to the sign-in screen
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// Title of the screen opened from the reset link
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get resetPasswordTitle;

  /// Button that sets the new password
  ///
  /// In en, this message translates to:
  /// **'Save new password'**
  String get resetPasswordButton;

  /// Shown after a successful password reset
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed. Sign in again on your devices.'**
  String get passwordChanged;

  /// Button shown when a reset link is invalid or used
  ///
  /// In en, this message translates to:
  /// **'Request a new link'**
  String get requestNewResetLink;

  /// Shown after signing out
  ///
  /// In en, this message translates to:
  /// **'You have signed out.'**
  String get signedOut;

  /// Sign-in failure; same text for an unknown email and a wrong password
  ///
  /// In en, this message translates to:
  /// **'The email or password is not correct.'**
  String get errorInvalidCredentials;

  /// Sign-in refused because the email is not confirmed yet
  ///
  /// In en, this message translates to:
  /// **'Confirm your email address before signing in.'**
  String get errorEmailNotVerified;

  /// The reset link is unknown, expired or used
  ///
  /// In en, this message translates to:
  /// **'This reset link is not valid or has already been used.'**
  String get errorInvalidResetLink;

  /// The server rejected the form
  ///
  /// In en, this message translates to:
  /// **'Check the details you entered.'**
  String get errorInvalidInput;

  /// The server limited the number of attempts
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a minute and try again.'**
  String get errorRateLimited;

  /// The server could not be reached
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Check your connection and try again.'**
  String get errorNetwork;

  /// Any other server failure
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again later.'**
  String get errorServer;

  /// Form validation: email address
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get validationEmail;

  /// Form validation: empty password on sign-in
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get validationPasswordRequired;

  /// Form validation: new password too short
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get validationPasswordLength;

  /// Form validation: the repeated password differs
  ///
  /// In en, this message translates to:
  /// **'The passwords do not match.'**
  String get validationPasswordsDiffer;

  /// Form validation: age confirmation not ticked (SEC-004)
  ///
  /// In en, this message translates to:
  /// **'You must be at least 15 years old to create an account.'**
  String get validationAgeRequired;
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
      <String>['el', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
