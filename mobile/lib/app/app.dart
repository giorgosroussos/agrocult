import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import 'locale.dart';
import 'router.dart';
import 'theme.dart';

class AgrocultApp extends StatelessWidget {
  const AgrocultApp({super.key, this.locale, this.features = const []});

  /// Forces a UI language; when null the device language decides.
  final Locale? locale;

  /// The features' screens, handed over by the composition root (main.dart).
  final List<FeatureRoutes> features;

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
      onGenerateRoute: (settings) =>
          AppRouter.onGenerateRoute(settings, features: features),
    );
  }
}
