import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/providers.dart';
import '../../l10n/generated/app_localizations.dart';
import '../routes.dart';
import 'auth_widgets.dart';

/// UC-012 step 2: asks the visitor to open the confirmation link. The text
/// is the same whether or not [email] already had an account (DEC-004), and
/// it offers sign-in and password reset for those who already do.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _busy = false;
  bool _resent = false;
  AuthError? _error;

  Future<void> _resend() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _resent = false;
    });
    try {
      await ref.read(authRepositoryProvider).resendVerification(widget.email);
      if (mounted) setState(() => _resent = true);
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
      title: l10n.verifyEmailTitle,
      children: [
        Text(
          l10n.verifyEmailBody(widget.email),
          key: const Key('verifyEmail.body'),
        ),
        const SizedBox(height: 16),
        Text(l10n.verifyEmailAlreadyRegistered),
        if (_resent)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              l10n.verificationResent,
              key: const Key('verifyEmail.resent'),
            ),
          ),
        if (error != null) AuthErrorText(authErrorMessage(l10n, error)),
        AuthSubmitButton(
          key: const Key('verifyEmail.signIn'),
          label: l10n.signInButton,
          busy: false,
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.signIn),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const Key('verifyEmail.resend'),
          onPressed: _busy ? null : _resend,
          child: Text(l10n.resendVerificationButton),
        ),
        TextButton(
          key: const Key('verifyEmail.forgotPassword'),
          onPressed: () => Navigator.of(
            context,
          ).pushNamed(AppRoutes.forgotPassword, arguments: widget.email),
          child: Text(l10n.forgotPasswordLink),
        ),
      ],
    );
  }
}
