import 'package:flutter/material.dart';

import '../../core/auth/auth_repository.dart';
import '../../l10n/generated/app_localizations.dart';

/// Minimum password length, the same as the server's rule.
const minPasswordLength = 8;

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(AppLocalizations l10n, String? value) {
  final email = value?.trim() ?? '';
  return _emailPattern.hasMatch(email) ? null : l10n.validationEmail;
}

String? validateNewPassword(AppLocalizations l10n, String? value) =>
    (value ?? '').length < minPasswordLength
    ? l10n.validationPasswordLength
    : null;

/// The text shown for an auth failure. Server texts are never shown: they
/// may echo user input and are not in the app's language.
String authErrorMessage(AppLocalizations l10n, AuthError error) =>
    switch (error) {
      AuthError.invalidCredentials => l10n.errorInvalidCredentials,
      AuthError.emailNotVerified => l10n.errorEmailNotVerified,
      AuthError.invalidResetLink => l10n.errorInvalidResetLink,
      AuthError.invalidInput => l10n.errorInvalidInput,
      AuthError.rateLimited => l10n.errorRateLimited,
      AuthError.network => l10n.errorNetwork,
      AuthError.server => l10n.errorServer,
    };

/// Scrollable, width-limited body shared by the auth screens.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Error line under a form, announced to screen readers.
class AuthErrorText extends StatelessWidget {
  const AuthErrorText(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(
          message,
          key: const Key('auth.error'),
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}

/// Primary button that shows progress while [busy].
class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: FilledButton(
        onPressed: busy ? null : onPressed,
        child: busy
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}
