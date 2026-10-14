import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import 'locale.dart';
import 'router.dart';
import 'theme.dart';

class AgrocultApp extends StatelessWidget {
  const AgrocultApp({super.key, this.locale});

  /// Forces a UI language; when null the device language decides.
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: locale,
      supportedLocales: supportedAppLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeListResolutionCallback: (deviceLocales, _) =>
          resolveAppLocale(deviceLocales),
      initialRoute: AppRouter.initialRoute,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
