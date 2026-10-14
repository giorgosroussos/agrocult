/// Named routes of the app.
abstract final class AppRoutes {
  static const start = '/';
  static const signUp = '/sign-up';

  /// Argument: the email address (String) the link was sent to.
  static const verifyEmail = '/verify-email';

  /// Optional argument: a notice (String) shown above the form.
  static const signIn = '/sign-in';

  /// Optional argument: an email address (String) to prefill.
  static const forgotPassword = '/forgot-password';

  /// Opened from the reset email as `/reset-password?token=...&email=...`.
  static const resetPassword = '/reset-password';
}
