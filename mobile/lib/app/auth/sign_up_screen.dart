import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/providers.dart';
import '../../l10n/generated/app_localizations.dart';
import '../routes.dart';
import 'auth_widgets.dart';

/// UC-012 step 1: email, password and the age confirmation (SEC-004).
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _ageConfirmed = false;
  bool _ageError = false;
  bool _busy = false;
  AuthError? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _form.currentState!.validate();
    setState(() => _ageError = !_ageConfirmed);
    if (!valid || !_ageConfirmed || _busy) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    final email = _email.text.trim();
    try {
      await ref
          .read(authRepositoryProvider)
          .signUp(
            email: email,
            password: _password.text,
            ageConfirmed: _ageConfirmed,
            language: Localizations.localeOf(context).languageCode,
          );
      if (!mounted) return;
      await Navigator.of(
        context,
      ).pushReplacementNamed(AppRoutes.verifyEmail, arguments: email);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = _error;
    return AuthScaffold(
      title: l10n.signUpTitle,
      children: [
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('signUp.email'),
                controller: _email,
                decoration: InputDecoration(labelText: l10n.emailLabel),
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                validator: (v) => validateEmail(l10n, v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('signUp.password'),
                controller: _password,
                decoration: InputDecoration(
                  labelText: l10n.passwordLabel,
                  helperText: l10n.passwordHint,
                ),
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                validator: (v) => validateNewPassword(l10n, v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          key: const Key('signUp.age'),
          value: _ageConfirmed,
          onChanged: (v) => setState(() {
            _ageConfirmed = v ?? false;
            if (_ageConfirmed) _ageError = false;
          }),
          title: Text(l10n.ageConfirmation),
          subtitle: _ageError
              ? Text(
                  l10n.validationAgeRequired,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                )
              : null,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        if (error != null) AuthErrorText(authErrorMessage(l10n, error)),
        AuthSubmitButton(
          key: const Key('signUp.submit'),
          label: l10n.signUpButton,
          busy: _busy,
          onPressed: _submit,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.signIn),
          child: Text(l10n.haveAccountLink),
        ),
      ],
    );
  }
}
