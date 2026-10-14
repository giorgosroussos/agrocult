import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/providers.dart';
import '../../l10n/generated/app_localizations.dart';
import '../routes.dart';
import 'auth_widgets.dart';

/// UC-013 step 2: opened from the one-time link in the reset email
/// (`<reset url>?token=...&email=...`); sets a new password.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.token, this.email});

  final String? token;
  final String? email;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _repeat = TextEditingController();
  bool _busy = false;
  AuthError? _error;

  bool get _linkComplete =>
      (widget.token?.isNotEmpty ?? false) &&
      (widget.email?.isNotEmpty ?? false);

  @override
  void dispose() {
    _password.dispose();
    _repeat.dispose();
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
          .read(authRepositoryProvider)
          .resetPassword(
            token: widget.token!,
            email: widget.email!,
            password: _password.text,
          );
      // Every token of the account was revoked, this device's included.
      await ref.read(authSessionProvider.notifier).refresh();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      await Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.signIn,
        (route) => route.settings.name == AppRoutes.start,
        arguments: l10n.passwordChanged,
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = _linkComplete ? _error : AuthError.invalidResetLink;
    return AuthScaffold(
      title: l10n.resetPasswordTitle,
      children: [
        if (_linkComplete)
          Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const Key('resetPassword.password'),
                  controller: _password,
                  decoration: InputDecoration(
                    labelText: l10n.newPasswordLabel,
                    helperText: l10n.passwordHint,
                  ),
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.next,
                  validator: (v) => validateNewPassword(l10n, v),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('resetPassword.repeat'),
                  controller: _repeat,
                  decoration: InputDecoration(
                    labelText: l10n.repeatPasswordLabel,
                  ),
                  obscureText: true,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) => v == _password.text
                      ? null
                      : l10n.validationPasswordsDiffer,
                ),
              ],
            ),
          ),
        if (error != null) AuthErrorText(authErrorMessage(l10n, error)),
        if (error == AuthError.invalidResetLink)
          AuthSubmitButton(
            key: const Key('resetPassword.requestNew'),
            label: l10n.requestNewResetLink,
            busy: false,
            onPressed: () => Navigator.of(context).pushReplacementNamed(
              AppRoutes.forgotPassword,
              arguments: widget.email,
            ),
          )
        else
          AuthSubmitButton(
            key: const Key('resetPassword.submit'),
            label: l10n.resetPasswordButton,
            busy: _busy,
            onPressed: _submit,
          ),
      ],
    );
  }
}
