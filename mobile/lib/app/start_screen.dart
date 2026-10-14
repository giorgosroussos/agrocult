import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../l10n/generated/app_localizations.dart';
import 'routes.dart';

/// First screen of the app skeleton; replaced by the real home screen later.
/// Offers sign-in and sign-up, or sign-out when this device is signed in.
class StartScreen extends ConsumerWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final signedIn = ref.watch(authSessionProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.welcome,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            if (signedIn == true)
              OutlinedButton(
                key: const Key('start.signOut'),
                onPressed: () => _signOut(context, ref),
                child: Text(l10n.signOutButton),
              )
            else if (signedIn == false) ...[
              FilledButton(
                key: const Key('start.signIn'),
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.signIn),
                child: Text(l10n.signInButton),
              ),
              const SizedBox(height: 8),
              TextButton(
                key: const Key('start.signUp'),
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.signUp),
                child: Text(l10n.signUpTitle),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context).signedOut;
    await ref.read(authSessionProvider.notifier).signOut();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}
