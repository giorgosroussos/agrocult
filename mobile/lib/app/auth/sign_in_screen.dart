import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/providers.dart';
import '../../l10n/generated/app_localizations.dart';
import '../routes.dart';
import 'auth_widgets.dart';

/// UC-012 step 3: signs this device in.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key, this.notice});

  /// Message shown above the form (e.g. after a password reset).
  final String? notice;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  AuthError? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate() || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authSessionProvider.notifier)
          .signIn(email: _email.text.trim(), password: _password.text);
      if (!mounted) return;
      await Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.start, (_) => false);
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.error;
          // Never keep a rejected password on screen.
          _password.clear();
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = _error;
    final notice = widget.notice;
    return AuthScaffold(
      title: l10n.signInTitle,
      children: [
        if (notice != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(notice, key: const Key('signIn.notice')),
          ),
        Form(
          key: _form,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const Key('signIn.email'),
                  controller: _email,
                  decoration: InputDecoration(labelText: l10n.emailLabel),
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  validator: (v) => validateEmail(l10n, v),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('signIn.password'),
                  controller: _password,
                  decoration: InputDecoration(labelText: l10n.passwordLabel),
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) => (v == null || v.isEmpty)
                      ? l10n.validationPasswordRequired
                      : null,
                ),
              ],
            ),
          ),
        ),
        if (error != null) AuthErrorText(authErrorMessage(l10n, error)),
        if (error == AuthError.emailNotVerified)
          TextButton(
            key: const Key('signIn.verify'),
            onPressed: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.verifyEmail, arguments: _email.text.trim()),
            child: Text(l10n.resendVerificationButton),
          ),
        AuthSubmitButton(
          key: const Key('signIn.submit'),
          label: l10n.signInButton,
          busy: _busy,
          onPressed: _submit,
        ),
        const SizedBox(height: 8),
        TextButton(
          key: const Key('signIn.forgotPassword'),
          onPressed: () => Navigator.of(
            context,
          ).pushNamed(AppRoutes.forgotPassword, arguments: _email.text.trim()),
          child: Text(l10n.forgotPasswordLink),
        ),
        TextButton(
          key: const Key('signIn.signUp'),
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.signUp),
          child: Text(l10n.noAccountLink),
        ),
      ],
    );
  }
}
