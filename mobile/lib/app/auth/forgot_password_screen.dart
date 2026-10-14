import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/providers.dart';
import '../../l10n/generated/app_localizations.dart';
import '../routes.dart';
import 'auth_widgets.dart';

/// UC-013 step 1: requests a reset link. The confirmation is the same for
/// every email address (DEC-004).
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail ?? '');
  bool _busy = false;
  bool _sent = false;
  AuthError? _error;

  @override
  void dispose() {
    _email.dispose();
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
          .requestPasswordReset(_email.text.trim());
      if (mounted) setState(() => _sent = true);
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
    if (_sent) {
      return AuthScaffold(
        title: l10n.forgotPasswordTitle,
        children: [
          Text(l10n.resetLinkSent, key: const Key('forgotPassword.sent')),
          AuthSubmitButton(
            key: const Key('forgotPassword.backToSignIn'),
            label: l10n.backToSignIn,
            busy: false,
            onPressed: () => Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.signIn, _isStart),
          ),
        ],
      );
    }
    return AuthScaffold(
      title: l10n.forgotPasswordTitle,
      children: [
        Text(l10n.forgotPasswordIntro),
        const SizedBox(height: 16),
        Form(
          key: _form,
          child: TextFormField(
            key: const Key('forgotPassword.email'),
            controller: _email,
            decoration: InputDecoration(labelText: l10n.emailLabel),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            onFieldSubmitted: (_) => _submit(),
            validator: (v) => validateEmail(l10n, v),
          ),
        ),
        if (error != null) AuthErrorText(authErrorMessage(l10n, error)),
        AuthSubmitButton(
          key: const Key('forgotPassword.submit'),
          label: l10n.sendResetLinkButton,
          busy: _busy,
          onPressed: _submit,
        ),
      ],
    );
  }
}

/// Keeps only the start screen below the pushed route.
bool _isStart(Route<Object?> route) => route.settings.name == AppRoutes.start;
