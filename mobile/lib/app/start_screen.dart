import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

/// First screen of the app skeleton; replaced by the real home screen later.
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
        child: Text(
          l10n.welcome,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
