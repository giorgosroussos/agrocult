// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get appTitle => 'Agrocult';

  @override
  String get welcome => 'Καλώς ήρθατε';

  @override
  String get pageNotFound => 'Η σελίδα δεν βρέθηκε';

  @override
  String get signInTitle => 'Σύνδεση';

  @override
  String get signUpTitle => 'Δημιουργία λογαριασμού';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Κωδικός πρόσβασης';

  @override
  String get newPasswordLabel => 'Νέος κωδικός πρόσβασης';

  @override
  String get repeatPasswordLabel => 'Επανάληψη νέου κωδικού';

  @override
  String get passwordHint => 'Τουλάχιστον 8 χαρακτήρες';

  @override
  String get ageConfirmation => 'Επιβεβαιώνω ότι είμαι τουλάχιστον 15 ετών';

  @override
  String get signUpButton => 'Δημιουργία λογαριασμού';

  @override
  String get signInButton => 'Σύνδεση';

  @override
  String get signOutButton => 'Αποσύνδεση';

  @override
  String get forgotPasswordLink => 'Ξεχάσατε τον κωδικό σας;';

  @override
  String get noAccountLink => 'Δεν έχετε λογαριασμό; Δημιουργήστε έναν';

  @override
  String get haveAccountLink => 'Έχετε ήδη λογαριασμό; Συνδεθείτε';

  @override
  String get verifyEmailTitle => 'Επιβεβαιώστε το email σας';

  @override
  String verifyEmailBody(String email) {
    return 'Αν το $email μπορεί να χρησιμοποιηθεί για νέο λογαριασμό, σας στείλαμε σε αυτό έναν σύνδεσμο επιβεβαίωσης. Ανοίξτε τον σύνδεσμο και μετά συνδεθείτε.';
  }

  @override
  String get verifyEmailAlreadyRegistered =>
      'Έχετε ήδη λογαριασμό με αυτό το email; Συνδεθείτε ή επαναφέρετε τον κωδικό σας αν τον ξεχάσατε.';

  @override
  String get resendVerificationButton => 'Αποστολή του συνδέσμου ξανά';

  @override
  String get verificationResent =>
      'Αν αυτό το email χρειάζεται επιβεβαίωση, σας στάλθηκε νέος σύνδεσμος.';

  @override
  String get forgotPasswordTitle => 'Επαναφορά κωδικού';

  @override
  String get forgotPasswordIntro =>
      'Γράψτε το email του λογαριασμού σας. Θα σας στείλουμε έναν σύνδεσμο για να ορίσετε νέο κωδικό.';

  @override
  String get sendResetLinkButton => 'Αποστολή συνδέσμου';

  @override
  String get resetLinkSent =>
      'Αν υπάρχει λογαριασμός με αυτό το email, σας στείλαμε έναν σύνδεσμο επαναφοράς. Ο σύνδεσμος λειτουργεί μόνο μία φορά.';

  @override
  String get backToSignIn => 'Επιστροφή στη σύνδεση';

  @override
  String get resetPasswordTitle => 'Ορισμός νέου κωδικού';

  @override
  String get resetPasswordButton => 'Αποθήκευση νέου κωδικού';

  @override
  String get passwordChanged =>
      'Ο κωδικός σας άλλαξε. Συνδεθείτε ξανά στις συσκευές σας.';

  @override
  String get requestNewResetLink => 'Ζητήστε νέο σύνδεσμο';

  @override
  String get signedOut => 'Αποσυνδεθήκατε.';

  @override
  String get errorInvalidCredentials => 'Το email ή ο κωδικός δεν είναι σωστά.';

  @override
  String get errorEmailNotVerified =>
      'Επιβεβαιώστε το email σας πριν συνδεθείτε.';

  @override
  String get errorInvalidResetLink =>
      'Αυτός ο σύνδεσμος επαναφοράς δεν ισχύει ή έχει ήδη χρησιμοποιηθεί.';

  @override
  String get errorInvalidInput => 'Ελέγξτε τα στοιχεία που γράψατε.';

  @override
  String get errorRateLimited =>
      'Πάρα πολλές προσπάθειες. Περιμένετε ένα λεπτό και δοκιμάστε ξανά.';

  @override
  String get errorNetwork =>
      'Δεν ήταν δυνατή η σύνδεση με τον διακομιστή. Ελέγξτε τη σύνδεσή σας και δοκιμάστε ξανά.';

  @override
  String get errorServer => 'Κάτι πήγε στραβά. Δοκιμάστε ξανά αργότερα.';

  @override
  String get validationEmail => 'Γράψτε ένα έγκυρο email.';

  @override
  String get validationPasswordRequired => 'Γράψτε τον κωδικό σας.';

  @override
  String get validationPasswordLength =>
      'Χρησιμοποιήστε τουλάχιστον 8 χαρακτήρες.';

  @override
  String get validationPasswordsDiffer => 'Οι κωδικοί δεν ταιριάζουν.';

  @override
  String get validationAgeRequired =>
      'Πρέπει να είστε τουλάχιστον 15 ετών για να δημιουργήσετε λογαριασμό.';

  @override
  String get catalogueTitle => 'Κατάλογος φυτών';

  @override
  String get catalogueSearchHint =>
      'Αναζήτηση με όνομα, στα ελληνικά ή αγγλικά';

  @override
  String get catalogueInSeasonFilter => 'Της εποχής τώρα';

  @override
  String get catalogueAllCategories => 'Όλα';

  @override
  String get catalogueNoResults => 'Δεν βρέθηκαν φυτά';

  @override
  String get catalogueLoadError => 'Ο κατάλογος φυτών δεν άνοιξε.';

  @override
  String get plantNotFound => 'Αυτό το φυτό δεν υπάρχει στον κατάλογο.';

  @override
  String get notTranslated => 'Δεν έχει μεταφραστεί';

  @override
  String get plantOtherNames => 'Άλλες ονομασίες';

  @override
  String get plantCategory => 'Κατηγορία';

  @override
  String get plantSectionConditions => 'Συνθήκες καλλιέργειας';

  @override
  String get plantSectionCalendar => 'Ημερολόγιο';

  @override
  String get plantSectionPlanting => 'Φύτευση';

  @override
  String get plantSectionDescription => 'Περιγραφή';

  @override
  String get plantSectionCare => 'Φροντίδα';

  @override
  String get plantSectionSeedSaving => 'Συλλογή σπόρων';

  @override
  String get plantSectionTips => 'Συμβουλές';

  @override
  String get plantSectionCompanions => 'Συγκαλλιέργεια';

  @override
  String get plantTempMin => 'Ελάχιστη θερμοκρασία';

  @override
  String get plantTempOpt => 'Ιδανική θερμοκρασία';

  @override
  String get plantTempMax => 'Μέγιστη θερμοκρασία';

  @override
  String get plantWaterNeed => 'Ανάγκη σε νερό';

  @override
  String plantWaterNeedValue(int value) {
    return '$value από 5';
  }

  @override
  String get plantSun => 'Ηλιοφάνεια';

  @override
  String get sunFullSun => 'Πλήρης ήλιος';

  @override
  String get sunPartialShade => 'Ημισκιά';

  @override
  String get sunShade => 'Σκιά';

  @override
  String get plantSoil => 'Έδαφος';

  @override
  String get plantPh => 'pH εδάφους';

  @override
  String get plantFrost => 'Αντοχή στον παγετό';

  @override
  String get frostTender => 'Ευαίσθητο';

  @override
  String get frostHalfHardy => 'Μέτρια ανθεκτικό';

  @override
  String get frostHardy => 'Ανθεκτικό';

  @override
  String get plantPropagation => 'Πολλαπλασιασμός';

  @override
  String get plantSowDepth => 'Βάθος σποράς';

  @override
  String get plantSpacing => 'Απόσταση μεταξύ φυτών';

  @override
  String get plantRowSpacing => 'Απόσταση μεταξύ γραμμών';

  @override
  String get plantDaysToHarvest => 'Ημέρες ως τη συγκομιδή';

  @override
  String get activitySowIndoors => 'Σπορά σε σπορείο';

  @override
  String get activitySowOutdoors => 'Σπορά στον κήπο';

  @override
  String get activityTransplant => 'Μεταφύτευση';

  @override
  String get activityHarvest => 'Συγκομιδή';

  @override
  String get calendarYourZone => 'Η ζώνη του κήπου σας';

  @override
  String get calendarEmpty => 'Δεν υπάρχει ακόμη ημερολόγιο.';

  @override
  String get careWater => 'Πότισμα';

  @override
  String get careFertilise => 'Λίπανση';

  @override
  String get carePrune => 'Κλάδεμα';

  @override
  String get careWeed => 'Βοτάνισμα';

  @override
  String get careSpray => 'Ψεκασμός';

  @override
  String get careOther => 'Άλλη φροντίδα';

  @override
  String careEvery(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'κάθε $days μέρες',
      one: 'κάθε μέρα',
    );
    return '$_temp0';
  }

  @override
  String get companionsGood => 'Καλοί γείτονες';

  @override
  String get companionsBad => 'Κακοί γείτονες';

  @override
  String get plantNoInformation => 'Δεν υπάρχουν ακόμη πληροφορίες.';
}
